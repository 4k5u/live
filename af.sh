#!/bin/bash
# Config
#用法：bash synctv.sh moem9e9 

afcookie="$AFCOOKIE"
userToken="$USERTOKEN"
bot="$BOTTOKEN"
synctv="$SYNCTV"
username="$USERNAME"
password="$PASSWORD"
m3u8site="$M3U8SITE"
logfile="log/log_`date '+%Y%m%d'`.txt"
#userIds=$1
userIds="dana9282 Tmdgus5411 navi04 alswl2208 jeehyeoun lolsos asianbunnyx leelate gremmy y1026 kkkku96 rud9281 somsom0339 eunyoung1238 dign1461 gusdk2362 sol3712 m0m099 namuh0926 kjjeong0609 flower1023 hanny27 glglehddl yin2618";
#
#afreeca gusdk2362  sol3712 m0m099  namuh0926  m0m099
#pop162cm
#flex golaniyule0
#? lovether

echo -e `date` >> $logfile


for userId in ${userIds}; do
    if grep -q "${userId}" data.txt; then
        echo "The UID $uid exists in data.txt"
    else
        json=`curl -sSL --connect-timeout 5 --retry-delay 3 --retry 3 -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"  "https://bjapi.afreecatv.com/api/{$userId}/station"` 
        BNO=`echo $json| jq -r .broad.broad_no`
        is_password=`echo $json| jq -r .broad.is_password`
        timestamp=$(date +%s)
        img="https://liveimg.afreecatv.com/m/${BNO}?${timestamp}.jpg"
        echo $img
        startTime=`echo "$json"|jq -r .station.broad_start`
        
        echo "开始获取直播源"
        if [ -n "$BNO"  ] &&  [ "$BNO" != null ] && [ "$is_password" != "true" ]; then
            hls_json=`curl -k --http1.1 -sSL --connect-timeout 5 --retry-delay 3 --retry 3 -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" -H "cookie:${afcookie}" -F "bid=${userId}" -F "type=aid" -X POST 'https://live.afreecatv.com/afreeca/player_live_api.php'`
            echo $hls_json
            hls_key=`echo $hls_json| jq -r .CHANNEL.AID`
            sleep 1
            hls_url=`curl -sSL --connect-timeout 5 --retry-delay 3 --retry 3 -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" "https://livestream-manager.afreecatv.com/broad_stream_assign.html?return_type=gcp_cdn&broad_key=${BNO}-common-master-hls"|jq -r .view_url`
            hls="${hls_url}?aid=${hls_key}" 
            echo "${userId}获取成功。"
            echo "直播源：${hls}"

            echo "$userId 推送到TG"
            #text="*J哥提醒你！！！！*\n\nAfreeca主播${userId}直播源已添加到SyncTV\n\n本场开播时间：$startTime（韩国时间快1小时）\n\n[直达地址，让我康康！](${synctv}/web/cinema/${roomid})\n\n[直达地址②，再次康康！](${m3u8site}?url=${userId})\n\n"
            text="<b>J哥提醒你！！！！</b>\n\n#Afreeca 主播 #${userId} 在线\n\n本场开播时间：$startTime（韩国时间快1小时）\n\n<a href=\"$hls\">直播源地址</a>\n\n<a href=\"https://play.afreecatv.com/${userId}/${BNO}\">直播间链接</a>\n\n-----"
            #text=$(echo "${text}" | sed 's/-/\\\\-/g')
            curl -H 'Content-Type: application/json' -d "{\"chat_id\": \"@kbjol\", \"caption\":\"$text\", \"photo\":\"$img\"}" "https://api.telegram.org/${bot}/sendPhoto?parse_mode=HTML"
            echo -e "$userId $hls">> data.txt
            echo -e "添加$userId $hls">> $logfile
        else 
            echo "$userId 获取直播源失败！"
            echo "错误提示：$(echo $json| jq -r .broad)"  #$json "
        fi   
        echo "-----------`date`--------------"
        sleep 2
    fi
done   

