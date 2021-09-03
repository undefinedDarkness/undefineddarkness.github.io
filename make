#!/usr/bin/env bash

# shellcheck disable=2059
# Taken from pure-sh-bible
basename() {
    dir=${1%${1##*[!/]}}
    dir=${dir##*/}
    dir=${dir%"$2"}
    printf '%s\n' "${dir:-/}"
}

dirname() {
    dir=${1:-.}
    dir=${dir%%"${dir##*[!/]}"}
    [ "${dir##*/*}" ] && dir=.
    dir=${dir%/*}
    dir=${dir%%"${dir##*[!/]}"}
    printf '%s\n' "${dir:-/}"
}

# Toad:
# This is meant to be my super minimal SSG and meant to only fulfill my needs and do nothing more

# Configuration
port=5000

# Extract relevant parts of the template
pre=$(grep -Pzo '[^$]+(?=!CONTENT!)' template.html | tr -d '\0') # Posixify
post=$(grep -Pzo '(?<=!CONTENT!)[^$]+' template.html | tr -d '\0') # Posixify

# General build process
process () {
	out=${2/.${out#*.}/.html}
	mkdir -p "$(dirname "$out")"
	printf "\nBuilding $1 -> $out\n"

	x=${out%%.html}
	x=${x##out/}
	header="${pre/!TITLE!/$x}" # Substitute Header
	printf '%s' "$header" > "$out"
	$3 "$1" 1>> "$out" # Generate HTML -- CHANGE
	printf '%s' "$post" >> "$out" # Output To File
}

# Primary Build Function - handles every file
build () {
	# Output File Path
	out=${1/src/out}

	case "${out#*.}" in
		# HTML
		"html")
			cp -fv "$1" "$out"
			return
			;;
		# Pond's Format
		"fmt.txt")
			process "$1" "$out" 'env MARKDOWN_COMPAT=1; ENABLE_HEADERS=1; ENABLE_CODE_LINES=1; bash tool/pond.sh'
			;;
		# Markdown
		"md")
			process "$1" "$out" 'env MARKDOWN_COMPAT=1 bash tool/pond.sh'
		;;
	esac

}

case $1 in

	# Serve files with hot reloading
	live)
		live-server --no-browser --port=$port --ignore=out --ignore=src & 
		printf "$(find src -name "*.fmt.txt")\n$(realpath ./template.html)\n$(find tool -name "*.sh")" | entr ./make
		;;

	# Generates a super simple index of all the articles found
	index)
		while read -r file; do
			filename=${file%%.html}
			printf "<a href=\"$file\">${filename/out\//}</a>\n"
		done < <(find out/ -type f -not -name "index.html")
		;;

	# Serve without hot realoading
	serve)
		python3 -m http.server $port &
		;;
	clean)
		rm -r out index.html
		;;

	# Build Files
	*)
		mkdir -p src out
		for file in ${2:-src/**/*.fmt.txt src/*.fmt.txt}; do
			build "$file"
		done
		mv ./out/index.html .
		printf "\nFinished!\n"
	;;
esac
