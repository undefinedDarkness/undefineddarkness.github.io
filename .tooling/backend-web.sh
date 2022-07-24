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

# TRANSFORMERS:

# Put the content in a box. Simple enough
box () {
	printf "<div class='box'>\n%s\n</div>" "$1"
}

# Folded text
f () {
	content=$1
	shift
	printf "<details open>\n<summary>%s</summary>\n<p>\n%s\n</p>\n</details>\n" "${*#'#f '}" "$content"
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

verbatim () {
    printf '%s' "$1"  
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
	IFS=$NEWL
	local inside_list=0
	local inside_code_block=0
	local inside_quote_block=0
	local inside_paragraph=0
    local inside_transformer_block=0
	local loaded_mermaid=0
	
	while read -r line; do

		if [ -z "${line/ /}" ] && (( inside_list )) && ! (( inside_code_block )) && ! (( inside_quote_block )); then
			inside_list=0	
			dbg "SKIPPING LINE : $line"
            printf '</li>\n</ul><br/>'
			continue
		fi

		case "$line" in
			# For reader mode.
			'# '*)
				if ! (( inside_code_block )); then
					printf '<header>\n<h1>%s</h1>\n</header>\n' "${line#'# '}"
					continue
				fi
				;;
			'## '* | '### '* | '#### '* | '##### '* | '###### '*)

				if (( inside_paragraph )); then
					inside_paragraph=0
					printf '</p>\n'
				fi
				
				if ! (( inside_code_block )); then
					local level=${line%% *}
                    local id=${line,,}
                    id=${line/' '/'-'}
					printf '<h%d id="%s">%s</h%d>\n' "${#level}" "$id" "${line#"$level"}" "${#level}"
					inside_paragraph=1
					printf '<p>\n'
					continue
				fi
				;;
			'---' | '___' | '***' )
				(( inside_code_block == 0 )) && printf '<hr />\n' && continue
				;;
			'#~'*)
				(( inside_code_block == 0 )) && printf '&num;%s\n' "${line#'#~'}" && continue
				;;
            '#END '*)
                (( inside_code_block == 0 )) && inside_transformer_block=0 && printf '%s' "$line"
                ;;
            '#verbatim'*|'#VERBATIM'*)
                (( inside_code_block == 0 )) && inside_transformer_block='verbatim' && printf '%s' "$line"
                ;;
            '#'*)
                (( inside_code_block == 0 )) && inside_transformer_block=1 && printf '%s' "$line"
                ;;
			'> '*)
				(( inside_code_block == 0 )) && printf '<q>%s</q><br/>\n' "${line#'> '}" || printf '%s' "$line"
				continue
				;;
			'```'*)

				if (( inside_code_block )); then
					dbg "--- END CODE BLOCK ---"

					if [ "$language" = "mermaid" ]; then
						printf '<div class="mermaid">%s</div>' "$buffer"
						loaded_mermaid=1
					elif [ -z "$language" ]; then
						printf '%s</code>\n</pre>\n' "${buffer//'#'/'&#35;'}"
					else 
						# dbg 'Passing to syntax-hl: %s' "$buffer"
						__syntax_hl "$language" <<< "$buffer"
						printf '</code>\n</pre>\n'
					fi
					
					unset buffer
					unset language
					inside_code_block=0
					continue
				else
					local buffer=''
					local language=${line#'```'}
					inside_code_block=1
					[ "$language" != "mermaid" ] && printf '<pre>\n<code>'
					dbg "--- CODE BLOCK ---"
					continue
				fi
				;;
			'>>>'*)
				if ! (( inside_quote_block )); then
					inside_quote_block=1
					printf '<figure>\n<blockquote>\n'
					continue
				else
					inside_quote_block=0
					local caption=${line#'>>>'}
					caption=${caption# }
					printf '</blockquote>\n'
					[ -n "$caption" ] && printf '<figcaption>%s</figcaption>\n' "$caption"
					printf '</figure>\n' 
				fi
				;;
			'- '*)
				if ! (( inside_list )); then
					inside_list=1
					printf '<ul>\n'
					printf '<li>%s' "${line#'- '}"
				else
					printf '</li>\n<li>%s' "${line#'- '}"
				fi
				;;
			*)
				if (( inside_code_block == 0 )); then
					printf '%s' "$line"
				fi
				;;
		esac
		
		if (( inside_code_block == 1 )); then
			buffer+=$line$NEWL
			dbg "++ $line"
		else
			if [[ "$line" == '#'* ]] || [[ "$line" == "<!--"*"-->" ]] || [[ "$inside_transformer_block" == 'verbatim' ]]; then
				printf '\n'; 
				continue
			fi

			if ! [[ "$line" == '<'* ]]; then
				printf '<br/>\n'
			fi
		fi
	done 

	if (( loaded_mermaid )); then 
		printf '<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
<script>mermaid.initialize({startOnLoad:true});
</script>'
	fi
}

final_transformer() {
	local content=$1

	while read -r match; do
		re=${match//'*'/'&ast';}
		re=${re//'<'/'&lt;'}
		re=${re//'>'/'&gt;'}
		re=${re/'`'/'<code>'}
		re=${re/'`'/'</code>'}
		content=${content/"$match"/"$re"}
	done < <(grep -Po "\`.*?\`" <<< "$content")

	LC_ALL=C perl -pe '
		s!\*\*(.+?)\*\*!<b>\1</b>!g;
		s@!\[(.*?)\]\((.+?)\)@<img src="\2" alt="\1" title="\1" loading="lazy" />@g;
		s!\[(.+?)\]\((.+?)\)!<a href="\2">\1</a>!g;
		s!\*(.+?)\*!<i>\1</i>!g;
		s!(?<\!")(https?://[^<\s\),]+)!<a href="\1">\1</a>!g;
		s!~~(.+?)~~!<strike>\1</strike>!g;
        s!==(.+?)==!<mark>\1</mark>!g;
	' <<< "$content"
}
