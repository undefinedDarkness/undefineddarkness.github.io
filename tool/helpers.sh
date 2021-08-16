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
normalize () {
	out=$(echo $1 | tr '[:upper:]' '[:lower:]' | tr '-' '_')
	echo $out
}


contains() {
    # Check if a "string list" contains a word.
    case " $1 " in *" $2 "*) return 0; esac; return 1
}

# Start grepping from line
grep_from () {
	# 1 = Line Number, 2 = File, 3 = Grep Options 4 = Regex
	tail +"$1" "$2" | grep  "$4" $3
}

# Get everything between 2 line numbers
get_between () {
	sed -n "${2},${3}p" $1
}

# Remove first and last line
strip_head_and_tail () {
	echo "$1" | awk NF | sed '1d;$d'
}

fnr() {
    # Replace all occurrences of substrings with substrings. This
    # function takes pairs of arguments iterating two at a time
    # until everything has been replaced.
    _fnr=$1
    shift 1

    while :; do case $_fnr-$# in
        *"$1"*) _fnr=${_fnr%"$1"*}${2}${_fnr##*"$1"} ;;
           *-2) break ;;
             *) shift 2
    esac done
}
