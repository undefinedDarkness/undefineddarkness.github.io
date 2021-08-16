#!/usr/bin/env bash

# Get time in milliseconds
ms () {
	date +"%T.%3N"
}

warn () {
	printf "\e[33m[WARN]\e[0m %s\n" "$@" 1>&2
}

err () {
	printf "\e[31m[ERR]\e[0m %s\n" "$@" 1>&2
}

dbg () {
	if [ -n "$pond_debug" ]; then
		printf "$@\n"
	fi
}

# Normalize to lowercase & replace - with _
_normalize () {
	echo "$1" | tr '[:upper:]' '[:lower:]' | tr '-' '_'
}


contains() {
    # Check if a "string list" contains a word.
    case " $1 " in *" $2 "*) return 0; esac; return 1
}

# Start grepping from line
grep_from () {
	# 1 = Line Number, 2 = File, 3 = Grep Options 4 = Regex
	echo "$2" | tail +"$1"  | grep  "$4" $3
}

# Get everything between 2 line numbers
get_between () {
	echo "$1" | sed -n "${2},${3}p"
}

# Remove first and last line
strip_head_and_tail () {
	echo "$1" | sed '1d;$d'
}


