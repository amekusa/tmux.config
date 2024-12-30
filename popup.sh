#!/usr/bin/env bash

# === TMUX Popup Manager ===
# github.com/amekusa
#
# Usage:
#   display-popup -E popup.sh
#
# Note:
#   Add following option to 'choose-tree' to hide popup windows:
#   -f '#{?@is_popup,0,1}'
#

# get the current 'session_id' and 'window_id'
arr=($(tmux display -p '#{session_id} #{window_id}'))
sid="${arr[0]}"
wid="${arr[1]}"

# name of the popup session to associate with the current sid & wid
session="_popup_${sid:1}_${wid:1}_"

# arguments
case "$1" in
clear) # kill all the popup sessions
	tmux ls -F '#{session_name}' -f '#{m:_popup_*,#{session_name}}' | while read -r line; do
		tmux kill-session -t "$line"
	done
	exit 0
	;;
gc) # kill orphaned popup sessions
	tmux ls -F '#{session_name}' -f '#{m:_popup_*,#{session_name}}' | while read -r line; do
		src="${line:7:-1}" # <src_sid>_<src_wid>
		src_sid="\$${src%_*}"
		src_wid="@${src#*_}"
		windows="$(tmux lsw -a -F 'x' -f "#{&&:#{==:#{session_id},${src_sid}},#{==:#{window_id},${src_wid}}}")"
		[ -z "$windows" ] && tmux kill-session -t "${line}"
	done
	exit 0
	;;
esac

# create the session
if ! tmux has -t="$session" 2> /dev/null; then
	# 'destroy-unattached' option must be off globally
	destroy_unattached="$(tmux show-option -gv destroy-unattached)"  # save the current value
	tmux set -g destroy-unattached off  # turn it off temporarily

	# create a session to store popup windows into
	tmux new -d -s "$session"

	# session options
	tmux set -t "$session" destroy-unattached off
	tmux set -t "$session" status off

	# restore global 'destroy-unattached' to the original value
	tmux set -g destroy-unattached "$destroy_unattached"
fi

# show a popup with the window attached
exec tmux attach -t "$session"

# Thanks:
#   https://willhbr.net/2023/02/07/dismissable-popup-shell-in-tmux/

