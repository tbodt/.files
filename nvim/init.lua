-- vim:foldmethod=marker

-- === utility === {{{

vim.loader.enable()

if vim.env.PROF then
    vim.cmd.packadd 'snacks.nvim'
    require'snacks.profiler'.startup{ startup = { event = "VimEnter" } }
end

local augroup = vim.api.nvim_create_augroup('vimrc', {})
local function autocmd(event, opts)
	vim.api.nvim_create_autocmd(event, vim.tbl_extend('force', opts, { group = augroup }))
end

local function after_ui(func)
    autocmd('VimEnter', { once = true, callback = function() vim.schedule(func) end })
end

-- }}}

-- === visual === {{{

-- colorscheme
vim.pack.add{'https://github.com/tbodt/vim-colors-tbodt'}
vim.cmd.colorscheme 'bare'

-- statusline
vim.pack.add{'https://github.com/nvim-lualine/lualine.nvim'}
local ll_filename = {
    'filename',
    path = 1,
    symbols = {
        modified = '•',
        readonly = '',
    },
}
after_ui(function()
    require'lualine'.setup{
        options = {
            theme = 'bare',
            icons_enabled = false,
            section_separators = '',
            component_separators = '|',
            always_show_tabline = false,
        },
        sections = {
            lualine_b = {ll_filename},
            lualine_c = {'branch', 'diff', 'diagnostics', 'lsp_status'},
        },
        inactive_sections = {
            lualine_c = {ll_filename},
        },
        tabline = {
            lualine_b = { { 'tabs', max_length = vim.o.columns, mode = 2, path = 1 } },
        },
    }
end)

-- don't clutter up the bottom with -- INSERT -- when this is already in the statusline
vim.opt.showmode = false

-- line numbers
vim.opt.number = true

-- scroll before the screen edge
vim.opt.scrolloff = 10

-- show tabs and trailing space
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '●' }

-- scrollbar
vim.pack.add{'https://github.com/dstein64/nvim-scrollview'}
vim.api.nvim_set_hl(0, 'ScrollView', {ctermbg = 8})

-- neovim ui2 is just better
require('vim._core.ui2').enable()

-- defined edges on popup windows
vim.opt.winborder = 'rounded'

-- search
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.keymap.set('n', '<esc>', vim.cmd.nohlsearch)

-- highlighted yank
autocmd('TextYankPost', { callback = function() vim.hl.on_yank{timeout = 500} end })

--- }}}

-- i guess i like this leader better...
vim.g.mapleader = vim.keycode'<space>'

-- no mouse in insert mode
vim.opt.mouse:remove('i')

-- swap : and ,
vim.keymap.set({'n','v','o'}, ',', ':')
vim.keymap.set({'n','v','o'}, ':', ',')

-- window movement
vim.keymap.set('n', '<c-j>', '<c-w><c-j>')
vim.keymap.set('n', '<c-k>', '<c-w><c-k>')
vim.keymap.set('n', '<c-l>', '<c-w><c-l>')
vim.keymap.set('n', '<c-h>', '<c-w><c-h>')
vim.keymap.set('n', '<c-s>', '<c-l>') -- alternate screen redraw map

-- wtf nvim default!11
pcall(vim.keymap.del, 'n', 'Y')

-- default g flag on s command
vim.opt.gdefault = true

-- autosave
autocmd({'FocusLost', 'BufLeave'}, { command = [[silent! update]], nested = true })
vim.opt.autowriteall = true
-- autoload
autocmd({'FocusGained'}, { command = [[checktime]] })

-- undo greatness!
vim.opt.undofile = true
vim.cmd.packadd'nvim.undotree'
vim.keymap.set('ca', 'u', 'Undotree')

-- exrc! now with trust!
vim.opt.exrc = true

-- grep to quickfix
vim.opt.shell = '/bin/bash' -- fish takes too long to start
vim.opt.shellpipe = '>'
vim.opt.grepprg = 'rg --vimgrep'

