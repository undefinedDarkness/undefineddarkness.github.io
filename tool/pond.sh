#!/usr/bin/env sh

# Taken from sh bible
dirname() {
    dir=${1:-.}
    dir=${dir%%"${dir##*[!/]}"}
    [ "${dir##*/*}" ] && dir=.
    dir=${dir%/*}
    dir=${dir%%"${dir##*[!/]}"}
    printf '%s\n' "${dir:-/}"
}

_script_dir=$(dirname $0)

. $_script_dir/helpers.sh

# Simple Formatting System - Meant to be used with the toad ssg
# Requires GNU Coreutils

# Load backend
backend=$_script_dir/backend-${pond_backend:-web}.sh
_start=$(ms)

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
. $backend
transformers="$(grep -Po '.*(?=\(\))' $backend | tr '\n' ' ')" # POSIX ify
dbg "Available Transformers: $transformers"

# $1 = IN FILE
# $2 = OUT FILE
cp "./$1" "./$2" # FIX
file=$(cat "$1")

# Loop over lines
_line_number=0
_find_list=""
_replace_list=""
while read -r line; do
	_line_number=$(( _line_number + 1 ))

	case "$line" in
		"#END "*)
			;;
		"#"*)
				# Detected Transformer!
				transformer=${line#\#}
				transformer=${transformer%% *}
				if ! contains "$transformers" "$(normalize $transformer)"; then
					warn "Invalid Tranformer (DOES NOT EXIST IN BACKEND): $transformer @ $1:$_line_number"
					continue
				fi

				ending=$(grep_from "$_line_number" "$2" '-s -n' "\#END $transformer")
				ending=${ending%%:*}
				ending=$(( _line_number + ending - 2 ))
				if [ -z "$ending" ]; then
					warn "Invalid Transfomer (DOES NOT HAVE AN END): $transformer @ $1:$_line_number"
					continue
				fi
				
				original_contents=$(get_between $2 $((_line_number + 1)) $ending )
				new_contents=$($(normalize $transformer) "$original_contents") # add args support
				new_file_contents=$(echo "$file" | $_script_dir/reeplace "$original_contents" "$new_contents")
				
				# This check fixes stuff.. idk why
				if [ -n "$new_file_contents" ]; then
					echo "$new_file_contents" > $2
					file="$new_file_contents"
				fi
			;;
	esac
done < "$1"

echo "$(perl -p0e 's/#.*\n//g' $2)" > $2

_end=$(ms)
dbg "Finished in $(( end - start ))ms"
