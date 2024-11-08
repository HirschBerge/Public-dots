#!/usr/bin/env bash

while true; do
    # Battery status and level
    status=$(cat /sys/class/power_supply/BAT0/status)
    level=$(cat /sys/class/power_supply/BAT0/capacity)
    
    # Check if the battery is discharging
    if [ "$status" == "Discharging" ]; then
        # Check if the battery level is less than 15
        if [ "$level" -le 15 ]; then
            # Show notification with actions
            response=$(notify-send "Battery Low" "Battery level is $level%. Choose an action:" \
                -a "battery_monitor" \
                -t 0 \
                -u critical \
                -A "I'll plug in" \
                -A "Hibernate" \
                -i ~/.config/notification_icons/critical.png)

            if [ "$response" = '0' ]; then
                echo ""
                # exit 0
            elif [ "$response" = '1' ]; then
                systemctl hibernate
            fi
        else
            echo -en "Battery level is: $level%."
            
        fi
    fi
    
    # Check if --continue is not passed
    if [ "$1" != "--continue" ]; then
        break
    fi
    
    # Sleep for 2 minutes
    sleep 2m
done

