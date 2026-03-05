#!/bin/bash
set -euo pipefail

REPO="$HOME/zphr-linux-config"
DIRTY=false
STASHED=false

cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        git -C "$REPO" rebase --abort 2>/dev/null || true
        $STASHED && git -C "$REPO" stash pop 2>/dev/null || true
        notify-send -u critical "Dotfiles sync failed" \
            "Check ~/zphr-linux-config manually"
    fi
}
trap cleanup EXIT

cd "$REPO"

git fetch origin main

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)
if [ "$LOCAL" = "$REMOTE" ]; then
    notify-send "Dotfiles sync" "Already up to date"
    exit 0
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
    DIRTY=true
    git stash push -m "dotfiles-sync auto-stash"
    STASHED=true
fi

git rebase origin/main

if $STASHED; then
    STASHED=false  # prevent cleanup from double-popping
    if ! git stash pop; then
        notify-send -u critical "Dotfiles sync" "Stash pop conflict — resolve manually"
        exit 1
    fi
fi

# Restow only packages that got new files
NEW_FILES=$(git diff --diff-filter=A --name-only "$LOCAL" HEAD)
STOW_FAILED=false
if [ -n "$NEW_FILES" ]; then
    for pkg in $(echo "$NEW_FILES" | cut -d/ -f1 | sort -u); do
        if [ -d "$pkg" ] && ! stow --restow "$pkg"; then
            STOW_FAILED=true
            notify-send -u critical "Dotfiles sync" "stow --restow $pkg failed"
        fi
    done
fi

COUNT=$(git diff --name-only "$LOCAL" HEAD | wc -l)
if ! $STOW_FAILED; then
    notify-send "Dotfiles synced" "$COUNT file(s) updated"
fi
