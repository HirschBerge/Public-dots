---@type ChadrcConfig 
local M = {}
M.ui = {theme = 'catppuccin'}
M.ui = {
  theme = "tokyonight",
  theme_toggle = { "tokyonight", "tokyodark" },
  tabufline = {
    enabled = false
  },
  statusline = {
    theme = "vscode_colored",
    separator_style = "round",
  },
}
M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"
return M
