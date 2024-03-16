convert_percentage() {
  local percentage
  percentage=$(echo "$1" |sd "%" "")
  local total_mbs=$((16 * 1024))  # 16 GB in MB (1 GB = 1024 MB)
  local result=$((percentage * total_mbs / 100))
  echo "$result"
}
get_info (){
  # output=$(nvidia-smi --query-gpu=memory.used,utilization.gpu,temperature.gpu --format=csv,noheader,nounits | awk -F"," '{ print $1 $2 $3}')
  output=$(rocm-smi | awk '$1 == 0 { print $2" " $9" " $10 }')
  mem=$(echo "$output" |awk '{ print $2 }')
  mem=$(convert_percentage "$mem")
  temp=$(echo "$output" |awk '{ print $1}' |sd "c" "")
  title="RX 7900 GRE"
  util=$(echo "$output" |awk '{ print $3 }')
}

return_json(){
  rocm-smi | awk '$1 == 0' |sd "\s+" " "| jq -n -R '[inputs | split(" ") | {GPU: .[0], Temp: .[1], AvgPwr: .[2], SerialClock: .[3], MasterClock: .[4], Fan: .[5], Perf: .[6], PwrCap: .[7], VRAMPercent: .[8], GPUPercent: .[9]}]'
}

while true;
do
  if [[ $1 == '--json' ]]; then
    return_json
  else
    get_info # TODO output as json
    if [[ "$*" == *"--side"* ]]; then
      echo  "    ${title}\n    Mem: ${mem}MB\nUsage: ${util} ${temp}°C" # This is correct
      # Your code here for when --side is present
    else
      echo  "${title} ${mem}MB\nUsage: ${util} ${temp}°C" # This is correct
      # Your code here for when --side is not present
    fi
  fi
  sleep 3
done

