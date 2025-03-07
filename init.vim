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
lua <<EOF
table = require('table')
deferred = {}
function defer(f)
    table.insert(deferred, f)
end
EOF
" }}}

" despite my best efforts, fish still takes 50-100ms to start
set shell=/bin/bash

call plug#begin()

" UI {{{
Plug 'tbodt/vim-colors-tbodt'
Defer colorscheme bare

" lightline {{{
Plug 'itchyny/lightline.vim'
let g:lightline = {
        \ 'colorscheme': 'bare',
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

function! s:lightline_colorscheme(colorscheme)
    let g:lightline.colorscheme = a:colorscheme
    call lightline#init()
    call lightline#colorscheme()
    call lightline#update()
endfunction
command! -nargs=1 LightlineColorscheme call <sid>lightline_colorscheme(<q-args>)

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

Plug 'dstein64/nvim-scrollview', {'branch': 'main'}
highlight ScrollView ctermbg=8
let g:scrollview_column = 1

" }}}
" MAPPINGS {{{
let mapleader = "\<space>"

" wtf nvim!!!
silent! unmap Y

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
let g:python3_host_prog = 'python3'
let g:python_support_python3_requirements = []
command! -nargs=* PyRequire
        \ call extend(g:python_support_python3_requirements, [<f-args>])

" fzf: fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
nnoremap <c-p> :FZF<cr>
let g:fzf_action = {
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit',
        \ }
let g:fzf_layout = {'down': '30%'}

" lsp
Plug 'neovim/nvim-lspconfig'
lua << EOF
defer(function()
require'lspconfig'.clangd.setup{}
require'lspconfig'.gopls.setup{}
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    update_in_insert = true,
  }
)
vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename)
vim.keymap.set('n', '<ctrl-\\>', vim.lsp.buf.references)
end)
EOF
sign define LspDiagnosticsSignError text=🛑 texthl=LspDiagnosticsSignError linehl= numhl=
sign define LspDiagnosticsSignWarning text=⚠️" texthl=LspDiagnosticsSignWarning linehl= numhl=
sign define LspDiagnosticsSignInformation text=ℹ️" texthl=LspDiagnosticsSignInformation linehl= numhl=

" autocomplete
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
lua << EOF
defer(function()
local cmp = require 'cmp'
local luasnip = require 'luasnip'
cmp.setup{
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = {
        ['<cr>'] = cmp.mapping.confirm({select = false}),
        ['<c-space>'] = cmp.mapping.complete(),
        ['<tab>'] = function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback()
            end
        end,
        ['<s-tab>'] = function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback()
            end
        end,
    },
    completeopt = 'menuone,noselect',
    sources = {
        { name = 'nvim_lsp' },
    },
}
end)
--let g:compe = {}
--let g:compe.enabled = v:true
--let g:compe.source = {
        --\ 'path': v:true,
        --\ 'buffer': v:true,
        --\ 'nvim_lsp': v:true,
        --\ 'throttle_time': 0,
        --\ }
-- press tab for the next match
function _G.last_char_is_space()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then return false else return true end
end
EOF
"inoremap <expr> <tab> pumvisible() ? "\<c-n>" : v:lua.last_char_is_space() ? compe#complete() : "\<tab>"
"inoremap <expr> <s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
"inoremap <expr> <c-y> pumvisible() ? "\<c-e><c-y>" : "\<c-y>"
"inoremap <expr> <c-e> pumvisible() ? "\<c-e><c-e>" : "\<c-e>"

Plug 'mfussenegger/nvim-dap'
Plug 'nvim-neotest/nvim-nio'
Plug 'rcarriga/nvim-dap-ui'
lua << EOF
defer(function()
local dap = require'dap'
dap.adapters.php = {
  type = 'executable',
  command = 'node',
  args = { '/Users/tbodt/.local/share/nvim/plugged/nvim-dap/dap/vscode-php-debug/out/phpDebug.js' }
}

dap.configurations.php = {
  {
    type = 'php',
    request = 'launch',
    name = 'Listen for Xdebug',
    port = 9003
  }
}

local dapui = require("dapui")
require("dapui").setup()
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>c', function() require('dap').continue() end)
vim.keymap.set('n', '<Leader>n', function() require('dap').step_over() end)
vim.keymap.set('n', '<Leader>s', function() require('dap').step_into() end)
vim.keymap.set('n', '<Leader>f', function() require('dap').step_out() end)

end)
EOF
" }}}
" EDITOR {{{

Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-fugitive'
set previewheight=30
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-rsi'
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
nnoremap <silent> <leader>u :UndotreeToggle<cr>

Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-indent'

Plug 'stefandtw/quickfix-reflector.vim'
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
    autocmd BufWritePre *.go lua vim.lsp.buf.format()
augroup END

augroup lang_detect
    autocmd!
    autocmd BufRead,BufNewFile .babelrc,.eslintrc,.tern-project setfiletype json
    autocmd BufRead,BufNewFile *.S let b:asmsyntax = 'gas'
    autocmd BufRead,BufNewFile changelog.txt setfiletype text
    autocmd BufRead,BufNewFile *.suml setfiletype yaml
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
    autocmd FocusGained * checktime
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
set grepprg=rg\ --no-heading\ --with-filename\ --line-number\ --column\ --color\ never
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

" obsession obsession
let s:reading_from_stdin = 0
augroup obsobs
    autocmd!
    autocmd StdinReadPre * let s:reading_from_stdin = 1
    autocmd VimEnter * if argc() == 0 && !s:reading_from_stdin && filereadable("session.vim") | source session.vim | endif
augroup END

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
let g:signify_sign_change = '~'
let g:signify_sign_delete = '-'
augroup my_signify
    autocmd!
    autocmd User SignifyAutocmds exe 'autocmd! signify | autocmd signify TextChanged,InsertLeave * call sy#start()'
augroup END

" todo
Plug 'machakann/vim-highlightedyank'
Plug 'christianrondeau/vimcastle', {'on': 'Vimcastle'}

Plug 'embear/vim-localvimrc'
let g:localvimrc_persistent = 2
let g:localvimrc_reverse = 1
let g:localvimrc_event = ['BufWinEnter']

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
lua for i, f in ipairs(deferred) do f() end
set secure " exrc should do nothing risky
" }}}
