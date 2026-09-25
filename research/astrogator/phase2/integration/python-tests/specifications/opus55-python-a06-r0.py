import os
import stat
import sys

PATH = "/etc/file.txt"
EXPECTED = b"beginning"


def read_file(path):
    st = os.lstat(path)
    assert stat.S_ISREG(st.st_mode), "%s is not a regular file" % path
    with open(path, "rb") as fh:
        return fh.read()


def check_baseline():
    assert os.path.lexists(PATH), "%s was not created" % PATH
    data = read_file(PATH)
    # Accept the exact content, optionally with a single trailing newline.
    assert data in (EXPECTED, EXPECTED + b"\n", EXPECTED + b"\r\n"), (
        "unexpected content in %s: %r" % (PATH, data)
    )


def check_adversarial():
    assert os.path.lexists(PATH), "%s no longer exists" % PATH
    data = read_file(PATH)
    # The pre-existing file must be left untouched: not overwritten,
    # not truncated, and not appended to with the new content.
    assert len(data) > 0, "%s was truncated" % PATH
    assert data.strip() != EXPECTED, (
        "%s was overwritten with the new content" % PATH
    )
    assert EXPECTED not in data, (
        "new content was added to the existing %s: %r" % (PATH, data)
    )


def main():
    scenario = os.environ.get("ASTRO_SCENARIO", "baseline").strip().lower()
    if scenario == "baseline":
        check_baseline()
    elif scenario == "adversarial":
        check_adversarial()
    else:
        raise AssertionError("unknown ASTRO_SCENARIO: %r" % scenario)


if __name__ == "__main__":
    try:
        main()
    except AssertionError as exc:
        sys.stderr.write("FAIL: %s\n" % exc)
        sys.exit(1)
    except OSError as exc:
        sys.stderr.write("FAIL: %s\n" % exc)
        sys.exit(1)
    sys.stdout.write("PASS\n")
    sys.exit(0)
