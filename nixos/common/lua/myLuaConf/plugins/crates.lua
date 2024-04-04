local crates  = require('crates')
crates.setup({
    smart_insert = true,
    insert_closing_quote = true,
    avoid_prerelease = true,
})
-- require('cmp').setup.buffer({
  -- sources = { { name = "crates" }}
-- })
crates.show()
-- Rust Tools
local rt = require("rust-tools")
rt.setup({
  -- dap = {
  --   adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
  -- },
  server = {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
      vim.keymap.set("n", "<Leader>ca", rt.code_action_group.code_action_group, { buffer = bufnr, desc = "[C]ode [A]ction" })
      vim.keymap.set("n", "<Leader>ca", rt.code_action_group.rename, { buffer = bufnr, desc = "[C]ode [R]ename" })
    end,
  },
  tools = {
    hover_actions = {
      auto_focus = true,
    },
  },
})

-- Dap

require("dapui").setup()

local dap, dapui = require("dap"), require("dapui")

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

vim.keymap.set("n", "<Leader>db", ':DapToggleBreakpoint<CR>', {desc = "Debug Breakpoint"})
vim.keymap.set("n", "<Leader>dx", ':DapTerminate<CR>',{desc = "Debug Exit"})
vim.keymap.set("n", "<Leader>do", ':DapStepOver<CR>',{desc = "Debug Next Point"} )
