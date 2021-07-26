#!/usr/bin/env bash

build () {
	template="./template.html"
	
	for arg in $@
	do
		if [ ${arg#*.} != "fmt.txt" ]; then
			bash $0
			exit
		fi
	done

	# Read And Get Parts Of Template
	pre_template=$(grep -Poz '[^$]+(?=!CONTENT!)' template.html | tr -d '\0')
	post_template=$( grep -Poz '(?<=!CONTENT!)[^$]+' template.html | tr -d '\0')

	mkdir -p out

	count=0

	_start=$(date +%s%3N)
	for item in $@; do
		x=${item/src/out}
		out=${x/.fmt.txt/.html}

		echo "Building $item -> $out"

		mkdir -p $(dirname $out)
		echo $pre_template > $out
		node tool/out/main.js $item --mode=web --emoji-fix=no >> $out
		echo $post_template >> $out

		echo ""

		count=$(( count + 1 ))
	done
	_end=$(date +%s%3N)

	mv './out/index.html' .
	echo "Finished $count in $((_end - _start))ms"
}

case $1 in
	"watch")
		live-server --no-browser --ignore=src/ &
		#tsc -p tool -w &
		ls -d ./src/**/* ./template.html | entr -dc bash make.sh /_
		exit
		;;
	"index")
		items=$(find src -type f -name "*.fmt.txt" -not -name "index.fmt.txt")
		for item in $items; do
			x=${item/src/out}
			out=${x/.fmt.txt/.html}
			y=${out#*/}
			echo "<a href=\"$out\">@/${y%.*}</a>"
		done
		exit
		;;
	*)
		if [ -f "$1" ]; then
			build "$1"
		else
			build $(find src -type f -name "*.fmt.txt")
		fi
esac


