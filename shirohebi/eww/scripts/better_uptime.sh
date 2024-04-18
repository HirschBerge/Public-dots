#!/usr/bin/env bash
converts()
{
    local t=$1

    local d=$((t/60/60/24))
    local h=$((t/60/60%24))
    local m=$((t/60%60))
    local s=$((t%60))

    if [[ $d > 0 ]]; then
            [[ $d = 1 ]] && echo -n "${d}d " || echo -n "${d}d "
    fi
    if [[ $h > 0 ]]; then
            [[ $h = 1 ]] && echo -n "${h}h " || echo -n "${h}h "
    fi
    if [[ $m > 0 ]] && [[ $d -lt 1 ]]; then
            [[ $m = 1 ]] && echo -n "${m}m " || echo -n "${m}m "
    fi
    if [[ $d = 0 && $h = 0 && $m = 0 ]]; then
            [[ $s = 1 ]] && echo -n "${s}s" || echo -n "${s}s"
    fi  
    echo
}

converts "$1"
