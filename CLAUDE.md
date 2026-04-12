# zphr-linux-config

Dotfiles repo managed with GNU Stow on Debian + sway.

## Structure

Each top-level directory is a stow package (e.g., `kitty/`, `nvim/`, `sway/`). Files inside mirror `$HOME` paths — stow symlinks them into place.

**Packages requiring `--no-folding`:** Some apps auto-generate files in their config directory. Without `--no-folding`, stow symlinks the whole directory and those files end up written into the repo.

- `stow --no-folding btop` — btop auto-generates `btop.log` and a `themes/` directory
- `stow --no-folding kitty` — `kitten themes` auto-generates theme files in `~/.config/kitty/`
- `stow --no-folding systemd` — systemd creates `*.target.wants/` directories when enabling user units

**`scripts/` directory:** Not a stow package. Contains standalone scripts that are run directly, not symlinked.

- `scripts/debian-setup/debian-setup.sh` — Full system bootstrap script. Adds apt repos, installs all packages, configures greetd, sets up XDG portals, installs flatpaks/homebrew, stows all dotfiles, and reboots. This is the single entry point for provisioning a fresh Debian + sway desktop.
- `scripts/dotfiles-sync.sh` — Syncs dotfiles (used by a systemd user timer).
- `scripts/action.sh`, `scripts/zphr-second-brain-backup.sh` — Other utility scripts.

## Commit messages

Use the format: `component: lowercase description`

- `component` = the stow package name (top-level directory) the change belongs to
- Examples: `bash: add claude code aliases`, `nvim: add neotest-gradle for running Java tests`, `kitty: remap stack layout toggle`
- For cross-cutting changes, use a descriptive component like `dotfiles` or name the primary package affected

## Workflow

- Research and verify before applying config changes — check docs or man pages rather than guessing option names or syntax.
- Only commit and push when explicitly asked.
