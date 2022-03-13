const $ = _ => document.querySelector(_)
const $$ = _ => document.querySelectorAll(_)

        
let folds = Array.from($$('details'))
folds.shift()
for (let fold of folds) {
    fold.open = false
}

