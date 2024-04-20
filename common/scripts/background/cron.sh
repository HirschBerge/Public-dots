#!/usr/bin/env bash


HOSTNM="$(hostname)"
if [[ $HOSTNM == "yoitsu" ]]; then
    folder="$HOME/Pictures/Sci-Fi/"
else
    folder="$HOME/Pictures/Monogatari"
fi
sleep_time=300

if [ -n "$2" ]; then
  sleep_time="$2"
fi

if [ -n "$1" ]; then
  folder="$1"
fi

randomize(){
  echo $folder
  img1=$(find "$folder" -type f | shuf -n 1)
  img2=$(find "$folder" -type f | shuf -n 1)
  if [ -f "$img1" ] && [ -f "$img2" ]; 
  then echo ""
  else 
    randomize
  fi
}


function stopprocess {
   local mypid=$$    # capture this run's pid
   declare pids=($(pgrep -f ${0##*/}))   # get all the pids running this script
   for pid in ${pids[@]/$mypid/}; do   # cycle through all pids except this one
      kill $pid                        # kill the other pids
      sleep 1                          # give time to complete
   done
}

sets_background_yoitsu() {
  randomize
  current_time=$(date +"%m-%d-%y %H:%M:%S")
  echo -en "$current_time\n" >> $HOME/.cache/background.log
  echo -en "One: $img1\n" >> $HOME/.cache/background.log
  echo -en "Two: $img2\n" >> $HOME/.cache/background.log
  # cp "$imgwide" ~/.config/wallwide.png
  cp "$img2" ~/.config/wallwide2.png
  export SWWW_TRANSITION_FPS=120
  export SWWW_TRANSITION_STEP=2
  $(which swww) img -t random -o DP-1 "$img1"
  $(which swww) img -t random -o DP-3 "$img2"
  # $(which notify-send) --icon "$imgwide" "Hyprland Started!" "Have a great day!"
}

sets_background_shiro() {
  randomize
  current_time=$(date +"%m-%d-%y %H:%M:%S")
  echo -en "$current_time\n" >> $HOME/.cache/background.log
  echo -en "One: $img1\n" >> $HOME/.cache/background.log
  # cp "$imgwide" ~/.config/wallwide.png
  cp "$img1" ~/.config/wallwide2.png
  export SWWW_TRANSITION_FPS=120
  export SWWW_TRANSITION_STEP=2
  $(which swww) img -t random -o eDP-1 "$img1"
  # $(which notify-send) --icon "$imgwide" "Hyprland Started!" "Have a great day!"
}
main() {
  stopprocess
  while true; do
    if [[ $HOSTNM == "yoitsu" ]]; then
      sets_background_yoitsu
    else
      sets_background_shiro
    fi
    # chmod +x -R "$HOME/Backgrounds/*" "$HOME/.scripts/"
    sleep $sleep_time
  done
}


main #>/dev/null 2>&1 &
