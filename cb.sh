#!/bin/bash
# Config
#用法：bash st.sh Daji-520

userToken="$USERTOKEN"
bot="$BOTTOKEN"
synctv="$SYNCTV"
username="$USERNAME"
password="$PASSWORD"
m3u8site="$M3U8SITE"
cookie="";
logfile="log/log_`date '+%Y%m%d'`.txt"
#userIds=$1
userIds="taitehambelton mizuki_aikawa_ii rosyemily lovewindy alicechina Kim_possible_01 hee_jeen calliadesigner amilia4u gina_gracia _marydel_ Northern_gracia joysuniverse ad0res techofoxxx jiso-baobei oki_dokie galantini _meganmeow_ ake_mi oda_assuri iminako mode_bad intim_mate cuddles_me mazzanti_ honey_pinkgreen sexygamesx foxylovesyou kiriko_chan kiyoko_rin my_eyes_higher _katekeep your_desssert";

echo $(curl ip.sb)

for userId in ${userIds}; do
    http_code=`curl -sSL -w "%{http_code}" -o /dev/null --connect-timeout 5 --retry-delay 3 --retry 3 -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" https://jpeg.live.mmcdn.com/stream?room=${userId}`
    if [ "${http_code}" == 200 ]; then
        echo -e "$userId ">> online.txt
        echo "在线，开始获取直播源"
        if grep -q "${userId}" data.txt; then
            echo "The UID $uid exists in data.txt"
        else
            json=`curl --location 'https://chaturbate.com/get_edge_hls_url_ajax/' --header 'x-requested-with: XMLHttpRequest' --form "room_slug=${userId}"`
            #echo $(curl "https://chaturbate.com//streamapi/?modelname=${userId}")
            #json=`curl -sSL --connect-timeout 5 --retry-delay 3 --retry 3 -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" "https://proxy.scrapeops.io/v1/?api_key=b3db67ba-385b-4f20-a1ea-4463df5ab939&url=https://chaturbate.com.tw/streamapi/?modelname=${userId}"` 
            #json=`curl -sSL --connect-timeout 5 --retry-delay 3 --retry 3 -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" "https://chaturbate.com.tw/streamapi/?modelname=${userId}"`
            hls=`echo $json|jq -r .url`
            #img="https://cbjpeg.stream.highwebmedia.com/stream?room=${userId}&f=$(date '+%Y%m%d%H%M')"
            img="https://jpeg.live.mmcdn.com/stream?room=${userId}&f=$(date '+%Y%m%d%H%M')"
            if [ -n "$hls"  ] &&  [ "$hls" != null ]; then
                echo "${userId}获取成功。"
                echo "直播源：${hls}"
                
                echo "$userId 已推送到TG"
                text="<b>@kbjba 提醒你！！！！</b>\n\n#Chaturbate 主播 #${userId} 在线\n\n<a href='${m3u8site}?url=${hls}'>让我康康！直播源地址</a>\n\n<a href='https://www.chaturbate.com/${userId}'>直播间链接</a>\n\n_"
                echo $text
                #text=$(echo "${text}" | sed 's/-/\\\\-/g')
                #text=$(echo "${text}" | sed 's/_/\\\\_/g')
                curl -H 'Content-Type: application/json' -d "{\"chat_id\": \"@kbjol\", \"caption\":\"$text\", \"photo\":\"$img\"}" "https://api.telegram.org/${bot}/sendPhoto?parse_mode=HTML"
                echo -e "$userId $hls">> data.txt
                echo -e "添加$userId $hls">> $logfile
            else 
                echo "$userId 获取直播源失败！"
                echo "错误提示：$json "
            fi
        fi
    else
        echo "$userId 可能没开播。"
    fi
    echo "-----------`date`--------------"
    sleep 2
done
