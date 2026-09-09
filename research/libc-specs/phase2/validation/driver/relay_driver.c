/* Deterministic IO adapter for frozen relay.c; see phase2 CONTRACT.md.
 * Macro substitution or ld --wrap redirects only relay's read/write calls.
 * After loading stdin, isolate fd 0/1 so unintended libc calls fail.
 */
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <signal.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#ifndef RELAY_MAX_ACTION
#define RELAY_MAX_ACTION 1048576UL
#endif
#ifndef RELAY_MAX_SCHEDULE
#define RELAY_MAX_SCHEDULE 4096UL
#endif
#ifndef RELAY_MAX_INPUT
#define RELAY_MAX_INPUT (16UL << 20)
#endif
#ifndef RELAY_MAX_OUTPUT
#define RELAY_MAX_OUTPUT (64UL << 20)
#endif
#define STATUS_ABORT 3
#define STATUS_USAGE 64

int relay(void);

#if defined(RELAY_WRAP)
ssize_t __real_read(int fd, void *buf, size_t count);
ssize_t __real_write(int fd, const void *buf, size_t count);
#define REAL_READ __real_read
#define REAL_WRITE __real_write
#define SHIM_READ __wrap_read
#define SHIM_WRITE __wrap_write
#elif defined(RELAY_SHIM_MACRO)
#define REAL_READ read
#define REAL_WRITE write
#define SHIM_READ shim_read
#define SHIM_WRITE shim_write
#else
#error "compile with -DRELAY_SHIM_MACRO or -DRELAY_WRAP"
#endif

struct schedule {
    long *v;
    size_t n;
    size_t next;
};

static struct schedule g_reads;
static struct schedule g_writes;
static unsigned char *g_input;
static size_t g_input_len;
static size_t g_input_pos;
static unsigned char *g_output;
static size_t g_output_len;
static size_t g_output_cap;
static unsigned long g_read_calls;
static unsigned long g_write_calls;
static unsigned long g_max_calls = 1000000UL;
static unsigned long g_timeout_seconds = 20UL;
static int g_fd_isolation = 1;
static int g_saved_stdout = -1;

static int real_write_all(int fd, const unsigned char *p, size_t len) {
    while (len > 0) {
        ssize_t w = REAL_WRITE(fd, p, len);
        if (w < 0) {
            if (errno == EINTR) continue;
            return -1;
        }
        if (w == 0) return -1;
        p += (size_t)w;
        len -= (size_t)w;
    }
    return 0;
}

static void err_str(const char *s) {
    (void)real_write_all(2, (const unsigned char *)s, strlen(s));
}

static void emit_diagnostics(void) {
    char line[160];
    int k = snprintf(line, sizeof line, "consumed=%zu\nread_calls=%lu\nwrite_calls=%lu\n",
                     g_input_pos, g_read_calls, g_write_calls);
    if (k > 0) (void)real_write_all(2, (const unsigned char *)line, (size_t)k);
}

static void deliver_output(void) {
    int fd = g_saved_stdout >= 0 ? g_saved_stdout : 1;
    if (real_write_all(fd, g_output, g_output_len) != 0) {
        err_str("relay_driver: failed to deliver output to stdout\n");
        emit_diagnostics();
        err_str("aborted=delivery\n");
        _exit(STATUS_ABORT);
    }
}

static void safety_abort(const char *why) {
    /* Reachable only by relays that do not terminate under the finite schedule. */
    deliver_output();
    emit_diagnostics();
    err_str("aborted=");
    err_str(why);
    err_str("\n");
    _exit(STATUS_ABORT);
}

static void on_alarm(int sig) {
    (void)sig;
    /* Fixed diagnostic: snprintf is not async-signal-safe. */
    static const char msg[] = "aborted=alarm\n";
    (void)REAL_WRITE(2, msg, sizeof msg - 1);
    _exit(STATUS_ABORT);
}

static void usage_fail(const char *msg, const char *detail) {
    err_str("relay_driver: ");
    err_str(msg);
    if (detail) {
        err_str(": ");
        err_str(detail);
    }
    err_str("\n");
    _exit(STATUS_USAGE);
}

