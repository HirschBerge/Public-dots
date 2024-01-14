#!/usr/bin/env bash

toggle_flag=false
dnd_flag=false

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --toggle) toggle_flag=true ;;
    --dnd) dnd_flag=true ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# Check flag combinations and execute corresponding commands
if [ "$toggle_flag" = true ]; then
  swaync-client -t -sw
elif [ "$dnd_flag" = true ]; then
  swaync-client -d -sw
else
  echo "Please specify a valid flag: --toggle or --dnd"
fi
