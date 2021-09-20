#!/usr/bin/env sh
#shellcheck disable=2059

# Toad:
# This is meant to be my super minimal SSG and meant to only fulfill my needs and do nothing more

# Configuration
port=5000

fnr() {
    _fnr=$1
    shift 1

    while :; do case $_fnr-$# in
        *"$1"*) _fnr=${_fnr%"$1"*}${2}${_fnr##*"$1"} ;;
           *-2) break ;;
             *) shift 2
    esac done
}

# Extract relevant parts of the template
template=$(cat template.html)
pre=${template%%\!CONTENT\!*} # Posixify
post=${template##*\!CONTENT\!} # Posixify

server="deno run --unstable -A ./tool/server/server.ts"

# General multi purpose build process
process () {
	#out=${2/.${out#*.}/.html}
	fnr "$2" ".${2#*.}" ".html"
	out=$_fnr

	mkdir -p "$(dirname "$out")"
	printf "\nBuilding \033[34m%s\033[0m \033[32m->\033[0m \033[34m%s\033[0m\n" "$1" "$out"

	x=${out%%.html}
	x=${x##out/}
	#header="${pre/!TITLE!/$x}" # Substitute Header
	fnr "$pre" "!TITLE!" "$x"
	header=$_fnr
	printf '%s' "$header" > "$out"
	$3 "$1" 1>> "$out" # Generate HTML -- CHANGE
	printf '%s' "$post" >> "$out" # Output To File
}

# Primary Build Function - handles every file
build () {
	fnr "$1" "src" "out"
	out=$_fnr

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

gen_index () {
		fnr "$pre" "!TITLE!" "Full Index"
		echo "$_fnr" > out/index.html # TODO: Integrate tree script here
		no_icon=1 NO_COLOR=1 make_link_tree=1 folder_icon="📁" ~/tree src 1>> out/index.html
		echo "$post" >> out/index.html
}

case $1 in

	# Serve files with hot reloading
	live)
		pkill "${server% *}"
		$server --port=$port --ignore=out,src --live=false &  
		printf "$(find src -name "*.fmt.txt")\n$(realpath ./template.html)\n$(find tool -name "*.sh")\n$0" | entr -p ./make build /_
		;;

	# Generates a super simple index of all the articles found
	index)
		find out/ -type f -not -name "index.html" | while read -r file; do
			filename=${file%%.html}
			printf "<a href=\"$file\">${filename##out/}</a>\n"
		done
		;;

	# Serve without hot realoading
	serve)
		$server --live=false --port=$port 
		#python3 -m http.server $port &
		;;

	# Clean output directory and index.
	clean)
		rm -rv out index.html
		;;

	# Build Files
	
	build)
		shift
		for file in "$@"; do
			build "$file"
		done
		kill -s USR1 "$(pgrep deno)" # In POSIX, There is no SIG... prefix 
		gen_index &
		;;

	*)
		rm -r out
		mkdir -p src out
		for file in ${2:-src/**/*.fmt.txt src/*.fmt.txt}; do
			build "$file"
		done
		# Post Build
		mv ./out/index.html .
		gen_index 


		p=$(pgrep deno)
		[ -n "$p" ] && kill -s USR1 "$p" # 2> /dev/null 

		printf "\nFinished!\n"
	;;
esac