/* Strict ASCII schedule grammar; reject invalid values before accumulation can overflow. */
static void parse_schedule(const char *text, const char *kind, int allow_zero, struct schedule *out) {
    size_t cap = 16;
    out->v = malloc(cap * sizeof *out->v);
    out->n = 0;
    out->next = 0;
    if (!out->v) usage_fail("out of memory", NULL);
    if (*text == '\0') return;
    const char *p = text;
    for (;;) {
        int neg = 0;
        unsigned long acc = 0;
        size_t digits = 0;
        if (*p == '-') {
            neg = 1;
            p++;
        }
        if (*p < '0' || *p > '9') usage_fail("invalid schedule item (expected digit)", kind);
        if (*p == '0' && p[1] >= '0' && p[1] <= '9') usage_fail("leading zeros are not allowed", kind);
        while (*p >= '0' && *p <= '9') {
            acc = acc * 10UL + (unsigned long)(*p - '0');
            digits++;
            if (acc > RELAY_MAX_ACTION) usage_fail("schedule value exceeds cap", kind);
            p++;
        }
        (void)digits;
        long value = neg ? -(long)acc : (long)acc;
        if (neg && acc != 1UL) usage_fail("negative value other than -1", kind);
        if (value == 0 && !allow_zero) usage_fail("value 0 is not a valid read action", kind);
        if (out->n >= RELAY_MAX_SCHEDULE) usage_fail("too many schedule entries", kind);
        if (out->n == cap) {
            cap *= 2;
            long *nv = realloc(out->v, cap * sizeof *nv);
            if (!nv) usage_fail("out of memory", NULL);
            out->v = nv;
        }
        out->v[out->n++] = value;
        if (*p == '\0') return;
        if (*p != ',') usage_fail("unexpected character in schedule", kind);
        p++;
        if (*p == '\0') usage_fail("trailing comma", kind);
    }
}

static unsigned long parse_ulong_strict(const char *text, const char *what, unsigned long max) {
    if (*text == '\0') usage_fail("empty numeric option", what);
    unsigned long acc = 0;
    if (*text == '0' && text[1] != '\0') usage_fail("leading zeros are not allowed", what);
    for (const char *p = text; *p; p++) {
        if (*p < '0' || *p > '9') usage_fail("invalid numeric option", what);
        acc = acc * 10UL + (unsigned long)(*p - '0');
        if (acc > max) usage_fail("numeric option exceeds cap", what);
    }
    return acc;
}

static long take_action(struct schedule *s, int have, long dflt) {
    (void)have;
    if (s->next < s->n) return s->v[s->next++];
    s->next++; /* Count calls after schedule exhaustion too. */
    return dflt;
}

static void check_call_cap(void) {
    if (g_read_calls + g_write_calls > g_max_calls) safety_abort("max_calls");
}

ssize_t SHIM_READ(int fd, void *buf, size_t count) {
    g_read_calls++;
    check_call_cap();
    if (fd != 0) safety_abort("read_on_unexpected_fd");
    if (count > (size_t)LONG_MAX) safety_abort("read_request_too_large");
    long a = take_action(&g_reads, 1, (long)count);
    if (a == -1) {
        errno = EIO;
        return -1;
    }
    size_t q = (size_t)a;
    size_t remaining = g_input_len - g_input_pos;
    if (q > count) q = count;
    if (q > remaining) q = remaining;
    if (q > 0) memcpy(buf, g_input + g_input_pos, q);
    g_input_pos += q;
    return (ssize_t)q;
}

ssize_t SHIM_WRITE(int fd, const void *buf, size_t count) {
    g_write_calls++;
    check_call_cap();
    if (fd != 1) safety_abort("write_on_unexpected_fd");
    if (count > (size_t)LONG_MAX) safety_abort("write_request_too_large");
    long a = take_action(&g_writes, 1, (long)count);
    if (a == -1) {
        errno = EIO;
        return -1;
    }
    if (a == 0) return 0;
    size_t q = (size_t)a;
    if (q > count) q = count;
    if (g_output_len + q > RELAY_MAX_OUTPUT) safety_abort("output_cap");
    if (g_output_len + q > g_output_cap) {
        size_t nc = g_output_cap ? g_output_cap : 4096;
        while (nc < g_output_len + q) nc *= 2;
        unsigned char *no = realloc(g_output, nc);
        if (!no) safety_abort("out_of_memory");
        g_output = no;
        g_output_cap = nc;
    }
    if (q > 0) memcpy(g_output + g_output_len, buf, q);
    g_output_len += q;
    return (ssize_t)q;
}

