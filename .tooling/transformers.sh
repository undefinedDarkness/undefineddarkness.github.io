#!/usr/bin/env bash

# UTILITIES:

# Generate syntax highlighted html code
# using Vim's :TOHtml command

# TRANSFORMERS:

# Put the content in a box. Simple enough
box () {
	printf "<div class='box'>\n%s\n</div>" "$1"
}

# Folded text
f () {
	content=$1
	shift
	trimmed=$*
	trimmed=${trimmed#'#f '}
	printf "
<details>
	<summary>
		<h4>%s</h4>
	</summary>
	<p>
		%s
	</p>
</details>" "${trimmed}" "$content"
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

# TODO: Eliminate script and use css only
# https://css-tricks.com/css-only-carousel/
# TODO: Allow multile carousels in one page
carousel () {
	script="const slideGallery = document.querySelector('.slides');
const slides = slideGallery.querySelectorAll('div');
const thumbnailContainer = document.querySelector('.thumbnails');
const slideCount = slides.length;
const slideWidth = slides[0].offsetWidth;

const highlightThumbnail = () => {
  thumbnailContainer
    .querySelectorAll('div.highlighted')
    .forEach(el => el.classList.remove('highlighted'));
  const index = Math.floor(slideGallery.scrollLeft / slideWidth);
  thumbnailContainer
    .querySelector('div[data-id=\"' + index + '\"]')
    .classList.add('highlighted');
};

const scrollToElement = el => {
  const index = parseInt(el.dataset.id, 10);
  slideGallery.scrollTo(index * slideWidth, 0);
};

thumbnailContainer.innerHTML += [...slides]
  .map((slide, i) => '<div data-id=\"' + i  + '\"></div>')
  .join('');

thumbnailContainer.querySelectorAll('div').forEach(el => {
  el.addEventListener('click', () => scrollToElement(el));
});

slideGallery.addEventListener('scroll', e => highlightThumbnail());

highlightThumbnail();"
	content="$1"
	printf '
	<div class="gallery-container">
	<div class="thumbnails"></div>
		<div class="slides">\n'
	while read -r line; do
		printf '<div><img src="%s"></div>' "${line%'<br/>'}"
	done <<< "$content"
	printf '</div>
	</div>
	<script defer>%s</script>\n' "$script"
}

columns () {
	content="$1"
	printf '<div class="row>%s</div>' "$content"
}

table () {
	content="$1"
	shift
	#printf "<div class=\"ovr-x\">"
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
	#IFS=$TAB
	# shift
	for heading in "$@"; do
		# dbg ">>> ~ $heading"
		case "$heading" in
			'#TABLE')
				continue
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
	dbg "Found classes: '$classes' and headings: '$headings'"
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
	echo "</tbody></table>"
}
