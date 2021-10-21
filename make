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
pre=${template%%\!CONTENT\!*}
post=${template##*\!CONTENT\!}

server="deno run --unstable -A ./tool/server/server.ts --port=$port --log=false --live=false "

# General multi purpose build process
process () {
	#out=${2/.${out#*.}/.html}
	fnr "$2" ".${2#*.}" ".html"
	out=$_fnr

	mkdir -p "$(dirname "$out")"
	printf "\nBuilding \033[34m%s\033[0m \033[32m->\033[0m \033[34m%s\033[0m\n" "$1" "$out"

	x=${out%%.html}
	x=${x##out/}
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
		echo "$_fnr" > out/index.html
		echo "<style>
		article { 
			text-align: left;
			white-space: pre-wrap;
			display: inline-block;
		}
		body {
		text-align: center;
		}
	</style>" >> out/index.html
		tool/tree src 1>> out/index.html
		echo "$post" >> out/index.html
}

case $1 in

	# Serve files with hot reloading
	live)
		pkill "${server% *}"
		$server &  
		

		# Paths to watch
		(
		find src -name "*.fmt.txt" -or -name '*.html'
		realpath ./template.html
		find tool -name "*.sh"
		echo $0
		) | entr ./make # build /_
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
		$server
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

	--help|help)
		printf "
\033[1m🐸 Toad: A simple diet ssg\033[0m
--------------------

\033[4mUsage:\033[0m
> ./make [subcommand] [subcommand-args]

\033[4mSubcommands:\033[0m
build   - Builds a single file & updates the index
clean   - Remove old build output
serve   - Simply serve the site ( = python3 -m http.server)
index   - Print every recognized article
live    - Live server with hot reloading
*       - Build everything

"
		;;

	*)
		rm -r out
		mkdir -p src out
		for file in ${2:-src/**/*.fmt.txt src/*.fmt.txt src/*.html src/**/*.html}; do
			case "$file" in
				'src/*.fmt.txt')
					continue
					;;
				'src/*.html')
					continue
					;;
				'src/**/*.html')
					continue
					;;
				'src/**/*.fmt.txt')
					continue
					;;
				*)
					build "$file"
			esac
		done
		# Post Build
		mv ./out/index.html .
		gen_index 


		p=$(pgrep deno)
		[ -n "$p" ] && kill -s USR1 "$p" 

		printf "\nFinished!\n"
	;;
esac
