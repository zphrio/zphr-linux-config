#!/bin/bash
# Source this file from bootstrap, sync, or an interactive shell.

STOW_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_PACKAGES=(
    adhan bash btop fuzzel gtklock ideavim kanshi kitty mimeapps
    nvim swappy sway systemd tmux vim waybar yazi
)

is_stow_package() {
    local package
    for package in "${STOW_PACKAGES[@]}"; do
        if [[ "$1" == "$package" ]]; then
            return 0
        fi
    done
    return 1
}

stow_package() {
    local package="${1:?Usage: stow_package <package> [options]}"
    shift
    if ! is_stow_package "$package"; then
        echo "Not a Stow package: $package" >&2
        return 1
    fi

    local options=()
    case "$package" in
        btop|kitty|systemd) options+=(--no-folding) ;;
    esac
    stow --dir="$STOW_REPO_DIR" --target="$HOME" "${options[@]}" "$@" "$package"
}
