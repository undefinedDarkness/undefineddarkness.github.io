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
dbg "Pond v0"

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
# $_out_f = OUT FILE
_out_f=$(mktemp)
cp "./$1" "$_out_f" # FIX
file=$(cat "$1")
in=$1

# Loop over lines
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
				transformer=${transformer%% *}
				if ! contains "$transformers" "$(normalize $transformer)"; then
					warn "Invalid Tranformer (DOES NOT EXIST IN BACKEND): $transformer @ $1:$_line_number"
					continue
				fi

				ending=$(grep_from "$_line_number" "$_out_f" '-s -n -m1' "\#END $transformer")
				dbg "Found ending for: $_line_number:#$transformer at $ending"
				ending=${ending%%:*}
				ending=$(( _line_number + ending - 1 ))
				if [ -z "$ending" ]; then
					warn "Invalid Transfomer (DOES NOT HAVE AN END): $transformer @ $1:$_line_number"
					continue
				fi
				
				original_contents=$(get_between $_out_f $((_line_number)) $((ending)) )
				new_contents=$($(normalize $transformer) "$(strip_head_and_tail "$original_contents")" ) # add args support
				echo "\n--- $transformer: $_line_number:$line ---\n$original_contents\n---\n"
				# echo "\n---\n$(strip_head_and_tail "$original_contents")\n---\n$new_contents\n---\n"
				new_file_contents=$(echo "$file" | $_script_dir/reeplace "$original_contents" "$new_contents")
				
				# This check fixes stuff.. idk why
				if [ -n "$new_file_contents" ]; then
					echo "$new_file_contents" > $_out_f
					file="$new_file_contents"
				fi

				echo "$new_file_contents"
				#break
			;;
	esac
done < $_out_f
}

fn
echo "$(perl -p0e 's/#.*\n//g' $_out_f)" > $_out_f
echo "FINAL:"
cat $_out_f
rm $_out_f

_end=$(ms)
dbg "Finished in $(( end - start ))ms"
