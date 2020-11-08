#!/bin/bash
# Generates setup-wakeup.sh for installing on opsi server via bash setup-wakeup.sh
cat pre.conf > setup-wakeup.sh
cat wakeup.py >> setup-wakeup.sh
cat post.conf >> setup-wakeup.sh

