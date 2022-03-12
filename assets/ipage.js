const $ = _ => document.querySelector(_)
const $$ = _ => document.querySelectorAll(_)

        
let folds = Array.from($$('details'))
folds.shift()
for (let fold of folds) {
    fold.open = false
}

const main = async () => {

    // Page uses mermaid graphs so import it.
    if ($('.mermaid')) {
        console.log(await import("https://cdn.jsdelivr.net/npm/mermaid/+esm"))
    }

}
main()
