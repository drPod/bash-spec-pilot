/* Pointer-event probe for frozen relay.c; see TRACE_SCHEMA.md and phase2 PROTOCOL.md.
 * Macro substitution or ld --wrap redirects only relay's read/write calls.
 * Transfers are clamped to the array bounds so out-of-range mutants can be measured.
 * Snapshots must be taken inside probe calls while relay's automatic array is alive.
 */
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <signal.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#ifndef PROBE_CAPACITY
#define PROBE_CAPACITY 32UL /* unsigned char buf[32] in the frozen relay.c */
#endif
#ifndef PROBE_MAX_ACTION
#define PROBE_MAX_ACTION 1048576UL
#endif
#ifndef PROBE_MAX_SCHEDULE
#define PROBE_MAX_SCHEDULE 4096UL
#endif
#ifndef PROBE_MAX_INPUT
#define PROBE_MAX_INPUT (16UL << 20) /* inclusive acceptance cap on stdin */
#endif
#define STATUS_ABORT 3
#define STATUS_USAGE 64

/* Fixed line buffers hold two hex-encoded windows of at most PROBE_CAPACITY bytes each
   plus a few hundred bytes of text; keep the capacity small enough for that to be true. */
#if PROBE_CAPACITY > 256
#error "PROBE_CAPACITY above 256 would overflow the fixed trace line buffers"
#endif
#if PROBE_CAPACITY < 1
#error "PROBE_CAPACITY must be positive"
#endif

int relay(void);

#if defined(PROBE_WRAP)
ssize_t __real_read(int fd, void *buf, size_t count);
ssize_t __real_write(int fd, const void *buf, size_t count);
#define REAL_READ __real_read
#define REAL_WRITE __real_write
#define PROBE_READ __wrap_read
#define PROBE_WRITE __wrap_write
#elif defined(PROBE_MACRO)
#define REAL_READ read
#define REAL_WRITE write
#define PROBE_READ probe_read
#define PROBE_WRITE probe_write
#else
#error "compile with -DPROBE_MACRO or -DPROBE_WRAP"
#endif

ssize_t PROBE_READ(int fd, void *buf, size_t count);
ssize_t PROBE_WRITE(int fd, const void *buf, size_t count);

struct schedule {
    long long *v;
    size_t n;
    size_t next;
};

static struct schedule g_reads;
static struct schedule g_writes;
static unsigned char *g_input;
static size_t g_input_len;
static size_t g_input_pos;
static unsigned long g_read_calls;
static unsigned long g_write_calls;
static unsigned long g_max_calls = 100000UL;
static unsigned long g_timeout_seconds = 2UL;
static int g_fd_isolation = 1;
static int g_saved_stdout = -1;
static int g_trace_fd = -1;
static const char *g_trace_path = NULL;
static unsigned char *g_base;   /* pointer passed to the first read call; VALID ONLY WHILE
                                   relay() is on the stack (buf is relay's automatic array) */
static int g_base_known;
static size_t g_chunk;          /* valid chunk length n (offset+result of last non-negative read) */
static size_t g_defined;        /* defined prefix: bytes of the array ever stored by a read */
static unsigned char g_shadow[PROBE_CAPACITY]; /* copy of the defined prefix taken inside each
                                   probe call; the only memory image used after relay() returns */
static unsigned long g_seq;

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
    if (k > 0 && (size_t)k < sizeof line) (void)real_write_all(2, (const unsigned char *)line, (size_t)k);
}

/* Unrecoverable harness failure: no further trace output is attempted. */
static void fatal(const char *why) {
    emit_diagnostics();
    err_str("aborted=");
    err_str(why);
    err_str("\n");
    _exit(STATUS_ABORT);
}

static void trace_write(const char *s, size_t len) {
    if (g_trace_fd < 0) return;
    if (real_write_all(g_trace_fd, (const unsigned char *)s, len) != 0) fatal("trace_write");
}

/* Reachable only by relays that do not follow the finite schedule (call cap) or by
   harness-level failures. The trace records the reason before exit. */
static void safety_abort(const char *why) {
    char line[256];
    int k = snprintf(line, sizeof line,
                     "{\"kind\":\"abort\",\"reason\":\"%s\",\"seq\":%lu,\"read_calls\":%lu,\"write_calls\":%lu}\n",
                     why, g_seq, g_read_calls, g_write_calls);
    if (k > 0 && (size_t)k < sizeof line) trace_write(line, (size_t)k);
    fatal(why);
}

static void on_alarm(int sig) {
    (void)sig;
    /* Fixed diagnostic: snprintf is not async-signal-safe. */
    static const char msg[] = "aborted=alarm\n";
    (void)REAL_WRITE(2, msg, sizeof msg - 1);
    _exit(STATUS_ABORT);
}

