#!/usr/bin/env bash
waybar_init (){  
  ps aux |grep [w]aybar  |grep -v "vim" | awk '{ print $2 }' |xargs kill
  sleep 1
  waybar 2>&1 &
}
launch-eww () {
  bash $HOME/.config/eww/scripts/eww-start.sh &
}
swww_init (){
  sleep 1
  swww init
  sleep 1
  ~/.scripts/background/cron.sh ~/Pictures/Monogatari & #Issues with this, kinda hacking, but oh well
}
dunst_init (){
  dunst
}
xwaylandbridge (){
  ps aux |grep [x]waylandvideobridge  |grep -v "vim" | awk '{ print $2 }' |xargs kill
  sleep 1
  xwaylandvideobridge
}
player ()
{
  ps aux |grep [p]layerctld |grep -v "vim" |awk '{ print $2 }' |xargs kill
  sleep 2
  playerctld daemon
}
main (){
  # waybar_init
  swww_init
  # dunst_init
  player
  # launch-eww
  xwaylandbridge
}
main
notify-send --icon  ~/.config/wallwide2.png "Hyprland Started!" "Have a great day!"
