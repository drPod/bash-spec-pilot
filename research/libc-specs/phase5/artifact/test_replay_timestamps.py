#!/usr/bin/env python3
"""Focused mock-clock check: started_utc is the start instant, finished_utc is later.

Does not run the manifest, compilers, or network. Importing replay.py hashes the script
only; it does not execute entries.
"""
import datetime
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from replay import run_id_from, summary_time_fields, utc_stamp  # noqa: E402


class MockClock:
    def __init__(self, start):
        self._now = start

    def advance(self, seconds):
        self._now = self._now + datetime.timedelta(seconds=seconds)
        return self._now

    def now(self):
        return self._now


def main():
    start = datetime.datetime(2026, 9, 8, 10, 40, 47, tzinfo=datetime.timezone.utc)
    clock = MockClock(start)
    started = clock.now()
    clock.advance(11 * 60 + 29)  # 10:40:47 -> 10:52:16, matching full19 wall
    finished = clock.now()
    fields = summary_time_fields(started, finished)
    assert fields['run_id'] == '20260908T104047Z', fields
    assert fields['started_utc'] == '2026-09-08T10:40:47+00:00', fields
    assert fields['finished_utc'] == '2026-09-08T10:52:16+00:00', fields
    assert fields['started_utc'] != fields['finished_utc']
    assert run_id_from(started) == fields['run_id']
    assert utc_stamp(started) == fields['started_utc']
    naive = datetime.datetime(2026, 9, 8, 10, 40, 47)
    assert run_id_from(naive) == '20260908T104047Z'
    print('ok', fields)


if __name__ == '__main__':
    main()
