[![GitHub repo size](https://img.shields.io/github/repo-size/HirschBerge/Public-dots.svg)](https://github.com/HirschBerge/Public-dots) [![GitHub stars](https://img.shields.io/github/stars/HirschBerge/Public-dots
)](https://github.com/HirschBerge/Public-dots/stargazers) [![GitHub issues](https://img.shields.io/github/issues/HirschBerge/Public-dots.svg)](https://github.com/HirschBerge/Public-dots/issues) [![GitHub pull requests](https://img.shields.io/github/issues-pr/HirschBerge/Public-dots.svg)](https://github.com/HirschBerge/Public-dots/pulls)

# My Dotfiles

This repository contains my personal dotfiles for configuring various tools and applications. Feel free to explore and use any configurations that might be helpful for your setup.

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
## Getting Started

### Prerequisites

- Generic NixOS installation.
- Generate a Config (for your hardware config) with `nixos-generate-config`
- Continued below

### Installation

Clone this repository and run the setup script.

```bash
git clone https://github.com/HirschBerge/Public-dots.git
cd Public-dots
chmod +x setup.sh
# It will ask you a few questions. Please Select the nixos-unstable branch.
./setup.sh
```
