#!/usr/bin/env bash
converts()
{
    local t=$1

    local d=$((t/60/60/24))
    local h=$((t/60/60%24))
    local m=$((t/60%60))
    local s=$((t%60))
    # Test to see if the amount of days is greater than Zero
    if [[ $d > 0 ]]; then
      # Echo amount of days 
      echo -n "${d}d "
    fi
    # If amount of hours is positive
    if [[ $h > 0 ]]; then
      # Echo the amount of hours.
      echo -n "${h}h "
    fi
    # If there are minutes, and it is less than one day, print only the minutes
    if [[ $m > 0 ]] && [[ $d -lt 1 ]]; then
      echo -n "${m}m "
    fi
    # If days and hours are zero, print minutes only.
    if [[ $d = 0 && $h = 0 && $m = 0 ]]; then
      echo -n "${s}s"
    fi  
    echo
}
# Accepts
converts "$1"
