const $ = _ => document.querySelector(_)

function sleep (time) {
  return new Promise((resolve) => setTimeout(resolve, time));
}

class Renderer {
    #WIDTH;
    #HEIGHT;
    #lines;
	#layers;
	#canvas;
    constructor(canvas, height, width) {
        this.#canvas = $(canvas)
        this.#canvas.style.height = height+'ch'
        this.#canvas.style.width = width+'ch'

        this.#layers = {
			"base": [],
			"enemies": [],
			"projectiles": []
		};
        this.#lines = new Array(height+1).fill('')
        Object.seal(this.#lines)
        
		this.#WIDTH = width
		this.#HEIGHT = height
    }

	// Actually draw to the canvas
    async draw() {
        this.#canvas.innerHTML = this.#lines.join('\n')
    }

	set onclick(fn) {
		this.#canvas.addEventListener('click', fn)
	}
    
   	// Draw a line
	async drawLine(y) {
        if (y < 0) { 
            y = this.#HEIGHT + y
        }
        this.#lines[y] = "-".repeat(this.#WIDTH)
    }

	// Draw a chunk of text
    async drawMe(me, y, x, layer) {
        if (x>this.#WIDTH || !layer) {return}
        me = me.split('\n');
        let before = " ".repeat(x);
		let points = []
        for (let i = 0; i < me.length; i++) {
            if (me[i].trim().length > 0) {
				
				// Construct the line
				let last = this.#lines[y+i]
                let line = before + me[i]
                let rest = last.substr(line.length)
				
				// Add co-ordinate to layers data
				points.push([y+i, x, line.length])
                
				this.#lines[y+i] = line + rest
            }
        }
		this.#layers[layer].push(points)
    }

	async replaceSection (ch, y, start, end) {
		let s = this.#lines[y];
		this.#lines[y] = s.substr(0, start) + ch.repeat(end-start) + s.substr(end)
	}

	async checkForCollision(layer, x, cb) {
		for (let i = 0; i < this.#layers[layer].length; i++) {
			let blob = this.#layers[layer][i]
			if (blob.some(v => { console.log(x, v[1]);return x >= v[1] })) {
				this.#layers[layer].splice(i, 1)
				cb(blob)
			}
			console.log(`NEXT`)
		}
	}
}

const render = new Renderer("#canvas", 40, 200, false);

let game = {
    dino: [33, 0], // y x
	laser: undefined,
    started: false
}

function endGame() {
    game.started = false;
    render.drawMe(
    `
/----------------------\\
| Game Over. You suck. |
\\----------------------/`, 20, 94, 'base');
	render.draw()
}

function drawCacti() {
    render.drawMe(`  
  _  _
 | || | _
-| || || |
 | || || |-
  \\_  || |
    |  _/
   -| | \\
    |_|- `, 31, 100, 'enemies')

	    render.drawMe(`  
    ,*-.
    |  |
,.  |  |
| |_|  | ,.
\`---.  |_| |
    |  .--\`
    |  |
    |  | `, 31, 40, 'enemies')
}

function drawPlayer() {
    render.drawMe(`
               __
              / _)
     _.----._/ / 
    /         / 
 __/ (  | (  |
/__.-'|_|--|_|`, game.dino[0], game.dino[1], 'base')
	render.checkForCollision('enemies', game.dino[1]+15, endGame)
}

function drawLaser() {
	render.drawMe(`--*`, game.laser[0], game.laser[1], 'projectiles')
	game.laser = [34, game.laser[1]+5]
	render.checkForCollision('enemies', game.laser[1]-5, (blob) => {
						blob.forEach(p => render.replaceSection(' ', p[0], p[1], p[2]))
						render.draw()
						game.laser = undefined
				})
}

render.onclick = () => {
	if (!game.laser) {
		game.laser = [34, game.dino[1]+20]
	}
}

function drawInstructions() {
	render.drawMe(`
/--------------------------\\
| Click to fire lasers.    |
| Dont hit the cactus.     | 
| See <a href="https://github.com/undefinedDarkness/undefineddarkness.github.io/tree/master/assets/other/dino.js">source</a>               |
\\--------------------------/`, 5, 10, 'base')
}

(async () =>  {
    game.started = true
    drawCacti()
	drawInstructions()
    render.drawLine(40)
	while (game.started) {
	    	drawPlayer()
			render.draw()
	    	game.dino = [33, game.dino[1]+1]
			if (game.laser) {
				drawLaser()
				
				// console.log(game.laser[1])
			}
			
	    	await sleep(333)
	}
})()
