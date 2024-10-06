// @ts-check

/** @param {string} _ */
const $ = _ => document.querySelector(_) ?? document.createElement(`span`)

/** 
 * @param {FileSystemDirectoryHandle} dir  
 * @param {string} path 
 * @param {string} res */
async function walkDir(dir, path = '', res = '') {
    for await (const [name, value] of dir.entries()) {
        if (value.kind === 'file') {
            res += `<li>${name}</li>`
        } else {
            res += `<li>
            ${name}/
            <ul>`
            res += await walkDir(value, path + name + '/', '')
            res += `</ul></li>` 
        }
    }
    return res
}

function openPicker() {
    window.showDirectoryPicker({
        mode: 'read',
        startIn: 'documents'
    }).then(dir => {
        walkDir(dir, '', '').then(res => {
            $('#dirName').textContent = dir.name
            $('#dirList').innerHTML = res
        })
    })
}