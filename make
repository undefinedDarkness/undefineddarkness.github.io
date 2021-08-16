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
# Its written in POSIX shell but does require GNU grep :)

# Configuration
port=5000

# Extract relevant parts of the template
pre=$(grep -Pzo '[^$]+(?=!CONTENT!)' template.html | tr -d '\0') # Posixify
post=$(grep -Pzo '(?<=!CONTENT!)[^$]+' template.html | tr -d '\0') # Posixify

# Primary Build Function
build () {
	out=${1/src/out}
	out=${out/.fmt.txt/.html}
	mkdir -p $(dirname $out)
	printf "\nBuilding $1 -> $out\n"
	
	header="${pre/!TITLE!/$(basename $out .html)}" # Substitute Header
	printf "$header" >> "$out"
	#pong_debug=1 sh tool/pond.sh "$1" "$out" # Generate HTML
	printf "$post" >> "$out" # Output To File
}

case $1 in

	# Serve files with hot reloading
	live)
		live-server --port=$port --no-browser --ignore=src --ignore=out & 
		printf "$(find src -name "*.fmt.txt")\n$(realpath ./template.html)" | entr ./make
		;;

	# Generates a super simple index of all the articles found
	index)
		for file in $(find out/ -type f -not -name "index.html" -not -name "startpage.html"); do
			printf "<a href=\"$file\">${file/out\//}</a>\n"
		done
		;;

	# Serve without hot realoading
	serve)
		python3 -m http.server $port
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
