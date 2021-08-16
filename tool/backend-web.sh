#!/usr/bin/env bash

box () {
	printf "<div style=\"border: 1px solid #fafafa; padding: 0px 16px; margin: 8px 0; \">\n$1\n</div>"
}

# Sandbox somehow?
sh_script () {
	f=$(mktemp)
	echo "$1" >> $f
	echo "$(. $f)"
	rm $f
}

right_align () {
	printf "<div style=\"text-align: right\">\n$1\n</div>"
}

preserve_center () {
	printf "<div style=\"display: flex; justify-content: center; align-items: center\"><div>\n$1\n</div></div>"
}

# TODO: Make functional
auto_link () {
	out="$1"
	IFS=$'\n'   
	for link in $( echo "$1" | grep -Po '(?<!href=")https?://[\w-./]+' ); do
		out=${out/$link/<a href="$link">$link</a>}
	done
	echo "$out"
}

center () {
	printf "<div style=\"text-align:center\">\n$1\n</div>"
}

code () {
	if [ $(wc -l <<< "$1") -lt 15 ]; then
		echo "> $1" | awk 'NF' | $_script_dir/reeplace $'\n' $'\n> ' | head -n -1
	else
		ll=0
		while read -r line; do
			ll=$(( ll + 1 ))
			printf "%02d│ $line\n" $ll
		done <<< "$1"
	fi
}
