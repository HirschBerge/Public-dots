{ config, lib, inputs, ... }: let
  utils = inputs.nixCats.utils;
  # the options for this are defined at the end of the file,
  # and will be how to include this template module in your system configuration.
in {
  imports = [
    inputs.nixCats.nixosModules.default
  ];
  config = {
    # this value, nixCats is the defaultPackageName you pass to mkNixosModules
    # it will be the namespace for your options.
    nixCats = {
      # these are some of the options. For the rest see
      # :help nixCats.flake.outputs.utils.mkNixosModules
      # you do not need to use every option here, anything you do not define
      # will be pulled from the flake instead.
      enable = true;
      # this will add the overlays from ./overlays and also,
      # add any plugins in inputs named "plugins-pluginName" to pkgs.neovimPlugins
      # It will not apply to overall system, just nixCats.
      packageNames = [ "myNixModuleNvim" ];
      luaPath = "${./.}";
      # you could also import lua from the flake though,
      # which we do for user config after this config for root

      # packageDef is your settings and categories for this package.
      # categoryDefinitions.replace will replace the whole categoryDefinitions with a new one
      categoryDefinitions.replace = ({ pkgs, settings, categories, name, ... }@packageDef: {
        propagatedBuildInputs = {
          # add to general or create a new list called whatever
          general = [];
        };
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          universal-ctags
          ripgrep
          zls
          fd
          rust-analyzer
          lua-language-server
          nodePackages_latest.bash-language-server
          nodePackages_latest.pyright
          black
          mypy
          ruff
          nixd
          lldb_17
        ];
        neonixdev = {
          # also you can do this.
          inherit (pkgs) nix-doc nil lua-language-server nixd;
          # nix-doc tags will make your tags much better in nix
          # but only if you have nil as well for some reason
        };
      };
      startupPlugins = {
        debug = with pkgs.vimPlugins; [
        ];
        neonixdev = with pkgs.vimPlugins; [
          neodev-nvim
          neoconf-nvim
        ];
        # yes these category names are arbitrary
        markdown = with pkgs.vimPlugins; [
          markdown-preview-nvim
        ];
        lazy = with pkgs.vimPlugins; [
          lazy-nvim
        ];
        general = {
          gitPlugins = with pkgs.neovimPlugins; [
            hlargs
          ];
          vimPlugins = {
            # you can make a subcategory
            cmp = with pkgs.vimPlugins; [
              # cmp stuff
              nvim-cmp
              luasnip
              friendly-snippets
              cmp_luasnip
              cmp-buffer
              cmp-path
              cmp-nvim-lua
              cmp-nvim-lsp
              cmp-cmdline
              cmp-nvim-lsp-signature-help
              cmp-cmdline-history
              lspkind-nvim
              crates-nvim
              rust-vim
              null-ls-nvim
            ];
            general = with pkgs.vimPlugins; [
              telescope-fzf-native-nvim
              nvim-dap
              nvim-dap-ui
              nvim-dap-virtual-text
              nvim-dap-python
              plenary-nvim
              telescope-nvim
              # treesitter
              nvim-treesitter-textobjects
              nvim-treesitter.withAllGrammars
              nvim-treesitter-parsers.rasi
              # This is for if you only want some of the grammars
              # (nvim-treesitter.withPlugins (
              #   plugins: with plugins; [
              #     nix
              #     lua
              #   ]
              # ))
              # other
              nvim-lspconfig
              fidget-nvim
              lualine-nvim
              gitsigns-nvim
              which-key-nvim
              comment-nvim
              vim-sleuth
              vim-fugitive
              # vim-rhubarb
              # vim-repeat
              todo-comments-nvim
              undotree
              nvim-surround
              indent-blankline-nvim
              nvim-web-devicons
              oil-nvim
              noice-nvim
              neo-tree-nvim
              nvim-notify
              nui-nvim
              ChatGPT-nvim
              alpha-nvim
              better-escape-nvim
              tokyonight-nvim
              nvim-autopairs
              nvim-highlight-colors
              rust-tools-nvim
              renamer-nvim
            ];
          };
        };
        # You can retreive information from the
        # packageDefinitions of the package this was packaged with.
        # :help nixCats.flake.outputs.categoryDefinitions.scheme
        # themer = with pkgs.vimPlugins;
          # (builtins.getAttr categories.colorscheme {
              # Theme switcher without creating a new category
              # "onedark" = onedark-nvim;
              # "catppuccin" = catppuccin-nvim;
              # "catppuccin-mocha" = catppuccin-nvim;
              # "tokyonight" = tokyonight-nvim;
              # "tokyonight-day" = tokyonight-nvim;
            # }
          # );
          # This is obviously a fairly basic usecase for this, but still nice.
          # Checking packageDefinitions also has the bonus
          # of being able to be easily set by importing flakes.
      };
      optionalPlugins = {
        custom = with pkgs.nixCatsBuilds; [ ];
        gitPlugins = with pkgs.neovimPlugins; [ ];
        general = with pkgs.vimPlugins; [ ];
      };
        environmentVariables = {
          test = {
            CATTESTVAR = "It worked!";
          };
        };
        extraWrapperArgs = {
          test = [
            '' --set CATTESTVAR2 "It worked again!"''
          ];
        };
        extraPythonPackages = {
          test = [ (_:[]) ];
        };
        extraPython3Packages = {
          test = [ (_:[]) ];
        };
        extraLuaPackages = {
          test = [ (_:[]) ];
        };
      });

      # see :help nixCats.flake.outputs.packageDefinitions
      packages = {
        # These are the names of your packages
        # you can include as many as you wish.
        myNixModuleNvim = {pkgs , ... }: {
          # they contain a settings set defined above
          # see :help nixCats.flake.outputs.settings
          settings = {
            wrapRc = true;
            # IMPORTANT:
            # you may not alias to nvim
            # your alias may not conflict with your other packages.
            aliases = [ "nv" "v" ];
            # nvimSRC = inputs.neovim;
          };
          # and a set of categories that you want
          # (and other information to pass to lua)
          categories = {
            # test = true;
            general = true;
            markdown = true;
            lspsAndRuntimeDeps.general = true;
            lspsAndRuntimeDeps.neonixdev  = true;
            startupPlugins = true;
            example = {
              youCan = "add more than just booleans";
              toThisSet = [
                "and the contents of this categories set"
                "will be accessible to your lua with"
                "nixCats('path.to.value')"
                "see :help nixCats"
              ];
            };
          };
        };
      };
    };
  };
}
