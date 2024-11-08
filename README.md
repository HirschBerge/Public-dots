<h1 align="center">
   <img src="./common/notification_icons/nixos-logo.svg" width="100px" /> 
   <br>
      HirschBerge's NixOS .dotfiles 
   <br>
      <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="600px" /> <br>
   <div align="center">

   <div align="center">
      <p></p>
      <div align="center">
         <a href="https://github.com/HirschBerge/Public-dots/stargazers">
            <img src="https://img.shields.io/github/stars/HirschBerge/Public-dots?color=F5BDE6&labelColor=303446&style=for-the-badge&logo=starship&logoColor=F5BDE6">
         </a>
         <a href="https://github.com/HirschBerge/Public-dots/">
            <img src="https://img.shields.io/github/repo-size/HirschBerge/Public-dots?color=C6A0F6&labelColor=303446&style=for-the-badge&logo=github&logoColor=C6A0F6">
         </a>
         <a = href="https://nixos.org">
            <img src="https://img.shields.io/badge/NixOS-unstable-blue.svg?style=for-the-badge&labelColor=303446&logo=NixOS&logoColor=white&color=91D7E3">
         </a>
         <a = href="https://github.com/HirschBerge/Public-dots/issues">
            <img src="https://img.shields.io/github/issues/HirschBerge/Public-dots.svg?style=for-the-badge&labelColor=303446&color=D2F7A6">
         </a>
         <a href="https://github.com/HirschBerge/Public-dots/blob/main/LICENSE">
            <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&colorA=313244&colorB=F5A97F&logo=unlicense&logoColor=F5A97F&"/>
         </a>
      </div>
      <br>
   </div>
</h1>
<p align="center">
   <img src="https://i.imgur.com/efEWq4M.png" width="800px" /> <br>
</p>
<p align="center">
   Screeenshot last updated <b>01/14/24</b>
</p>


# My Dotfiles

## Flakes

