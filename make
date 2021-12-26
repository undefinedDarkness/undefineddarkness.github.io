#!/usr/bin/env bash
#shellcheck disable=2059

# Toad:
# This is meant to be my super minimal SSG and meant to only fulfill my needs and do nothing more

# Configuration
port=5000

# Extract relevant parts of the template
buffer=
pre=
post=
while read -r line; do
	case "$line" in
		"!CONTENT!")
			pre=$buffer
			buffer=
			continue
			;;
	esac
	buffer+="$line"$'\n'
done < ./template.html
post=$buffer

# Extract sidebar from the index
# sidebar=$(grep -Ezo -m1 '<nav>.*</nav>' ./index.html | tr -d '\0')

server="deno run --unstable -A ./tool/server/server.ts --port=$port --log=false --live=false "

# bash only and im lazy :(
get-modified-time () {
	o=$(stat -c '%y' $1)
	echo "${o%.*}"
}

# General multi purpose build process
process () {
	out=${2/.${out#*.}/.html}

	mkdir -p "$(dirname "$out")"
	printf "Building \033[34m%s\033[0m \033[32m->\033[0m \033[34m%s\033[0m\n" "$1" "$out"

	x=${out%%.html}
	x=${x##out/}
	header=${pre/\!TITLE\!/$x}
	t=$(get-modified-time $1)
	header=${header/\!TIME\!/$t}
	printf '%s' "$header" > "$out"
	$3 "$1" 1>> "$out" # Generate HTML -- CHANGE
	printf '%s' "$post" >> "$out" # Output To File
}

# Primary Build Function - handles every file
build () {
	out=${1/src/out}

	case "${out#*.}" in
		# HTML
		"html")
			cp -fv "$1" "$out"
			printf '\n'
			;;
		# Pond's Format
		# + Markdown
		"fmt.txt"|"md")
			process "$1" "$out" 'bash tool/pond.sh'
			;;
	esac

}

get-title () {
	case "${1#*.}" in
		# HTML
		"html")
			grep -Po -m1 '<h1>\K.*(?=<\/h1>)' $1
			;;
		# Pond's Format
		# + Markdown
		"fmt.txt"|"md")
			grep -Po -m1 '<h1>\K.*(?=<\/h1>)|# \K.*' $1 
			;;
	esac
}

year=2021
get-date () {
	month=$4
	day=$5
	time=$6
	printf "$day-$month-$year"
}

gen-index () {
	cp ./src/index.html ./out/index.html # override with format
	find src/ -type d -not -path 'src/' | while read -r folder; do
		posts=''
		while read -r file_l; do
			[[ $file_l == total* ]] && continue
			file=${file_l##* }
			title=$(get-title $folder/$file)
			f_date=$(get-date $file_l)
			posts="$posts<li>${f_date}	<a href=\"${folder##*/}/${file/.md/.html}\">${title}</a></li>"
		done < <(ls --sort=time --time=creation -1 -o -g $folder)
		sed -i "s@!POSTS-$(tr '[:lower:]' '[:upper:]' <<< "${folder##*/}")!@${posts}@g" ./out/index.html #> ./out/index.html
	done
	printf "Generated Article Index\n"
	exit 0
}

post-build () {
		gen-index 
}

optimize-image () {
	file=${1%%:*}
	image=${1#*:}
	image_path=$image
	[[ $image == *.webp ]] && return
	echo "Converting $image to WEBP"
	if [[ $image == https://* ]]; then
		echo "Downloading"
		image_path=/assets/images/dump/$(cat /proc/sys/kernel/random/uuid).webp
		curl -L -o .$image_path --progress-bar $image
	fi
	echo "Saved output to $image_path"
	# if ! [ -f $image_path ]; then
	# 	return
	# fi
	out_image_path=${image_path/.png/.webp}
	out_image_path=${out_image_path/.jpg/.webp}
	cwebp .$image_path -o .$out_image_path -q 90
	initial_size=$(du .$image_path)
	final_size=$(du .$out_image_path)
	if (( ${final_size%%	*} > ${initial_size%%	*} )); then
		echo 'WEBP Conversion war larger than original image!!!'
		rm .$out_image_path
		out_image_path=$image_path
		return
	fi
	echo ">>>> s!$image_path!$out_image_path!g $file"
	sed -i "s!$image!$out_image_path!g" $file
	#if [[ $image_path != $out_image_path ]]; then
	#	rm .$image_path
	#fi
	printf '\n\n'
}

case $1 in

	# Serve files with hot reloading
	live)
		pkill "${server% *}"
		$server &  
		

		# Paths to watch
		(
		find src -name "*.md" -or -name '*.html'#  -not -name 'index.html'
		realpath ./template.html
		realpath assets/styles.css
		find tool -name "*.sh"
		echo $0
		) | entr ./make # build /_
		;;

	# Serve without hot realoading
	serve)
		$server
		;;

	optimize-images)
		mkdir -p assets/images/dump
		while read -r line; do
			optimize-image "$line" 
			# echo $line
			#break
		done < <(grep -Por '(\(|")\K\S+\.png' src | grep -v '/favicon.png')
		;;

	*)
		mkdir -p src out
		while read -r file; do
			case "$file" in
				'src/*.md')
					continue
					;;
				'src/*.html')
					continue
					;;
				'src/**/*.html')
					continue
					;;
				'src/**/*.md')
					continue
					;;
				*)
					build "$file" &
			esac
		done < <(find src -name "*.md" -or -name "*.html")

		post-build

		pkill --signal USR1 deno
		printf "Finished!\n"
	;;
esac
