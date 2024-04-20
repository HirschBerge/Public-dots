convert_percentage() {
  local percentage
  percentage=$(echo "$1" |sd "%" "")
  local total_mbs=$((16 * 1024))  # 16 GB in MB (1 GB = 1024 MB)
  local result=$((percentage * total_mbs / 100))
  echo "${result}MB"
}
get_info (){
  # output=$(nvidia-smi --query-gpu=memory.used,utilization.gpu,temperature.gpu --format=csv,noheader,nounits | awk -F"," '{ print $1 $2 $3}')
  output=$(rocm-smi | awk '$1 == 0 { print $5" " $14" " $15 }')
  mem=$(echo "$output" |awk '{ print $2 }')
  mem=$(convert_percentage "$mem")
  temp=$(echo "$output" |awk '{ print $1}' |sd "c" "")
  title="RX 7900 GRE"
  util=$(echo "$output" |awk '{ print $3 }')
}

# return_json(){
#   rocm-smi | awk '$1 == 0' |sd " : " ":" |sd ", " "," |sd "\s+" " "| jq -n -R '[inputs | split(" ") | {GPU: .[0], Model: .[1], Temp: .[2], AvgPwr: .[3], Partitions: .[4], SerialClock: .[5], MasterClock: .[6], Fan: .[7], Perf: .[8], PwrCap: .[9], VRAMPercent: .[10], GPUPercent: .[11]}]' |jq .[]
# }
return_json(){
  gpu_info_filtered=$(rocm-smi | awk '$1 == 0')
  gpu_info_cleaned=$(echo "$gpu_info_filtered" | sed -e "s/ : /:/g" -e "s/, /,/g" | tr -s ' ')
  gpu_json=$(echo "$gpu_info_cleaned" | jq -n -R '[inputs | split(" ") | {GPU: .[0], Model: .[1], Temp: .[2], AvgPwr: .[3], Partitions: .[4], SerialClock: .[5], MasterClock: .[6], Fan: .[7], Perf: .[8], PwrCap: .[9], VRAMPercent: .[10], GPUPercent: .[11]}]')
  vram_percent=$(echo "$gpu_json" | jq '.[0].VRAMPercent' |sd '\"' '')
  new_vram_percent=$(convert_percentage "$vram_percent")
  gpu_variables=$(echo "$gpu_json" | jq --arg new_vram_percent "$new_vram_percent" '.[0].VRAMPercent = $new_vram_percent')
  echo "$gpu_variables" |jq .[]
}


while true;
do
  if [[ $1 == '--json' ]]; then
    return_json
    exit
  else
    get_info # TODO output as json
    if [[ "$*" == *"--side"* ]]; then
      echo  "    ${title}\n    Mem: ${mem}MB\nUsage: ${util} ${temp}" # This is correct
      # Your code here for when --side is present
    else
      echo  "${title} ${mem}MB\nUsage: ${util} ${temp}" # This is correct
      # Your code here for when --side is not present
    fi
  fi
  sleep 3
done

