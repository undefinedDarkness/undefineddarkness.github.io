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
# . "$( dirname "$0" )"/helpers.sh

# UTILITIES:

# Generate syntax highlighted html code
# using Vim's :TOHtml command

__syntax_hl () {
	printf "<pre>"
	highlight\
		--syntax "$2"\
		-q\
		--force \
		--stdout \
		-l \
		-f \
		--inline-css \
		--pretty-symbols \
		--config-file=assets/zenburn.theme \
		--no-version-info <<< "$1"
	printf "</pre>"
}

# Replaced. {{{
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
# }}}

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
	line_no=0

	code_lang=
	code_block=
	code_content=

	used_detail_tag=
	
	#line=$()

	IFS=''
	while read -r line; do
		#line=$( <<< "$line")
		
		line_no=$(( line_no + 1 ))
		case "$line" in
			# Headings
			"# "*|"## "*|"### "*|"#### "*|"##### "*|"###### "*)
				dbg ">> Found a heading"
				heading=${line%% *}
				if [ "${#heading}" -eq 2 ]; then
					echo "${used_detail:+</p></details>}
<details${used_detail:- open}>
<summary><h2>${line##${heading} }</h2></summary><p>" # cheeky uwu
					used_detail=" " # this bit makes sure the first one is open.
				else
					echo "<h${#heading}>${line##${heading} }</h${#heading}>"
				fi
				;;
			
			# Block of code
			'```'*)
				dbg ">> Found a code block"
				# Not currently in code block
				if [ -z "$code_block" ]; then
					code_lang=${line#'```'}
					code_block=1
				else
					__syntax_hl "${code_content#-$NEWL}" "$code_lang"
					# Reset state
					code_content=
					code_block= 
					code_lang=
				fi
				;;

			# Nothing, just reprint
			*)
				[ -z "$code_block" ] && echo "$line"
		esac
		
			
		if [ -n "$code_block" ] && [ -n "$code_content" ]; then
			#shellcheck disable=2027
			code_content="$code_content"$NEWL"$line"
		elif [ -n "$code_block" ]; then
			code_content="-"
		fi
	done <<< "$1" | perl -p \
	-e '
		s!\`(.*?)\`!<code>\1</code>!g;
		s!\*\*(.*?)\*\*!<b>\1</b>!g;
		s!\[(.*?)\]\((.*?)\)!<a href="\2">\1</a>!g;
		s!\*(.*?)\*!<i>\1</i>!g;
		s!(?<\!")(https?://[^<\s]+)!<a href="\1">\1</a>!g;
		s!~(.*?)~!<strike>\1</strike>!g
	' # Markdown has returned to its roots :euphoria:


}


