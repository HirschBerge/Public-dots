local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

-- Set header
dashboard.section.header.val = {
   "             ███╗   ██╗██╗██╗  ██╗               ",
   "             ████╗  ██║██║╚██╗██╔╝               ",
   "             ██╔██╗ ██║██║ ╚███╔╝               ",
   "             ██║╚██╗██║██║ ██╔██╗               ",
   "             ██║ ╚████║██║██╔╝ ██╗               ",
   "             ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝               ",
   "        ██████╗ █████╗ ████████╗███████╗       ",
   "        ██╔════╝██╔══██╗╚══██╔══╝██╔════╝       ",
   "        ██║     ███████║   ██║   ███████╗       ",
   "        ██║     ██╔══██║   ██║   ╚════██║       ",
   "        ╚██████╗██║  ██║   ██║   ███████║       ",
   "         ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝       ",
   "                                                ",
}

-- Set menu
dashboard.section.buttons.val = {
    dashboard.button( "e", "  > New file" , ":ene <BAR> startinsert <CR>"),
    dashboard.button( "f", "  > Find file", ":Telescope find_files<CR>"),
    dashboard.button( "r", "  > Recent"   , ":Telescope oldfiles<CR>"),
    dashboard.button( "g", "  > Live Grep", ":Telescope live_grep<CR>"),
    dashboard.button( "s", "  > Settings" , ":e ~/.dotfiles/flake.nix | :cd %:p:h | pwd<CR>"),
    dashboard.button( "q", "  > Quit nixCats", ":qa<CR>"),
}

-- Set footer
--   NOTE: This is currently a feature in my fork of alpha-nvim (opened PR #21, will update snippet if added to main)
--   To see test this yourself, add the function as a dependecy in packer and uncomment the footer lines
--   ```init.lua
--   return require('packer').startup(function()
--       use 'wbthomason/packer.nvim'
--       use {
--           'goolord/alpha-nvim', branch = 'feature/startify-fortune',
--           requires = {'BlakeJC94/alpha-nvim-fortune'},
--           config = function() require("config.alpha") end
--       }
--   end)
--   ```
-- local fortune = require("alpha.fortune") 
-- dashboard.section.footer.val = fortune()

-- Send config to alpha
alpha.setup(dashboard.opts)

-- Disable folding on alpha buffer
vim.cmd([[
    autocmd FileType alpha setlocal nofoldenable
]])
