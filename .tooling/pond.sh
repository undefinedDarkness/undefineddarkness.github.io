#!/usr/bin/env bash

_script_dir=$(dirname "$0")
transformers=""
__start=0
__outfile=""
__infile=''

# shellcheck source=./tool/helpers.sh
. "$_script_dir/helpers.sh"
# shellcheck source=./initial.sh
. "$_script_dir/initial.sh"
# shellcheck source=./final.sh
. "$_script_dir/final.sh"
# shellcheck source=./transformers.sh
. "$_script_dir/transformers.sh"

# NEWLINE=$'\n'
TAB=$'\t'
__start=$(ms)

get-functions transformers
if [ -n "${pond_debug:-}" ]; then
	dbg 'Available Transformers: \e[0m%s' "$transformers" >&2
fi


# Comes from backend



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
					transformer=${transformer//'	'/ }
					transformer=${transformer%% *}
					ntransformer=${transformer//-/_}
					ntransformer=${ntransformer,,}

					# Check that transformer exists
					if ! contains "$transformers" "$ntransformer"; then
						warn "Tranformer $transformer does not exist in the provided backend. (@ $__infile:$_line_number)"
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
						warn "Transformer ending not found for: $line ($__infile)"
						continue
					fi

					ending=${ending%%:*}
					ending=$(( _line_number + ending - 1 ))
					timer start
					dbg "Found ending for \e[34m#$transformer\e[0m (@\e[34m$_line_number\e[0m) at \e[34m$ending\e[0m"
					
					# Original Contents
					original_contents="$(get-between "$file" ${_line_number} ${ending} )"

					# Modified Contents
					# dbg ">>> Passing this as main content: %s" "$(snip "$original_contents")"
					# arguments="${line#'#BEGIN '$transformer}"
					dbg ">>> Passing this as arguments: '%s'" "${line###'#BEGIN '"${transformer}"}"
					new_contents=$($ntransformer  "$(snip "$original_contents")" ${line##'#BEGIN '"$transformer"} )
					
					# Entire Modified File Contents
					new_file_contents=${file/"$original_contents"/"$new_contents"}
					#fnr "$file" "$original_contents" "$new_contents"
					#new_file_contents="$_fnr"
					
					# This check fixes stuff.. idk why
					if [ -n "$new_file_contents" ]; then
						file="$new_file_contents"
					fi

					# MAGIC PART - IGNORE IT
					main 
					break
				;;
		esac
	done <<< "$file"
}

if [ -z "$1" ]; then
	error "No valid file given"
	exit
else
	__infile=$1
fi

oIFS="$IFS"
if contains "$transformers" "initial_transformer"; then
	dbg "Running initial transformer."
	timer start
	file=""
	prefix=""
	initial_transformer prefix file < "${__infile}" 2> /dev/stderr
		
	# file=$(initial_transformer < "${__infile}" 2> /dev/stderr)
	timer end
fi
IFS="$oIFS"

main
IFS="$oIFS"

printf '%s' "$prefix"
dbg "Final Transformer"
timer start
final_transformer "$file"
timer end

timer end "$__start"
