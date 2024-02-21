#!/usr/bin/env bash

upgrade () {
  fd . ~/ -H -e backup -tf -X rm -f
  # nix flake update
  nix flake update $HOME/.dotfiles
  home-manager --flake $HOME/.dotfiles#$USER@shirohebi switch -b backup
  sleep 1
  sudo nixos-rebuild switch --flake $HOME/.dotfiles#shirohebi
  send_notification
}

home_manager_only(){
  notify-send "Started Home Manager" "We'll let ya know" -i ~/.config/swaync/nixos-logo.png
  fd . ~/ -H -e backup -tf -X rm -f
  home-manager --flake $HOME/.dotfiles#$USER@shirohebi switch -b backup
  send_notification
}

rebuild (){
  fd . ~/ -H -e backup -tf -X rm -f
  home-manager --flake $HOME/.dotfiles#$USER@shirohebi switch -b backup
  sleep 1
  sudo nixos-rebuild switch --flake $HOME/.dotfiles#shirohebi
  send_notification
}


send_notification(){
  aplay $HOME/.config/swaync/notification.wav &
  response=$(timeout 10 notify-send -A "Okay!" "Rebuild Complete!" "All built uppppp!" -A "Reboot" -i ~/.config/swaync/nixos-logo.png)
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
