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
        \ 'colorscheme': 'Tomorrow_Night',
        \ 'component_function': {
        \   'filename': 'LightlineFilename',
        \ },
        \ 'component': {
        \   'modified': "%{&modified ? '•' : ''}",
        \   'readonly': "%{&readonly ? '': ''}",
        \ },
        \ 'component_visible_condition': {
        \   'filetype': 'winwidth(0) >= 70',
        \   'fileencoding': 'winwidth(0) >= 70',
        \   'fileformat': 'winwidth(0) >= 70',
        \ },
        \ 'active': {
        \   'right': [['lineinfo'],
        \             ['percent'],
        \             ['filetype', 'fileencoding', 'fileformat']],
        \ },
        \ 'tabline': {
        \   'right': [[]],
        \ },
        \ }

function! LightlineFilename()
    let fname = expand('%:~:.')
    if fname ==# ''
        let fname = '[No Name]'
    endif
    return fname
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
nnoremap <c-v><c-l> <c-l>

nnoremap <c-s> <c-l>

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

" good stuff from unimpaired
nnoremap <silent> ]q :cnext<cr>
nnoremap <silent> [q :cprev<cr>

" nnoremap <expr> gv "`[".getregtype()[0]."`]"
" }}} 
" IDE {{{

" nothing works if you don't have python
Plug 'roxma/python-support.nvim',
let g:python_support_python2_require = 0
let g:python_support_python3_requirements = []
command! -nargs=* PyRequire
        \ call extend(g:python_support_python3_requirements, [<f-args>])

" fzf: fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
nnoremap <silent> <c-p> :FZF<cr>
let g:fzf_action = {
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit',
        \ }

" autocomplete
let s:completer = 'coc'
set completeopt=menu,noinsert,noselect
set shortmess+=c
if s:completer ==# 'deoplete'
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    let g:deoplete#enable_at_startup = 1
    inoremap <expr> <c-space> deoplete#refresh()
    Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }
elseif s:completer ==# 'ncm'
    Plug 'ncm2/ncm2'
    Plug 'roxma/nvim-yarp'
    autocmd BufEnter * call ncm2#enable_for_buffer()
    let g:ncm2#complete_delay = 1000
    let g:ncm2#popup_delay = 1000
    imap <c-space> <plug>(ncm2_manual_trigger)
elseif s:completer ==# 'coc'
    Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
    highlight link CocErrorVirtualText ErrorMsg
    Defer command! -nargs=1 -bar CocAction call CocAction(<q-args>)
    command! -nargs=1 -bar CocActionSplit call CocAction(<q-args>, <q-mods>.' split')
    function! s:coc_action(provider, action, vim_action, ...)
        if !CocHasProvider(a:provider)
            return a:vim_action
        endif
        return ":call CocAction('".a:action."', '".get(a:, 1, '')."')\<cr>"
    endfunction
    nnoremap <silent> <expr> <c-]> <sid>coc_action('definition', 'jumpDefinition', "\<c-]>")
    nnoremap <silent> <expr> <c-w><c-]> <sid>coc_action('definition', 'jumpDefinition', "\<c-]>", 'split')
    nnoremap <silent> <expr> K <sid>coc_action('hover', 'doHover', "K")
    "let g:coc_node_args = ['--nolazy', '--inspect=6045']
endif
" press tab for the next match
inoremap <expr> <tab> pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <expr> <s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
inoremap <expr> <c-y> pumvisible() ? "\<c-e><c-y>" : "\<c-y>"
inoremap <expr> <c-e> pumvisible() ? "\<c-e><c-e>" : "\<c-e>"
inoremap <expr> <cr> pumvisible() ? "\<c-y><cr>" : "\<cr>"
if s:completer ==# 'coc'
    inoremap <expr> <cr> pumvisible() ? "\<c-y>" : "\<cr>"
    inoremap <expr> <tab> pumvisible() ? "\<c-n>" : coc#jumpable() ? coc#rpc#request('snippetNext', []) : "\<tab>"
    inoremap <expr> <s-tab> pumvisible() ? "\<c-p>" : coc#jumpable() ? coc#rpc#request('snippetPrev', []) : "\<s-tab>"
    snoremap <expr> <tab> coc#jumpable() ? coc#rpc#request('snippetNext', []) : "\<tab>"
    snoremap <expr> <s-tab> coc#jumpable() ? coc#rpc#request('snippetPrev', []) : "\<s-tab>"
endif

