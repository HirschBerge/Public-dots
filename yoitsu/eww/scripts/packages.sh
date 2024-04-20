#!/usr/bin/env bash
get_uniq_pkg_name () {
  echo "$(nix-store -qR "$1" |awk -F '-' '{print substr($0, index($0,$2))}' | sort -u)"
}

show_count() {
  all_packages=$(get_uniq_pkg_name "/run/current-system/sw")
  all_packages+=$(get_uniq_pkg_name "/etc/profiles/per-user/$USER")
  all_packages+=$(get_uniq_pkg_name "$HOME/.nix-profile/")
  result=$(echo "$all_packages" |sed -e 's/\-host//g' -e 's/\-info//g' -e 's/\-bin//g' -e 's/\-dev//g' -e 's/\-doc//g' -e 's/\-man//g'| sort -u |wc -l)
  echo "$result"
}
show_names() {
  all_packages=$(get_uniq_pkg_name "/run/current-system/sw")
  all_packages+=$(get_uniq_pkg_name "/etc/profiles/per-user/$USER")
  all_packages+=$(get_uniq_pkg_name "$HOME/.nix-profile/")
  result=$(echo "$all_packages" | sort -u)
  echo "$result"
}

if [ "$1" = "--names" ];
then
  show_names
else
  show_count
fi
