# zphr-linux-config

Debian + Sway dotfiles managed with GNU Stow, with a provider-neutral OpenCode V2 workflow.

## Install dotfiles

From the repository root:

```bash
source scripts/stow-packages.sh
stow_package nvim --simulate --verbose
stow_package nvim
```

The shared package list covers the desktop, terminal, and editor configurations. The helper targets `$HOME` explicitly and preserves `--no-folding` for btop, Kitty, and systemd. Repository metadata and scripts are never Stow packages.

`scripts/debian-setup/debian-setup.sh` provisions a fresh Debian desktop, installs Neovim and OpenCode V2 through Homebrew, links the packages, enables services, and reboots.

## OpenCode

For an existing machine with Homebrew:

```bash
brew install anomalyco/tap/opencode-v2
opencode .
```

Use `/connect` to connect your preferred provider, then `/models` to select a model. Credentials are managed by OpenCode outside this repository. Personal defaults belong in `~/.config/opencode/opencode.jsonc`; terminal preferences belong in `~/.config/opencode/cli.json`.

`AGENTS.md` contains shared repository instructions. Root `opencode.jsonc` adds `/check-dotfiles` and `/review-dotfiles` without pinning a provider or model. Future portable skills belong in `.agents/skills/<name>/SKILL.md`. These project files are not linked into your home directory.

### Shell shortcuts

After applying the Bash package and starting a new shell:

| Shortcut | Action |
| --- | --- |
| `oc` | Open OpenCode in the current directory |
| `ocr` | Continue the last session |
| `ocu` | Update OpenCode |

### Neovim shortcuts

The existing Snacks terminal integration runs the OpenCode V2 CLI in the project root. It uses the provider/model selected in OpenCode.

| Shortcut | Action |
| --- | --- |
| `<leader>ac` | Toggle OpenCode |
| `<leader>af` | Focus OpenCode; hide it if already focused |
| `<leader>ar` | Open/toggle a terminal continuing the last session |
| `<leader>as` (visual) | Enter a question and start a new session with the selected text, file path, and line range |

Selection context includes unsaved buffer text. Press Escape twice in the terminal to return to Neovim's normal mode. When migrating an existing checkout, run `stow_package nvim --restow` to replace old configuration links, then `:Lazy clean` to remove the retired editor plugin from your local plugin directory.

## Verification

```bash
bash -n scripts/stow-packages.sh
bash -n scripts/dotfiles-sync.sh
bash -n scripts/debian-setup/debian-setup.sh
shellcheck -x scripts/stow-packages.sh scripts/dotfiles-sync.sh scripts/debian-setup/debian-setup.sh
python3 -m unittest discover -s scripts/tests -v
git diff --check
```

The regression tests require Python 3, Git, and GNU Stow and use temporary repositories and home directories. Set `TMPDIR` to choose their scratch directory.
