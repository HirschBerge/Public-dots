#!/usr/bin/env bash


search_term="$(rofi -dmenu -p "NixOS Packages:" -format "s")"

# Declare arrays to store package names and URLs
names=()
urls=()

# Set the record separator to blank lines
IFS=$'\n\n'


# Get the search result
result="$(nh search "$search_term"| sed 's/[^[:print:]]//g'| sd "\[..m" ""| rg -iv "Querying |Took |Most relevant")"

# Read each record and store it in the names and urls arrays
while read -r record; do
    name=$(echo "$record" | rg -e '^\S+')
    url=$(echo "$record" | rg -oP 'Homepage: \K.+')
    names+=("$name")
    if [[ -n "$url" ]]; then
        urls+=("$url")
    fi
done <<< "$result"

reversed_names=()
reversed_urls=()
for ((i=${#names[@]}-1; i>=0; i--)); do
    reversed_names+=("${names[i]}")
    if [[ -n "${urls[i]}" ]]; then
        reversed_urls+=("${urls[i]}")
    fi
done

# echo "${urls[@]}"
# echo "${reversed_urls[@]}"
# Construct a list of names for rofi
formatted_names=$(printf "%s\n" "${reversed_names[@]}"|sed '/^[[:space:]]*$/d')

# Pass the names to rofi
selected_index=$(echo "$formatted_names" | rofi -dmenu -replace -sep "\n" -p "Search Results" -format "i" )

# Look up the URL corresponding to the selected name
selected_url="${reversed_urls[$selected_index]}"

# Echo out the selected URL
$BROWSER "$selected_url"