-- quickfix goodness
autocmd('QuickFixCmdPost', { pattern = '[^l]*', command = [[cwindow]], nested = true })
autocmd('QuickFixCmdPost', { pattern = 'l*', command = [[lwindow]], nested = true })
vim.pack.add{'https://github.com/stevearc/quicker.nvim'}
require'quicker'.setup{}

-- surround
vim.pack.add{'https://github.com/tpope/vim-repeat'}
vim.pack.add{'https://github.com/tpope/vim-surround'}

-- sessions
vim.pack.add{'https://github.com/tpope/vim-obsession'}
vim.g.reading_from_stdin = false
autocmd('StdinReadPre', { callback = function() vim.g.reading_from_stdin = true end })
autocmd('VimEnter', { callback = function()
    if vim.fn.argc() ~= 0 then return end
    if vim.g.reading_from_stdin then return end
    if vim.fn.filereadable('Session.vim') ~=0 then vim.cmd.source('Session.vim') end
end, nested = true })

-- let's have some lsp
vim.pack.add{
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/mason-org/mason.nvim',
    'https://github.com/mason-org/mason-lspconfig.nvim',
}
after_ui(function()
    require'mason'.setup{}
    require'mason-lspconfig'.setup{}

    -- lua lsp, for vimrc itself in particular
    vim.pack.add{'https://github.com/folke/lazydev.nvim'}
    require'lazydev'.setup{}

    vim.lsp.enable'clangd'
end)

-- redo completion bindings
vim.opt.completeopt = {'menu', 'fuzzy'}
vim.keymap.set({'i', 's'}, '<tab>', function()
    local prefix = vim.fn.getline('.'):sub(0, vim.fn.col('.')-1)
    if vim.fn.pumvisible() ~= 0 then
        return '<c-n>'
    elseif vim.snippet.active({direction = 1}) then
        vim.snippet.jump(1)
    elseif prefix ~= "" and prefix:match('%s', prefix:len()) == nil then -- non-space before cursor
        return '<c-x><c-o>'
    else
        return '<tab>'
    end
end, { expr = true })
vim.keymap.set({'i', 's'}, '<s-tab>', function()
    if vim.fn.pumvisible() ~= 0 then
        return '<c-p>'
    elseif vim.snippet.active({direction = -1}) then
        vim.snippet.jump(-1)
    else
        return '<s-tab>'
    end
end, { expr = true })

-- make lsp progress messages real
autocmd('LspProgress', { callback = function(ev)
    local value = ev.data.params.value
    vim.api.nvim_echo({ { value.message or 'done' } }, true, {
        id = 'lsp.' .. ev.data.params.token,
        kind = 'progress',
        source = 'vim.lsp',
        title = value.title,
        status = value.kind ~= 'end' and 'running' or 'success',
        percent = value.percentage,
    })
end })

-- favorite indent config
vim.opt.shiftwidth = 4
vim.opt.softtabstop = -1
vim.opt.expandtab = true

-- quick vimrc edit
vim.keymap.set('n', '<leader>v', function() vim.cmd.tabedit(vim.env.MYVIMRC) end)

-- jump to last position
autocmd('BufReadPost', { callback = function(opts)
    local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
    if last_known_line > 1 and last_known_line <= vim.api.nvim_buf_line_count(opts.buf) then
        vim.api.nvim_feedkeys([[g`"]], 'nx', false)
    end
end })

-- in c/c++, don't indent case labels, and the inside of namespace blocks
vim.opt.cinoptions:append {'l1', 'N-s'}

vim.pack.add{'https://github.com/tpope/vim-vinegar.git'}
vim.g.netrw_liststyle = 3

vim.pack.add{'https://github.com/ibhagwan/fzf-lua'}
vim.keymap.set('n', '<c-p>', function() require'fzf-lua'.global() end)

vim.pack.add{'https://github.com/wellle/targets.vim'}

-- todo
-- - git signs
-- - dap
-- - text objects
