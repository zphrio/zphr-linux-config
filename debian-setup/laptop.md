# Laptop Configuration (Lid Close, Sleep, Hibernate)

## Overview

When the laptop lid closes:
1. swayidle catches `before-sleep` event → locks screen with gtklock
2. systemd-logind suspends the system
3. After 20 minutes of sleep → hibernates to save battery

## Configuration Files

### 1. Sway - swayidle (screen locking)

**File:** `~/.config/sway/config`

```bash
exec swayidle -w \
    timeout 300 'gtklock -d' \
    before-sleep 'gtklock -d'
```

- `timeout 300` - lock after 5 min idle
- `before-sleep` - lock before suspend/hibernate

### 2. logind - Lid Switch Behavior

**File:** `/etc/systemd/logind.conf.d/power.conf`

```ini
[Login]
HandleLidSwitch=suspend-then-hibernate
HandleLidSwitchExternalPower=suspend-then-hibernate
```

Create with:
```bash
sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/power.conf << 'EOF'
[Login]
HandleLidSwitch=suspend-then-hibernate
HandleLidSwitchExternalPower=suspend-then-hibernate
EOF
sudo systemctl restart systemd-logind
```

### 3. sleep.conf - Hibernate Delay

**File:** `/etc/systemd/sleep.conf.d/hibernate-delay.conf`

```ini
[Sleep]
HibernateDelaySec=20min
```

Create with:
```bash
sudo mkdir -p /etc/systemd/sleep.conf.d
sudo tee /etc/systemd/sleep.conf.d/hibernate-delay.conf << 'EOF'
[Sleep]
HibernateDelaySec=20min
EOF
```
