#!/usr/bin/env bash
set -euo pipefail

sidebar_width="$(tmux show-option -gqv @sidebar_width 2>/dev/null || true)"
[[ "$sidebar_width" =~ ^[0-9]+$ ]] || exit 0

# tmux 3.7c runs client-resized before the window layout has fully settled.
sleep 0.1

while IFS= read -r pane_id; do
  [[ -n "$pane_id" ]] || continue
  tmux resize-pane -t "$pane_id" -x "$sidebar_width" 2>/dev/null || true
done < <(tmux list-panes -a -F '#{?#{==:#{@pane_role},sidebar},#{pane_id},}' 2>/dev/null)
