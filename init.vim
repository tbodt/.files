" my nvim vimrc, rewritten

" deferring configuration until runtimepath has been set {{{
let s:deferred = []
function! s:defer(command)
    call add(s:deferred, a:command)
endfunction
function! s:run_deferred()
    for command in s:deferred
        execute command
    endfor
endfunction
command! -nargs=1 Defer call <sid>defer(<q-args>)
" }}}

call plug#begin()

" UI {{{
Plug 'flazz/vim-colorschemes'
Defer colorscheme Tomorrow-Night

" lightline {{{
Plug 'itchyny/lightline.vim'
let g:lightline = {
            \ 'component_function': {
            \   'mode': 'LightlineMode',
            \   'filename': 'LightlineFilename',
            \   'readonly': 'LightlineReadonly',
            \   'modified': 'LightlineModified',
            \   'fileformat': 'LightlineFileformat',
            \   'fileencoding': 'LightlineFileencoding',
            \   'filetype': 'LightlineFiletype',
            \ },
            \ 'component': {
            \   'filename': '%f',
            \ },
            \ 'active': {
            \   'right': [['lineinfo'],
            \             ['percent'],
            \             ['filetype', 'fileformat', 'fileencoding']],
            \ },
            \ 'tabline': {
            \   'right': [[]],
            \ },
            \ }

function! LightlineReadonly()
    return &modifiable ? '' : ''
endfunction
function! LightlineModified()
    return &modified ? '•' : ''
endfunction

function! LightlineFilename()
    let fname = expand('%:~:.')
    if fname ==# ''
        let fname = '[No Name]'
    endif
    return fname
endfunction
function! LightlineMode()
    return lightline#mode()
endfunction

function! LightlineFiletype()
    if winwidth(0) < 70 | return '' | endif
    return &ft != '' ? &ft : 'no ft'
endfunction
function! LightlineFileformat()
    if winwidth(0) < 70 | return '' | endif
    return &fileformat
endfunction
function! LightlineFileencoding()
    if winwidth(0) < 70 | return '' | endif
    return &fileencoding
endfunction
" }}}

" search
set nohlsearch
set incsearch
set hlsearch
set inccommand=nosplit
set ignorecase
set smartcase
nnoremap <silent> <esc> :nohlsearch<cr>

" misc
set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor
set number
" set relativenumber
set noshowmode " don't clutter up the bottom with -- INSERT --
set showcmd
set lazyredraw
set mouse=nvc
set scrolloff=10
set nostartofline

set list
set listchars=tab:»\ ,trail:●

Plug 'yuttie/comfortable-motion.vim'

" }}}
" MAPPINGS {{{
let mapleader = "\<space>"

"" insert
" line autocomplete
inoremap <c-l> <c-x><c-l>

"" normal
" easier beginning/ending
noremap H ^
noremap L $

" windows
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>

" operator-pending
onoremap J j
onoremap K k

" yes i am going to do this
noremap , :
noremap : ,

set gdefault
nnoremap <silent> & :&&<cr>
xnoremap <silent> & :&&<cr>
xnoremap <silent> . :normal .<cr>

" nnoremap <expr> gv "`[".getregtype()[0]."`]"
" }}} 
" IDE {{{

" nothing works if you don't have python
Plug 'roxma/python-support.nvim'
let g:python_support_python3_requirements = []
command! -nargs=* PyRequire
            \ call extend(g:python_support_python3_requirements, [<f-args>])

" fzf: fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
nnoremap <silent> <c-p> :Files<cr>

" autocomplete
set completeopt=menu,noinsert,noselect
set shortmess+=c
let s:completer = 'deoplete'
if s:completer ==# 'deoplete'
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
	let g:deoplete#enable_at_startup = 1
elseif s:completer ==# 'ncm'
    Plug 'roxma/nvim-completion-manager'
    let g:cm_refresh_default_min_word_len = [[1,1]]
    let g:cm_complete_start_delay = 100
    PyRequire setproctitle psutil
    let g:cm_completeopt = &completeopt
    imap <c-space> <plug>(cm_force_refresh)
