#!/usr/bin/env bash

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

# Primary Build Function
build () {
	# Output File Path
	out=${1/src/out}

	# if is html, directly copy
	if [ ${out##*.} = "html" ]; then
		cp -r $1 $out
	fi

	out=${out/.fmt.txt/.html}
	mkdir -p $(dirname $out)
	printf "\nBuilding $1 -> $out\n"

	x=${out%%.html}
	x=${x##out/}
	header="${pre/!TITLE!/$x}" # Substitute Header
	printf "$header" > "$out"
	bash tool/pond.sh "$1" >> $out # Generate HTML -- CHANGE
	printf "$post" >> "$out" # Output To File
}

case $1 in

	# Serve files with hot reloading
	live)
		live-server --no-browser --port=$port --ignore=out --ignore=src & 
		printf "$(find src -name "*.fmt.txt")\n$(realpath ./template.html)\n$(find tool -name "*.sh")" | entr ./make
		;;

	# Generates a super simple index of all the articles found
	index)
		for file in $(find out/ -type f -not -name "index.html"); do
			filename=${file%%.html}
			printf "<a href=\"$file\">${filename/out\//}</a>\n"
		done
		;;

	# Serve without hot realoading
	serve)
		python3 -m http.server $port &
		;;

	# Build Files
	*)
		mkdir -p src out
		for file in ${2:-src/**/*.fmt.txt src/*.fmt.txt}; do
			build $file
		done
		mv ./out/index.html .
		printf "\nFinished!\n"
	;;
esac
