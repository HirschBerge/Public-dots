#!/usr/bin/env bash

upgrade () {
  fd . ~/ -H -e backup -tf -X rm -f
	nix flake update $HOME/.dotfiles
	home-manager --flake $HOME/.dotfiles#$USER@shirohebi switch -b backup
	sleep 1
	sudo nixos-rebuild switch --flake $HOME/.dotfiles#shirohebi
	aplay $HOME/.config/swaync/notification.wav &
	response=$(timeout 10 notify-send -A "Okay!" "Rebuild Complete!" "All built uppppp!" -A "Reboot") 
	case "$response" in
		(0) exit 0 ;;
		(1) reboot ;;
		(*) echo "Invalid response: $response" ;;
	esac
	read -p "Press any key to continue"
}

rebuild (){
  fd . ~/ -H -e backup -tf -X rm -f
  # nix flake update
  home-manager --flake $HOME/.dotfiles#$USER@shirohebi switch -b backup
  sleep 1
  sudo nixos-rebuild switch --flake $HOME/.dotfiles#shirohebi
  aplay $HOME/.config/swaync/notification.wav &
  response=$(timeout 10 notify-send -A "Okay!" "Rebuild Complete!" "All built uppppp!" -A "Reboot")
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
            ;;
        --rebuild)
            rebuild
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done
