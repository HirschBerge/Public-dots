require("chatgpt").setup({
    api_key_cmd = "gpg --decrypt " .. vim.fn.expand("$HOME") .. "/.dotfiles/yoitsu/gpt.txt.gpg"
})
local autopairs = require('nvim-autopairs')
autopairs.setup()
