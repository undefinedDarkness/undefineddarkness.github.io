#!/usr/bin/env bash

# Warning / Error / Debug
warn () {
	printf "\033[33m[WARN]\033[0m %s\n" "$@" 1>&2
}

err () {
	printf "\033[31m[ERR]\033[0m %s\n" "$@" 1>&2
}

dbg () {
	if [ -n "${pond_debug:-}" ]; then
		# shellcheck disable=2059
		printf "$*\n" #"$*"
	fi
}

# Normalize to lowercase & replace - with _
_normalize () {
	echo "${1//-/_}" | tr '[:upper:]' '[:lower:]' # | tr '-' '_'
}


# Check if a "string list" contains a word.
contains() {
    case " $1 " in *" $2 "*) return 0; esac; return 1
}

# Contains but for an array
containsArray () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Start grepping from line
grep_from () {
	# 1 = File 2 = Line Number, 3 = Grep Options 4 = Regex
	# shellcheck disable=2086
	echo "$1" | tail +"$2"  | grep $3 -- "$4"
}

# Get everything between 2 line numbers
get_between () {
	echo "$1" | sed -n "${2},${3}p"
}

# Remove first and last line
snip () {
	echo "$1" | sed '1d;$d'
}

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}

# POSIX Find And Replace - Taken from https://github.com/kisslinux/kiss/blob/master/kiss#L106-L118 
fnr() {
    _fnr=$1
    shift 1

    while :; do case $_fnr-$# in
        *"$1"*) _fnr=${_fnr%"$1"*}${2}${_fnr##*"$1"} ;;
           *-2) break ;;
             *) shift 2
    esac done
}

# Calculations
calc() { awk "BEGIN{print $*}"; }

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
			printf "Finished in \033[31m%d\033[0m ms\n\n" "$( calc "$(ms)-$_start" )"
			;;
	esac
}

export NEWL="
"
export TAB="	"
