<div class="txt-c hor-ord jus-c algn-c header flx-wrp">
<img class="img-sml" alt="art by u/astrellon3" src="/assets/images/dump/fd1bdbbb-2de7-4d24-ab5a-e883d5f2f103.webp" />
<!-- TODO: recreate myself -->
<h1>Vi IMproved</h1>
</div>
<i>This is just a bunch of neat stuff I find related to Vim, maybe plugins, scripts or just neat settings.</i>

## Plugins
- <a href="https://github.com/dense-analysis/ale">🍻 Asynchronous Linting Engine</a>
A great plugin that takes care of Linting, Formatting & Autocompletion
Quite customizable but some bits are a bit dated by default.

- <a href="https://github.com/ap/vim-css-color">CSS Color</a>
Highlight hex codes & web names for colors with the actual color :), works really well
Lacks support for some languages (lua) but that can be easily fixed via autocommand.

- <a href="https://github.com/sheerun/vim-polyglot">Polygot</a>
Language pack for vim,
A good one to have since you do not notice it much unless you're very worried about startup times

- <a href="https://github.com/mattn/emmet-vim">Emmet</a>
Essential if you edit HTML, You probably already know about this one.	

- <a href="https://github.com/eraserhd/parinfer-rust">Parinfer</a>
Infer your parenthesis!
True bliss if you ever edit lisp code 😳
Also use this, it helps a lot: [junegunn/rainbow_parentheses.vim](https://github.com/junegunn/rainbow_parentheses.vim)

- <a href="https://github.com/lambdalisue/fern.vim">🌵 Fern</a>
Great alternative to NERDTree / netrw and imo a much better one
Feels pretty clean and nice to use,
If you're using neovim, [nvim-tree](kyazdani42/nvim-tree.lua) will work much better for you & it has some nicer features.

<!-- Replace with something better -->
- <a href="https://github.com/itchyny/lightline.vim">Lightline</a>
I don't use a status line but if I did I would use lightline, it works really well and is easy to customize ([MEME](https://i.imgflip.com/5pb8qw.jpg))

- <a href="https://github.com/nvim-telescope/telescope.nvim">🔭 Telescope</a>
I wish I had learnt about this before, its a really nice plugin, it generates a menu for you that allows to
search through files, content of files, anything and it can be mightly handy instead of fiddling with the wildmenu all day.
Vim users have [fzf.vim](junegunn/fzf.vim) which does some similar stuff.

- <a href="https://github.com/folke/zen-mode.nvim">Zen Mode</a>
This is an interesting one, What it does is slim down vim's UI so it becomes very bare bones, this is really useful
for when you are editing documents instead of code and need vim to done down the hacker man aesthetic.
This plugin is [goyo](https://github.com/junegunn/goyo.vim) for vim users.

## Configuration 
Making the most out of vanilla vim features

#f NetRW 
Using NetRW as a file tree.
From <a href="https://shapeshed.com/vim-netrw/">this post</a>
tldr:
```vim
let g:netrw_banner = 0 " Hide the banner
let g:netrw_browse_split = 3 " Open in new tab
let g:netrw_winsize = 25 " Size
let g:netrw_liststyle = 3 " Show files in tree form
```
See what each option does with `:help netrw-browser-settings`
#END f

#f :Grep
Improving the :grep command to work similar to how [ack.vim](https://github.com/mileszs/ack.vim) works
See the <a href="https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3">full gist</a>, it explains everything
final snippet:
```vim
function! Grep(...)
    return system(join([&grepprg] + [expandcmd(join(a:000, ' '))], ' '))
endfunction
command! -nargs=+ -complete=file_in_path -bar Grep  cgetexpr Grep(<f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrep lgetexpr Grep(<f-args>)
augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost cgetexpr cwindow
    autocmd QuickFixCmdPost lgetexpr lwindow
augroup END
```
#END f

#f Tab Indicator 
If and only if you indent with tabs, vim can bestow upon you a slick tab line:
`set list lcs=tab:\│\ " There is a space here :)`
#END f

#f Export to HTML 
This is a pretty neat capability I did not know vim had,
By the power of an included plugin, You can run `:TOhtml` to convert the entire current file to a HTML with all of vim's
syntax highlighted goodness,
And you can script it! Like so:
```sh
lang="$2"
f=$(mktemp)
echo "$0" | head -n -1 | nvim -n --headless \
	+"let g:html_no_progress = 0"\
	+"let g:html_ignore_folding = 0"\
	+'let g:html_prevent_copy = "fn"'\
	+"set ft=$1"\
	+"runtime! syntax/2html.vim"\
	+"wq! $f"\
	+"q!" - 1> /dev/null
```
You can see more options for it here: https://vimhelp.org/syntax.txt.html#%3ATOhtml ,
[Here](/assets/make.html) is a example file from the make script of this website.
* ✏ ~~This is now used to generate code syntax highlighting for this site.~~ - Turns out it was way too slow
#END f

#f Improving :help and :Man 
I find vim's help pages annoying to navigate since by default, its difficult to navigate between sections, this fixes it:
`au FileType help,man nnoremap <buffer> <CR> <C-]>`
This makes it so hitting enter in a help buffer will try to just to the currently selected word 
(the world the cursor is on.)
Here are some more nice shortcuts: https://vim.fandom.com/wiki/Learn_to_use_help#Simplify_help_navigation

#### Using vim as a man pager 
There are lots of ways to do it (documented [here](https://vim.fandom.com/wiki/Using_vim_as_a_man-page_viewer_under_Unix) but 
the simplest way I found is to simple alias `man`, like so in your shell configuration file:
```sh
man () {
	nvim +"Man $2 $1" +"only"
}
```
If you use vim, remember to add this to your vimrc:
`runtime ftplugin/man.vim`
as `:help ft-man-plugin` instructs you to.

* This has some issues like files like `./local.man` but I do not often use this so its not a problem for me.
#END f

#f Linting 
Here are a few useful gists on the topic:
https://gist.github.com/romainl/2f748f0c0079769e9532924b117f9252<br> 
https://gist.github.com/romainl/ce55ce6fdc1659c5fbc0f4224fd6ad29
 
What I did to get `shellcheck` to work:
- Setup an autocommand to set the `compiler` to `shellcheck -f gcc` for any shell files
- Used https://github.com/mh21/errormarker.vim to get ALE like markings
- From error marker's readme: `let &errorformat="%f:%l:%c: %t%*[^:]:%m,%f:%l: %t%*[^:]:%m," . &errorformat`
- Made vim run `:make` on file write.

✏ Actually I have reconsidered this, its way too painful for anything complicated over multiple lines, its a lot
simpler to just use ALE for those, fine for stuff like GCC or Shell check tho
#END f

#f Spell Checking & Dictionary Completion
As much as I hate to link a luke smith video, this one actually explains stuff so here ya go: https://www.youtube.com/watch?v=ez1XBUqbS68
But basically:
- Enable spell checking with `:set spell`
- Add words to the white list with `zg`
- Add words to the black list with `zug`
- Go through the suggest corrections with `z=` while your cursor is over misspelled word.

For dictionary completion, you can use the following snippet:
You might need to rewrite it in vim script for vim...
```lua
local spell_complete = vim.api.nvim_replace_termcodes('<C-x><C-k>', true, true, true) 
local M = {}
function M.spell()
	if vim.opt.spell 
	and (vim.fn.pumvisible() == 0) 
	and ((vim.v.char >= 'a' and vim.v.char <= 'z') 
	or (vim.v.char >= 'A' and vim.v.char <= 'Z')) then
		vim.fn.feedkeys(spell_complete, 'n')
	end
end
function M.setup_spell()
	vim.opt.spell = true
	vim.cmd [[ 
	autocmd InsertCharPre * lua require('auto').spell() " You'll need to change this 
	]]
end

-- And this too:
vim.cmd [[ au FileType markdown,html lua require('auto').setup_spell() ]]

return M 
```
It works, fairly ~~well.~~ badly, it has lots of issues when you have multiple buffers open...
#END f

#CENTER
<i>~ More to come.. Maybe 🚧 ~</i>
#END CENTER