static void usage_fail(const char *msg, const char *detail) {
    err_str("pointer_probe: ");
    err_str(msg);
    if (detail) {
        err_str(": ");
        err_str(detail);
    }
    err_str("\n");
    _exit(STATUS_USAGE);
}

static size_t hex_append(char *dst, size_t cap, size_t len, const unsigned char *p, size_t n) {
    static const char digits[] = "0123456789abcdef";
    size_t i;
    if (n > (cap - len) / 2 || len + 2 * n + 1 > cap) fatal("trace_line_overflow");
    for (i = 0; i < n; i++) {
        dst[len++] = digits[p[i] >> 4];
        dst[len++] = digits[p[i] & 0x0f];
    }
    dst[len] = '\0';
    return len;
}

/* Copy the defined prefix of relay's live array into g_shadow. Called only from inside a
   probe call, while relay() (and therefore buf) is alive. Every byte in [0, g_defined) was
   stored by this probe, so nothing indeterminate is read. */
static void refresh_shadow(void) {
    if (!g_base_known) return;
    if (g_defined > PROBE_CAPACITY) fatal("defined_prefix_exceeds_capacity");
    if (g_defined > 0) memcpy(g_shadow, g_base, g_defined);
}

static void emit_event(const char *kind, int fd, long long offset, size_t request, long long action,
                       const char *source, long long result, const unsigned char *bytes, size_t nbytes,
                       size_t init_before, size_t init_after, size_t defined_before, size_t defined_after,
                       int in_bounds, int clamped) {
    char line[2048];
    size_t len;
    int k;
    refresh_shadow();
    if (g_trace_fd < 0) {
        g_seq++;
        return;
    }
    if (nbytes > PROBE_CAPACITY || defined_after > PROBE_CAPACITY) fatal("trace_window_exceeds_capacity");
    k = snprintf(line, sizeof line,
                 "{\"seq\":%lu,\"kind\":\"%s\",\"fd\":%d,\"block\":0,\"offset\":%lld,\"request\":%zu,"
                 "\"action\":%lld,\"action_source\":\"%s\",\"result\":%lld,\"bytes_hex\":\"",
                 g_seq, kind, fd, offset, request, action, source, result);
    if (k < 0 || (size_t)k >= sizeof line) fatal("trace_line_overflow");
    len = (size_t)k;
    len = hex_append(line, sizeof line, len, bytes, nbytes);
    k = snprintf(line + len, sizeof line - len,
                 "\",\"init_before\":%zu,\"init_after\":%zu,\"defined_before\":%zu,\"defined_after\":%zu,"
                 "\"memory_hex\":\"",
                 init_before, init_after, defined_before, defined_after);
    if (k < 0 || (size_t)k >= sizeof line - len) fatal("trace_line_overflow");
    len += (size_t)k;
    len = hex_append(line, sizeof line, len, g_shadow, g_base_known ? defined_after : 0);
    k = snprintf(line + len, sizeof line - len,
                 "\",\"probe\":{\"base_known\":%s,\"in_bounds\":%s,\"clamped\":%s}}\n",
                 g_base_known ? "true" : "false", in_bounds ? "true" : "false", clamped ? "true" : "false");
    if (k < 0 || (size_t)k >= sizeof line - len) fatal("trace_line_overflow");
    len += (size_t)k;
    trace_write(line, len);
    g_seq++;
}

/* Called AFTER relay() returned: buf no longer exists, so g_base must not be dereferenced.
   The memory image comes from g_shadow, last refreshed inside the final probe call. */
static void emit_exit(int status) {
    char line[1024];
    size_t len;
    int k;
    if (g_trace_fd < 0) return;
    if (g_defined > PROBE_CAPACITY) fatal("defined_prefix_exceeds_capacity");
    k = snprintf(line, sizeof line,
                 "{\"kind\":\"exit\",\"status\":%d,\"consumed\":%zu,\"read_calls\":%lu,\"write_calls\":%lu,"
                 "\"base_known\":%s,\"chunk\":%zu,\"defined\":%zu,\"memory_hex\":\"",
                 status, g_input_pos, g_read_calls, g_write_calls, g_base_known ? "true" : "false",
                 g_chunk, g_defined);
    if (k < 0 || (size_t)k >= sizeof line) fatal("trace_line_overflow");
    len = (size_t)k;
    len = hex_append(line, sizeof line, len, g_shadow, g_base_known ? g_defined : 0);
    k = snprintf(line + len, sizeof line - len, "\"}\n");
    if (k < 0 || (size_t)k >= sizeof line - len) fatal("trace_line_overflow");
    len += (size_t)k;
    trace_write(line, len);
}

