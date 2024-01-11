#!/bin/bash

# Dummy fallback
loaded_hljs=1
__syntax_hl_dummy () {
	loaded_hljs=1
	cat
}

# Real one
__syntax_hl_highlight () {

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

escape_code_block () {
	local -n retptr=${1}
	ptr=$retptr
	ptr=${ptr//'#'/'&#35;'}
	ptr=${ptr//'<'/'&lt;'}
	ptr=${ptr//'>'/'&gt;'}
	ptr=${ptr//'['/'&lsqb;'}
	ptr=${ptr//']'/'&rsqb;'}
	ptr=${ptr//'='/'&equals;'}
	ptr=${ptr//'*'/'&#42;'}
	retptr=$ptr
}

# Check if highlight is installed, if so use it else use the other thing
syntax_hl_backend="__syntax_hl_dummy"
if command -v highlight &> /dev/null; then
	syntax_hl_backend="__syntax_hl_highlight"
fi

slugify () {
    echo "$1" | iconv -c -t ascii//TRANSLIT | sed -E 's/[~^]+//g' | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr A-Z a-z
}

# This will be called before any *tranforming* has taken place
# It is useful for defining custom syntax as well as 
# following the markdown syntax.
# Its counterpart: final_transformer is also available.
initial_transformer () {
	local -n prefix_ptr=${1}
	local -n output_ptr=${2}
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
            output_ptr+="</li>$NEWL</ul><br/>"
			continue
		fi

		case "$line" in

			# For HTML Comments
			'<!--'*'-->')
				output_ptr+="${line}$NEWL"
				continue
			;;

			# For reader mode.
			'</'*'>'*)
				inside_transformer_block=0
				output_ptr+="${line}$NEWL"	
				# printf '%s$NEWL' "$line"
				continue
			;;

			# HTML Block entirely in one line
			'<'*'>'*'</'*'>')
				(( inside_code_block == 0 )) && output_ptr+="$line"
			;;

			# HTML Block over multiple lines
			'<'*'>'*)
				if (( inside_code_block == 0 )); then
					inside_transformer_block='verbatim'
					output_ptr+="$line"
				fi
			;;

			# Primary Article Heading
			'# '*)
				if ! (( inside_code_block )); then
					output_ptr+="<header>$NEWL<h1>${line#'# '}</h1>$NEWL</header>$NEWL" #${line#'# '}"
					continue
				fi
				;;

			# Other heading levels
			'## '* | '### '* | '#### '* | '##### '* | '###### '*)

				# End previous paragraph if opened
				if (( inside_paragraph )); then
					inside_paragraph=0
					output_ptr+="</p>$NEWL"
				fi
				
				if ! (( inside_code_block )); then
					local level=${line%% *}
                    local id=$(slugify "${line#$level }")
					output_ptr+="<h${#level} id=\"${id}\">${line#"$level "}</h${#level}>$NEWL" # "${#level}" "$id" "${line#"$level "}" "${#level}"
					inside_paragraph=1
					output_ptr+="<p>$NEWL"	
					# printf '<p>$NEWL'
					continue
				fi
				;;

			# Horizontal Line
			'---' | '___' | '***' )
				(( inside_code_block == 0 )) && output_ptr+="<hr />$NEWL" && continue # printf '<hr />$NEWL' && continue
				;;
			'#~'*)
				(( inside_code_block == 0 )) && output_ptr+="&num;${line#'#~ '}$NEWL" && continue
				;;
            '#END '*)
                (( inside_code_block == 0 )) && inside_transformer_block=0 && output_ptr+="$line" && skip_forced_newline=1
                ;;
            #'\(')
			#	(( inside_code_block == 0 )) && inside_transformer_block='math' && printf '%s' "$line"
			#	;;
			'#verbatim'*|'#VERBATIM'*)
                (( inside_code_block == 0 )) && inside_transformer_block='verbatim' && output_ptr+="$line"
                ;;
			#'\)')
			#	(( inside_code_block == 0 )) && inside_transformer_block='' && printf '%s' "$line" && skip_forced_newline=1
			#	;;
            '#'*)
                (( inside_code_block == 0 )) && inside_transformer_block=1 && output_ptr+="$line" && skip_forced_newline=1
                ;;
			'> '*)
				(( inside_code_block == 0 )) && output_ptr+="<q>${line#'> '}</q><br/>$NEWL" || output_ptr+="$line"
				continue
				;;
			'```'*)

				if (( inside_code_block )); then
					dbg "--- END CODE BLOCK ---"

					if [ "$language" = "mermaid" ]; then
						output_ptr+="<div class=\"mermaid\">$ptr</div>" # "$ptr"
						loaded_mermaid=1
					elif [ "$language" = "math" ]; then
						output_ptr+="\[$NEWL$ptr$NEWL\]" # "$ptr"
						loaded_mathjax=1
					elif [ -z "$language" ]; then
						# Escape charachters that get caught by `final_transformer` later on
						# TODO: Convert to single sed call
						escape_code_block ptr
						output_ptr+="${ptr}</code>$NEWL</pre>$NEWL"
					else 
						ptr=$($syntax_hl_backend "$language" <<< "$ptr")
						escape_code_block ptr
						output_ptr+="${ptr}$TAB</code>$NEWL</pre>$NEWL"	
						# printf '$TAB</code>$NEWL</pre>$NEWL'
					fi
					
					unset ptr
					unset language
					inside_code_block=0
					continue
				else
					local ptr=''
					local language=${line#'```'}
					inside_code_block=1
					if [[ "$language" != "mermaid" &&  "$language" != "math" ]]; then 
						
						output_ptr+="<pre>$NEWL<code class=\"language-${language:-plaintext}\">"
					fi
					dbg "--- CODE BLOCK ($language) ---"
					continue
				fi
				;;
			'>>>'*)
				if ! (( inside_code_block )); then	

				if ! (( inside_quote_block )); then
					inside_quote_block=1
					output_ptr+="<figure>$NEWL<blockquote>$NEWL"
					continue
				else
					inside_quote_block=0
					local caption=${line#'>>>'}
					caption=${caption# }
					output_ptr+="</blockquote>$NEWL"
					[ -n "$caption" ] && output_ptr+="<figcaption>${caption}</figcaption>$NEWL" # "$caption"
					output_ptr+="</figure>$NEWL"
				fi

				fi
				;;
			'- '*)
				if ! (( inside_list )); then
					inside_list=1
					output_ptr+="<ul>$NEWL"
					output_ptr+="<li>${line#'- '}"
				else
					output_ptr+="</li>$NEWL<li>${line#'- '}"
				fi
				;;
			*)
				if (( inside_code_block == 0 )); then
					output_ptr+="$line"
				fi
				;;
		esac
		
		if (( inside_code_block == 1 )); then
			ptr+=$line$NEWL
			dbg "$TAB++ $line"
		else
			if (( skip_forced_newline == 1)) || [ "$inside_transformer_block" == "math" ] || [[ "$inside_transformer_block" == 'verbatim' ]]; then
				output_ptr+="$NEWL"; 
				dbg "Skipping newline for '$line'"
				continue
			fi

			if ! [[ "$line" == '<'* ]]; then
				output_ptr+="<br/>$NEWL"
			fi
		fi
	done 

	if (( loaded_mermaid )); then 
		prefix_ptr+='
		<!-- MERMAID LOADING -->
		<script defer src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js" onload="mermaid.initialize({startOnLoad:true})"></script>
		<script>document.addEventListener("DOMContentLoaded", () => mermaid.initialize({startOnLoad:true}))</script>'
	fi

	if (( loaded_mathjax )); then
		prefix_ptr+="
		<!-- KATEX LOADING -->
		<script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.4/dist/katex.min.js\"></script>
		<script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.4/dist/contrib/auto-render.min.js\" onload=\"
			renderMathInElement(document.body, {
				output: 'mathml'
			});
		\"></script>
		"
	fi

	if (( loaded_hljs )); then
		prefix_ptr+='
		<!-- HIGHLIGHTJS LOADING -->
		<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/monokai.min.css">
		<script defer src="//cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.7.0/build/highlight.min.js" onload="hljs.highlightAll();"></script>
		'
	fi
}
