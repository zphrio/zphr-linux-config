#!/bin/bash
set -euo pipefail

REPO="$HOME/zphr-linux-config"
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
    exit 0
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
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

# Load the updated package list after pulling. Agent metadata is never stowed.
# shellcheck source=scripts/stow-packages.sh
source "$REPO/scripts/stow-packages.sh"

# Restow changed packages, including deletions and both sides of renames.
while IFS= read -r pkg; do
    if is_stow_package "$pkg" && [ -d "$pkg" ] && ! stow_package "$pkg" --restow; then
        notify-send -u critical "Dotfiles sync" "stow --restow $pkg failed"
    fi
done < <(git diff --no-renames --name-only "$LOCAL" HEAD | cut -d/ -f1 | sort -u)
