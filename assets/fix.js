const $ = _ => document.querySelector(_)
const $$ = _ => document.querySelectorAll(_)

// Set up before/after handlers
const beforePrint = () => {
    $$("details").forEach( e => e.setAttribute('open', '') );
};
const afterPrint = () => {
    $$("details").forEach( e => e.removeAttribute('open') );
};

// Webkit
if (window.matchMedia) {
    var mediaQueryList = window.matchMedia('print');
    mediaQueryList.addListener(function(mql) {
        if (mql.matches) {
            beforePrint();
        } else {
            afterPrint();
        }
    });
}

// IE, Firefox
window.onbeforeprint = beforePrint;
window.onafterprint = afterPrint;
