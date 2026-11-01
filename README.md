# zphr-linux-config

Debian + Sway dotfiles managed with GNU Stow.

## Install dotfiles

From the repository root, stow the packages you want:

```bash
stow bash sway
stow --no-folding btop kitty systemd
```

`scripts/debian-setup/debian-setup.sh` provisions a fresh Debian desktop and stows everything.

## OpenCode

For an existing machine with Homebrew:

```bash
brew install anomalyco/tap/opencode-v2
opencode .
```

Use `/connect` to connect your preferred provider, then `/models` to select a model. Credentials are managed by OpenCode outside this repository. Personal defaults belong in `~/.config/opencode/opencode.jsonc`.

`AGENTS.md` contains shared repository instructions. Root `opencode.jsonc` adds `/check-dotfiles` and `/review-dotfiles` without pinning a provider or model. Future portable skills belong in `.agents/skills/<name>/SKILL.md`. These project files are not linked into your home directory.

### Shell shortcuts

After applying the Bash package and starting a new shell:

| Shortcut | Action |
| --- | --- |
| `oc` | Open OpenCode in the current directory |
| `ocr` | Continue the last session |
| `ocu` | Update OpenCode |
