#!/bin/bash

# Define some colors
txtdef="\e[0m"    # Revert to default
bldred="\e[1;31m" # Red - error
bldgrn="\e[1;32m" # Green - success
bldblu="\e[1;34m" # Blue - no action/ignored
bldcyn="\e[1;36m" # Cyan - pending action
bldwht="\e[1;37m" # White - info

function err {
	local exit_status=$1
	local reason="$2"
	shift 2
	if [[ -n $pending_status ]]; then
		fail
	fi
	status "$bldred" "error" "$reason" >&2
	for line in "$@"; do
		printf "$line\n" >&2
	done
	exit $exit_status
}

function status {
	if $TALK; then
		printf "$1%13s$txtdef %s\n" "$2" "$3"
	fi
}

function info {
	status "$bldwht" "$1" "$2"
}

pending_status=''
pending_message=''
function pending {
	pending_status="$1"
	pending_message="$2"
	if $TALK; then
		printf "$bldcyn%13s$txtdef %s" "$pending_status" "$pending_message"
	fi
}

function fail {
	[[ $1 ]] && pending_status=$1
	[[ $2 ]] && pending_message=$2
	status "\r$bldred" "$pending_status" "$pending_message"
	unset pending_status pending_message
}

function ignore {
	[[ $1 ]] && pending_status=$1
	[[ $2 ]] && pending_message=$2
	status "\r$bldblu" "$pending_status" "$pending_message"
	unset pending_status pending_message
}

function success {
	[[ $1 ]] && pending_status=$1
	[[ $2 ]] && pending_message=$2
	status "\r$bldgrn" "$pending_status" "$pending_message"
	unset pending_status pending_message
}

function prompt {
	if ! $BATCH; then
		local answer
		while true; do
			read -p "$1" answer
			case $answer in
				Y|y) return 0 ;;
				N|n) return 1 ;;
				"")  return 2 ;;
			esac
		done
	else
		return 2
	fi
}
