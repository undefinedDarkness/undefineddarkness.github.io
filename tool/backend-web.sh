#!/usr/bin/env bash

# UTILITIES:

# Generate syntax highlighted html code
# using Vim's :TOHtml command

__syntax_hl () {
	printf "<pre class=\"code\" data-language=\"%s\"><code>" "$2"
	highlight\
		--syntax "$2"\
		-q\
		--force \
		--stdout \
		-f \
		--inline-css \
		--pretty-symbols \
		--config-file=assets/zenburn.theme \
		--no-version-info <<< "$1"
	printf "</code></pre>"
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
	printf "<details><summary><h3>%s</h3></summary>%s</details>" "${*#'#f '}" "$content"
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
	line_no=0

	code_lang=
	code_block=
	code_content=

	quote_block=

	in_list=
	
	header_no=0

	IFS=''
	while read -r line; do
		line_no=$(( line_no + 1 ))
		
		# Empty line & is in list
		if [ -z "$line" ] && [ -n "$in_list" ]; then
			dbg '<<< Ending list'
			printf '</li></ul>' # close the last item and the list itself
			in_list=
			continue
		fi

		case "$line" in
			# Lists
			'- '*)
				line=${line#- }
				if [ -z "$in_list" ]; then
					# Open a new list and start a new item in that list.
					printf "<ul><li>%s\n"  "$line"
					in_list=1
				else
					printf "</li><li>%s\n" "$line"
				fi
			;;
			# Headings
			'#-'*|"# "*|"## "*|"### "*|"#### "*|"##### "*|"###### "*)
				dbg ">> Found a heading"
				header_no=$((header_no + 1))
				heading=${line%% *}
				echo "<h${#heading} id='heading-${header_no}'>${line#${heading}* }</h${#heading}>"
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
			# Block quote
			'>>>'*)
				dbg '>> Found a quote block'
				if [ -z "$quote_block" ]; then # is not in quote block
					quote_block=1
					printf "<blockquote>"
				else # is in quote block
					quote_block=0
					printf "</blockquote>"
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
		s!`(.+?)`!<code>\1</code>!g;
		s!\*\*(.+?)\*\*!<b>\1</b>!g;
		s@!\[(.+?)\]\((.+?)\)@<img src="\2" alt="\1" title="\1" loading="lazy"></img>@g;
		s!\[(.+?)\]\((.+?)\)!<a href="\2">\1</a>!g;
		s!\*(.+?)\*!<i>\1</i>!g;
		s!(?<\!")(https?://[^<\s\),]+)!<a href="\1">\1</a>!g;
		s!~~(.+?)~~!<strike>\1</strike>!g;
		s!{(.+?)}!<span class="reset">\1</span>!;
		s!^> (.+)!<q>\1</q>!g;' # Markdown has returned to its roots :euphoria:


}


