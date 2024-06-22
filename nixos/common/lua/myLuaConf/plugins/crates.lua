local crates = require('crates')
crates.setup({
  smart_insert = true,
  insert_closing_quote = true,
  -- avoid_prerelease = true,
})
-- require('cmp').setup.buffer({
-- sources = { { name = "crates" }}
-- })
crates.show()
-- Rust Tools
local rt = require("rust-tools")
rt.setup({
  dap = {
    adapter = require('dap').adapters.lldb
  },
  server = {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
      vim.keymap.set("n", "<Leader>ca", rt.code_action_group.code_action_group,
        { buffer = bufnr, desc = "[C]ode [A]ction" })
      vim.keymap.set("n", "<Leader>ca", rt.code_action_group.rename, { buffer = bufnr, desc = "[C]ode [R]ename" })
      vim.keymap.set("n", "<leader>cv", rt.open_cargo_toml.open_cargo_toml, { buffer = bufnr, desc = "[C]argo [V]iew" })
    end,
  },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        runBuildScripts = true,
      },
      -- Add clippy lints for Rust.
      checkOnSave = {
        allFeatures = true,
        command = "clippy",
        extraArgs = {
          "--",
          "--no-deps",
          "-Dclippy::correctness",
          "-Dclippy::complexity",
          "-Wclippy::perf",
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
  tools = {
    hover_actions = {
      auto_focus = true,
    },
  },
})

rt.inlay_hints.enable()

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
    prefix = "",
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

