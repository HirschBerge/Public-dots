{inputs, ...}: let
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
      packageNames = ["myNixModuleNvim"];
      luaPath = "${./.}";
      # you could also import lua from the flake though,
      # which we do for user config after this config for root

      # packageDef is your settings and categories for this package.
      # categoryDefinitions.replace will replace the whole categoryDefinitions with a new one
      categoryDefinitions.replace = {pkgs, ...} @ packageDef: {
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
            cargo
            lua-language-server
            nodePackages_latest.bash-language-server
            pyright
            black
            mypy
            ruff
            nixd
            alejandra
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
            tree-sitterPlugins = with pkgs.vimPlugins; [
              nvim-treesitter-textobjects
              nvim-treesitter-parsers.rasi
              (nvim-treesitter.withPlugins (
                _:
                  nvim-treesitter.allGrammars
                # TODO: IDk figure it out
                  # ++ [
                  #   pkgs.tree-sitter.builtGrammars.tree-sitter-nu
                  # ]
              ))
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
                nvim-nu
                nvim-dap-ui
                nvim-dap-virtual-text
                nvim-dap-python
                plenary-nvim
                telescope-nvim
                # treesitter
                nvim-lspconfig
                fidget-nvim
                lualine-nvim
                gitsigns-nvim
                which-key-nvim
                comment-nvim
                vim-sleuth
                vim-fugitive
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
                # rust-tools-nvim
                rustaceanvim
                renamer-nvim
                rainbow-delimiters-nvim
                zellij-nvim
                twilight-nvim
                markview-nvim
              ];
            };
          };
        };
      };

      # see :help nixCats.flake.outputs.packageDefinitions
      packages = {
        # These are the names of your packages
        # you can include as many as you wish.
        myNixModuleNvim = {pkgs, ...}: {
          # they contain a settings set defined above
          # see :help nixCats.flake.outputs.settings
          settings = {
            wrapRc = true;
            # IMPORTANT:
            # you may not alias to nvim
            # your alias may not conflict with your other packages.
            aliases = ["nv" "v"];
            # nvimSRC = inputs.neovim;
          };
          # and a set of categories that you want
          # (and other information to pass to lua)
          categories = {
            general = true;
            markdown = true;
            startupPlugins = true;
            lspsAndRuntimeDeps = {
              general = true;
              neonixdev = true;
            };
          };
        };
      };
    };
  };
}
