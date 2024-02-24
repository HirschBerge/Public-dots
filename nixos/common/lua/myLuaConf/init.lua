require("myLuaConf.plugins")
require("myLuaConf.LSPs")
require('myLuaConf.format')
if nixCats('debug') then
  require('myLuaConf.debug')
end
vim.cmd('set clipboard+=unnamedplus')
vim.cmd[[colorscheme tokyonight]]
-- Set transparency for all modes
vim.cmd([[ hi Normal guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi SignColumn guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi VertSplit guibg=NONE ctermbg=NONE ]])

-- Set transparency for specific mode
vim.cmd([[ hi NormalNC guibg=NONE ctermbg=NONE ]])  -- Normal mode without current line highlighting

-- Set transparency for floating windows
vim.cmd([[ hi NormalFloat guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi FloatBorder guibg=NONE ctermbg=NONE ]])

-- Disable background color for transparent terminal
vim.cmd([[ hi Normal guibg=NONE ctermbg=NONE ]])

-- Set transparency for statusline and tabline (if applicable)
vim.cmd([[ hi StatusLine guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi StatusLineNC guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi TabLine guibg=NONE ctermbg=NONE ]])
vim.cmd([[ hi TabLineFill guibg=NONE ctermbg=NONE ]])

-- Adjust alpha (transparency) level for floating windows (requires Neovim 0.5+)
vim.cmd([[ hi NormalFloat guibg=NONE ctermbg=NONE blend=alpha ]])
vim.cmd([[ hi FloatBorder guibg=NONE ctermbg=NONE blend=alpha ]])

-- If you are using Neovim with a GUI (e.g., Neovim-Qt), you might need the following
vim.cmd([[ hi Normal guibg=NONE ctermbg=NONE term=NONE ]])

-- Disable background for terminal
vim.cmd([[ hi TermNormal guibg=NONE ctermbg=NONE ]])

-- If you are using a GUI, you might want to set the transparency of the whole window
vim.cmd([[ hi NormalNC guibg=NONE ctermbg=NONE term=NONE ]])
vim.cmd [[ hi Pmenu guibg=#191e29 ]]
vim.cmd [[ hi PmenuSel guibg=#2f394f ]]
vim.cmd 'set termguicolors'
vim.cmd 'set t_Co=256'
