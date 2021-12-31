const $ = _ => document.querySelector(_)
const $$ = _ => document.querySelectorAll(_)

$$('.sidebar ul li').forEach(e => {
		e.addEventListener('click', () => {
			$$('section').forEach(e => e.style.display = 'none')
			$('#'+e.dataset.tab).style.display = 'block'
		})
})

/*-- Color Rows --*/
$$('#color-rows tr td:first-child').forEach(e => {
	e.style.color = e.innerText == 'Black' ? '#888' : e.innerText// .toLowerCase()
})

$('#color-toggle-bright').addEventListener('input', ev => {
	const find = /(m|;1m)$/
	$$('#color-rows tr td:first-child').forEach(e => e.classList.toggle('glow'))
	$$('#color-rows tr td:last-child').forEach(e => {
		if (ev.target.checked) {
			e.innerText = e.innerText.replace(find, ';1m') //== 'Black' ? '#888' : e.innerText// .toLowerCase()
		} else {
			e.innerText = e.innerText.replace(find, 'm')
		}
	})
})


let replaceColorPrefix = '\\033'
$('#color-rows-fmt').addEventListener('change', (e) => {
	const find = /\\(027|u001b|033)/
	switch (e.target.value) {
		case "Lua":
			replaceColorPrefix = '\\027'
			break;
		case "Posix":
			replaceColorPrefix = '\\033'
			break;
		case "Most":
			replaceColorPrefix = '\\u001b'
			break;
	}
	$$('.special-m tr td:last-child').forEach(e => {
		e.innerText = e.innerText.replace(find, replaceColorPrefix)
	})
})

/*-- Color --*/

const hexToRgb = hex =>
  hex.replace(/^#?([a-f\d])([a-f\d])([a-f\d])$/i
             ,(m, r, g, b) => '#' + r + r + g + g + b + b)
    .substring(1).match(/.{2}/g)
    .map(x => parseInt(x, 16))

$('#color-in').addEventListener('input', e => {
	let val = e.target.value
	let color = [] //{ r: 0, g: 0, b: 0 }
	if (val.match(/#\d+\d+\d+/)) {
		color = hexToRgb(val)
	} else {
		let a = val.match(/rgb\((\d+),\s?(\d+),\s?(\d+)\)/)
		if (!a) { return }
		color[0] = parseInt(a[1])
		color[1] = parseInt(a[2])
		color[2] = parseInt(a[3])
	}
	$('#color-out').innerText = `${replaceColorPrefix}[38;2;${color[0]};${color[1]};${color[2]}m`
})
