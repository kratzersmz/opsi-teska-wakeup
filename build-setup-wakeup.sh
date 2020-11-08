#!/bin/bash
# Generates setup-wakeup.sh for installing on opsi server via bash setup-wakeup.sh
cat wakeup-pre.conf > setup-wakeup.sh
cat wakeup.py >> setup-wakeup.sh
cat wakeup-post.conf >> setup-wakeup.sh

