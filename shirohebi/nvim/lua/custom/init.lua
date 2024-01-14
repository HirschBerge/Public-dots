vim.g.dap_virtual_text = true
local vimrc = "~/.vimrc"
vim.cmd('source ' .. vimrc)
vim.opt.scrolloff = 20
vim.keymap.set('n', 'j', "jzz", {})
vim.keymap.set('n', 'j', "kzz", {})
vim.cmd('source ' .. "~/.config/nvim/lua/custom/autocmds.lua")
