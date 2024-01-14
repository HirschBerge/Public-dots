#!/usr/bin/env bash


# Define a function to prevent multiple instances of the script
prevent_multiple_instances() {
  if pgrep "wf-recorder";
  then
    notify-send -t 3000 -u critical "Killing recording."
    pgrep "wf-recorder" |xargs kill -2
  else 
    start_recording
  fi
}




start_recording ()
{
  file="$HOME/Videos/recordings/$(date '+%Y-%m-%d_%H:%M:%S').mp4"
  [[ -d "$(dirname "$file")" ]] || mkdir -p "$(dirname "$file")"
  notify-send -u normal "Starting recording!"
  wf-recorder -g "$(slurp)" --file=$file
}

prevent_multiple_instances
