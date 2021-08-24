#!/usr/bin/env bash

# Time in milliseconds
ns () {
	 date +%s%3N
}

# Warning / Error / Debug
warn () {
	printf "\e[33m[WARN]\e[0m %s\n" "$@" 1>&2
}

err () {
	printf "\e[31m[ERR]\e[0m %s\n" "$@" 1>&2
}

dbg () {
	if [ -n "$pond_debug" ]; then
		printf "$*\n"
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

# Start grepping from line
grep_from () {
	# 1 = File 2 = Line Number, 3 = Grep Options 4 = Regex
	echo "$1" | tail +"$2"  | grep  "$4" $3
}

# Get everything between 2 line numbers
get_between () {
	echo "$1" | sed -n "${2},${3}p"
}

# Remove first and last line
snip () {
	echo "$1" | sed '1d;$d'
}

