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
