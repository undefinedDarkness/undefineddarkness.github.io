#!/bin/bash

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
		s!\[\[man:(.+?)\]\]!<a href="https://man.openbsd.org/\1">manpage</a>!g;
		s!\[(.+?)\]\((.+?)\)!<a href="\2">\1</a>!g;
		s!\*(.+?)\*!<i>\1</i>!g;
		s!(?<\!")(https?://[^<\s\),]+)!<a href="\1">\1</a>!g;
		s!~~(.+?)~~!<strike>\1</strike>!g;
        s!==(.+?)==!<mark>\1</mark>!g;
	' <<< "$content"
}
