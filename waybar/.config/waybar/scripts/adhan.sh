#!/bin/bash
# Waybar custom module: next prayer in the bar, full day schedule in the tooltip.
# Clicking the module toggles the bar text to the time remaining (see format-alt).
ADHAN="$HOME/.local/bin/adhan"

[ -x "$ADHAN" ] || exit 0

next=$("$ADHAN" next --json 2>/dev/null) || exit 0
today=$("$ADHAN" today 2>/dev/null) || exit 0

jq -cn --argjson next "$next" --arg tooltip "$today" '
  ($next.remaining_minutes | floor) as $mins
  | (if $mins >= 60 then "\($mins / 60 | floor)h \($mins % 60)m" else "\($mins)m" end) as $left
  | {
      text: "\($next.name) \($next.display)",
      alt: "\($next.name) in \($left)",
      tooltip: $tooltip
    }
'
