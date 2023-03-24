#!/bin/bash


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
	local loaded_mathjax=0
	local skip_forced_newline=0
	
	while read -r line; do
		skip_forced_newline=0

		if [ -z "${line/ /}" ] && (( inside_list )) && ! (( inside_code_block )) && ! (( inside_quote_block )); then
			inside_list=0	
			dbg "SKIPPING LINE : $line"
            printf '</li>\n</ul><br/>'
			continue
		fi

		case "$line" in

			# For HTML Comments
			'<!--'*'-->')
				printf '%s\n' "$line"
				continue
			;;

			# For reader mode.
			'</'*'>'*)
				inside_transformer_block=0
				printf '%s\n' "$line"
				continue
			;;

			# HTML Block entirely in one line
			'<'*'>'*'</'*'>')
				(( inside_code_block == 0 )) && printf '%s' "$line"
			;;

			'<'*'>'*)
				if (( inside_code_block == 0 )); then
					inside_transformer_block='verbatim'
					printf '%s' "$line"
				fi
			;;
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
                    local id=${line#"$level "}
					id=${id,,}
                    id=${id/' '/'-'}
					printf '<h%d id="%s">%s</h%d>\n' "${#level}" "$id" "${line#"$level "}" "${#level}"
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
                (( inside_code_block == 0 )) && inside_transformer_block=0 && printf '%s' "$line" && skip_forced_newline=1
                ;;
            #'\(')
			#	(( inside_code_block == 0 )) && inside_transformer_block='math' && printf '%s' "$line"
			#	;;
			'#verbatim'*|'#VERBATIM'*)
                (( inside_code_block == 0 )) && inside_transformer_block='verbatim' && printf '%s' "$line"
                ;;
			#'\)')
			#	(( inside_code_block == 0 )) && inside_transformer_block='' && printf '%s' "$line" && skip_forced_newline=1
			#	;;
            '#'*)
                (( inside_code_block == 0 )) && inside_transformer_block=1 && printf '%s' "$line" && skip_forced_newline=1
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
					elif [ "$language" = "math" ]; then
						printf "\[\n%s\n\]" "$buffer"
						loaded_mathjax=1
					elif [ -z "$language" ]; then
						buffer=${buffer//'#'/'&#35;'}
						buffer=${buffer//'<'/'&lt;'}
						buffer=${buffer//'>'/'&gt;'}
						buffer=${buffer//'['/'&lsqb;'}
						buffer=${buffer//']'/'&rsqb;'}
						buffer=${buffer//'='/'&equals;'}
						printf '%s</code>\n</pre>\n' "${buffer}"
					else 
						__syntax_hl "$language" <<< "$buffer"
						printf '\t</code>\n</pre>\n'
					fi
					
					unset buffer
					unset language
					inside_code_block=0
					continue
				else
					local buffer=''
					local language=${line#'```'}
					inside_code_block=1
					if [[ "$language" != "mermaid" &&  "$language" != "math" ]]; then 
						printf '<pre>\n\t<code>'
					fi
					dbg "--- CODE BLOCK ($language) ---"
					continue
				fi
				;;
			'>>>'*)
				if ! (( inside_code_block )); then	

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
			if (( skip_forced_newline == 1)) || [ "$inside_transformer_block" == "math" ] || [[ "$inside_transformer_block" == 'verbatim' ]]; then
				printf '\n'; 
				dbg "Skipping newline for '$line'"
				continue
			fi

			if ! [[ "$line" == '<'* ]]; then
				printf '<br/>\n'
			fi
		fi
	done 

	if (( loaded_mermaid )); then 
		printf '
		<!-- MERMAID LOADING -->
		<script defer src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
		<script>document.addEventListener("DOMContentLoaded", () => mermaid.initialize({startOnLoad:true}))</script>'
	fi

	if (( loaded_mathjax )); then
		printf "
		<!-- KATEX LOADING -->
		<script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.4/dist/katex.min.js\"></script>
		<script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.4/dist/contrib/auto-render.min.js\" onload=\"
			renderMathInElement(document.body, {
				output: 'mathml'
			});
		\"></script>
		"
	fi
}
