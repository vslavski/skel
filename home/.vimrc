" File: home/.vimrc
"
" This file is a part of skel project which is distributed under MIT License.
" See file LICENSE for full license details.
"
" Copyright (c) 2020-present Nikita Zuev (V.Slavski!) <nikita.zuev@gmx.com>

" NOTE Add the following line in your '$HOME/.vimrc' file to include this one:
":source /path/to/skel.git/home/.vimrc

" Tabulation size (and shift width) 4
:set ts=4
:set sw=4
" Do not wrap lines
:set nowrap
" Full statusline
:set laststatus=2
":set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
" Key bindings
:nmap <Tab> : tabnext <CR>
:nmap <S-Tab> : tabprev <CR>
:nmap <F10> : qa! <CR>
:nmap <C-C> : terminal <CR>
" Display number row
:set number
" Highlight syntax, search (use incremental search), print margin at col 90
:syntax on
:set hlsearch
:set incsearch
:set colorcolumn=120
" Set text width as colorcolumn (for auto wrapping)
:let &textwidth=&colorcolumn
" Rmember last 1000 commands
:set history=1000
" Securely execute local .vimrc scripts
:set secure
:set exrc
" Open git log
:command -nargs=* GitLog vnew|setf git|execute "read!git log <args>"|set ro|set nomodified|normal gg
:command DiffAll windo diffthis
