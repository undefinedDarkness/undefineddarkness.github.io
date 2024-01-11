// vim: fdm=marker:
import interactjs from 'https://cdn.jsdelivr.net/npm/interactjs/+esm'

const $$ = _ => document.querySelectorAll(_)
const $ = (_, p = document) => p.querySelector(_)
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
            start(e) {
                e.preventDefault()
            },
            move(event) {
                if (event.target.id == 'rectangle') {
                    $set('body', '--box-x', parseInt($get('body', '--box-x')) + event.dx + 'px');
                    $set('body', '--box-y', parseInt($get('body', '--box-y')) + event.dy + 'px');
                } else {
                    event.target.dataset.x = parseInt(event.target.dataset.x ?? 0) + event.dx;
                    event.target.dataset.y = parseInt(event.target.dataset.y ?? 0) + event.dy;
                    event.target.style.translate = `${event.target.dataset.x}px ${event.target.dataset.y}px`
                }
            },
            end(e) {
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

const _this = {};

// -- View Animations --

_this.animateCards = () => {
    const cards = $$('.card')
    const ani_cards = $$('#ani-card-group > *')
    const ani_group = $('#ani-card-group')
    const ani_group_coords = ani_group.getBoundingClientRect()
    const card_size = [ cards[0].offsetWidth, cards[1].offsetHeight ]

    // $('#ani-card-group').animate({
    //     left: ['50%', '0'],
    //     top: ['-50%', '0']
    // }, {
    //     duration: 1 * 1000,
    //     fill: 'forwards',
    //     delay: 1000,
    // })

    ani_cards.forEach((ani_card, idx) => {
        const card = cards[idx]
        
        // Initial Animation
        const card_coords = card.getBoundingClientRect()
        ani_card.style.width = `${card_coords.width}px`;
        ani_card.style.height = `${card_coords.height}px`

        const left_i = `-${ani_group_coords.left}px`
        const top_i = `${ card_coords.top - ani_group_coords.bottom }px`

        ani_card.animate(
            {
                left: ["0", `calc(${left_i} + ${card_coords.x}px)`],
                top: ["0", top_i],
                // rotate: [ani_card.style.rotate, '0deg'],
            },
            {
                duration: 0.5 * 1000,
                fill: "forwards",
                delay: idx * 500 + 500,
            }
        )

        ani_card.animate({
            rotate: [ani_card.style.rotate, '0deg']
        }, {
            duration:100,fill:'forwards',delay:idx*500 + 1000
        })

    //     ani_card.animate(
    //         {
    //             left: [left_i, `${card_coords.x}px`],
    //             top: [top_i, `${card_coords.y}px`],
    //             width: [`${ani_card.offsetWidth}px`, `${card.offsetWidth}px`],
    //             height: [`${ani_card.offsetHeight}px`, `${card.offsetHeight}px`]
    //         },
    //         {
    //             duration: 0.4 * 1000,
    //             fill: 'forwards',
    //             delay: 1 * 1000,
    //         }
    //     )

       setTimeout(() => { 
                $('.card-bg', card).classList.remove('hidden')
                // card.addEventListener('click', () => {
                
                card.animate({
                    transform: ['rotateY(0deg)', 'rotateY(180deg)']
                }, {
                    duration: 300,
                    fill: 'forwards'
                })
                
                // })
                ani_card.remove()
                console.log(`finished`)
            }, idx*500 + 500 + 200 + 500)
    })
}


// -- View Switching --


let view_idx = 0
const views = $$('.viewport')
const switch_views = (offset) => {
    if (view_idx + offset >= views.length || view_idx + offset < 0)
        return;
    views[view_idx].classList.add('hidden')
    view_idx += offset;
    views[view_idx].classList.remove('hidden')
    if (views[view_idx].hasAttribute('i-on-visible')) {
        const cb = new Function(views[view_idx].getAttribute('i-on-visible'))
        cb.call(_this);
    }
}

$('#prev-view-btn').addEventListener('click', _ => switch_views(-1))
$('#next-view-btn').addEventListener('click', _ => switch_views(1))

