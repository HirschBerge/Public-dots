#!/usr/bin/env bash

check_if_empty() {
	[[ -z "$1" ]] && echo "0" || echo "$1"
}

KEY="8b05d62206f459e1d298cbe5844d7d87"
ID="5206379"
UNITS="imperial"
WEATHER=$(curl -sf "api.openweathermap.org/data/2.5/weather?appid=$KEY&id=$ID&units=$UNITS")

SUNRISE=$(date -d @"$(echo "$WEATHER" | jq ".sys.sunrise")" | awk '{ print $4 }' | rg ':[0-9]{2}$' -r "")
SUNSET=$(date -d @"$(echo "$WEATHER" | jq ".sys.sunset")" | awk '{ print $4 }' | rg ':[0-9]{2}$' -r "")
WEATHER_DESC=$(echo "$WEATHER" | jq -r ".weather[].description" | head -1 | sed -e "s/\b\(.\)/\u\1/g")
WEATHER_TEMP=$(echo "$WEATHER" | jq ".main.temp" | cut -d "." -f 1)
WEATHER_ICON_CODE=$(echo "$WEATHER" | jq -r ".weather[].icon" | head -1)
WEATHER_FEELS_LIKE=$(echo "$WEATHER" | jq ".main.feels_like" | cut -d "." -f 1)
WEATHER_WIND=$(echo "$WEATHER" | jq -r ".wind.speed")
WEATHER_HUMIDITY=$(echo "$WEATHER" | jq ".main.humidity" | cut -d "." -f 1)
WEATHER_ICON=""
WEATHER_HEX=""

case $WEATHER_ICON_CODE in
	"01d") WEATHER_ICON=""; WEATHER_HEX="#ffd86b";;
	"01n") WEATHER_ICON=""; WEATHER_HEX="#fcdcf6";;
	"02d") WEATHER_ICON=""; WEATHER_HEX="#adadff";;
	"02n") WEATHER_ICON=""; WEATHER_HEX="#adadff";;
	"03d") WEATHER_ICON=""; WEATHER_HEX="#adadff";;
	"03n") WEATHER_ICON=""; WEATHER_HEX="#adadff";;
	"04d") WEATHER_ICON=""; WEATHER_HEX="#adadff";;
	"04n") WEATHER_ICON=""; WEATHER_HEX="#acb0d0";;
	"09d") WEATHER_ICON=""; WEATHER_HEX="#6b95ff";;
	"09n") WEATHER_ICON=""; WEATHER_HEX="#6b95ff";;
	"10d") WEATHER_ICON=""; WEATHER_HEX="#6b95ff";;
	"10n") WEATHER_ICON=""; WEATHER_HEX="#6b95ff";;
	"11d") WEATHER_ICON=""; WEATHER_HEX="#ffeb57";;
	"11n") WEATHER_ICON=""; WEATHER_HEX="#ffeb57";;
	"13d") WEATHER_ICON=""; WEATHER_HEX="#e3e6fc";;
	"13n") WEATHER_ICON=""; WEATHER_HEX="#e3e6fc";;
	"40d") WEATHER_ICON=""; WEATHER_HEX="#84afdb";;
	"40n") WEATHER_ICON=""; WEATHER_HEX="#84afdb";;
	*) WEATHER_ICON=""; WEATHER_HEX="#adadff";;
esac

JSON_RESPONSE=$(cat <<EOF
{
  "current_temp": "$(check_if_empty "$WEATHER_TEMP")",
  "feels_like": "$(check_if_empty "$WEATHER_FEELS_LIKE")",
  "wind": "$(check_if_empty "$WEATHER_WIND")",
  "humidity": "$(check_if_empty "$WEATHER_HUMIDITY")",
  "weather_desc": "$(check_if_empty "$WEATHER_DESC")",
  "icon": "$WEATHER_ICON",
  "hex": "$WEATHER_HEX",
  "city": "$CITY",
  "wmodule": "$WEATHER_ICON $WEATHER_TEMP°",
  "rise": "$SUNRISE AM",
  "set": "$SUNSET PM"
}
EOF
)

echo "$JSON_RESPONSE"

