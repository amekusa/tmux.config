#!/bin/sh

# === TMUX Popup Manager ===
# github.com/amekusa
#
# Usage:
#   display-popup -E popup.sh
#
# Note:
#   Add following option to 'choose-tree' to hide popup windows:
#   -f '#{?#{m:_popup_*,#{session_name}},0,1}'
#

# session name
session="_popup$(tmux display -p '#{s/[$@]/_/:#{session_id}#{window_id}}')"

if ! tmux has -t "$session" 2> /dev/null; then
	# 'destroy-unattached' option must be off globally
	destroy_unattached="$(tmux show-option -gv destroy-unattached)"  # save the current value
	tmux set -g destroy-unattached off  # turn it off temporarily

	# create a session to store popup windows into
	tmux new -d -s "$session"
	tmux set -t "$session" @is_popup 1
	tmux set -t "$session" destroy-unattached off
	tmux set -t "$session" status off

	# restore global 'destroy-unattached' to the original value
	tmux set -g destroy-unattached "$destroy_unattached"
fi

# show a popup with the window attached
exec tmux attach -t "$session"

# Thanks:
#   https://willhbr.net/2023/02/07/dismissable-popup-shell-in-tmux/

