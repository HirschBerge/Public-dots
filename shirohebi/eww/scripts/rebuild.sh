#!/usr/bin/env bash

fix_nvim_links() {
  # lua-language
  local nvim_path=~/.local/share/nvim
  fd lua-language $nvim_path -tf -X rm -f
  fd lua-language $nvim_path -tl -X rm -f
  sudo ln -s $(which lua-language-server ) $HOME/.local/share/nvim/mason/packages/lua-language-server/
  if command -v rust-analyzer &> /dev/null; then
    fd rust-analyzer $nvim_path -tf -X rm -f
    fd rust-analyzer $nvim_path -tl -X rm -f
    sudo ln -s $(which rust-analyzer ) $HOME/.local/share/nvim/mason/bin/
  fi
}

upgrade () {
  fd . ~/ -H -e backup -tf -X rm -f
  # nix flake update
  nix flake update $HOME/.dotfiles
  home-manager --flake $HOME/.dotfiles#$USER@shirohebi switch -b backup
  sleep 1
  sudo nixos-rebuild boot --flake $HOME/.dotfiles#shirohebi
  send_notification "Upgrade complete. Reboot to finalize."
  fix_nvim_links
}

home_manager_only(){
  notify-send "Started Home Manager" "We'll let ya know" -i ~/.config/swaync/nixos-logo.png
  fd . ~/ -H -e backup -tf -X rm -f
  home-manager --flake $HOME/.dotfiles#$USER@shirohebi switch -b backup
  send_notification "Home Manager build complete\!"
  fix_nvim_links
}

rebuild (){
  fd . ~/ -H -e backup -tf -X rm -f
  home-manager --flake $HOME/.dotfiles#$USER@shirohebi switch -b backup
  sleep 1
  sudo nixos-rebuild switch --flake $HOME/.dotfiles#shirohebi
  fix_nvim_links
  send_notification "Rebuild Complete\!"
  fix_nvim_links
}


send_notification(){
  aplay $HOME/.config/swaync/notification.wav &
  response=$(timeout 10 notify-send -A "Okay!" "Rebuild Complete!" "$1" -A "Reboot" -i ~/.config/swaync/nixos-logo.png)
  case "$response" in
    0) exit 0 ;;
    1) reboot ;;
    *) echo "Invalid response: $response";;
  esac
  read -p "Press any key to continue"
}


while [[ $# -gt 0 ]]; do
    case "$1" in
        --upgrade)
            upgrade
            exit 0
            ;;
        --rebuild)
            rebuild
            exit 0
            ;;
        --home)
          home_manager_only
          exit 0
          ;;
        *)
          echo "Unknown option: $1"
          exit 1
          ;;
    esac
    shift
done
