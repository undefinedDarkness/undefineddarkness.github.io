#!/usr/bin/env sh

example="ABCDEFGHIJKLM\nNOPQRSTUVWXYZ\nabcdefghijklm\nnopqrstuvwxyz\n1234567890\n!@$\%(){}[]"

build () {
	font=$1
	convert \
		-size 350x350 \
		xc: \
		-gravity center\
		-pointsize 32 \
		-font "$font" "${2:-}"\
		-annotate +0+0 \
		"$example" -flatten "$font".png 
}

# rm -v ./*.png
fonts='Sarasa-Term-K Poppins-Regular ETBembo-RomanLF Lexend-Deca-Regular Piazzolla-Regular Merriweather-Regular IBM-Plex-Sans-Regular JuliaMono-Regular JetBrains-Mono-Regular IBM-Plex-Mono-Regular Libre-Baskerville Merriweather-Regular Roboto Roboto-Mono-Regular Recursive-Sans-Linear-Light Ubuntu-Regular'
for font in $fonts; do
	build "$font" &
done

bitmaps="Unifont-Nerd-Font-Complete CozetteVector"
for font in $bitmaps; do
	build "$font" "+antialias" &
done