endif
" press tab for the next match
inoremap <expr> <tab> pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <expr> <s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
inoremap <expr> <c-y> pumvisible() ? "\<c-e><c-y>" : "\<c-y>"
inoremap <expr> <c-e> pumvisible() ? "\<c-e><c-e>" : "\<c-e>"
inoremap <expr> <cr> pumvisible() ? "\<c-y><cr>" : "\<cr>"

Plug 'Shougo/neco-vim'
" Plug 'roxma/nvim-cm-tern'

Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh' }
let g:LanguageClient_serverCommands = {
            \ 'c': ['clangd'],
            \ 'cpp': ['clangd'],
            \ 'python': ['pyls'],
            \ 'javascript.jsx': ['node', '/Users/tbodt/Developer/projects/js-langserver/index.js', '--stdio'],
            \ 'json': ['json-languageserver', '--stdio'],
            \ 'css': ['css-languageserver', '--stdio'],
            \ 'html': ['html-languageserver', '--stdio'],
            \ }
let g:LanguageClient_settingsPath = expand('~/.config/nvim/settings.json')
let g:LanguageClient_selectionUI = 'location-list'
let g:LanguageClient_diagnosticsDisplay = {
            \ 1: {"signText": "🛑"},
            \ 2: {"signText": "⚠️"},
            \ 3: {"signText": "ℹ️"},
            \ }
let g:LanguageClient_diagnosticsList = v:null
function! s:lsp_map()
    nnoremap <buffer> <silent> <c-\> :<c-u>call LanguageClient#textDocument_references()<cr>
    nnoremap <buffer> <silent> <c-]> :<c-u>call LanguageClient#textDocument_definition()<cr>
    nnoremap <buffer> <silent> K :<c-u>call LanguageClient#textDocument_hover()<cr>
    " setlocal formatexpr=LanguageClient#textDocument_rangeFormatting()
    " setlocal formatoptions=
endfunction
augroup lsp-langs
    autocmd!
    for lang in keys(g:LanguageClient_serverCommands)
        execute 'autocmd FileType' lang 'call s:lsp_map()'
    endfor
augroup END

" Tags
Plug 'ludovicchabant/vim-gutentags'
let g:gutentags_define_advanced_commands = 1
let g:gutentags_file_list_command = "ag --follow --nocolor --nogroup -g ''"
let g:gutentags_project_root = ['.tags']

PyRequire websockets
PyRequire remote-pdb
" }}}
" EDITOR {{{

Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'
Plug 'rking/ag.vim'
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
nnoremap <silent> <leader>u :UndotreeToggle<cr>

Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-function'

Plug 'Olical/vim-enmasse'
Plug 'chaoren/vim-wordmotion'
let g:wordmotion_mappings = {
            \ 'w' : '<a-w>',
            \ 'b' : '<a-b>',
            \ 'e' : '<a-e>',
            \ 'ge' : 'g<a-e>',
            \ 'aw' : 'a<a-w>',
            \ 'iw' : 'i<a-w>'
            \ }
Plug 'tommcdo/vim-exchange'

Plug 'PeterRincker/vim-argumentative'

" italics
Defer let &t_ZH="\e[3m"
Defer let &t_ZR="\e[23m"
Defer highlight Comment cterm=italic
Defer highlight clear SpellBad
Defer highlight SpellBad cterm=undercurl gui=undercurl guisp=red
Defer highlight clear SpellCap
Defer highlight SpellCap cterm=undercurl gui=undercurl guisp=red
Defer syntax match ErrorMsg "\v\S\zs\s+$"

" netrw
Plug 'tpope/vim-vinegar'
let g:netrw_liststyle = 3
let g:netrw_winsize = 25
" }}}
" LANGUAGES {{{