Now that I have moved to moved to using flakes, this rice is much easier to replicate. With just changing a few variables, and renaming the folder structure to match, you can now have my exact build in just a few minutes.
I will provide some steps to replication [below](#getting-started).

## Disclaimer! I do not offer any support

Use at your own risk. I suggest cherry-picking sections of the code for your own use case What you do on your computer is something for which I cannot and will not be held accountable. If you really want to use my setup as-is, in addition to [Installation](#installation)
Please review the official [NixOS Installation Guide](https://nixos.wiki/wiki/NixOS_Installation_Guide)
## Overview

| Category                  | Software/Theme/Distro                                                                                             |
|---------------------------|-------------------------------------------------------------------------------------------------------------------|
| OS                        | [NixOS](https://nixos.org/)                                                                                       |
| Window Manager            | [Hyprland](https://hyprland.org/)                                                                                 |
| Discord Modifications     | [Vesktop](https://github.com/Vencord/Vesktop)                                                                       |
| Notification Manager      | [Custom EWW Widget](https://github.com/elkowar/eww)                                                    |
| Web Browser               | [Firefox](https://www.mozilla.org/en-US/firefox/new/)                                                             |
| Video Player              | [MPV](https://mpv.io/)                                                                                            |
| Text Editor               | [Neovim](https://neovim.io/)                                                                                      |
| Neovim "Distro"           | [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim)                                                         |
| CLI File Manager          | [Yazi](https://github.com/sxyazi/yazi)                                                                             |
| Wallpaper Engine          | [SWWW](https://github.com/LGFae/swww)                                                                             |
| GUI File Manager          | [Thunar](https://docs.xfce.org/xfce/thunar/start)                                                                 |
| Launcher                  | [Rofi](https://github.com/davatorium/rofi)                                                                        |
| Bar/Widgets               | [EWW](https://github.com/elkowar/eww)                                                                             |
| Terminal                  | [Kitty](https://sw.kovidgoyal.net/kitty/)                                                                         |
| MultiPlexer               | [Zellij](https://zellij.dev/)                                                                                     |
| Zellij Bar                | [zjstatus](https://github.com/dj95/zjstatus/)                                                                     |
| Shell                     | [NuShell](https://www.nushell.sh/)                                                                                       |
| Fonts                     | [Termina Test](https://www.cufonfonts.com/font/termina-test), [Jetbrains Nerdfonts Mono](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip), [Fira Code](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip), [Iosevka Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Iosevka.zip) |
| Linux ISO Torrents        | [rtorrent](https://github.com/rakshasa/rtorrent)                                                                  |
| CLI tool rewrites         | `find` ➡ [fd](https://github.com/sharkdp/fd)  `grep` ➡ [rg](https://github.com/BurntSushi/ripgrep) `sed` ➡ [sd](https://github.com/chmln/sd) `du` ➡ [dust](https://github.com/bootandy/dust)|
| NixOS Helper              | [nh](https://github.com/viperML/nh)                                                                               |

## Getting Started
</details>
<details>
   <summary>
      <h3>
         Prerequisites
      </h3>
   </summary>
 
- Generic NixOS installation. Whether this is minimal or not, does not matter.
- `git` installed
- General skill with troubleshooting.
- Recommendation to fork the repo and substitute your repo's URL below
</details>
<details>
   <summary>
      <h3>
         Installation
      </h3>
   </summary>


I have not had the opportunity to test installation too much, as I really just want to share
Note: Termina Test from above does seem to think that is has a copy right, but doesn't provide a real license anywhere I could find. Out of respect, I don't want to host it for imperatively install, so please go to the link in the table to install.
Clone this repository and run the following.

```bash
git clone https://github.com/HirschBerge/Public-dots.git ~/.dotfiles
cd .dotfiles
git switch flakes # If not already on the flakes branch.
```
Use your favorite text editor to edit the [flake](./flake.nix) in any places that `TODO` is located to change your hostname and username. Please note that I have the flake set up for both a laptop, `shirohebi` and a desktop `yoitsu`. 
If you only have one or the other, you can simply remove the other directories as they won't be referenced at all.
We will be assuming that you are using `yoitsu` in the installation example.
If you have specific dot files that you want to deploy, you can copy them to `~/.dotfiles/yoitsu/<path>` and change/add the home.file source in [deploy_dots.nix](./nixos/common/configs/deploy_dots.nix)

```bash
# Copy your hardware-configuration.nix to ~/.dotfiles/nixos/yoitsu/
cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/nixos/yoitsu/
sudo nixos-rebuild switch --flake ~/.dotfiles#yoitsu
# You could probably reboot here.
# Home Manager config.
home-manager --flake ~/.dotfiles#$USER@yoitsu switch -b backup
# Optionally, you can then update the flake with
nix flake update #and repeat the above two. I would definitely reboot before that though and sign back in.
```
If you run into issues doing this, please make an issue and I will try and get it working or update instructions.
</details>
<details>
   <summary>
      <h3>
         NH Nix Helper
      </h3>
   </summary>
These are my workflows with `nh` to rebuild/update Home-Manager and NixOS

### Full rebuild

```bash
nh os switch
rm ~/.mozilla/firefox/<profile>/search.json.mozlz4
nh home switch
```
### Home Manager only
```bash
# These files tend to rewrite themselves from being links, so i remove them.
rm ~/.mozilla/firefox/<profile>/search.json.mozlz4 -f
nh home switch
# Alternatively
nhhome
```
### System Upgrade
```bash
nh os boot --update
# These files tend to rewrite themselves from being links, so i remove them.
rm ~/.mozilla/firefox/<profile>/search.json.mozlz4
nh home switch
# Alternatively
nhupdate
```
</details>

# Credits and Inspiration

| Credit                                                              |  Reason                               |
|---------------------------------------------------------------------|---------------------------------------|
| [Frost-Phoenix](https://github.com/Frost-Phoenix/nixos-config)      | README.md Ricing guidance             |
| [Hypr-Dots](https://github.com/prasanthrangan/hyprdots)             | Scripts mostly.                       |
| [r/UnixPorn](https://www.reddit.com/r/unixporn/)                    | More inspiration than you can imagine |
| [LibrePhoenix](https://github.com/librephoenix)                     | Beautiful guides and great knowledge  |
| [VimJoyer](https://www.youtube.com/@vimjoyer)                       | Short, simple, concise guides and info|
| [BirdeeHub/nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim) | Super neat tool and very useful help  |
