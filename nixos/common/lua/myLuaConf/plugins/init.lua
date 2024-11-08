local colorschemeName = nixCats('colorscheme')
if not require('nixCatsUtils').isNixCats then colorschemeName = 'tokyonight' end
vim.cmd.colorscheme(colorschemeName)

require('myLuaConf.plugins.telescope')
require('myLuaConf.plugins.null-ls')
require('myLuaConf.plugins.startify')
require('myLuaConf.plugins.treesitter')
require('myLuaConf.plugins.crates')
require('myLuaConf.plugins.completion')
require('myLuaConf.plugins.noice')
require('myLuaConf.plugins.other')
require('myLuaConf.plugins.renamer')
-- HACK: in case I can't get an lsp to be configured correctly in the main lsp bit
require('myLuaConf.plugins.lspconfig')

if nixCats('markdown') then
    vim.g.mkdp_auto_close = 0
    vim.keymap.set('n', '<leader>Mp', '<cmd>MarkdownPreview <CR>',
        { noremap = true, desc = 'markdown preview' })
    vim.keymap.set('n', '<leader>Ms', '<cmd>MarkdownPreviewStop <CR>',
        { noremap = true, desc = 'markdown preview stop' })
    vim.keymap.set('n', '<leader>Mt', '<cmd>MarkdownPreviewToggle <CR>',
        { noremap = true, desc = 'markdown preview toggle' })
end

vim.keymap.set('n', '<leader>U', vim.cmd.UndotreeToggle, { desc = "Undo Tree" })
vim.g.undotree_WindowLayout = 1
vim.g.undotree_SplitWidth = 40

vim.cmd([[hi clear @lsp.type.parameter]])
vim.cmd([[hi link @lsp.type.parameter Hlargs]])
require('Comment').setup()

require('fidget').setup()

local custom_palenight = require('lualine.themes.palenight')
local mauve = '#cba6f7'

-- use emotes for mode names

local mode_map = {
    n = "パワー N",
    nt = "パワー N",
    i = "ホロ Ins",
    R = "忍野忍 Rep",
    v = "👀 ",
    V = "👀 ",
    no = "What is this mode?",
    ["\22"] = "(⊙ _ ⊙ )",
    t = "(⌐■_■)",
    ['!'] = " ",
    c = " ",
    s = "SUB"
}
custom_palenight.normal.c.fg = mauve
custom_palenight.inactive.c.fg = mauve
custom_palenight.inactive.b.fg = mauve

local lualine = require('lualine')
lualine.setup {
    options = {
        icons_enabled = true,
        theme = custom_palenight,
        component_separators = '┆',
        section_separators = { right = "", left = "" }
    },
    sections = {
        lualine_a = {
            {
                "mode",
                icons_enabled = true,
                fmt = function()
                    return mode_map[vim.api.nvim_get_mode().mode] or
                        vim.api.nvim_get_mode().mode
                end
            }
        },
        lualine_c = { { 'filename', path = 1, status = true } }
    }
}
require('nvim-surround').setup()

-- indent-blank-line
require("ibl").setup()

require('gitsigns').setup({
    -- See `:help gitsigns.txt`
    signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' }
    },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs',
            function() gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end,
            { desc = 'stage git hunk' })
        map('v', '<leader>hr',
            function() gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end,
            { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>gs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>gS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>gR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>gp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>gb', function() gs.blame_line { full = false } end,
            { desc = 'git blame line' })
        map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>gD', function() gs.diffthis '~' end,
            { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame,
            { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted,
            { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>',
            { desc = 'select git hunk' })
    end
})
vim.cmd([[hi GitSignsAdd guifg=#04de21]])
vim.cmd([[hi GitSignsChange guifg=#83fce6]])
vim.cmd([[hi GitSignsDelete guifg=#fa2525]])

require("oil").setup({
    columns = { "icon", "permissions", "size", "mtime" },
    keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = "actions.select_vsplit",
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",

        -- Which-key does not like this keybind AT ALL
        -- ["g\\"] = "actions.toggle_trash",
        ["g!"] = "actions.toggle_trash",
        ["g\\"] = false
    }
})
vim.keymap.set("n", "-", "<cmd>Oil<CR>",
    { noremap = true, desc = 'Open Parent Directory' })
vim.keymap.set("n", "<leader>-", "<cmd>Oil .<CR>",
    { noremap = true, desc = 'Open nvim root directory' })
-- Which key has kind-of a lot of bugs.
-- Nix or not, some things need to be disabled.

-- NOTE: Default state on
require('gitsigns').toggle_deleted()
package.loaded.gitsigns.toggle_current_line_blame()
