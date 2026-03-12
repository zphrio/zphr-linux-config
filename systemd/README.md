# systemd stow package

## Important: use `--no-folding`

```bash
stow --no-folding systemd
```

Without `--no-folding`, stow symlinks the entire `~/.config/systemd` directory into the repo. Then when systemd writes its own files (e.g. `timers.target.wants/`), they end up inside the repo.

With `--no-folding`, stow creates real directories and only symlinks the individual unit files, keeping the repo clean.

## Enable the timers

```bash
systemctl --user daemon-reload
systemctl --user enable --now dotfiles-sync.timer
systemctl --user enable --now zphr-second-brain-backup.timer
```
