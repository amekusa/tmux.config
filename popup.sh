#!/usr/bin/env bash

# === TMUX Popup Manager ===
# github.com/amekusa
#
# Usage:
#   display-popup -E popup.sh

session="_popup_$(tmux display -p '#{session_id}')"
window="_popup_$(tmux display -p '#{window_id}')"

if ! tmux has -t "$session" 2> /dev/null; then
	# 'destroy-unattached' option must be off globally
	destroy_unattached="$(tmux show-option -gv destroy-unattached)"  # save the current value
	tmux set -g destroy-unattached off  # turn it off temporarily

	# create a session for keeping popup windows alive
	tmux new-session -d -s "$session" -n "$window"
	tmux set -t "$session" destroy-unattached off
	tmux set -t "$session" automatic-rename off
	tmux set -t "$session" key-table popup
	tmux set -t "$session" status off
	tmux set -t "$session" prefix None

	# restore global 'destroy-unattached' to the original value
	tmux set -g destroy-unattached "$destroy_unattached"
fi

# create/select the popup window
tmux new-window -Sd -t "$session:" -n "$window"

# attach
exec tmux attach -t "$session:$window"

# Thanks:
#   https://willhbr.net/2023/02/07/dismissable-popup-shell-in-tmux/

