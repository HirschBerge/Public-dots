#!/usr/bin/env bash
PR="$(cat "$HOME/.cache/PR_tracker.txt")"
data="$(curl -slf https://nixpk.gs/pr-tracker.html\?pr="$PR")"
title="$(echo "$data" |rg title | rg -oP '(?<=\().+?(?=\))' | sd "\-&gt;" "  " |sd '"' ""| tr '[:lower:]' '[:upper:]' | sed 's/\([[:alpha:]]\)\([[:alpha:]]*\)/\u\1\L\2/g')"
statuses="$(echo "$data" |rg -v li| rg "state" -A2 | rg -oP '(?<=>).+?(?=<)' |awk 'NR%2{emoji=$0; next} {print $0 ":" emoji}' |sd "⚪" " " |sd "✅" "  ")" > /dev/null
url="https://github.com/NixOS/nixpkgs/pull/$PR"
master=$(echo "$statuses" |rg "master" |awk -F':' '{ print $2 }')
small=$(echo "$statuses" |rg "small" |awk -F':' '{ print $2 }')
nix_pkgs=$(echo "$statuses" |rg nixpkgs |awk -F':' '{ print $2 }')
unstable=$(echo "$statuses" |rg -v small |rg nixos |awk -F':' '{ print $2 }')
json_output=$(printf '{"title": "%s", "master": "%s", "small": "%s", "nix_pkgs": "%s", "unstable": "%s", "url": "%s"}' \
  "$title" "$master" "$small" "$nix_pkgs" "$unstable" "$url")

# Print the JSON object
echo "$json_output" |jq
