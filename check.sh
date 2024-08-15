#!/bin/bash
synctv="$SYNCTV"
pdapi="$PDAPI"
logfile="log/log_`date '+%Y%m%d'`.txt"
while IFS= read -r line || [ -n "$line" ]
do
    # 从每行中提取URL
    userId=$(echo "$line" | cut -d ' ' -f1)
    url=$(echo "$line" | cut -d ' ' -f2)
    # 使用curl检测URL的可用性
    # 检测URL是否包含特定字符串
    if [[ "$url" == *"https://ffdced"* ]]; then
        if ! grep -q "${userId}" userid.txt; then
            echo "$userId 已下播, 删除记录" 
            echo -e "删除$userId $url">> $logfile
            sed -i "\~$url~d" data.txt
        else
            echo "$userId 直播源有效"
        fi
        
    elif curl --max-time 15 --connect-timeout 5 --retry-delay 0 --retry 1  --output /dev/null --silent --head --fail "$url"; then
        echo "$userId - $url 直播源有效"
    else
        if grep -q "${userId}" online.txt; then
            echo "$userId 直播源失效,但在线" 
        else
            echo "$userId - $url 直播源失效, 且已下播, 删除记录" 
            echo -e "删除$userId $url">> $logfile
            sed -i "\~$url~d" data.txt
        fi
    fi
done < data.txt
