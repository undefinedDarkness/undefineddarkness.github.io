const $ = _ => document.querySelector(_)
const $$ = _ => document.querySelectorAll(_)

let folds = Array.from($$('details'))
console.log(folds)
folds.shift()
for (let fold of folds) {
    fold.open = false
}
