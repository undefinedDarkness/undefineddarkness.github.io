#!/usr/bin/env bash

_script_dir=$(dirname "$0")

# shellcheck source=./tool/helpers.sh
. "$_script_dir/helpers.sh"

# Pond Simple Formatting System - Meant to be used with the toad ssg
# Requires GNU Coreutils

# Load backend
backend=$_script_dir/backend-${pond_backend:-web}.sh

# Check that files exists
if ! [ -f "$1" ]; then
	err "Invalid file given: '$1'"
	exit 1
fi

if ! [ -f "$backend" ]; then
	err "Invalid backend file: '$backend'"
	exit 1
fi

# Load backend
dbg "Using backend: \e[34m$backend\e[0m"
# shellcheck source=./tool/backend-web.sh
. "$backend"
#transformers=${transformers//$NEWL/ }
transformers=""
get-functions transformers
if [ -n "${pond_debug:-}" ]; then
	dbg 'Available Transformers: \e[0m%s' "$transformers" >&2
fi

# $1 = IN FILE
__start=$(ms)
# file=""
# while read -r line; do
# 	file+="$line$NEWL"
# done < "${1}"

# Comes from backend
if contains "$transformers" "initial_transformer"; then
	dbg "Running initial transformer."
	timer start
	file=$(initial_transformer < "${1}" 2> /dev/stderr)
	timer end
fi


# dbg "$file"

main () {

_line_number=0
 while read -r line; do
	_line_number=$(( _line_number + 1 ))

	case "$line" in
		"#END "*)
			;;
		"#"*)
				# Detected Transformer!
				transformer=${line#\#}
				#transformer=$( echo "$transformer" | tr $'\t' ' ' ) # Take care of tabs
				transformer=${transformer//$TAB/ }
				transformer=${transformer%% *}
				ntransformer=${transformer//-/_}
				ntransformer=${ntransformer,,}

				# Check that transformer exists
				if ! contains "$transformers" "$ntransformer"; then
					warn "Tranformer $transformer does not exist in the provided backend. (@ $1:$_line_number)"
					continue
				fi

				# TODO: Replace this with something better!
				ending=""
				# dbg "<<< before ending $line"
				#dbg "Found transformer call: %s @ %d" "$line" "$_line_number"
				#dbg "Current state of FILE: %s" "$file"
				get-line-number-of "$file" "$_line_number" "#END $transformer" ending
				# dbg "<<< after ending $line"

				if [ -z "$ending" ]; then
					warn "Transformer not found in $1 for: $line"
					continue
				fi

				ending=${ending%%:*}
				ending=$(( _line_number + ending - 1 ))
				timer start
				dbg "Found ending for \e[34m#$transformer\e[0m (@\e[34m$_line_number\e[0m) at \e[34m$ending\e[0m"
				
				# Original Contents
				original_contents="$(get-between "$file" ${_line_number} ${ending} )"

				# Modified Contents
				# dbg ">>> Passing this as main content: " "$(snip "$original_contents")"
				# dbg ">>> Passing this as arguments" "${line###BEGIN $tranformer}"
				new_contents="$($ntransformer  "$(snip "$original_contents")" "${line##"#BEGIN $tranformer"}" )"
				
				# Entire Modified File Contents
				new_file_contents=${file/"$original_contents"/"$new_contents"}
				#fnr "$file" "$original_contents" "$new_contents"
				#new_file_contents="$_fnr"
				
				# This check fixes stuff.. idk why
				if [ -n "$new_file_contents" ]; then
					file="$new_file_contents"
				fi

				main "$1" 
				break
			;;
	esac
done <<< "$file"
}

main "$1"

# Comes from backend
if contains "$transformers" "final_transformer"; then
	dbg "Final Transformer"
	timer start
	final_transformer "$file"
	timer end
fi

# echo "$file"
timer end "$__start"
