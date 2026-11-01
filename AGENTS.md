# zphr-linux-config

Dotfiles repo managed with GNU Stow on Debian + sway.

## Structure

Stow packages (e.g., `kitty/`, `nvim/`, `sway/`) are explicitly listed in `scripts/stow-packages.sh`. Files inside mirror `$HOME` paths — stow symlinks them into place. Root instructions, `opencode.jsonc`, agent directories, and `scripts/` are project metadata, not Stow packages.

**Packages requiring `--no-folding`:** Some apps auto-generate files in their config directory. Without `--no-folding`, stow symlinks the whole directory and those files end up written into the repo.

- `stow --no-folding btop` — btop auto-generates `btop.log` and a `themes/` directory
- `stow --no-folding kitty` — `kitten themes` auto-generates theme files in `~/.config/kitty/`
- `stow --no-folding systemd` — systemd creates `*.target.wants/` directories when enabling user units

**`scripts/` directory:** Not a stow package. Contains standalone scripts that are run directly, not symlinked.

- `scripts/debian-setup/debian-setup.sh` — Full system bootstrap script. Adds apt repos, installs all packages, configures greetd, sets up XDG portals, installs flatpaks/homebrew, stows all dotfiles, and reboots. This is the single entry point for provisioning a fresh Debian + sway desktop.
- `scripts/dotfiles-sync.sh` — Syncs dotfiles (used by a systemd user timer).
- `scripts/stow-packages.sh` — Shared package list and Stow helpers used by bootstrap and sync. Source it and call `stow_package <package> [options]`; it targets `$HOME` explicitly, including from worktrees.
- `scripts/action.sh`, `scripts/zphr-second-brain-backup.sh` — Other utility scripts.

## Commit messages

Use the format: `component: lowercase description`

- `component` = the stow package name (top-level directory) the change belongs to
- Examples: `bash: add opencode aliases`, `nvim: add neotest-gradle for running Java tests`, `kitty: remap stack layout toggle`
- For cross-cutting changes, use a descriptive component like `dotfiles` or name the primary package affected

## Workflow

- Research and verify before applying config changes — check docs or man pages rather than guessing option names or syntax.
- Only commit and push when explicitly asked.

## Agent configuration

- Keep these instructions usable by any coding agent. OpenCode V2 is the default integration.
- Keep tracked OpenCode configuration, commands, and future skills provider-neutral: inherit the selected model rather than pinning a provider or model.
- Keep credentials and personal provider preferences outside the repository. Use OpenCode's `/connect` and `/models` UI.
- Put future portable skills in `.agents/skills/<name>/SKILL.md`, which OpenCode discovers automatically.

## Verification

- Check changed shell scripts with `bash -n` and ShellCheck. Run ShellCheck from the repository root with `-x` to follow shared helpers.
- After changing Stow or sync behavior, run `python3 -m unittest discover -s scripts/tests -v` (requires Git and GNU Stow). Tests use disposable repositories and home directories.
- Preview package changes with `source scripts/stow-packages.sh` and `stow_package <package> --simulate --verbose`.
- Validate Neovim configuration with the installed Neovim and the pinned plugin APIs.
- The bootstrap script provisions the system and reboots; verify its syntax rather than running it as a test.
