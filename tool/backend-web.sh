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

# This is mostly for shellcheck, helpers are already imported when this is run
# shellcheck source=helpers.sh
#. $( dirname $0 )/helpers.sh

# UTILITIES:

# Generate syntax highlighted html code
# using Vim's :TOHtml command

__syntax_hl () {
	printf "<pre>"
	printf "$1" | highlight\
		--syntax "$2"\
		-q\
		--force \
		--stdout \
		-l \
		-f \
		--inline-css \
		--pretty-symbols \
		--config-file=assets/zenburn.theme \
		--no-version-info
	printf "</pre>"
}

# TODO: Replace with GNU Source-Highlight, This is way too slow
# There might be a way to make this faster but rn its slow as fuck
__SLOW_syntax_hl () {
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
	
	# This is soo dumb ;-;
	(
	style=${l#</style>*}
	style=${style%*<style>}
	style=${style#*<!--}
	style=${style%%-->*}
	style=${style/pre \{/pre.vim-highlight \{}
	style=${style//input/.vim-highlight input}
	IFS=$'\n' 
	read -d '' -r -a existing_styles < ./assets/styles.css

	while read -r line; do
		case "$line" in
			"*"*|"body"*)
				continue
				;;
		esac
		if containsArray "$line" "${existing_styles[@]}"; then
				continue
			else
			# assume style is not found.
			existing_styles+=("$line")
		fi
	done <<< "$style"
	printf "${existing_styles[*]}" > ./assets/styles.css
	) &

	code=${l%</pre>*}
	code=${code#*<pre id=\'vimCodeElement\'>$'\n'}

	echo "<pre class=\"vim-highlight\">
	<code class=\"language-$lang\">$code</code>
	</pre>"

	rm "$f"
}

# TRANSFORMERS:

# Put the content in a box. Simple enough
box () {
	printf "<div class='box'>\n%s\n</div>" "$1"
}

# NOTE: This is very unsafe.
# !! Run a shell script and return its output.
sh_script () {
	#f=$(mktemp)
	#echo "$1" >> "$f"
	#$SHELL "$f"
	#rm "$f"
	$1
}

# Right align text
right_align () {
	printf "<div style=\"text-align: right\">\n$1\n</div>"
}

# Center align text while preserving indentation: useful for ascii art
preserve_center () {
	printf "<div class='preserve-center'><pre>\n%s\n</pre></div>" "$1"
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
	shift
	printf "<table>\n"
	print_row () {
		columns=${1#\#TABLE}
		IFS=$TAB
		echo "<tr>"
		for column in $columns; do
			# Problem? Use a bashism!
			if [ -n "${column// }" ]; then
				echo "<${2:-td}>$column</${2:-td}>"
			fi
		done
		echo "</tr>"
	}

	echo "<thead>"
	print_row "$1" "th"
	printf "</thead>\n<tbody>\n"
	while read -r row; do
		print_row "$row"
	done <<< "$content"

	echo "</tbody></table>"
}

# PREDEFINED TRANSFORMERS

# This will be called before any *tranforming* has taken place
# It is useful for defining custom syntax as well as 
# following the markdown syntax.
# Its counterpart: final_transformer is also available.
initial_transformer () {
	out="$1"

	# TODO: Use prebuilt parser?
	# Markdown Links
	while read -r a; do
		url=$( echo "$a" | grep -Po '(?<=\().*(?=\))' )
		text=$(echo "$a" | grep -Po '(?<=\[)[^\]]+(?=\])')
		mod="<a href=\"${url}\">${text}</a>"
		replaceList+=( "$a" "$mod" )
		out=${out/"$a"/"$mod"}
	done < <( grep -Po '\[[^\]]+\]\(.*?\)' <<< "$out" )

	# Markdown Code
	while read -r -d $'\0' match; do
		v=${match#\`\`\`}
		v=${v%\`\`\`}
		lang=$( grep -Po -m1 '```\K.*' <<< "$match" )
		v=${v#$lang}
		v=${v#$'\n'}
		if [ -n "$lang" ]; then
			v=$( __syntax_hl "$v" "$lang" ) 
			# __syntax_hl only adds ~100ms
			# __SLOW_syntax_hl makes the program take 10s instead of 0.5s
		else
			v="<pre><code lang=\"$lang\">$v</code></pre>"
		fi
		out=${out/"$match"/"$v"}
	done < <(grep -Pzo '(?s)```.*?```' <<< "$out")

	while read -r a; do
		v=${a#\`}
		v=${v%\`}
		out=${out/"$a"/<code>$v</code>}
	done < <(grep -Po '`.*?`' <<< "$out")

	# Headers 
	while read -r a; do
		h=${a%% *}
		out=${out/"$a"/<h${#h}>${a#* }</h${#h}>}
	done < <(grep -Po '^#+ .*' <<< "$out")

	echo "$out"
}

final_transformer () {
	out="$1"
	while read -r a; do
		out=${out/"$a"/<a href=\"$a\">$a</a>}
	done < <(grep -Po '(?<!")https?://\S+' <<< "$out")
	echo "$out"
}
