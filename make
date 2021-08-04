#!/usr/bin/env bash

pre=$(grep -Pzo '[^$]+(?=!CONTENT!)' template.html | tr -d '\0')
post=$(grep -Pzo '(?<=!CONTENT!)[^$]+' template.html | tr -d '\0')

case $1 in

	# LIVE
	live)
		live-server --no-browser --ignore=src &
		echo -e "$(find src -name "*.fmt.txt")\n$(realpath ./template.html)" | entr -p ./make
		;;

	# INDEX
	index)
		for file in $(find out/ -type f -not -name "index.html" -not -name "startpage.html"); do
			echo "<a href=\"$file\">${file/out\//}</a>"
		done
		;;

	# SERVE
	serve)
		python3 -m http.server
		;;

	# BUILD
	*)
		mkdir -p src out
		for file in src/**/*.fmt.txt src/*.fmt.txt; do
			out=${file/src/out}
			out=${out/.fmt.txt/.html}
			mkdir -p $(dirname $out)
			echo -e "\nBuilding $file -> $out"
			data=$(node tool/out/main.js "$file" --mode=web --emoji-fix=no)
			echo "${pre/!TITLE!/$(basename $out .html)}$data$post" > "$out"
		done
		mv ./out/index.html .
		echo -e "\n--- Finished! ---"
	;;
esac
