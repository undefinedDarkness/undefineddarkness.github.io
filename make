#!/usr/bin/env bash

# Toad:
# This is meant to be my super minimal SSG and meant to only fulfill my needs and do nothing more

# Configuration
port=5000

# Extract relevant parts of the template
pre=$(grep -Pzo '[^$]+(?=!CONTENT!)' template.html | tr -d '\0') # Posixify
post=$(grep -Pzo '(?<=!CONTENT!)[^$]+' template.html | tr -d '\0') # Posixify

# General multi purpose build process
process () {
	out=${2/.${out#*.}/.html}
	mkdir -p "$(dirname "$out")"
	printf "\nBuilding \033[34m$1\033[0m \033[32m->\033[0m \033[34m$out\033[0m\n"

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
		# + Markdown
		"fmt.txt"|"md")
			process "$1" "$out" 'bash tool/pond.sh'
			;;
	esac

}

case $1 in

	# Serve files with hot reloading
	live)
		live-server --no-browser --port=$port --ignore=out --ignore=src &  
		printf "$(find src -name "*.fmt.txt")\n$(realpath ./template.html)\n$(find tool -name "*.sh")\n$0" | entr ./make
		;;

	# Generates a super simple index of all the articles found
	index)
		while read -r file; do
			filename=${file%%.html}
			printf "<a href=\"$file\">${filename##out/}</a>\n"
		done < <(find out/ -type f -not -name "index.html")
		;;

	# Serve without hot realoading
	serve)
		python3 -m http.server $port &
		;;

	# Clean output directory and index.
	clean)
		rm -rv out index.html
		;;

	# Build Files
	*)
		rm -r out
		mkdir -p src out
		for file in ${2:-src/**/*.fmt.txt src/*.fmt.txt}; do
			build "$file"
		done
		# Post Build
		mv ./out/index.html .
		
		echo "${pre/!TITLE!/Full Index}" > out/index.html
		NO_COLOR=1 make_link_tree=1 folder_icon="📁" ~/tree src 1>> out/index.html
		echo "$post" >> out/index.html

		printf "\nFinished!\n"
	;;
esac
