#!/usr/bin/env sh
HYPRGAMEMODE=$(hyprctl getoption general:gaps_in | sed -n '2p' | awk '{print $2}')
if [ $HYPRGAMEMODE -ge 1 ] ; then
    hyprctl --batch "\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;"
    exit
fi
hyprctl reload
