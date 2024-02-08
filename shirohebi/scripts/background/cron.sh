#!/usr/bin/env bash


function stopprocess {
   local mypid=$$    # capture this run's pid

   declare pids=($(pgrep -f ${0##*/}))   # get all the pids running this script

   for pid in ${pids[@]/$mypid/}; do   # cycle through all pids except this one
      kill $pid                        # kill the other pids
      sleep 1                          # give time to complete
   done
}

set_background() {
  while true; do
    opt1=$(shuf -n 1 -e "$1"/*)
    # opt2=$(shuf -n 1 -e ~/Pictures/Monogatari/*)
    swww img -t random -o eDP-1 $opt1
    # swww img -t random -o DP-2 $opt2
    sleep 300
  done
}
main() {
	stopprocess
  set_background "$1"
}
main "$1"
