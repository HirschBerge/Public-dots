#!/usr/bin/env bash
if [ -z "$1" ]; then
  echo "Error: Provide the season number"
  exit 1
fi

function rename(){
  OLD=$1
  NEW=$2
  while IFS= read -r old <&3 && IFS= read -r new <&4; do
	  mv -i -- "$old" "$new"
  done 3< $OLD 4< $NEW
  rm -f $OLD $NEW
}


eza --no-quotes -1 $2 |rg  "Episode" > OLD
cat OLD |rg "Episode " -r "S$1E" > NEW
# cat OLD | grep -E "Episode [0-9][^0-9]" | awk -v season="$1" -F"Episode " '{ print "S0"season "E0"$2 }' > NEW
# cat OLD | grep -E "Episode [0-9]+" | awk -v season="$1" -F"Episode " '{ print "S0"season "E"$2 }' >> NEW
# paste OLD NEW
rename OLD NEW
eza --no-quotes --group-directories-first -l --icons
