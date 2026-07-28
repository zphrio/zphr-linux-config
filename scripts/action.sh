#!/bin/bash

# Main menu
CHOICE=$(printf "⏻ Power\n🖥️ Displays\n🌐 Network\n📶 Bluetooth\n🔊 Sound" | fuzzel --dmenu -p "Action: " -i)

case "$CHOICE" in
    *"Power"*)
        # Power options sub-menu
        POWER_CHOICE=$(printf "⏻ Shutdown (shutdown the system)\n🔒 Lock\n💤 Sleep\n↻ Restart" | fuzzel --dmenu -p "Power: " -i)
        case "$POWER_CHOICE" in
            *"Shutdown"*)
                systemctl poweroff
                ;;
            *"Lock"*)
                swaymsg input type:keyboard xkb_switch_layout 0 && gtklock
                ;;
            *"Sleep"*)
                systemctl suspend-then-hibernate
                ;;
            *"Restart"*)
                systemctl reboot
                ;;
        esac
        ;;
    *"Displays"*)
        # Opens nwg-displays app
        nwg-displays
        ;;
    *"Network"*)
        nm-connection-editor
        ;;
    *"Bluetooth"*)
        blueman-manager
        ;;
    *"Sound"*)
        pavucontrol
        ;;
esac
