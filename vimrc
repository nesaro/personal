set hidden "Permite poner en background sin guardar
set nocompatible "Funcionalidades no compatibles con vi
set history=100
set incsearch " Busqueda incremental
set hlsearch " dejar iluminada la busqueda
set showmatch


if has( "gui_running" )
    colo PaperColor
elseif  $TERM =~ '256'
    colo PaperColor
elseif  $COLORTERM == 'gnome-terminal'
    set t_Co=256
    colo PaperColor
else
    colo desert
endif


" set is
" set si
" :au Filetype html,xml,xsl source ~/vim/closetag.vim 
filetype indent on
filetype plugin on
" set grepprg=grep\ -nH\ $*

"helptags ~/.vim/doc
"autocmd FileType python set omnifunc=pythoncomplete#Complete
"source ~/.vim/plugin/vimballPlugin.vim "plugin vimball

" Navegacion entre tabs
"map <silent><A-Right> :tabnext<CR>
"map <silent>&ltA-Left> :tabprevious<CR>

"runtime macros/matchit.vim "Match expandido
set wildmode=list:longest "Para el completion tipo bash
set scrolloff=3


"let Tlist_File_Fold_Auto_Close = 1

"map T :TaskList<CR>
"map <buffer> <S-e> :w<CR>:!/usr/bin/env python % <CR>
"map P :TlistToggle<CR>

"set invlist

set expandtab
"set textwidth=79
set tabstop=8
set softtabstop=4
set shiftwidth=4
set autoindent
syntax on


set statusline=%n\ %f\        "tail of the filename
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%y      "filetype
set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file

set laststatus=2

call plug#begin('~/.vim/plugged')
Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
call plug#end()

let g:vimwiki_list = [{'path':'~/doc/zim/', 'path_html':'~/doc/zim/', 'syntax': 'markdown', 'ext': '.md'}]

autocmd BufEnter *.md :setlocal filetype=markdown
