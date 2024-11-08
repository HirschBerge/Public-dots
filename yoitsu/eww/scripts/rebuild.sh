#!/usr/bin/env bash


upgrade () {
  rm -rf ~/.scripts/.venv
  rm ~/.mozilla/firefox/USER_NAME/search.json.mozlz4
  # nix flake update
  nh os boot --update
  sleep 1
  nh home switch
  send_notification "Upgrade complete. Reboot to finalize."
}

home_manager_only(){
  notify-send "Started Home Manager" "We'll let ya know" -a 'nixos-logo'
  rm -rf ~/.scripts/.venv
  rm ~/.mozilla/firefox/USER_NAME/search.json.mozlz4
  nh home switch
  send_notification "Home Manager build complete\!"
}

rebuild (){
  rm -rf ~/.scripts/.venv
  rm ~/.mozilla/firefox/USER_NAME/search.json.mozlz4
  nh home switch
  sleep 1
  nh os switch
  fix_nvim_links
  send_notification "Rebuild Complete\!"
}


send_notification(){
  aplay "$HOME"/.config/notification_icons/notification.wav &
  response=$(timeout 10 notify-send -A "Okay!" "Rebuild Complete!" "$1" -A "Reboot" -a 'nixos-logo')
  case "$response" in
    0) exit 0 ;;
    1) reboot ;;
    *) echo "Invalid response: $response";;
  esac
  read -rp "Press any key to continue"
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
