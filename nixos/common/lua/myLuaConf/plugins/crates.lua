local crates = require('crates')
crates.setup({
    smart_insert = true,
    insert_closing_quote = true
    -- avoid_prerelease = true,
})
-- require('cmp').setup.buffer({
-- sources = { { name = "crates" }}
-- })
crates.show()

vim.g.rustaceanvim = {
    dap = { adapter = require('dap').adapters.lldb },
    server = {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        on_attach = function(_, bufnr)
            local format_sync_grp = vim.api.nvim_create_augroup("RustaceanFormat", {})
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function() vim.lsp.buf.format() end,
                group = format_sync_grp,
            })
            vim.keymap.set("n", "K",
                function()
                    vim.cmd.RustLsp { 'hover', 'actions' }
                end, { buffer = bufnr })
            vim.keymap.set("n", "J",
                function() vim.cmd.RustLsp('joinLines') end,
                { buffer = bufnr })
            vim.keymap.set("n", "<Leader>ca",
                function() vim.cmd.RustLsp('codeAction') end,
                { buffer = bufnr, desc = "[C]ode [A]ction" })
            vim.keymap.set("n", "<Leader>ce", function()
                vim.cmd.RustLsp({ 'explainError', 'cycle' })
            end, { buffer = bufnr, desc = "[C]ode [E]plained" })
            vim.keymap.set("n", "<Leader>cd",
                function() vim.cmd.RustLsp('openDocs') end,
                { buffer = bufnr, desc = "[C]ode [D]ocs" })
            vim.keymap.set("n", "<Leader>cR", function()
                vim.cmd.RustLsp { 'runnables', bang = false }
            end, { buffer = bufnr, desc = "[C]ode [R]unnables" })
            vim.keymap.set("n", "<Leader>cT", function()
                vim.cmd.RustLsp { 'testables', bang = false }
            end, { buffer = bufnr, desc = "[C]ode [T]ests" })
            vim.keymap.set("n", "<Leader>cD", function()
                vim.cmd.RustLsp { 'debuggables', bang = false }
            end, { buffer = bufnr, desc = "[C]ode [D]ebug" })
            vim.api.nvim_set_keymap('n', '<leader>cu',
                ':lua require("crates").upgrade_all_crates()<CR>', {
                    noremap = true,
                    silent = true,
                    desc = "[C]rates [U]rgrade"
                })
            vim.api.nvim_set_keymap('n', '<leader>cr',
                '<cmd>lua require("renamer").rename()<cr>',
                {
                    noremap = true,
                    silent = true,
                    desc = "[C]ode [R]ename"
                })
            vim.keymap.set("n", "<Leader>cv", function()
                vim.cmd("vsplit")            -- Open a vertical split
                vim.cmd("wincmd h")          -- Move to the left split
                vim.cmd.RustLsp('openCargo') -- Execute the RustLsp command in the left split
            end, { buffer = bufnr, desc = "[C]argo [V]iew" })
        end
    },
    settings = {
        ["rust-analyzer"] = {
            rustdoc = {
                enable = true,
            },
            cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
            },
            checkOnSave = {
                allFeatures = true,
                command = "clippy",
                extraArgs = {
                    "--", "--no-deps", "-Dclippy::correctness",
                    "-Dclippy::complexity", "-Wclippy::perf",
                    "-Wclippy::pedantic",
                },
            },
            procMacro = {
                enable = true,
                ignored = {
                    ["async-trait"] = { "async_trait" },
                    ["napi-derive"] = { "napi" },
                    ["async-recursion"] = { "async_recursion" },
                },
            },
        },
    },
    tools = { hover_actions = { auto_focus = true } }
}
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    update_in_insert = true,
    underline = true,
    severity_sort = false,
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = ""
    }
})
-- Dap

require("dapui").setup()

local dap, dapui = require("dap"), require("dapui")

dap.listeners.after.event_initialized["dapui_config"] =
    function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] =
    function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
local focusGained = false -- Flag to track FocusGained event

-- Autocommand for FocusGained
vim.api.nvim_create_autocmd("FocusGained", {
    callback = function()
        if not focusGained then
            -- Execute shell command using system()
            vim.fn.system("!zellij action switch-mode locked")
            focusGained = true
        end
    end
})

-- Autocommand for FocusLost
vim.api.nvim_create_autocmd("FocusLost", {
    callback = function()
        -- Execute shell command using system()
        vim.fn.system("!zellij action switch-mode normal")
        focusGained = false -- Reset the flag
    end
})
