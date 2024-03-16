if [ "$1" == "Spotify" ] || [ "$1" == "discord" ]
then 
	mpv ~/.config/dunst/notification.wav
	echo ""
else	
	mpv ~/.config/dunst/notification.wav
fi
