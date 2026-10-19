#!/bin/bash
# Waybar custom module: screen brightness (percent) for the stats drawer.
# Empty output (no backlight device, e.g. the desktop) hides the module.

for d in "${BACKLIGHT_SYS:-/sys/class/backlight}"/*/; do
  [ -r "$d/brightness" ] && [ -r "$d/max_brightness" ] || continue
  max=$(<"$d/max_brightness")
  (( max > 0 )) || continue
  echo $(( $(<"$d/brightness") * 100 / max ))
  exit 0
done
