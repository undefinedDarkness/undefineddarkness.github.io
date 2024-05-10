package require Thread


# Extract functions and comments before them
set pool [tpool::create -minworkers 4 -initcmd {
proc processCFile {file_path lk} {
	set f [open $file_path]
	set last_comment ""
	set output ""

	set within_fn 0
	set within_fn_name ""
	set within_fn_comment ""
	set within_fn_def ""
	set within_fn_type ""

	set block_end 0
	
	array set groups {}
	set group_prefixes [list "Draw" "Unload" "Image" "Load" "Set" "Is" "Get"]
	set added_to_group 0

	set c_types [list "int" "float" "double" "void" "bool"]

	while {[gets $f line] >= 0} {
		if { $line eq "" } { 
			if { $within_fn && $block_end } {
				set within_fn_def_with_hl [exec -- highlight --syntax c -f -q --force --stdout --inline-css --no-trailing-nl --pretty-symbol --no-version-info << $within_fn_def]
				if { $within_fn_type ni $c_types } {
					set within_fn_type "<a href='#$within_fn_type' onclick='openDetails(\"$within_fn_type\")'>$within_fn_type</a>"
				}

#				set within_fn_final "<details><summary>$within_fn_type $within_fn_name</summary><pre><code>$within_fn_def_with_hl</code></pre></details>"
				set within_fn_id "${file_path}_${within_fn_name}"
				set within_fn_final "<details><summary id='${within_fn_id}' data-loaded='false' onclick='ensureLoaded(this)'>$within_fn_type $within_fn_name</summary></details>"

				foreach prefix $group_prefixes {
					if {[string first $prefix $within_fn_name] != -1} {
						append groups($prefix) $within_fn_final
						set added_to_group 1
						break
					}
				}
				if { !$added_to_group } {
					append groups(Misc) $within_fn_final
				}

				set snippet_file [open "index-cache/${within_fn_id}.html" w]
				puts $snippet_file "$within_fn_def_with_hl" 
				close $snippet_file

				puts stderr "$file_path > $within_fn_name"
				set within_fn 0
				set block_end 0
			} else {
				continue
			}
		} elseif [regexp {^\/\/ } $line ] {
			append last_comment $line
		} elseif [regexp {^(\w+)\s(\w+)\([\w\s,*]+\)( \{)?$} $line match within_fn_type within_fn_name] {
			set within_fn 1
			set within_fn_def "$line"
			set within_fn_comment $last_comment
		} elseif { $within_fn } {
			append within_fn_def "$line\n" 
			if [regexp {^\}} $line ] {
				set block_end 1
			}
		}
	}

	foreach { key value } [array get groups] {
		if { $key eq "Unload" } {
			continue
		}
		append output "<h3>$key</h3>
		$value"
	}
	thread::mutex lock $lk
	puts "<section><h3>$file_path</h3>$output</section>"
	thread::mutex unlock $lk
	close $f
}
}]

proc processHeaderFile { fp } {
	set f [open $fp]
	set last_struct_name ""
	set last_struct ""
	set within_struct 0
	set defines "<ul>"
	set output ""
	while {[gets $f line] >= 0} {
		if { $line eq "" } {
			continue
		} elseif [regexp {^typedef (struct|enum)} "$line" ] {
			set last_struct "$line"
			set within_struct 1
		} elseif { $within_struct } {
			set last_struct "$last_struct\n$line"
			if [regexp {^\} (\w+);} "$line" match last_struct_name ] {
				append output "<details id='$last_struct_name'><summary>$last_struct_name</summary><pre><code>$last_struct</code></pre></details>"
				set within_struct 0
				set last_struct ""
			}
		} elseif [regexp {^#define\s+(\S+)\s+(.*)$} $line defMatch defName defValue] {
			append defines "<li><b>$defName</b>: <code>$defValue</code></li>"
		} else {
			set last_struct ""
		}
	}

	#thread::mutex lock $lk
	append output "<details><summary>Macros / Defines</summary>$defines</details>"
	#thread::mutex unlock $lk

	puts $output
}

set script_start [clock milliseconds]
puts "
<!DOCTYPE html>
<html>
<head>

<!-- <link rel="stylesheet" href="https://unpkg.com/axist@latest/dist/axist.min.css" /> -->
    <link rel="stylesheet" href="../../assets/styles.css">
<!-- Generated by ... -->
<title>Raylib Cheatsheet</title>
<style>
    :root {
        --article-size: 0.6em;
    }
    pre {
        background-color: white;
        color: black;
    }
#content {
display: flex;
flex-direction: row;
font-family: system-ui;
}
summary h3 {
	display: inline-block;
}
</style>
</head>
<body style="display: flex; flex-direction: column; padding: 2em;">
    <header>
        <h1>Raylib Documentation With Source Code</h1>
        <p>It was fairly often that I wanted to lookup raylib source code to see what a badly documented function is really doing so I built this, Source code is lazy-loaded in from local files;
            This can be very out of date since I don't update it often :/, If you need to search use Ctrl-F
        </p>
    </header>
    <div id="content">
<section id='types'>
<h3>Types</h3>"

processHeaderFile "raylib.h"

puts "</section>"

set c_sources [list "rtext.c" "rmodels.c" "rtextures.c" "raudio.c" "rcore.c"]
set threads ""
set stdoutLock [thread::mutex create]

foreach fp $c_sources {
	lappend threads [tpool::post $pool [list processCFile $fp $stdoutLock]]
}

while {[llength $threads] > 0} {
	tpool::wait $pool $threads threads
}
thread::mutex destroy $stdoutLock
tpool::release $pool


puts "
</div>
<script>
const openDetails = (to) => {
	let elem = document.querySelector('#' + to)
	elem.open = true;
}

const ensureLoaded = (elem) => {
	console.log(elem)
	if (elem.dataset.loaded == 'false') {
		console.log('Trying to load: index-cache/' + elem.id)
		fetch('index-cache/' + elem.id).then(r => r.text()).then(resp => {
			elem.parentElement.innerHTML += '<pre><code>' + resp + '</code></pre>'
			document.getElementById(elem.id).dataset.loaded = 'true'
		})
	} 
}
</script>
</body>
</html>
"
set script_end [clock milliseconds]
set elapsed [expr { $script_end - $script_start }]
puts stderr "Finished in $elapsed ms"
