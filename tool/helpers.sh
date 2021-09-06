#!/usr/bin/env bash

# Warning / Error / Debug
warn () {
	printf "\e[33m[WARN]\e[0m %s\n" "$@" 1>&2
}

err () {
	printf "\e[31m[ERR]\e[0m %s\n" "$@" 1>&2
}

dbg () {
	if [ -n "${pond_debug:-}" ]; then
		printf "%s\n" "$*"
	fi
}

# Normalize to lowercase & replace - with _
_normalize () {
	echo "$1" | tr '[:upper:]' '[:lower:]' | tr '-' '_'
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