/* Strict ASCII schedule grammar; reject invalid values before accumulation can overflow. */
static void parse_schedule(const char *text, const char *kind, int allow_zero, struct schedule *out) {
    size_t cap = 16;
    const char *p = text;
    out->v = malloc(cap * sizeof *out->v);
    out->n = 0;
    out->next = 0;
    if (!out->v) usage_fail("out of memory", NULL);
    if (*text == '\0') return;
    for (;;) {
        int neg = 0;
        unsigned long acc = 0;
        long long value;
        if (*p == '-') {
            neg = 1;
            p++;
        }
        if (*p < '0' || *p > '9') usage_fail("invalid schedule item (expected digit)", kind);
        if (*p == '0' && p[1] >= '0' && p[1] <= '9') usage_fail("leading zeros are not allowed", kind);
        while (*p >= '0' && *p <= '9') {
            acc = acc * 10UL + (unsigned long)(*p - '0');
            if (acc > PROBE_MAX_ACTION) usage_fail("schedule value exceeds cap", kind);
            p++;
        }
        if (neg && acc != 1UL) usage_fail("negative value other than -1", kind);
        value = neg ? -1LL : (long long)acc;
        if (value == 0 && !allow_zero) usage_fail("value 0 is not a valid read action", kind);
        if (out->n >= PROBE_MAX_SCHEDULE) usage_fail("too many schedule entries", kind);
        if (out->n == cap) {
            long long *nv;
            cap *= 2;
            nv = realloc(out->v, cap * sizeof *nv);
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
    unsigned long acc = 0;
    const char *p;
    if (*text == '\0') usage_fail("empty numeric option", what);
    if (*text == '0' && text[1] != '\0') usage_fail("leading zeros are not allowed", what);
    for (p = text; *p; p++) {
        if (*p < '0' || *p > '9') usage_fail("invalid numeric option", what);
        acc = acc * 10UL + (unsigned long)(*p - '0');
        if (acc > max) usage_fail("numeric option exceeds cap", what);
    }
    return acc;
}

static long long take_action(struct schedule *s, long long dflt, const char **source) {
    if (s->next < s->n) {
        *source = "schedule";
        return s->v[s->next++];
    }
    *source = "default";
    return dflt;
}

static void check_call_cap(void) {
    if (g_read_calls + g_write_calls > g_max_calls) safety_abort("max_calls");
}

static long long pointer_offset(const unsigned char *p) {
    return (long long)((uintptr_t)p - (uintptr_t)g_base);
}

ssize_t PROBE_READ(int fd, void *buf, size_t count) {
    unsigned char *p = (unsigned char *)buf;
    const char *source = "default";
    const unsigned char *bytes = NULL;
    long long action, result, offset;
    size_t avail = 0, q = 0;
    size_t init_before = g_chunk, defined_before = g_defined;
    int in_bounds, clamped = 0;

    g_read_calls++;
    check_call_cap();
    if (count > (size_t)LLONG_MAX) safety_abort("read_request_too_large");
    if (!g_base_known) {
        g_base = p;
        g_base_known = 1;
    }
    offset = pointer_offset(p);
    in_bounds = offset >= 0 && (unsigned long long)offset <= (unsigned long long)PROBE_CAPACITY;
    if (in_bounds) avail = PROBE_CAPACITY - (size_t)offset;
    action = take_action(&g_reads, (long long)count, &source);
    if (action == -1) {
        errno = EIO;
        result = -1;
    } else {
        size_t remaining = g_input_len - g_input_pos;
        q = (size_t)action;
        if (q > count) q = count;
        if (q > remaining) q = remaining;
        if (q > avail) {
            q = avail;
            clamped = 1;
        }
        if (q > 0) memcpy(p, g_input + g_input_pos, q);
        bytes = g_input + g_input_pos;
        g_input_pos += q;
        g_chunk = in_bounds ? (size_t)offset + q : 0;
        if (g_defined < g_chunk) g_defined = g_chunk;
        result = (long long)q;
    }
    emit_event("read", fd, offset, count, action, source, result, bytes, q,
               init_before, g_chunk, defined_before, g_defined, in_bounds, clamped);
    return (ssize_t)result;
}

ssize_t PROBE_WRITE(int fd, const void *buf, size_t count) {
    const unsigned char *p = (const unsigned char *)buf;
    const char *source = "default";
    const unsigned char *bytes = NULL;
    long long action, result, offset = 0;
    size_t avail = 0, q = 0;
    int in_bounds = 0, clamped = 0;

    g_write_calls++;
    check_call_cap();
    if (count > (size_t)LLONG_MAX) safety_abort("write_request_too_large");
    if (g_base_known) {
        offset = pointer_offset(p);
        in_bounds = offset >= 0 && (unsigned long long)offset <= (unsigned long long)PROBE_CAPACITY;
        if (in_bounds) avail = PROBE_CAPACITY - (size_t)offset;
    }
    action = take_action(&g_writes, (long long)count, &source);
    if (action == -1) {
        errno = EIO;
        result = -1;
    } else if (action == 0) {
        result = 0;
    } else {
        q = (size_t)action;
        if (q > count) q = count;
        if (q > avail) {
            q = avail;
            clamped = 1;
        }
        if (q > 0 && real_write_all(g_saved_stdout >= 0 ? g_saved_stdout : 1, p, q) != 0)
            fatal("deliver_output");
        bytes = p;
        result = (long long)q;
    }
    emit_event("write", fd, offset, count, action, source, result, bytes, q,
               g_chunk, g_chunk, g_defined, g_defined, in_bounds, clamped);
    return (ssize_t)result;
}

static void slurp_stdin(void) {
    size_t cap = PROBE_MAX_INPUT < 65536 ? PROBE_MAX_INPUT : 65536;
    g_input = malloc(cap);
    if (!g_input) usage_fail("out of memory", NULL);
    for (;;) {
        ssize_t r;
        if (g_input_len == cap) {
            unsigned char *ni;
            if (cap >= PROBE_MAX_INPUT) {
                unsigned char extra;
                r = REAL_READ(0, &extra, 1);
                if (r < 0 && errno == EINTR) continue;
                if (r < 0) usage_fail("failed to read stdin", strerror(errno));
                if (r == 0) break;
                usage_fail("stdin exceeds input cap", NULL);
            }
            cap *= 2;
            if (cap > PROBE_MAX_INPUT) cap = PROBE_MAX_INPUT;
            ni = realloc(g_input, cap);
            if (!ni) usage_fail("out of memory", NULL);
            g_input = ni;
        }
        r = REAL_READ(0, g_input + g_input_len, cap - g_input_len);
        if (r < 0) {
            if (errno == EINTR) continue;
            usage_fail("failed to read stdin", strerror(errno));
        }
        if (r == 0) break;
        g_input_len += (size_t)r;
        if (g_input_len > PROBE_MAX_INPUT) usage_fail("stdin exceeds input cap", NULL);
    }
}

static void print_help(void) {
    const char *h =
        "usage: pointer_probe [--reads S] [--writes S] [--trace PATH] [--max-calls N]\n"
        "                     [--timeout-seconds N] [--no-fd-isolation]\n"
        "  S is a comma-separated list: -1 (error), positive quota; writes may also use 0.\n"
        "  Caps: value <= 1048576, <= 4096 entries, stdin <= 16 MiB.\n"
        "  --trace PATH writes one JSON object per intercepted read/write call.\n";
    err_str(h);
}

int main(int argc, char **argv) {
    const char *reads_text = "";
    const char *writes_text = "";
    int seen_reads = 0, seen_writes = 0, seen_trace = 0;
    int status;
    int i;
    for (i = 1; i < argc; i++) {
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
#define NEED_VAL()                                                          \
    do {                                                                    \
        if (!val) {                                                         \
            if (i + 1 >= argc) usage_fail("option requires a value", name); \
            val = argv[++i];                                                \
        }                                                                   \
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
        } else if (strcmp(name, "--trace") == 0) {
            NEED_VAL();
            if (seen_trace) usage_fail("duplicate option", name);
            if (*val == '\0') usage_fail("empty trace path", name);
            seen_trace = 1;
            g_trace_path = val;
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

    if (g_trace_path) {
        g_trace_fd = open(g_trace_path, O_WRONLY | O_CREAT | O_TRUNC | O_NOFOLLOW | O_CLOEXEC, 0600);
        if (g_trace_fd < 0) usage_fail("cannot open trace file", strerror(errno));
        if (g_trace_fd < 3) usage_fail("trace file received a standard descriptor", NULL);
    }

    slurp_stdin();

    if (g_fd_isolation) {
        /* Any genuine read(0)/write(1) from relay() must now fail. Nothing ever READS
           /dev/full here; it is only a write sink that reports ENOSPC. */
        int full;
        g_saved_stdout = dup(1);
        if (g_saved_stdout < 0) usage_fail("dup(1) failed", strerror(errno));
        full = open("/dev/full", O_WRONLY | O_CLOEXEC);
        if (full >= 0) {
            if (dup2(full, 1) < 0) usage_fail("dup2 failed", strerror(errno));
            if (full != 1) close(full);
        } else {
            close(1);
        }
        if (close(0) != 0) usage_fail("close(0) failed", strerror(errno));
    }

    if (g_timeout_seconds > 0) {
        struct sigaction sa;
        memset(&sa, 0, sizeof sa);
        sa.sa_handler = on_alarm;
        sigaction(SIGALRM, &sa, NULL);
        alarm((unsigned)g_timeout_seconds);
    }

    status = relay();
    /* relay's automatic array is dead from here on; g_base is stale and never used again. */
    g_base = NULL;

    alarm(0);
    emit_exit(status);
    emit_diagnostics();
    return status;
}
