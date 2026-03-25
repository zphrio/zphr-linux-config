# btop stow package

## Important: use `--no-folding`

```bash
stow --no-folding btop
```

Without `--no-folding`, stow symlinks the entire `~/.config/btop` directory into the repo. Then when btop writes its own files (e.g. `btop.log`, `themes/`), they end up inside the repo.

With `--no-folding`, stow creates real directories and only symlinks the individual config files, keeping the repo clean.
