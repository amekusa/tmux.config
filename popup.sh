#!/usr/bin/env bash

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

sid="$(tmux display -p '#{session_id}')"
wid="$(tmux display -p '#{window_id}')"
session="_popup_${sid:1}_${wid:1}_"

# arguments
case "$1" in
--clear)
	tmux ls -F '#{session_name}' -f '#{?#{m:_popup_*,#{session_name}},1,0}' | while read -r line; do
		tmux kill-session -t "$line"
	done
	exit
	;;
--gc) # kill orphaned popup sessions
	tmux ls -F '#{@src_sid} #{session_name}' -f '#{@is_popup}' | while read -r line; do
		arr=($line)  # 0:src_sid, 1:session_name
		windows="$(tmux list-windows -a -F 'x' -f "#{==:#{session_id},${arr[0]}}")"
		[ -z "$windows" ] && tmux kill-session -t "${arr[1]}"
	done
	exit 0
	;;
esac

# create the session
if ! tmux has -t "$session" 2> /dev/null; then
	# 'destroy-unattached' option must be off globally
	destroy_unattached="$(tmux show-option -gv destroy-unattached)"  # save the current value
	tmux set -g destroy-unattached off  # turn it off temporarily

	# create a session to store popup windows into
	tmux new -d -s "$session"
	tmux set -t "$session" @is_popup 1
	tmux set -F -t "$session" @src_sid "$sid"
	tmux set -F -t "$session" @src_wid "$wid"
	tmux set -t "$session" destroy-unattached off
	tmux set -t "$session" status off

	# restore global 'destroy-unattached' to the original value
	tmux set -g destroy-unattached "$destroy_unattached"
fi

# show a popup with the window attached
exec tmux attach -t "$session"

# Thanks:
#   https://willhbr.net/2023/02/07/dismissable-popup-shell-in-tmux/

