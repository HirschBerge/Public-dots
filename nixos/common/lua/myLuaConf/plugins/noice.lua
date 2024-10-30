-- noice.nvim setup
require("noice").setup({
    lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true -- requires hrsh7th/nvim-cmp
        }
    },
    -- you can enable a preset for easier configuration
    presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false -- add a border to hover docs and signature help
    },
    dependencies = {"MunifTanjim/nui.nvim", "rcarriga/nvim-notify"}
})
-- nvim-notify setup
require("notify").setup({
    opts = {
        timeout = 3000,
        max_height = function() return math.floor(vim.o.lines * 0.75) end,
        max_width = function() return math.floor(vim.o.columns * 0.75) end
    },
    background_colour = "#cba6f7"
})
vim.keymap
    .set("n", "<leader>dn", function() require("noice").cmd("dismiss") end)
local function firstToUpper(str) return (str:gsub("^%l", string.upper)) end

local function greet_user()
    -- Get the $USER environment variable
    local user = vim.fn.getenv("USER")
    local upper_user = firstToUpper(user)

    -- Construct the message
    local message = "Hello, " .. upper_user .. "\\n0x45 is my favorite number."

    -- Echo the message in Neovim
    vim.cmd('echo "' .. message .. '"')
end

-- Set an autocmd for the VimEnter event to echo the message
vim.api.nvim_create_autocmd("VimEnter", {callback = greet_user})
