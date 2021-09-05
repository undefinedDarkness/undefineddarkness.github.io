#!/usr/bin/env bash
# shellcheck disable=2016,2059

# This is a example implementation of a backend 
# for the pond formatting system.
# This one for generating HTML from a markdown like 
# format.

# Transformers must be defined as regular functions
# and must be available when the backend file is sourced 
# by an external script.
# By default, the script tries to guess any available transformers
# and if you wish to overrite this you can do:
# export transformers="transformerA transformerB transformerC"

# The following is utter hyprocisy but:
# It is generally recommended that transformers try to conform 
# to the POSIX standard when it is not an extra bother.

# !!: Indicates a transformer that should be available everywhere

# UTILITIES:

IMPORT_POLYFILL=0
# Generate syntax highlighted html code
# using Vim's :TOHtml command
__syntax_hl () {
	IMPORT_POLYFILL=1
	lang="$2"
	f=$(mktemp)
	echo "$1" | head -n -1 | nvim -n --headless \
		+"let g:html_no_progress = 1"\
		+"let g:html_ignore_folding = 1"\
		+'let g:html_prevent_copy = "fn"'\
		+"set ft=$2"\
		+"runtime! syntax/2html.vim"\
		+"wq! $f"\
		+"q!" - 2> /dev/null 
	l=$(cat "$f")
	
	style=${l#</style>*}
	style=${style%*<style>}
	style=${style#*<!--}
	style=${style%%-->*}
	
	code=${l%</pre>*}
	code=${code#*<pre id=\'vimCodeElement\'>$'\n'}

	# TODO: Fix vim's css and dont rely on scoped css to make the problem magically go away!
	echo "<div style='display: grid'>
	<style scoped>$style</style>
	<pre>
	<code lang=\"$lang\">$code</code>
	</pre></div>"

	rm "$f"
}

# TRANSFORMERS:

# Put the content in a box. Simple enough
box () {
	printf "<div style=\"border: 1px solid; padding: 0px 16px; margin: 8px 0; \">\n%s\n</div>" "$1"
}

# NOTE: This is very unsafe.
# !! Run a shell script and return its output.
sh_script () {
	f=$(mktemp)
	echo "$1" >> "$f"
	$SHELL "$f"
	rm "$f" 
}

# Right align text
right_align () {
	printf "<div style=\"text-align: right\">\n$1\n</div>"
}

# Center align text while preserving indentation: useful for ascii art
preserve_center () {
	printf "<div style=\"display: flex; justify-content: center; align-items: center\"><pre style=\"all: revert\">\n%s\n</pre></div>" "$1"
}

# Center align without preserving.
center () {
	printf "<p style=\"text-align:center\">\n$1\n</p>"
}

# Create a table with
# the columns defined by a tab seperated list
# and the rows denoted by newlines
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
			echo "<td>$( trim "$column" )</td>"
		done
		echo "</tr>"
	done <<< "$content"

	echo "</table>"
}

# PREDEFINED TRANSFORMERS

# This will be called before any *tranforming* has taken place
# It is useful for defining custom syntax as well as 
# following the markdown syntax.
# Its counterpart: final_transformer is also available.
initial_transformer () {
	out="$1"
	
	# Markdown Links
	while read -r a; do
		url=$( echo "$a" | grep -Po '(?<=\().*(?=\))' )
		text=$(echo "$a" | grep -Po '(?<=\[)[^\]]+(?=\])')
		mod="<a href=\"${url}\">${text}</a>"
		out=${out/"$a"/"$mod"}
	done < <( grep -Po '\[[^\]]+\]\(.*\)' <<< "$out" )
	
	# Markdown Code
	while read -r -d $'\0' match; do
		v=${match#\`\`\`}
		v=${v%\`\`\`}
		lang=$( grep -Po -m1 '```\K.*' <<< "$match" )
		v=${v#$lang}
		v=${v#$'\n'}
		if [ -n "$lang" ]; then
			v=$( __syntax_hl "$v" "$lang" )
		else
			v="<pre><code lang=\"$lang\">$v</code></pre>"
		fi
		out=${out/"$match"/"$v"}
	done < <(grep -Pzo '(?s)```.*?```' <<< "$out")

	while read -r a; do
		v=${a#\`}
		v=${v%\`}
		out=${out/"$a"/<code>$v</code>}
	done < <(grep -Po '`.*`' <<< "$out")

	# Headers 
	while read -r a; do
		h=${a%% *}
		out=${out/"$a"/<h${#h}>${a#* }</h${#h}>}
	done < <(grep -Po '^#+ .*' <<< "$out")

	echo "$out"
}

