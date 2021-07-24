#!/usr/bin/env bash

case $1 in
	"watch")
		live-server out &
		ls -d ./src/* | entr -dc bash make.sh
		exit
		;;
esac

_start=$(date +%s%3N)
template="./template.html"

pre_template=$(grep -Poz '(?s).+?(?=!CONTENT!)' template.html | tr -d '\0')
post_template=$(grep -Poz '!CONTENT!\n\K[^$]+' template.html | tr -d '\0')

mkdir -p out
count=0
for file in ./src/*.fmt.txt; do
	filen=$(basename $file)
	outfilen="out/${filen%%.*}.html"
	echo Building $file -\> $outfilen
	build=$(node ../out/main.js $file --web --no-fix-emoji 2> /dev/null)
	echo "$pre_template" > $outfilen
	echo "$build" >> $outfilen
	echo "$post_template" >> $outfilen
	count=$(( count + 1 ))
done
_end=$(date +%s%3N)
echo "Finished $count in $((_end - _start))ms"
