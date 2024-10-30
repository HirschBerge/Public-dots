local telescope_builtin = require('telescope.builtin')
if not telescope_builtin then error('Failed to load telescope.builtin') end

vim.keymap.set("n", "J", "mzJ`z")
vim.api.nvim_set_keymap('n', '<C-w>', '<C-w>', { noremap = true, silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "LSP formatting" })
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>",
    { silent = true, desc = "Set file e[X]ecutable" })

vim.api.nvim_set_keymap('n', '<leader>/',
    ':lua require("Comment.api").toggle.linewise.current()<CR>',
    { noremap = true, silent = true, desc = "Comment line" })
vim.api.nvim_set_keymap('v', '<leader>/',
    ':lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>',
    { noremap = true, silent = true, desc = "Toggle comment" })

vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ps", "<cmd> Telescope live_grep <CR>",
    { desc = "Telescope Grep" })
vim.keymap.set("n", "<leader>fg", "<cmd> Telescope git_files  <CR>",
    { desc = "Telescope Grep" })
vim.keymap.set("n", "<leader>ff", "<cmd> Telescope find_files <CR>",
    { desc = "Find files" })
vim.keymap.set("n", "<leader>fa",
    "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>",
    { desc = "Find all" })
vim.keymap.set("n", "<leader>fw", "<cmd> Telescope live_grep <CR>",
    { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd> Telescope buffers <CR>",
    { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd> Telescope help_tags <CR>",
    { desc = "Help page" })
vim.keymap.set("n", "<leader>fo", "<cmd> Telescope oldfiles <CR>",
    { desc = "Find oldfiles" })
vim.keymap.set("n", "<leader>fz",
    "<cmd> Telescope current_buffer_fuzzy_find <CR>",
    { desc = "Find in current buffer" })
vim.keymap.set("n", "<leader>ft", "<cmd> TodoTelescope <CR>",
    { desc = "Telescope TODO items" })
vim.keymap.set("n", '<leader>fd', telescope_builtin.lsp_definitions,
    { desc = '[F]ind [D]efinition' })
vim.keymap.set("n", '<leader>fr', telescope_builtin.lsp_references,
    { desc = '[F]ind [R]eferences' })
vim.keymap.set("n", '<leader>fi', telescope_builtin.lsp_implementations,
    { desc = '[F]ind [I]mplementation' })
vim.keymap.set("n", '<leader>ds', telescope_builtin.lsp_document_symbols,
    { desc = '[D]ocument [S]ymbols' })
vim.keymap.set("n", '<leader>ws',
    telescope_builtin.lsp_dynamic_workspace_symbols,
    { desc = '[W]orkspace [S]ymbols' })
vim.keymap.set("n", '<leader>fl', telescope_builtin.resume,
    { desc = '[F]ind [L]ast Search' })
-- vim.keymap.set("n", '<leader>wd', telescope_builtin.diagnostics, { buffer = 0, desc = '[W]orkspace [D]iagnostics'})
-- Define a keybinding for workspace diagnostics
vim.keymap.set("n", '<leader>wd', function()
    -- Invoke the diagnostics picker with the 'bufnr' set to 0 for workspace diagnostics
    telescope_builtin.diagnostics({
        bufnr = nil -- Specify workspace diagnostics
    })
end, { desc = '[W]orkspace [D]iagnostics' })

vim.keymap.set("n", "<Leader>db", ':DapToggleBreakpoint<CR>',
    { desc = "Debug Breakpoint" })
vim.keymap.set("n", "<Leader>dx", ':DapTerminate<CR>', { desc = "Debug Exit" })
vim.keymap.set("n", "<Leader>do", ':DapStepOver<CR>',
    { desc = "Debug Next Point" })

vim.keymap.set("n", "<Leader>cf", "<cmd>lua vim.lsp.buf.format()<CR>",
    { desc = "[C]ode [F]ormat" })

-- Git
vim.keymap.set("n", "<leader>cm", "<cmd> Telescope git_commits <CR>",
    { desc = "Git commits" })
vim.keymap.set("n", "<leader>gt", "<cmd> Telescope git_status <CR>",
    { desc = "Git status" })

vim.keymap.set("n", "<leader>fm", "<cmd> Telescope marks <CR>",
    { desc = "Telescope bookmarks" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
    { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
    { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float,
    { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist,
    { desc = 'Open diagnostics list' })

vim.keymap.set("n", "<leader>e", "<cmd> Neotree toggle <CR>",
    { desc = "Toggle Neotree" })
vim.keymap.set("n", "<leader>E", "<cmd> Neotree focus <CR>",
    { desc = "Focus Neotree" })

-- Add in Shebangs
function insert_shebang()
    local ft = vim.bo.filetype
    local shebang_lines = {
        lua = '#!/usr/bin/env lua',
        python = '#!/usr/bin/env python',
        sh = '#!/usr/bin/env bash',
        nu = '#!/usr/bin/env nu'
        -- Add more filetypes and shebang lines as needed
    }

    local shebang = shebang_lines[ft]

    if shebang then
        local current_lines = vim.fn.getline(1, '$')
        table.insert(current_lines, 1, shebang)
        vim.fn.setline(1, current_lines)
    end
end

vim.api.nvim_set_keymap('n', '<Leader>cs', '<Cmd>lua insert_shebang()<CR>',
    { noremap = true, silent = true })
