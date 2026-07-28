#!/usr/bin/env python3
"""
linux/log_rotation.py

Sample log rotation utility for applications that don't use logrotate
directly - compresses logs older than a threshold and deletes archives
past a retention period.

Usage:
    python log_rotation.py /var/log/myapp --compress-days 1 --delete-days 30
"""

import argparse
import gzip
import os
import shutil
import time


def rotate_logs(log_dir, compress_after_days, delete_after_days):
    now = time.time()
    compressed = 0
    deleted = 0

    for filename in os.listdir(log_dir):
        filepath = os.path.join(log_dir, filename)
        if not os.path.isfile(filepath):
            continue

        age_days = (now - os.path.getmtime(filepath)) / 86400

        if filename.endswith(".gz"):
            if age_days > delete_after_days:
                os.remove(filepath)
                deleted += 1
            continue

        if age_days > compress_after_days:
            with open(filepath, "rb") as f_in, gzip.open(f"{filepath}.gz", "wb") as f_out:
                shutil.copyfileobj(f_in, f_out)
            os.remove(filepath)
            compressed += 1

    return compressed, deleted


def main():
    parser = argparse.ArgumentParser(description="Rotate and clean up application log files")
    parser.add_argument("log_dir", help="Directory containing log files")
    parser.add_argument("--compress-days", type=int, default=1)
    parser.add_argument("--delete-days", type=int, default=30)
    args = parser.parse_args()

    compressed, deleted = rotate_logs(args.log_dir, args.compress_days, args.delete_days)
    print(f"Compressed {compressed} log file(s), deleted {deleted} old archive(s).")


if __name__ == "__main__":
    main()

