#!/bin/bash
# Generates setup-wakeup.sh for installing on opsi server via bash setup-wakeup.sh
cat shutdown-pre.conf > setup-shutdown.sh
cat shutdown.py >> setup-shutdown.sh
cat shutdown-post.conf >> setup-shutdown.sh