static void slurp_stdin(void) {
    size_t cap = RELAY_MAX_INPUT < 65536 ? RELAY_MAX_INPUT : 65536;
    g_input = malloc(cap);
    if (!g_input) usage_fail("out of memory", NULL);
    for (;;) {
        if (g_input_len == cap) {
            if (cap >= RELAY_MAX_INPUT) {
                unsigned char extra;
                ssize_t r = REAL_READ(0, &extra, 1);
                if (r < 0 && errno == EINTR) continue;
                if (r < 0) usage_fail("failed to read stdin", strerror(errno));
                if (r == 0) break;
                usage_fail("stdin exceeds input cap", NULL);
            }
            cap *= 2;
            if (cap > RELAY_MAX_INPUT) cap = RELAY_MAX_INPUT;
            unsigned char *ni = realloc(g_input, cap);
            if (!ni) usage_fail("out of memory", NULL);
            g_input = ni;
        }
        ssize_t r = REAL_READ(0, g_input + g_input_len, cap - g_input_len);
        if (r < 0) {
            if (errno == EINTR) continue;
            usage_fail("failed to read stdin", strerror(errno));
        }
        if (r == 0) break;
        g_input_len += (size_t)r;
        if (g_input_len > RELAY_MAX_INPUT) usage_fail("stdin exceeds input cap", NULL);
    }
}

static void print_help(void) {
    const char *h =
        "usage: relay_driver [--reads S] [--writes S] [--max-calls N] [--timeout-seconds N]\n"
        "                    [--no-fd-isolation]\n"
        "  S is a comma-separated list: -1 (error), positive quota; writes may also use 0.\n"
        "  Caps: value <= 1048576, <= 4096 entries, stdin <= 16 MiB.\n";
    err_str(h);
}

int main(int argc, char **argv) {
    const char *reads_text = "";
    const char *writes_text = "";
    int seen_reads = 0, seen_writes = 0;
    for (int i = 1; i < argc; i++) {
        const char *a = argv[i];
        const char *val = NULL;
        const char *name = a;
        char namebuf[64];
        const char *eq = strchr(a, '=');
        if (eq && strncmp(a, "--", 2) == 0) {
            size_t nl = (size_t)(eq - a);
            if (nl >= sizeof namebuf) usage_fail("unknown option", a);
            memcpy(namebuf, a, nl);
            namebuf[nl] = '\0';
            name = namebuf;
            val = eq + 1;
        }
#define NEED_VAL()                                                         \
    do {                                                                   \
        if (!val) {                                                        \
            if (i + 1 >= argc) usage_fail("option requires a value", name); \
            val = argv[++i];                                               \
        }                                                                  \
    } while (0)
        if (strcmp(name, "--reads") == 0) {
            NEED_VAL();
            if (seen_reads) usage_fail("duplicate option", name);
            seen_reads = 1;
            reads_text = val;
        } else if (strcmp(name, "--writes") == 0) {
            NEED_VAL();
            if (seen_writes) usage_fail("duplicate option", name);
            seen_writes = 1;
            writes_text = val;
        } else if (strcmp(name, "--max-calls") == 0) {
            NEED_VAL();
            g_max_calls = parse_ulong_strict(val, name, 1000000000UL);
        } else if (strcmp(name, "--timeout-seconds") == 0) {
            NEED_VAL();
            g_timeout_seconds = parse_ulong_strict(val, name, 3600UL);
        } else if (strcmp(name, "--no-fd-isolation") == 0) {
            if (val) usage_fail("option takes no value", name);
            g_fd_isolation = 0;
        } else if (strcmp(name, "--help") == 0 || strcmp(name, "-h") == 0) {
            print_help();
            return 0;
        } else {
            usage_fail("unknown option", a);
        }
#undef NEED_VAL
    }

    parse_schedule(reads_text, "--reads", 0, &g_reads);
    parse_schedule(writes_text, "--writes", 1, &g_writes);

    slurp_stdin();

    if (g_fd_isolation) {
        /* Any genuine read(0)/write(1) from relay() must now fail. */
        g_saved_stdout = dup(1);
        if (g_saved_stdout < 0) usage_fail("dup(1) failed", strerror(errno));
        if (close(0) != 0) usage_fail("close(0) failed", strerror(errno));
        int full = open("/dev/full", O_WRONLY | O_CLOEXEC);
        if (full >= 0) {
            if (dup2(full, 1) < 0) usage_fail("dup2 failed", strerror(errno));
            if (full != 1) close(full);
        } else {
            close(1);
        }
    }

    if (g_timeout_seconds > 0) {
        struct sigaction sa;
        memset(&sa, 0, sizeof sa);
        sa.sa_handler = on_alarm;
        sigaction(SIGALRM, &sa, NULL);
        alarm((unsigned)g_timeout_seconds);
    }

    int status = relay();

    alarm(0);
    deliver_output();
    emit_diagnostics();
    return status;
}
