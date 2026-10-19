#!/bin/bash
# Waybar custom module: CPU temperature for the stats drawer.
# The sensor is found by hwmon driver name (Intel coretemp, AMD k10temp/zenpower), so the same
# config works on any machine regardless of hwmon numbering or PCI address.
# Empty output (no sensor) hides the module.

for d in /sys/class/hwmon/hwmon*; do
  case $(<"$d/name") in
    coretemp|k10temp|zenpower)
      [ -r "$d/temp1_input" ] || continue
      temp=$(( $(<"$d/temp1_input") / 1000 ))
      if (( temp >= 80 )); then class=critical; elif (( temp >= 70 )); then class=warning; else class=normal; fi
      jq -cn --arg t "$temp" --arg c "$class" '{text: $t, percentage: ($t | tonumber), class: $c}'
      exit 0 ;;
  esac
done
