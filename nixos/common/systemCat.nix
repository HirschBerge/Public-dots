{inputs, ...}: let
  # utils = inputs.nixCats.utils; the options for this are defined at the end of the file, and will be how to include this template module in your system configuration.
in {
  imports = [
    inputs.nixCats.nixosModules.default
  ];
  config = {
    # this value, nixCats is the defaultPackageName you pass to mkNixosModules
    # it will be the namespace for your options.
    nixCats = {
      nixpkgs_version = inputs.nixpkgs;
      # these are some of the options. For the rest see :help nixCats.flake.outputs.utils.mkNixosModules you do not need to use every option here, anything you do not define will be pulled from the flake instead.
      enable = true;
      # this will add the overlays from ./overlays and also, add any plugins in inputs named "plugins-pluginName" to pkgs.neovimPlugins It will not apply to overall system, just nixCats.
      packageNames = ["myNixModuleNvim"];
      luaPath = "${./.}";
      # you could also import lua from the flake though, which we do for user config after this config for root packageDef is your settings and categories for this package. categoryDefinitions.replace will replace the whole categoryDefinitions with a new one
      categoryDefinitions.replace = {pkgs, ...}: {
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
            # nix-doc tags will make your tags much better in nix but only if you have nil as well for some reason
          };
        };
        startupPlugins = {
          # debug = with pkgs.vimPlugins; [
          # ];
          neonixdev = with pkgs.vimPlugins; [
            neodev-nvim
            neoconf-nvim
          ];
          # yes these category names are arbitrary
          markdown = with pkgs.vimPlugins; [
            markdown-preview-nvim
            markview-nvim
          ];
          texlive = with pkgs; [
            vimPlugins.vimtex
            texliveFull
          ];
          lazy = with pkgs.vimPlugins; [
            lazy-nvim
          ];
          general = {
            vimPlugins = {
              # you can make a subcategory
              tree-sitterALL = with pkgs.vimPlugins; [
                nvim-treesitter.withAllGrammars
              ];
              tree-sitterPlugins = with pkgs.vimPlugins; [
                nvim-treesitter-parsers.awk
                nvim-treesitter-parsers.bash
                nvim-treesitter-parsers.bibtex
                nvim-treesitter-parsers.css
                nvim-treesitter-parsers.csv
                nvim-treesitter-parsers.go
                nvim-treesitter-parsers.html
                nvim-treesitter-parsers.hyprlang
                nvim-treesitter-parsers.json
                nvim-treesitter-parsers.kdl
                nvim-treesitter-parsers.lua
                nvim-treesitter-parsers.markdown
                nvim-treesitter-parsers.nix
                nvim-treesitter-parsers.nu
                nvim-treesitter-parsers.powershell
                nvim-treesitter-parsers.python
                nvim-treesitter-parsers.rasi
                nvim-treesitter-parsers.regex
                nvim-treesitter-parsers.rust
                nvim-treesitter-parsers.scss
                nvim-treesitter-parsers.slint
                nvim-treesitter-parsers.ssh_config
                nvim-treesitter-parsers.toml
                nvim-treesitter-parsers.xml
                nvim-treesitter-parsers.yaml
                nvim-treesitter-parsers.yuck
                nvim-treesitter-parsers.zig
                nvim-treesitter-textobjects
              ];
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
                null-ls-nvim
              ];
              debugging = with pkgs.vimPlugins; [
                nvim-dap
                nvim-dap-ui
                nvim-dap-virtual-text
                nvim-dap-python
              ];
              git = with pkgs.vimPlugins; [
                gitsigns-nvim
                vim-sleuth
                vim-fugitive
              ];
              ui = with pkgs.vimPlugins; [
                renamer-nvim
                alpha-nvim
                neo-tree-nvim
                fidget-nvim
                lualine-nvim
                nvim-notify
                nui-nvim
                noice-nvim
              ];
              beautify = with pkgs.vimPlugins; [
                nvim-autopairs
                nvim-highlight-colors
                rainbow-delimiters-nvim
                tokyonight-nvim
                nvim-web-devicons
              ];
              otherlsp = with pkgs.vimPlugins; [
                nvim-nu
                nvim-lspconfig
                rustaceanvim
              ];
              core = with pkgs.vimPlugins; [
                telescope-fzf-native-nvim
                telescope-nvim
                undotree
                nvim-surround
                indent-blankline-nvim
                better-escape-nvim
                comment-nvim
                todo-comments-nvim
                zellij-nav-nvim
              ];
              general = with pkgs.vimPlugins; [
                plenary-nvim
                which-key-nvim
                oil-nvim
                ChatGPT-nvim
                twilight-nvim
              ];
            };
          };
        };
      };

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions = {
        replace = {
          # These are the names of your packages you can include as many as you wish.
          myNixModuleNvim = {...}: {
            # they contain a settings set defined above see :help nixCats.flake.outputs.settings
            settings = {
              wrapRc = true;
              # NOTE: IMPORTANT: you may not alias to nvim your alias may not conflict with your other packages.
              aliases = ["nv" "v"];
              # nvimSRC = inputs.neovim;
            };
            # and a set of categories that you want (and other information to pass to lua)
            categories = {
              general.vimPlugins = {
                tree-sitterPlugins = true;
                tree-sitterALL = false;
                debugging = true;
                git = true;
                ui = true;
                beautify = true;
                cmp = true;
                otherlsp = true;
                core = true;
                general = true;
              };
              markdown = true;
              # NOTE: true for vimtex
              texlive = false;
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
  };
}
