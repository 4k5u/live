#!/bin/bash
# Config

afcookie="$AFCOOKIE"
userToken="$USERTOKEN"
bot="$BOTTOKEN"
synctv="$SYNCTV"
username="$USERNAME"
password="$PASSWORD"
m3u8site="$M3U8SITE"
logfile="log/log_`date '+%Y%m%d'`.txt"
#userIds=$1
userIds="aesoon96 chitaya bada0629 jssisabel moto5053 yxyxyyy sumin2005 zoozoo1119 aesoon96 danhana yepyeppp dbzala yoda111 luvje000";

echo -e `date` >> $logfile


for userId in ${userIds}; do
    channelId=$(curl  -s "https://api.flextv.co.kr/api/lives/search?limit=1&name=${userId}" |jq -r .data[0].channelId)
    if [ -n "$channelId" ] && [ "$channelId" != null ] ; then
        echo "在线，开始获取直播源"
        echo -e "$userId ">> online.txt
        if grep -q "${userId}" data.txt; then
            echo "The UID $uid exists in data.txt"
        else
            res=`curl -sSL --connect-timeout 5 --retry-delay 3 --retry 3 -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" -H 'x-device-info:{"t":"webMobile","v":"1.0","ui":24631221}' -H "cookie:${FLEXCOOKIE}"  "https://api.flextv.co.kr/api/channels/${channelId}/stream?option=all" `
            hls=$(echo "$res"| jq -r .sources[].url)
            userId=$(echo "$res"| jq -r .owner.loginId)
            img=$(echo "$res"| jq -r .thumbUrl)
            startTime=$(echo "$res"| jq -r .stream.createdAt)
            if [ -n "$hls" ] && [ "$hls" != null ] ; then
            	echo "${userId}获取成功。"
            	echo "直播源：${hls}"

            	echo "$userId 推送到TG"
            	text="<b>@kbjba 提醒你！！！！</b>\n\n#Flextv 主播 #${userId} 在线\n\n本场开播时间：$startTime（UTC时间+8小时）\n\n<a href='{m3u8site}?url=${hls}'>直播源地址</a>\n\n<a href='https://www.flextv.co.kr/channels/${channelId}/live'>直播间链接</a>\n\n-----"
            	#text=$(echo "${text}" | sed 's/-/\\\\-/g')
            	curl -H 'Content-Type: application/json' -d "{\"chat_id\": \"@kbjol\", \"caption\":\"$text\", \"photo\":\"$img\"}" "https://api.telegram.org/${bot}/sendPhoto?parse_mode=HTML"
            	echo -e "$userId $hls">> data.txt
                echo -e "$userId ">> online.txt
            	echo -e "添加$userId $hls">> $logfile
            else 
            	echo "$userId 获取直播源失败！"
            	echo "错误提示： $res"
            fi 
        fi
    else
        echo "$userId 可能没开播。"
    fi
    echo "-----------`date`--------------"
    sleep 1
done
