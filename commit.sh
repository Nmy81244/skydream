#!/bin/sh

# Get a concise list of changed files (e.g., "M script.gd, A README.md")
CHANGES=$(git status --short | tr '\n' ' ' | sed 's/  */ /g')

# If there are no changes, exit early
if [ -z "$CHANGES" ]; then
    echo "No changes detected to commit."
    exit 0
fi

# Build dynamic commit message with timestamp and modified files
MSG="Auto-update ($(date '+%Y-%m-%d %H:%M')): $CHANGES"

git add . && \
git commit -m "$MSG" && \
git push
