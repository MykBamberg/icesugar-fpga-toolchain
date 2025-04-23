#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

sudo install -Dm0644 60-icesugar.rules -t /etc/udev/rules.d/
sudo udevadm control --reload
