#!/usr/bin/env bash

#MODIFY
box () {
	printf "<div style=\"border: 1px solid; padding: 0px 16px; margin: 8px 0; \">\n$1\n</div>"
}

# Sandbox somehow?
sh_script () {
	f=$(mktemp)
	echo "$1" >> $f
	$SHELL $f
	rm $f 
}

right_align () {
	printf "<div style=\"text-align: right\">\n$1\n</div>"
}

preserve_center () {
	printf "<div style=\"display: flex; justify-content: center; align-items: center\"><pre>\n$1\n</pre></div>"
}

# TODO: Make functional
initial_transformer () {
	out="$1"
	
	while read -r a; do
		read -r -a parts <<< "$(echo "$a" | tr -d '[])' | tr '(' ' ')"
		mod="<a href='${parts[1]}'>${parts[0]}</a>"
		out="${out/"$a"/"$mod"}"
	done <<< "$( grep -Eo '\[.*\]\(.*\)' <<< "$out" )"

	while read -r header; do
		prefix=${header%% *}
		content=${header##$prefix}
		v="<h${#prefix}>${content}</h${#prefix}>"
		out=${out/$header $prefix/$v}
	done <<< "$(grep -Po '\-+[^-]+' <<< "$out")"

	echo "$out"
}

final_transformer () {
	out="$1"
	#echo "$1"
	while read -r link; do
		out=${out/$link/<a href="$link">$link</a>}
	done <<< "$( grep -Po '(?<!href=)https?://[\w-./]+' <<< "$out" )"
	echo "$out"
}

center () {
	printf "<p style=\"text-align:center\">\n$1\n</p>"
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

color_codes () {
	f=$(mktemp)
	echo "$1" >> $f
	npx ansi-to-html $f
	rm $f
}

table () {
	content="$1"
	shift 2

	printf "<table>\n<tr>\n"
	for column in "$@"; do
		echo "<th>$column</th>"
	done
	echo "</tr>"

	while read -r row; do
		echo "<tr>"
		IFS=$'\t'
		for column in $row; do
			[ -z "$column" ] && continue;
			echo "<td>$( echo "$column" | xargs )</td>"
		done
		echo "</tr>"
	done <<< "$content"

	echo "</table>"
}
