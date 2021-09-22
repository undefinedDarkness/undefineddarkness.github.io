#!/usr/bin/env bash

_script_dir=$(dirname "$0")

. "$_script_dir/helpers.sh"

# Pond Simple Formatting System - Meant to be used with the toad ssg
# Requires GNU Coreutils

# Load backend
backend=$_script_dir/backend-${pond_backend:-web}.sh
dbg "Pond v${pond_version:-0}"

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
dbg "Using backend: \e[33m$backend\e[0m"
. "$backend"
transformers="${transfomers:-$(grep -Eo '^\w+ ' "$backend" )}" 
transformers=${transformers//$NEWL/ }
dbg "Available Transformers: $transformers"

# $1 = IN FILE
__start=$(ms)
file=$(cat "$1")

# Comes from backend
if contains "$transformers" "initial_transformer"; then
	dbg "Running initial transformer."
	timer start
	#initial_transformer "$file"
	#file=$transfomer_out
	file=$(initial_transformer "$file" 2> /dev/stdout)
	timer end
fi

fn () {

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
				ntransformer=$(_normalize "$transformer")

				# Check that transformer exists
				if ! contains "$transformers" "$ntransformer"; then
					warn "Tranformer $transformer does not exist in the provided backend. (@ $1:$_line_number)"
					continue
				fi

				# TODO: Replace this with something better!
				ending=$(grep_from "$file" "$_line_number" '-s -n -m1' "\#END $transformer")

				if [ -z "$ending" ]; then
					warn "Tranformer $transformer does not have an ending. (@ $1:$_line_number)"
					continue
				fi

				ending=${ending%%:*}
				ending=$(( _line_number + ending - 1 ))
				timer start
				dbg "Found ending for: $_line_number:#$transformer at $ending"
				
				# Original Contents
				original_contents="$(get_between "$file" $((_line_number)) $((ending)) )"

				# Modified Contents
				new_contents="$($ntransformer  "$(snip "$original_contents")" "${line###BEGIN $tranformer}" )"
				
				# Entire Modified File Contents
				new_file_contents=${file/"$original_contents"/"$new_contents"}
				#fnr "$file" "$original_contents" "$new_contents"
				#new_file_contents="$_fnr"
				
				# This check fixes stuff.. idk why
				if [ -n "$new_file_contents" ]; then
					file="$new_file_contents"
				fi

				timer end
				fn "$1" 
				break
			;;
	esac
done <<< "$file"
}

fn "$1"

# Comes from backend
if contains "$transformers" "final_transformer"; then
	dbg "Final Transformer"
	timer start
	file=$(final_transformer "$file")
	timer end
fi

echo "$file"
dbg "Finished in \033[34m$(calc "$(ms)-$__start")\033[0mms"
