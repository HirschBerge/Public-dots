function get_hostname()
    local f = io.popen("hostname")
    local hostname = f:read("*a")
    f:close()
    return string.gsub(hostname, "\n", "")  -- Remove trailing newline
end

-- Construct the file path with the replaced "shirohebi"
local file_path = vim.fn.expand("$HOME") .. "/.dotfiles/" .. get_hostname() .. "/gpt.txt.gpg"


require("chatgpt").setup({
    api_key_cmd = "gpg --decrypt " .. file_path
})
local autopairs = require('nvim-autopairs')
autopairs.setup()

-- Color Highlighting
require('nvim-highlight-colors').setup {
    enable_named_colors = true,
}

--Todo Comments
require('todo-comments').setup()

-- Zellij
require('zellij').setup()
vim.api.nvim_create_autocmd({ 'DirChanged', 'WinEnter', 'BufEnter' }, {
  pattern = '*',
  callback = function()
    vim.fn.system('zellij action rename-pane "' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t') .. '"')
  end,
})
-- Map Alt + hjkl to ZellijNavigate commands
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Alt+h to ZellijNavigateLeft
map('n', '<A-h>', ':ZellijNavigateLeft<CR>', opts)
map('i', '<A-h>', '<ESC>:ZellijNavigateLeft<CR>', opts)
map('v', '<A-h>', '<ESC>:ZellijNavigateLeft<CR>', opts)

-- Alt+j to ZellijNavigateDown
map('n', '<A-j>', ':ZellijNavigateDown<CR>', opts)
map('i', '<A-j>', '<ESC>:ZellijNavigateDown<CR>', opts)
map('v', '<A-j>', '<ESC>:ZellijNavigateDown<CR>', opts)

-- Alt+k to ZellijNavigateUp
map('n', '<A-k>', ':ZellijNavigateUp<CR>', opts)
map('i', '<A-k>', '<ESC>:ZellijNavigateUp<CR>', opts)
map('v', '<A-k>', '<ESC>:ZellijNavigateUp<CR>', opts)

-- Alt+l to ZellijNavigateRight
map('n', '<A-l>', ':ZellijNavigateRight<CR>', opts)
map('i', '<A-l>', '<ESC>:ZellijNavigateRight<CR>', opts)
map('v', '<A-l>', '<ESC>:ZellijNavigateRight<CR>', opts)


-- This module contains a number of default definitions
local rainbow_delimiters = require 'rainbow-delimiters'

---@type rainbow_delimiters.config
vim.g.rainbow_delimiters = {
    strategy = {
        [''] = rainbow_delimiters.strategy['global'],
        vim = rainbow_delimiters.strategy['local'],
    },
    query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
    },
    priority = {
        [''] = 110,
        lua = 210,
    },
    highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
    },
}
