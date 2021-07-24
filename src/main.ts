import { readFileSync } from 'fs'
import { performance } from 'perf_hooks'
import * as _builtin from './builtin'
import replaceAsync from 'string-replace-async';
import {length as _length} from 'stringz'

const builtin = {..._builtin}
export const TAB = '        '

enum Importance {
	Anywhere = 0,
	ResolveChildren = 1,
	WillResolve = 2,
	RunAtEnd = 3
}

export interface Transformer {
	inline: boolean,
	importance: Importance;
	fn: (a:string, args?: string) => Promise<string>;
}
type TransformerList = Record<string, Transformer>;

export const fail = (msg:string, do_exit:boolean=true) => {
	console.error('\u001b[1m\u001b[31m[ERROR]\u001b[0m '+msg)
	do_exit ? process.exit(1) : null
}

export const warn = (msg: string) => {
	console.error('\u001b[1m\u001b[33m[WARNING]\u001b[0m '+msg)
}

function filterObj(obj: Record<string, Transformer>, test_: (a: Transformer) => boolean) {
	return Object.fromEntries(Object.entries(obj).filter(([_, v]) => test_(v)))
}
async function useTransformer(data: string, obj: TransformerList, append_args='') {
		return await replaceAsync(data, new RegExp(`[\t\ ]*#(${Object.keys(obj).map(x => x.toUpperCase().replace('_', '-')).join('|')})+([^\n]+)?([^]+?)#END \\1`, 'g'), async (match: string, tag: string, args: string, value: string) => {
			tag = tag.toLowerCase().replaceAll('-', '_')
			args = (args ?? '') + append_args
			try {
				return (obj[tag] ? obj[tag].fn(value, args) : value)
			} catch (err) {
				fail(`Transformer: ${tag} failed to transform: ${value} ~ ${err}`);
				return match
			}
		})	
}

class Context {
	data: string;

	inlineTransformers: TransformerList; // eg: #TAG VALUE#
	simpleBlockTransformers: TransformerList; // eg #BEGIN TAG #END TAG
	complexBlockTransformers: TransformerList; 
	resolvedBlockTransformers: TransformerList;
	endBlockTransformers: TransformerList;

	constructor(file_path: string) {
		this.data = readFileSync(file_path, 'utf-8');
		this.inlineTransformers = filterObj(builtin,  (v) => v.inline && v.importance == 0)
		this.simpleBlockTransformers = filterObj(builtin, v => v.importance == 0 && !v.inline)
		this.complexBlockTransformers = filterObj(builtin, v => v.importance == 2)
		this.resolvedBlockTransformers =  filterObj(builtin, v => v.importance == 1)
		this.endBlockTransformers = filterObj(builtin, v => v.importance == 3)
	}
	
	preTransform() {
		if (process.argv.includes("--ascii")) {
			warn("Using ascii only chars, in accordance with `--ascii`")
			this.data = this.data.replace(/[^\x00-\x7F]/g, "");
		}

		if (!process.argv.includes("--no-fix-emoji")) {
			warn("Stripping all emojis (they break boxes), to ignore use `--no-fix-emoji`")
			this.data = this.data.replace(/\p{Extended_Pictographic}/u, "")
		}

		this.data = this.data.replaceAll('\t', TAB)
	}
	async transform() {

		// Replace Emoji & Unicode (if --ascii)
		this.preTransform()

		// -- Simple Processing --
		const matchInline = /#(\w+) (.*)#/g 
		while (true) {
			this.data = await replaceAsync(this.data, matchInline, async (_, tag: string, value: string) => {
				tag = tag.toLowerCase()
				return (this.inlineTransformers[tag] ? this.inlineTransformers[tag].fn(value.trim()) : value)
			})
			if (!matchInline.test(this.data)) { break }
		}

		this.data = await useTransformer(this.data, this.simpleBlockTransformers) 

		// -- Complex Processing -- 
		this.data = await useTransformer(this.data, this.complexBlockTransformers) 

		// get longest line
		let getLongest = (longest = 0, data = this.data) => {
			for (let line of data.split('\n')) {
				let l = length(line)
				if (l > longest) { longest = l }
			}
			return longest
		}

		let longest = getLongest()

		// -- Relative Processing --
		this.data = await useTransformer(this.data, this.resolvedBlockTransformers, longest.toString()) 

		longest = getLongest();
		this.data = await useTransformer(this.data, this.endBlockTransformers, longest.toString())

	}
}

async function main() {
let instance = new Context(process.argv[2])

const start = performance.now()
await instance.transform()
const end = performance.now()

console.log(instance.data)
console.error(`Finished transforming in \u001b[1m${Math.floor(end-start)}\u001b[0mms`)
}
main()
