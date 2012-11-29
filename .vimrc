set nu
set nocompatible
set backspace=indent,eol,start
set autoindent

set backspace=indent,eol,start

" Switch syntax highlighting on
syntax on

" Enable file type detection and do language-dependent indenting.
filetype plugin indent on

color neverland2-darker

set nofoldenable " Say no to code folding...

command! Q q " Bind :Q to :q
command! Qall qall 

" vim-latex
set grepprg=grep\ -nH\ $*
let g:tex_flavor = "latex"

set tabstop=4     " tabs are at proper location
set noexpandtab     " don't use actual tab character (ctrl-v)
set shiftwidth=4  " indenting is 4 spaces
set autoindent    " turns it on
set smartindent   " does the right thing (mostly) in programs
set cindent       " stricter rules for C programs


" Disable Ex mode
map Q <Nop>
