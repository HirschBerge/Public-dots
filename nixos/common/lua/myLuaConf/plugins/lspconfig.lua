capabilities = require('myLuaConf.LSPs.caps-on_attach').get_capabilities()
on_attach = require('myLuaConf.LSPs.caps-on_attach').on_attach
local lspconfig = require("lspconfig")
lspconfig.nixd.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = {"nixd"},
    settings = {
        nixd = {
            nixpkgs = {expr = "import <nixpkgs> { }"},
            formatting = {
                command = {"alejandra"} -- or nixfmt or nixpkgs-fmt
            },
            options = {
                nixos = {
                    expr = '(builtins.getFlake "$HOME/.dotfiles").nixosConfigurations.CONFIGNAME.options'
                },
                home_manager = {
                    expr = '(builtins.getFlake "$HOME/.dotfiles").homeConfigurations.CONFIGNAME.options'
                }
            }
        }
    }
})
