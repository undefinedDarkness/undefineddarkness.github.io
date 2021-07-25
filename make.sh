#!/usr/bin/env bash

case $1 in
	"watch")
		live-server &
		tsc --watch -p tool &
		ls -d ./src/* ./template.html | entr -dc bash make.sh
		exit
		;;
esac

_start=$(date +%s%3N)
template="./template.html"
tsc -p tool

pre_template=$(grep -Poz '(?s).+?(?=!CONTENT!)' template.html | tr -d '\0')
post_template=$(grep -Poz '!CONTENT!\n\K[^$]+' template.html | tr -d '\0')

mkdir -p out
count=0
for file in ./src/*.fmt.txt; do
	filen=$(basename $file)
	outfilen="out/${filen%%.*}.html"
	echo Building $file -\> $outfilen
	build=$(node ./tool/out/main.js $file --emoji-fix=false --mode=web)
	echo "$pre_template" > $outfilen
	echo "$build" >> $outfilen
	echo "$post_template" >> $outfilen
	count=$(( count + 1 ))
done
mv './out/index.html' .
_end=$(date +%s%3N)
echo "Finished $count in $((_end - _start))ms"
