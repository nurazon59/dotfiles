#!/usr/bin/env bash
set -euo pipefail

pane="$1"
window="$(tmux display-message -p -t "$pane" '#{window_id}')"
panes="$(tmux show-option -wqv -t "$window" @center_panes)"

if [[ -n "$panes" ]]; then
  tmux set-option -wu -t "$window" @center_panes
  for id in $panes; do
    pane_window="$(tmux display-message -p -t "$id" '#{window_id}' 2>/dev/null || true)"
    if [[ "$pane_window" == "$window" ]] && [[ "$(tmux list-panes -t "$window" | wc -l | tr -d ' ')" -gt 1 ]]; then
      tmux kill-pane -t "$id"
    fi
  done
  exit 0
fi

left="$(tmux split-window -h -b -d -P -F '#{pane_id}' -l 20% -c '#{pane_current_path}' -t "$pane")"
if ! right="$(tmux split-window -h -d -P -F '#{pane_id}' -l 25% -c '#{pane_current_path}' -t "$pane")"; then
  tmux kill-pane -t "$left"
  exit 1
fi
tmux set-option -w -t "$window" @center_panes "$left $right"