if index(['coc'], s:completer) < 0
    Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh' }
    let g:LanguageClient_settingsPath = expand('~/.config/nvim/settings.json')
    let g:LanguageClient_selectionUI = 'location-list'
    let g:LanguageClient_diagnosticsDisplay = {
            \ 1: {"signText": "🛑", "virtualTexthl": "ErrorMsg"},
            \ 2: {"signText": "⚠️"},
            \ 3: {"signText": "ℹ️"},
            \ }
    let g:LanguageClient_diagnosticsList = 'Location'
    function! s:lsp_map()
        nnoremap <buffer> <silent> <c-\> :<c-u>call LanguageClient#textDocument_references()<cr>
        nnoremap <buffer> <silent> <c-]> :<c-u>call LanguageClient#textDocument_definition()<cr>
        nnoremap <buffer> <silent> K :<c-u>call LanguageClient#textDocument_hover()<cr>
        " setlocal formatexpr=LanguageClient#textDocument_rangeFormatting()
        " setlocal formatoptions=
    endfunction
    let g:LanguageClient_serverStderr = '/tmp/clangderr-stderr.log'
    " SAVE ME
    noremap <f9> :<c-u>LanguageClientStop<cr>
    noremap <f10> :<c-u>LanguageClientStart<cr>
    inoremap <f9> <c-o>:<c-u>LanguageClientStop<cr>
    inoremap <f10> <c-o>:<c-u>LanguageClientStart<cr>
else
    function! s:lsp_map()
    endfunction
endif

PyRequire websockets
PyRequire remote-pdb
" }}}
" EDITOR {{{

Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-abolish'
"Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-obsession'
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
nnoremap <silent> <leader>u :UndotreeToggle<cr>

Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-indent'

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

"Plug 'PeterRincker/vim-argumentative'

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
Plug 'ziglang/zig.vim'
Plug 'LnL7/vim-nix'

Plug 'jamessan/vim-gnupg', {'on': []}
let g:GPGUseAgent = 0
" hacks to make this plugin lazy load, thanks blueyed
let g:GPGFilePattern = '*.\(gpg\|asc\|pgp\)'
function! s:autoload_gnupg(aucmd)
    augroup MyGnuPG
        au!
    augroup END
    call plug#load('vim-gnupg')
    exe 'doautocmd' a:aucmd
endfunction
augroup MyGnuPG
    autocmd!
    autocmd BufReadCmd *.\(gpg\|asc\|pgp\) call s:autoload_gnupg('BufReadCmd')
    autocmd FileReadCmd *.\(gpg\|asc\|pgp\) call s:autoload_gnupg('FileReadCmd')
augroup END

let g:xml_syntax_folding = 1
augroup langs
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
    autocmd FileType python iabbrev <buffer> bpoint from celery.contrib import rdb;rdb.set_trace()
    autocmd FileType markdown setlocal foldmethod=manual
    autocmd FileType fzf set laststatus=0 noshowmode noruler
            \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
    autocmd FileType zig setlocal cindent cinoptions=L0
    autocmd FileType go setlocal noexpandtab shiftwidth=8
    autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')
augroup END

augroup lang_detect
    autocmd!
    autocmd BufRead,BufNewFile .babelrc,.eslintrc,.tern-project setfiletype json
    autocmd BufRead,BufNewFile *.S let b:asmsyntax = 'gas'
    autocmd BufRead,BufNewFile changelog.txt setfiletype text
augroup END

set cinoptions=l1,N-s

" the one true indent config
set softtabstop=-1
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
set grepprg=rg\ --no-heading\ --with-filename\ --line-number\ --color\ never
command! -nargs=* -complete=file Ag if <q-args> == '' | grep! <cword> | else | grep! <args> | endif | cwindow | redraw!
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
" Plug 'timeyyy/orchestra.nvim'
" Plug 'timeyyy/clackclack.symphony'
" Defer call orchestra#prelude()
" Defer call orchestra#set_tune('clackclack')

" gitgutter
Plug 'mhinz/vim-signify'
Defer highlight DiffAdd cterm=bold ctermbg=none
Defer highlight DiffChange cterm=bold ctermbg=none
Defer highlight DiffDelete cterm=bold ctermbg=none
let g:signify_sign_change = '~'
let g:signify_sign_delete = '-'
"let g:signify_realtime = 1

" todo
Plug 'machakann/vim-highlightedyank'
Plug 'christianrondeau/vimcastle', {'on': 'Vimcastle'}

Plug 'embear/vim-localvimrc'
let g:localvimrc_persistent = 2
let g:localvimrc_reverse = 1
let g:localvimrc_event = ['BufWinEnter']

Plug 'wakatime/vim-wakatime'
Plug 'haya14busa/vim-debugger'
Plug 'junegunn/vader.vim'
Plug 'powerman/vim-plugin-AnsiEsc'

set undofile
" }}}
" WHY I USED TO HATE VIM {{{
" Backups can be nice but are mostly useless because of autosave
set backup
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
