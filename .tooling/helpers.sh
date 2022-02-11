#!/usr/bin/env bash

# Warning / Error / Debug
warn () {
	[ -z "$quiet" ] && printf "\033[33mWWW\033[0m %s\n" "$@" >&2
}

err () {
	printf "\033[31m[ERR]\033[0m %s\n" "$@" >&2
}

dbg () {
	if [ -n "${pond_debug:-}" ]; then
		format=$1
		shift
		printf "\033[32mDBG\033[0m $format \n" "$@" >&2
	fi
}

# Check if a "string list" contains a word.
contains() {
    case " $1 " in *" $2 "*) return 0; esac; return 1
}

# Contains but for an array
contains-in-array () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Start grepping from line
get-line-number-of () {
	# 1 = File 2 = Line to start from 3 = Check 4 = Return Value
	local -n ptr=${4}
	local lineno=0
	while read -r __line; do
		# printf "??? $__line = $3\n"
		if [[ "$__line" == *"$3" ]]; then
			ptr=$(( lineno + 1 ))
			return
		fi
		lineno=$(( lineno + 1 ))
	done < <(tail +"$2" <<< "$1")
}

# Get everything between 2 line numbers
get-between () {
	sed -n "${2},${3}p" <<< "$1"
}

# Remove first and last line
snip () {
	sed '1d;$d' <<< "$1"
}

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}

get-functions() {
	local -n ptr=${1}
	IFS=$'\n' read -d "" -ra functions < <(declare -F)
	ptr=${functions[*]//declare -f }
}

# Calculations
calc() { awk "BEGIN{printf $*}"; }

# Time in Milliseconds
ms () {
	date +"%s%3N"
}

_start=0
timer () {

	[ -z "$pond_debug" ] && return

	case $1 in
		start)
			_start=$(ms)
			;;
		end)
			printf "\e[32mDBG\e[0m Finished in \033[34m" >&2
			calc "$(ms) - ${2:-$_start}"  >&2
			printf '\033[0mms\n' >&2
			;;
	esac
}

export NEWL="
"
export TAB="	"
