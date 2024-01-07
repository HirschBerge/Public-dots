
# # Bold High Intensity
# NoColor="\033[0m"
# BIBlack='\033[1;90m'      # Black
# BIRed='\033[1;91m'        # Red
# %{F#00FF00}='\033[1;92m'      # Green
# BIYellow='\033[1;93m'     # Yellow
# BIBlue='\033[1;94m'       # Blue
# BIPurple='\033[1;95m'     # Purple
# BICyan='\033[1;96m'       # Cyan
# BIWhite='\033[1;97m'      # White
get_info ()
{
  output=$(nvidia-smi --query-gpu=memory.used,utilization.gpu,temperature.gpu --format=csv,noheader,nounits | awk -F"," '{ print $1 $2 $3}')
# echo $output
  mem=$(echo $output |awk '{ print $1 }')
  util=$(echo $output |awk '{ print $2 }')
  temp=$(echo $output |awk '{ print $3 }')
}

function color_mem() {
	if [ $mem -le "1000" ]
	then
		mem="%{F#00FF00}$mem"
	elif [ $mem -gt "1000" ] && [ $mem -le "3000" ]
	then
		mem="%{F#00ffff}$mem"
	elif [ $mem -gt "3001" ] && [ $mem -le "6000" ]
	then
		mem="%{F#ffff00}$mem"
	else
		mem="%{F#FF0000}$mem"
	fi
}
function color_util() {
	if [ $util -le "30" ]
	then
		util="%{F#00FF00}$util"
	elif [ $util -gt "30" ] && [ $util -le "70" ]
	then
		util="%{F#00ffff}$util"
	elif [ $util -gt "70" ] && [ $util -le "85" ]
	then
		util="%{F#ffff00}$util"
	else
		util="%{F#FF0000}$util"
	fi
}
function color_temp() {
	if [ $temp -le "40" ]
	then
		temp="%{F#00FF00}$temp"
	elif [ $temp -gt "40" ] && [ $temp -le "69" ]
	then
		temp="%{F#00ffff}$temp"
	elif [ $temp -gt "70" ] && [ $temp -le "79" ]
	then
		temp="%{F#ffff00}$temp"
	else
		temp="%{F#FF0000}$temp"
	fi
}
# color_mem
# color_temp
# color_util
# echo "%{F#00ffff}RTX 3060ti ${mem}Mb ${util}% ${temp}°C"
while true;
do
  get_info
  echo "RTX 3060ti ${mem}Mb\nUsage: ${util}% ${temp}°C"
  sleep 3
done
