#!/bin/bash
set -eo pipefail

# Log all output to file and terminal
exec > >(tee -a ~/log.txt) 2>&1

REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

section() {
  echo ""
  echo "=========================================="
  echo "  $1"
  echo "=========================================="
}

skip() {
  echo "-> $1 is already installed, skipping..."
}

section "Starting System Setup"

section "Adding Repositories"

# Backports
if ! grep -q "trixie-backports" /etc/apt/sources.list.d/*.sources 2>/dev/null; then
  echo "Adding backports repository..."
  sudo tee /etc/apt/sources.list.d/backports.sources <<EOF
Types: deb
URIs: http://deb.debian.org/debian
Suites: trixie-backports
Components: main contrib non-free non-free-firmware
EOF
fi

# GitHub CLI repo
if [ ! -f /etc/apt/sources.list.d/github-cli.sources ]; then
  echo "Adding GitHub CLI repository..."
  wget -q https://cli.github.com/packages/githubcli-archive-keyring.gpg -O- | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo tee /etc/apt/sources.list.d/github-cli.sources <<EOF
Types: deb
URIs: https://cli.github.com/packages/
Suites: stable
Components: main
Signed-By: /etc/apt/keyrings/githubcli-archive-keyring.gpg
EOF
fi

# Syncthing repo
if [ ! -f /etc/apt/sources.list.d/syncthing.sources ]; then
  echo "Adding Syncthing repository..."
  wget -q https://syncthing.net/release-key.gpg -O- | sudo tee /etc/apt/keyrings/syncthing-archive-keyring.gpg > /dev/null
  sudo tee /etc/apt/sources.list.d/syncthing.sources <<EOF
Types: deb
URIs: https://apt.syncthing.net/
Suites: syncthing
Components: stable-v2
Signed-By: /etc/apt/keyrings/syncthing-archive-keyring.gpg
EOF
fi

# Firefox repo
if [ ! -f /etc/apt/sources.list.d/mozilla.sources ]; then
  echo "Adding Firefox repository..."
  sudo install -d -m 0755 /etc/apt/keyrings
  wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
  cat <<EOF | sudo tee /etc/apt/sources.list.d/mozilla.sources
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
  echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
fi

# FirefoxPWA repo
if [ ! -f /etc/apt/sources.list.d/firefoxpwa.sources ]; then
  echo "Adding FirefoxPWA repository..."
  wget -q https://packagecloud.io/filips/FirefoxPWA/gpgkey -O- | sudo tee /usr/share/keyrings/firefoxpwa-keyring.gpg > /dev/null
  sudo tee /etc/apt/sources.list.d/firefoxpwa.sources <<EOF
Types: deb
URIs: https://packagecloud.io/filips/FirefoxPWA/any/
Suites: any
Components: main
Signed-By: /usr/share/keyrings/firefoxpwa-keyring.gpg
EOF
fi

# Griffo repo (yazi, lazydocker, lazygit)
if [ ! -f /etc/apt/sources.list.d/griffo.sources ]; then
  echo "Adding Griffo repository..."
  wget -q https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc -O- | sudo tee /etc/apt/keyrings/griffo.asc > /dev/null
  sudo tee /etc/apt/sources.list.d/griffo.sources <<EOF
Types: deb
URIs: https://debian.griffo.io/apt
Suites: $(lsb_release -sc)
Components: main
Signed-By: /etc/apt/keyrings/griffo.asc
EOF
fi

# Docker repo
if [ ! -f /etc/apt/sources.list.d/docker.sources ]; then
  echo "Adding Docker repository..."
  wget -q https://download.docker.com/linux/debian/gpg -O- | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
fi

section "System Update"
sudo apt update && sudo apt upgrade -y

# Remove Firefox ESR if present
if command -v firefox-esr &> /dev/null; then
  echo "Removing Firefox ESR..."
  sudo apt purge -y firefox-esr 'firefox-esr-l10n*' || true
  sudo apt autoremove --purge -y
  rm -rf ~/.mozilla/firefox
fi

section "Installing Packages"
sudo apt install -y \
  sway \
  waybar \
  swayidle \
  gtklock \
  gtklock-userinfo-module \
  xwayland \
  sway-notification-center \
  wl-clipboard \
  brightnessctl \
  xdg-desktop-portal-wlr \
  xdg-desktop-portal \
  xdg-desktop-portal-gtk \
  qt6-wayland \
  obs-studio \
  nwg-displays \
  nwg-look \
  network-manager-gnome \
  lxpolkit \
  thunar \
  thunar-archive-plugin \
  thunar-volman \
  gvfs-backends \
  pipewire-audio \
  pulseaudio-utils \
  pavucontrol \
  avahi-daemon \
  acpi \
  acpid \
  power-profiles-daemon \
  xdg-user-dirs-gtk \
  greetd \
  tuigreet \
  libnotify-bin \
  zathura \
  sxiv \
  tmux \
  bat \
  lazygit \
  syncthing \
  btop \
  lazydocker \
  yazi \
  galculator \
  fuzzel \
  fzf \
  fastfetch \
  fd-find \
  copyq \
  curl \
  grim \
  imagemagick \
  slurp \
  swappy \
  tesseract-ocr \
  tesseract-ocr-ara \
  blueman \
  tree \
  okular \
  libreoffice \
  gh \
  git \
  kitty \
  mpv \
  qbittorrent \
  resvg \
  sqlite3 \
  stow \
  build-essential \
  firefox \
  firefoxpwa \
  fonts-jetbrains-mono \
  fonts-font-awesome \
  fonts-recommended \
  fonts-noto-color-emoji \
  flatpak \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

sudo apt-mark hold docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

section "Greetd"
# Create cache directory (tmpfiles.d runs on boot, but we need it now)
sudo mkdir -p /var/cache/tuigreet
sudo chown _greetd:_greetd /var/cache/tuigreet
sudo chmod 0755 /var/cache/tuigreet

sudo tee /etc/greetd/config.toml <<EOF
[terminal]
vt = 2

[default_session]
command = "tuigreet --time --remember --remember-session --asterisks --cmd sway"
user = "_greetd"
EOF

# Mask getty on VT2 to prevent conflicts
sudo systemctl mask getty@tty2.service
sudo systemctl enable greetd
sudo systemctl set-default graphical.target

section "XDG Directories"
xdg-user-dirs-update

section "XDG Portals"
sudo mkdir -p /etc/sway/config.d
sudo tee /etc/sway/config.d/portals.conf <<EOF
# Update environment for portals
exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
EOF

mkdir -p ~/.config/xdg-desktop-portal
cat <<EOF > ~/.config/xdg-desktop-portal/portals.conf
[preferred]
default=wlr;gtk
EOF

section "1Password"
if command -v 1password &> /dev/null; then
  skip "1Password"
else
  curl -fsSL -o /tmp/1password.deb \
    "https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb"
  sudo apt install -y /tmp/1password.deb
fi

section "Flatpak"
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak update --user --appstream
flatpak install -y --user \
  app.zen_browser.zen \
  com.bambulab.BambuStudio \
  com.discordapp.Discord \
  com.getpostman.Postman \
  com.github.tchx84.Flatseal \
  com.slack.Slack \
  com.ticktick.TickTick \
  com.visualstudio.code \
  io.dbeaver.DBeaverCommunity \
  it.mijorus.gearlever \
  md.obsidian.Obsidian \
  org.telegram.desktop

section "Homebrew"
if ! command -v brew &> /dev/null; then
  NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
brew install neovim

section "Dotfiles"
rm -f "$HOME/.bashrc"
cd "$REPO_DIR"
for app in bash fuzzel gtklock ideavim mimeapps swappy sway tmux vim waybar yazi; do
  stow "$app"
done
stow --no-folding btop kitty systemd
kitten theme --reload-in=all Dracula

section "Dotfiles Sync"
systemctl --user daemon-reload
systemctl --user enable --now dotfiles-sync.timer

section "TPM"
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  echo "-> Run 'prefix + I' inside tmux to install plugins"
else
  skip "TPM"
fi

section "Syncthing"
sudo systemctl enable "syncthing@$USER"

section "Setup Complete"
echo "Restarting in 5 seconds..."
sleep 5
sudo reboot
