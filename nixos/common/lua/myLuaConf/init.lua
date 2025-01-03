#!/usr/bin/env lua

require("myLuaConf.plugins")
require("myLuaConf.LSPs")
require('myLuaConf.format')
require('myLuaConf.autocmds')
require('myLuaConf.mappings')

if nixCats('debug') then require('myLuaConf.debug') end
vim.opt.wrap = false
vim.cmd('set clipboard+=unnamedplus')
vim.cmd([[colorscheme tokyonight]])
-- NOTE: transparency. Is there a better way? Surely, but idk
-- Set transparency for all modes
vim.cmd([[ hi Normal guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi SignColumn guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi VertSplit guibg=NONE ctermbg=NONE ]])
-- Telecope
-- vim.cmd([[ hi TelescopeNormal guibg=NONE ctermbg=NONE ]])
-- vim.cmd([[ hi TelescopeBorder guibg=NONE ctermbg=NONE ]])
-- NeoTree background
vim.cmd([[ hi NeoTreeNormalNC guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi NeoTreeNormalNC guibg=NONE ctermbg=NONE ]])
-- Set transparency for specific mode
vim.cmd([[ hi NormalNC guibg=NONE ctermbg=NONE ]])
-- Set transparency for floating windows
vim.cmd([[ hi NormalFloat guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi FloatBorder guibg=NONE ctermbg=NONE ]])
-- Disable background color for transparent terminal
vim.cmd([[ hi Normal guibg=NONE ctermbg=NONE ]])
-- Set transparency for statusline and tabline (if applicable)
vim.cmd([[ hi StatusLine guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi StatusLineNC guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi TabLine guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi TabLineFill guibg=NONE ctermbg=NONE ]])
-- Adjust alpha (transparency) level for floating windows (requires Neovim 0.5+)
vim.cmd([[ hi NormalFloat guibg=NONE ctermbg=NONE blend=alpha ]])
vim.cmd([[ hi FloatBorder guibg=NONE ctermbg=NONE blend=alpha ]])
-- If you are using Neovim with a GUI (e.g., Neovim-Qt), you might need the following
vim.cmd([[ hi Normal guibg=NONE ctermbg=NONE term=NONE ]])
-- Disable background for terminal
vim.cmd([[ hi TermNormal guibg=NONE ctermbg=NONE ]])
-- If you are using a GUI, you might want to set the transparency of the whole window
vim.cmd([[ hi NormalNC guibg=NONE ctermbg=NONE term=NONE ]])
vim.cmd 'set termguicolors'
vim.cmd 'set t_Co=256'

-- NOTE:Unmap <C-a> from the current mapping (which selects all)
vim.api.nvim_set_keymap('n', '<C-a>', '<Nop>', { noremap = true })

-- Remap <C-a> to execute the CTRL-A command
vim.api.nvim_set_keymap('n', '<C-a>', '<cmd>execute "normal! <C-A>"<CR>',
                    { noremap = true })
-- NOTE: Folders
vim.cmd('set foldlevel=20')
vim.o.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.scrolloff = 15
-- NOTE:Color ofLine numbering
-- -- Change the color of regular line numbers (LineNr)
vim.api.nvim_set_hl(0, "LineNr", { fg = "#cba6f7" })
-- Doesn't work???
-- -- Change the color of the current line number (CursorLineNr)
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#D2F7A6" })
-- Enables inlay hints
vim.lsp.inlay_hint.enable()
vim.api.nvim_set_hl(0, 'LspInlayHint',
                    { fg = '#cba6f7', bg = '#11111b', italic = true })
