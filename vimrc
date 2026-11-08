" Undecided - do I want this?
" set nohlsearch

set noincsearch
" Ensure that we always start on the first line when editing a git commit
" message - it's really annoying when it starts on line 2 or 3
autocmd FileType gitcommit call setpos('.', [0, 1, 1, 0])

set nocompatible
" Syntax highlighting
syn on


" Necessary?
" set termguicolors

" This might not be the full story for true 256-color support
set t_Co=256
colorscheme desert

" Highlight trailing space (treat it as a todo)
match Todo /\s\+$/

" Macros
" Clean up trailing spaces
let @s='%s/ \+$//c'
" Indentation
let @i='s/^/  /'
" Set number on/off (toggle)
let @n='set number!'

" Toggle number display with ctrl-n ctrl-n
nmap <C-N><C-N> :set invnumber<CR>
" Toggle paste
nmap <C-P><C-P> :set paste<CR>

" Indent
nmap <C-I><C-I> :s/^/  /<CR>
" Unindent, escape-control-i
nmap <Esc><C-I> :s/^  //<CR>

" Show line numbers, with a fixed width "gutter"
set number
if v:version >=700
  set numberwidth=5
endif
" For this to work, we need TERM set: export TERM=xterm-256color
" If we don't have true 256 color support, then DarkGray is black
highlight LineNr term=bold cterm=NONE ctermfg=Black ctermbg=Gray gui=NONE guifg=DarkGrey guibg=NONE
"highlight LineNr term=bold cterm=NONE ctermfg=Black ctermbg=DarkGray gui=NONE guifg=DarkGrey guibg=NONE

" Always show a status bar
set laststatus=2

" Bloody UTF-8
set encoding=utf-8
set fileencoding=utf-8
setglobal fileencoding=utf-8


" In case there's code using tabs
set tabstop=2
" The number of spaces that we shift when indenting
set shiftwidth=2
" When indenting and tabbing, convert to spaces instead of tab
" To insert an actual tab, either disable with set expandtab! or enter CTRL-V-TAB
" set expandtab
