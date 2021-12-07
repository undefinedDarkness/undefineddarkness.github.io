#!/usr/bin/env bash
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

# Extract sidebar from the index
# sidebar=$(grep -Ezo -m1 '<nav>.*</nav>' ./index.html | tr -d '\0')

server="deno run --unstable -A ./tool/server/server.ts --port=$port --log=false --live=false "

# bash only and im lazy :(
getModifiedTime () {
	o=$(stat -c '%y' $1)
	echo "${o%.*}"
}

# General multi purpose build process
process () {
	#out=${2/.${out#*.}/.html}
	fnr "$2" ".${2#*.}" ".html"
	out=$_fnr

	mkdir -p "$(dirname "$out")"
	printf "Building \033[34m%s\033[0m \033[32m->\033[0m \033[34m%s\033[0m\n\n" "$1" "$out"

	x=${out%%.html}
	x=${x##out/}
	fnr "$pre" "!TITLE!" "$x" "!TIME!" "$(getModifiedTime "$1")"
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
			printf '\n'
			;;
		# Pond's Format
		# + Markdown
		"fmt.txt"|"md")
			process "$1" "$out" 'bash tool/pond.sh'
			;;
	esac

}

get-title () {
	case "${1#*.}" in
		# HTML
		"html")
			grep -Po -m1 '<h1>\K.*(?=<\/h1>)' $1
			;;
		# Pond's Format
		# + Markdown
		"fmt.txt"|"md")
			grep -Po -m1 '<h1>\K.*(?=<\/h1>)|# \K.*' $1 
			;;
	esac
}

gen_index () {
	cp ./src/index.html ./out/index.html # override with format
	for folder in $(ls src/ -p | grep '/'); do
		# echo $folder
		posts=
		for file in $(find src/$folder -name '*.fmt.txt'); do
			title=$(get-title $file)
			[ -z "$title" ] && title=$file
			file=${file/src\//\/out\/}
			file=${file/.fmt.txt/.html}
			posts="$posts\n<li><a href=\"${file}\">${title}</a></li>"
		done
		sed -i "s@!POSTS-$(tr '[:lower:]' '[:upper:]' <<< "${folder/\/}")!@${posts}@g" ./out/index.html #> ./out/index.html
	done
	printf "Generated Article Index\n"
}

post_build () {
		#mv ./out/index.html .
		gen_index &
		sed -E 's/\t//g;
				s/[[:space:]]{2,}//g; 
				s!/\*.*\*/!!g; 
				/^$/d;
				s/\n//g' assets/styles.css | tr -d '\n' > assets/styles-min.css
		printf '\nassets/styles.css -> assets/styles-min.css\n\n'
}

case $1 in

	# Serve files with hot reloading
	live)
		pkill "${server% *}"
		$server &  
		

		# Paths to watch
		(
		find src -name "*.fmt.txt" -or -name '*.html'#  -not -name 'index.html'
		realpath ./template.html
		realpath assets/styles.css
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
		#rm -rv out index.html
		;;


	# Build Files
	
	build)
		shift
		for file in "$@"; do
			build "$file" &
		done
		pkill --signal USR1 deno # In POSIX, There is no SIG... prefix 
		post_build 
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
		mkdir -p src out
		# shopt -s globstar
		look=$2
		if [ -z "$look" ]; then
			look=$(find src -name "*.fmt.txt" -or -name "*.html")
		fi
		for file in ${look}; do
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
					build "$file" &
			esac
		done

		post_build

		pkill --signal USR1 deno
		printf "Finished!\n"
	;;
esac
