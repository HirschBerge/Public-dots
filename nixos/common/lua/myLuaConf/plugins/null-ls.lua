local null_ls = require('null-ls')
local opts = {
  sources = {
    null_ls.builtins.formatting.black,
    null_ls.builtins.diagnostics.mypy,
    null_ls.builtins.diagnostics.ruff,
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.cmd([[
        augroup LspFormatting
          autocmd! BufWritePre <buffer>
          autocmd BufWritePre <buffer> lua vim.lsp.buf.format({ bufnr = ]] .. bufnr .. [[ })
        augroup END
      ]])
    end
  end,
}
null_ls.register(opts)