let g:c_syntax_for_h = 1
let g:vim_indent_cont = &sw
Plug 'dag/vim-fish', {'for': 'fish'}
Plug 'raimon49/requirements.txt.vim'
Plug 'hynek/vim-python-pep8-indent'
Plug 'mndrix/prolog.vim'
Plug 'elixir-lang/vim-elixir'
Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'
Plug 'chrisbra/csv.vim'
Plug 'igankevich/mesonic'
Plug 'Shirk/vim-gas'
let g:asmsyntax = 'gas'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
let g:jsx_ext_required = 0
Plug 'tpope/vim-markdown'
" Plug 'nelstrom/vim-markdown-folding'
Plug 'justinmk/vim-syntax-extra' " improved yacc/lex/c
Plug 'shogas/vim-ion'
set rtp+=~/llvm/utils/vim

Plug 'jamessan/vim-gnupg'
let g:GPGUseAgent = 0

augroup langs
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
    autocmd FileType python iabbrev <buffer> bpoint from celery.contrib import rdb;rdb.set_trace()
    autocmd FileType markdown setlocal foldmethod=manual
augroup END

augroup lang_detect
    autocmd!
    autocmd BufRead,BufNewFile .babelrc,.eslintrc,.tern-project setfiletype json
    autocmd BufRead,BufNewFile *.S let b:asmsyntax = 'gas'
augroup END

set cinoptions=l1,N-s

" Spaces. Four of them.
set tabstop=4
set shiftwidth=4
set expandtab
Plug 'editorconfig/editorconfig-vim' " ok fine
" }}}
" CUSTOM {{{

" quick vimrc editing
nnoremap <silent> <leader>v :tabe $MYVIMRC<cr>

augroup myautocommands
    autocmd!
    " auto vimrc reloading
    " autocmd BufWritePost,FileWritePost $MYVIMRC nested source $MYVIMRC
    " autosaving
    autocmd FocusLost,BufLeave * nested silent! update
    " jump to the last cursor position when reading a file
    autocmd BufReadPost *
                \ if line("'\"") >= 1 && line("'\"") <= line("$") |
                \   exe "normal! g`\"" |
                \ endif
    autocmd BufReadPre *.bin setlocal binary

    autocmd QuickFixCmdPost [^l]* nested cwindow
    autocmd QuickFixCmdPost l* nested lwindow
augroup END

Plug 'blueyed/vim-qf_resize'
set grepprg=rg\ -n
set shellpipe=>

function! Tail()
    while 1
        try
            edit | $
        catch /^Vim:Interrupt$/
            edit | $
            return
        endtry
        redraw
    endwhile
endfunction
command! Tail call Tail()

set autoread
set autowrite
set autowriteall
" }}}
" CRAP {{{

" best. idea. ever.
" PyRequire pyaudio
Plug 'timeyyy/orchestra.nvim'
Plug 'timeyyy/clackclack.symphony'
Defer call orchestra#prelude()
" Defer call orchestra#set_tune('clackclack')

" gitgutter
Plug 'airblade/vim-gitgutter'

" todo
Plug 'machakann/vim-highlightedyank'
Plug 'christianrondeau/vimcastle', {'on': 'Vimcastle'}

Plug 'embear/vim-localvimrc'
let g:localvimrc_persistent = 2
let g:localvimrc_reverse = 1
let g:localvimrc_event = ['BufWinEnter', 'BufRead']

Plug 'wakatime/vim-wakatime'
Plug 'haya14busa/vim-debugger'
Plug 'junegunn/vader.vim'

set undofile
" }}}
" WHY I USED TO HATE VIM {{{
" Backups can be nice but are mostly useless because of autosave
set backupdir=~/.vim-tmp
" Swapfiles are 100% useless for recovery because autosave, so put them on a
" ram disk
set directory=/tmp/vim
" }}}

" fin {{{
call plug#end()
filetype plugin indent on
syntax on
call s:run_deferred()
set secure " exrc should do nothing risky
" }}}
