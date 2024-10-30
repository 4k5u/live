#!/bin/bash

# 检查 WARP 状态
status=$(warp-cli --accept-tos status | grep -i "Status update" | awk '{print $3}')
echo "$status"
# 如果 WARP 没有连接，则执行注册和连接命令
if [ "$status" != "Connected" ]; then
  echo "WARP is not connected. Reconnecting..."
  
  sudo warp-cli --accept-tos disconnect
  
  # 设置 WARP 模式为 warp+doh
  sudo warp-cli --accept-tos mode warp+doh
  
  # 尝试连接
  sudo warp-cli --accept-tos connect
  sleep 5
  # 检查连接是否成功
  new_status=$(warp-cli --accept-tos status | grep -i "Status update" | awk '{print $3}')
  echo "$new_status"
  if [ "$new_status" == "Connected" ]; then
    echo "WARP connected successfully."
  else
    echo "Failed to connect to WARP."
  fi
else
  echo "WARP is already connected."
fi

echo "IPv4: $(sudo curl -s4m8 --retry 3 -A Mozilla https://api.ip.sb/geoip)"
echo "IPv6: $(sudo curl -s6m8 --retry 3 -A Mozilla https://api.ip.sb/geoip)"
