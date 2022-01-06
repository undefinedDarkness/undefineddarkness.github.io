#!/usr/bin/env bash

# UTILITIES:

# Generate syntax highlighted html code
# using Vim's :TOHtml command

__syntax_hl () {
	highlight\
		--syntax "$1"\
		-q\
		--force \
		--stdout \
		-f \
		--inline-css \
		--no-trailing-nl \
		--pretty-symbols \
		--config-file=assets/syntax.theme \
		--no-version-info | sed 's/*/\&ast;/g;'
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
	printf '%s' "${existing_styles[*]}" > ./assets/styles.css
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

# Folded text
f () {
	content=$1
	shift
	printf "<details><summary><h3>%s</h3></summary>\n%s</details>" "${*#'#f '}" "$content"
}

# Right align text
right_align () {
	printf "<div style=\"text-align: right\">\n%s\n</div>" "$1"
}

# Center align text while preserving indentation: useful for ascii art
preserve_center () {
	printf "<div class='txt-c'>%s</div>" "$1"
}

# Center align without preserving.
center () {
	printf "<p style=\"text-align:center\">\n%s\n</p>" "$1"
}

# Create a table with
# the columns defined by a tab seperated list
# and the rows denoted by newlines
table () {
	content="$1"
	shift
	printf "<div class=\"ovr-x\">"
	print_row () {
		columns=${1#\#TABLE}
		IFS=$TAB
		echo "<tr>"
		for column in $columns; do
			if [ -n "${column// }" ]; then
				echo "<${2:-td}>$column</${2:-td}>"
			fi
		done
		echo "</tr>"
	}

	headings=""
	classes=""
	IFS=$TAB
	for heading in $1; do
		case "$heading" in
			'#TABLE')
				;;
			.*)
				classes="$classes ${heading#.}"
				continue
				;;
			*)
				headings="$headings	$heading"
				;;
		esac
	done
	echo "<table class=\"$classes\">"
	if [ -n "${headings/ /}" ]; then
		printf "<thead>"
		print_row "$headings" "th"
		printf "</thead>"
	fi

	printf "<tbody>"
	while read -r row; do
		print_row "$row"
	done <<< "$content"
	echo "</tbody></table></div>"
}

# PREDEFINED TRANSFORMERS

# This will be called before any *tranforming* has taken place
# It is useful for defining custom syntax as well as 
# following the markdown syntax.
# Its counterpart: final_transformer is also available.
initial_transformer () {
	local inside=""
	IFS=$NEWL
	while read -r line; do

		if [ -z "${line/ /}" ] && [[ $inside == *' list '* ]] && ! [[ $inside == *' code-block '* ]]; then
				inside=${inside/' list '/}
				printf '</ul><br/>'
				continue
		fi
		
		case "$line" in
			'# '* | '## '* | '### '* | '#### '* | '##### '* | '###### '*)
				if ! [[ "$inside" == *' code-block '* ]]; then
					local level=${line%% *}
					printf '<h%d>%s</h%d>\n' "${#level}" "${line#"$level"}" "${#level}"
					continue
				fi
				;;
			'#-'*)
				printf '<h3>%s</h3>\n' "${line#'#-'}"
				continue
				;;
			'#~'*)
				printf '&num;%s\n' "${line#'#~'}"
				continue
				;;
			'> '*)
				printf '<q>%s</q><br/>\n' "${line#'> '}"
				continue
				;;
			'```'*)

				if [[ "$inside" == *' code-block '* ]]; then
					dbg 'Passing to syntax-hl: %s' "$buffer"
					__syntax_hl "$language" <<< "$buffer"
					unset buffer
					unset language
					inside=${inside/' code-block '/}
					printf '</code></pre>\n'
					continue
				else
					local buffer=''
					local language=${line#'```'}
					inside+=" code-block "
					printf '<pre><code>'
					continue
				fi
				;;
			'- '*)
				if ! [[ "$inside" == *' list '* ]]; then
					inside+=" list "
					printf '<ul>\n'
				fi
				printf '<li>%s</li>\n' "${line#'- '}"
				;;
			*)
				if ! [[ "$inside" == *' code-block '*  ]]; then
					printf '%s' "$line"
				fi
				;;
		esac
		
		if [[ "$inside" == *' code-block '*  ]]; then
			buffer+=$line$NEWL
		fi

		
		if [ -z "${inside/ /}" ]; then
			if [[ "$line" == '#'* ]]; then
				dbg "$line starts with #"
				printf '\n'; 
				continue
			fi

			if ! [[ "$line" == '<'* ]]; then
				printf '<br/>\n'
			fi
		fi
	done 
}

final_transformer() {
	perl -pe '
		s!`(.+?)`!<code>\1</code>!g;
		s!\*\*(.+?)\*\*!<b>\1</b>!g;
		s@!\[(.+?)\]\((.+?)\)@<img src="\2" alt="\1" title="\1" loading="lazy"></img>@g;
		s!\[(.+?)\]\((.+?)\)!<a href="\2">\1</a>!g;
		s!\*(.+?)\*!<i>\1</i>!g;
		s!(?<\!")(https?://[^<\s\),]+)!<a href="\1">\1</a>!g;
		s!~~(.+?)~~!<strike>\1</strike>!g;
		s!{(.+?)}!<span class="reset">\1</span>!;
	'
}
