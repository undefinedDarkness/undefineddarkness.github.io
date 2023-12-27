// vim: fdm=marker:
import interactjs from 'https://cdn.jsdelivr.net/npm/interactjs/+esm'

const $$ = _ => document.querySelectorAll(_)
const $ = _ => document.querySelector(_)
const $set = (_, p, v) => (_ instanceof HTMLElement ? _ : $(_)).style.setProperty(p, v)
const $get = (_, p) => window.getComputedStyle($(_)).getPropertyValue(p)

$('#foldoutbutton').addEventListener('click', (e) => {
	e.target.classList.toggle('flip');
	$('#popout').classList.toggle('slide-out')
})

$('#cursor').addEventListener('animationend', (e) => {
    if (e.animationName == 'mouse-disappear') {
        $('#intro').classList.add('halt-animation')
    }
    console.log(e.animationName)
})

// -- Draggable --

interactjs('.box')//{{{
    .draggable({
        listeners: {
            start (e) {
                e.preventDefault()
            },
        move (event) {
            if (event.target.id == 'rectangle') {
                $set('body', '--box-x', parseInt($get('body', '--box-x')) + event.dx + 'px');
                $set('body', '--box-y', parseInt($get('body', '--box-y')) + event.dy + 'px');
            } else {
                event.target.dataset.x = parseInt(event.target.dataset.x ?? 0) + event.dx;
                event.target.dataset.y = parseInt(event.target.dataset.y ?? 0) + event.dy;
                event.target.style.translate = `${event.target.dataset.x}px ${event.target.dataset.y}px`
            }
        },
        end (e) {
            e.preventDefault()
        }
    }
    })
    .resizable({
        edges: {
            top: true,
            bottom: true,
            right: true,
            left: true
        },
        listeners: {
            move: function (event) {
                let { x, y } = event.target.dataset
        
                x = (parseFloat(x) || 0) + event.deltaRect.left
                y = (parseFloat(y) || 0) + event.deltaRect.top
        
                Object.assign(event.target.style, {
                width: `${event.rect.width}px`,
                    maxWidth: `${event.rect.width}px`,
                        maxHeight: `${event.rect.height}px`,
                height: `${event.rect.height}px`,
                transform: `translate(${x}px, ${y}px)`
                })
        
                Object.assign(event.target.dataset, { x, y })
            }
        }
    })

//}}}

// -- View Switching --

let view_idx = 0

const switch_views = (offset) => {
    const views = $$('.viewport')
    console.log(views)
    if (view_idx + offset >= views.length || view_idx + offset < 0)
        return;
    views[view_idx].classList.add('hidden')
    view_idx += offset;
    views[view_idx].classList.remove('hidden')
    console.log(views)
}

$('#prev-view-btn').addEventListener('click', _ => switch_views(-1))
$('#next-view-btn').addEventListener('click', _ => switch_views(1))