#!/usr/bin/env sh

box () {
	echo "<div style=\"border: 1px solid #fafafa; padding: 8px; \">\n$1\n</div>"
}

# Sandbox somehow?
sh_script () {
	f=$(mktemp)
	echo "$1" >> $f
	echo "$(. $f)"
	rm $f
}

right_align () {
	echo "<div style=\"text-align: right\">\n$1\n</div>"
}

preserve_center () {
	echo "<div style=\"display: flex; justify-content: center; align-items: center\"><div>\n$1\n</div></div>"
}

# TODO: Make functional
auto_link () {
	echo "$1"
}

center () {
	echo "<div style=\"text-align:center\">\n$1\n</div>"
}

code () {
	echo "$1"
}
