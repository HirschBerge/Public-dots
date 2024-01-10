[![GitHub repo size](https://img.shields.io/github/repo-size/HirschBerge/Public-dots.svg)](https://github.com/HirschBerge/Public-dots) [![GitHub stars](https://img.shields.io/github/stars/HirschBerge/Public-dots
)](https://github.com/HirschBerge/Public-dots/stargazers) [![GitHub issues](https://img.shields.io/github/issues/HirschBerge/Public-dots.svg)](https://github.com/HirschBerge/Public-dots/issues) [![GitHub pull requests](https://img.shields.io/github/issues-pr/HirschBerge/Public-dots.svg)](https://github.com/HirschBerge/Public-dots/pulls)

# My Dotfiles

## Flakes
I have decided to move to flakes finally. Please see the [flakes](../../tree/flakes) branch. I will be merging that into main eventually.. Please be on the lookout!

This repository contains my personal dotfiles for configuring various tools and applications. Feel free to explore and use any configurations that might be helpful for your setup.

## Disclaimer! I do not offer any support

Use at your own risk. I suggest cherry-picking sections of the code for your own use case What you do on your computer is something for which I cannot and will not be held accountable. If you really want to use my setup as-is, in addition to [Installation](https://github.com/HirschBerge/Public-dots#installation)
Please consider the following:

Running the `./setup.sh` script will change all occurances 

## Overview

| Category                  | Software/Theme/Distro                                                                                             |
|---------------------------|---------------------------------------------------------------------------------------------------------------------|
| OS                        | [NixOS](https://nixos.org/)                                                                                       |
| Window Manager            | [Hyprland](https://hyprland.org/)                                                                                 |
| Discord Modifications     | [BetterDiscord](https://betterdiscord.app/)                                                                       |
| Notification Manager      | [Swaync](https://github.com/ErikReider/SwayNotificationCenter)                                                    |
| Web Browser               | [Firefox](https://www.mozilla.org/en-US/firefox/new/)                                                             |
| Video Player              | [MPV](https://mpv.io/)                                                                                           |
| Text Editor               | [Neovim](https://neovim.io/)                                                                                     |
| Neovim Distro             | [NVChad](https://nvchad.com/)                                                                                   |
| Neovim Distro Plugins     | williamboman/mason.nvim, junegunn/fzf.vim, arnamak/stay-centered.nvim, elkowar/yuck.vim, catppuccin/nvim, neovim/nvim-lspconfig, simrat39/rust-tools.nvi, neovim/nvim-lspconfig, mfussenegger/nvim-dap, rust-lang/rust.vim, theHamsta/nvim-dap-virtual-text, hrsh7th/nvim-cmp |
| CLI File Manager          | [Ranger](https://github.com/ranger/ranger)                                                                       |
| GUI File Manager          | [Thunar](https://docs.xfce.org/xfce/thunar/start)                                                                |
| Launcher                  | [Rofi](https://github.com/davatorium/rofi)                                                                       |
| Bar/Widgets               | [EWW](https://github.com/elkowar/eww)                                                                            |
| Shell                     | [Zsh](https://www.zsh.org/)                                                                                      |
| Fonts                     | [Termina Test](https://www.cufonfonts.com/font/termina-test), [Jetbrains Nerdfonts Mono](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip), [Fira Code](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip), [Iosevka Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Iosevka.zip) |
| Linux ISO Torrents        | [rtorrent](https://github.com/rakshasa/rtorrent)                                                                |
| `Find` replacement        | [fd](https://github.com/sharkdp/fd) `nix-env -iA nixos.fd` for use in the Installation section                  |
| `grep` replacement        | [rg](https://github.com/BurntSushi/ripgrep) `nix-env -iA nixos.ripgrep` if needed before installation           |

## Getting Started

### Prerequisites
 
- Generic NixOS installation.
- Generate a Config (for your hardware config) with `nixos-generate-config`
- Continued below
- `fd` to be installed (see above)

### Installation

Clone this repository and run the setup script.

```bash
git clone https://github.com/HirschBerge/Public-dots.git
cd Public-dots
git switch flakes
chmod +x setup.sh
# It will ask you a few questions. 
./setup.sh
```

To "rebuild" you can run the following

```bash
nix flake update
home-manager --flake /path/to/repo#$USER@your_hostname switch -b backup
sleep 1
sudo nixos-rebuild switch --flake /path/to/repo#your_hostname
```

Note: `rebuild` is a zsh alias to this, as a oneliner
