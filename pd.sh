#!/bin/bash
# Config
#用法：bash synctv.sh moem9e9 

cookie="$COOKIE"
userToken="$USERTOKEN"
bot="$BOTTOKEN"
synctv="$SYNCTV"
username="$USERNAME"
password="$PASSWORD"
m3u8site="$M3U8SITE"
pdapi="$PDAPI"
logfile="log/log_`date '+%Y%m%d'`.txt"
#userIds=$1


fetch_json() {
    local offset="$1"
    local limit="$2"
    local json
    json=$(curl -sSL --connect-timeout 5 --retry-delay 3 --retry 3 \
        -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" \
        -H "cookie:${cookie}" \
        -X POST  "${pdapi}/v1/live?offset=${offset}&limit=${limit}&orderBy=hot&onlyNewBj=N")
    echo "$json"
}
# 主要脚本
json_file1="json1.tmp"
json_file2="json2.tmp"
merged_json_file="merged.json"

# 获取第一页的 JSON 数据并写入临时文件1
fetch_json 0 96 > "$json_file1"
if [ "$(jq -r .result < "$json_file1")" != true ]; then
    echo "获取列表失败"
    exit 1
fi
echo "------$(date)------"
total=$(jq -r .page.total < "$json_file1")
echo -n "在线主播:$total | 获取前96主播"
# 如果在线主播数超过96，则获取额外的页面并合并JSON数据
if [ "$total" -gt 96 ]; then
    remaining=$((total - 96))
    page=2
    while [ "$remaining" -gt 0 ]; do
        echo -n " | 获取第$page页"
        offset=$(( (page - 1) * 96 ))
        fetch_json "$offset" 96 > "$json_file2"
        #echo  "使用jq合并两个JSON文件中的list数组，并去除重复项"
        jq -s '.[0].list += .[1].list | unique_by(.code)' "$json_file1" "$json_file2" > "$merged_json_file"
        sed -i 's/^\[//; s/\]$//' "$merged_json_file"
        #jq '.list' "$merged_json_file"|head -n 10
        #echo "更新json_file1以便下次追加数据"
        mv  "$merged_json_file" "$json_file1"
        remaining=$((remaining - 96))
        page=$((page + 1))
    done
fi

#echo "最终合并后的JSON数据保存在 json 中"
mv  "$json_file1"  all.json

#echo "清理临时文件"
rm "$json_file2"
json=$(cat all.json)

isAdults=$(echo "$json" |jq .list[]|jq 'select(.isAdult == true)'|jq .userId|wc -l)
fans=$(echo "$json" |jq .list[]|jq 'select(.type == "fan")'|jq .userId|wc -l)
isPws=$(echo "$json" |jq .list[]|jq 'select(.isPw == true)'|jq .userId|wc -l)
echo " | 19+房间:$isAdults | 粉丝房:$fans | 密码房:$isPws"

#cat json |jq .list[]|jq 'select(.type == "free")'|jq .userId
#userIds=$(echo $json|jq -r .list[].userId)
IFS=$'\n' read -r -d '' -a onlineIds < <(jq -r '.list[].userId' <<< "$json")
echo "${onlineIds[@]}" > userid.txt
echo "获取到主播数：${#onlineIds[@]}"

freeIds=($(echo "$json"|jq .list[]|jq 'select(.type == "free")'|jq -r .userId))
watchIds="100042 100472 123phmaaa 162cm 1919152 1stforever 1toptoontv 20152022 2671907618 2dayday 362540 3721710014 3ww1ww3 4ocari 5050yourii 54soda acac88 achoo1322 acron5 aeaei5082 aesoon96 aesoon_96 ah2love ahri0801 ajswl12 akakak11112 als0723 alswjd04 angelovo angzzi anystar00 apffhdn1219 apfhdfhd00 areno0512 aszx601 axcvdbs23 bada0629 banet523 bblove17 blue0722 bmg4262 bo1004 bom124 bongbong486 cccc01235 cho77j choi122199 choyunkyung chuchu22 chuing77 chzhffpt432 cool3333 csp1208 dana9282 danhana day59day dbzala deer9805 dhvms18 dkdlfjqm758 dks2003 dkssudgktpdy233 dmsdms1247 do2do2 dondus777 double101 dudvv7 duk97031 duk970313 dusdk2 dusqhfk456 ee5844 eerttyui12 ehdbs0105 eli05021212 emforhs1919 fjqwldus1998 flowerwar foru5858 gena723 getme1004 ggseol123 giyoming gkfnsus5573 gksmf0f0 goldmandarin green10004 gucci333 guqehdwhgkq gyg4618 gyuri26 haeleun3 hani0924 happyy2 heenoo hehe0000 hfpw4i19 hhj11230 hidana hj0011 hncsphj holymoly62 homegirl hotse777 howru010 hyhy990 hyuna0721 icubi69 iloveyeon7 imanatural imgroot5 imissy0u imsocutesexy in0410 ina2048 ioibibi j900726 jdm777 jenny9999 jiji4809 jinricp jinricrew1 jjine0127 jodong2 jssisabel jubin0725 jxxhxx1202 k19g61m1pzneds kaakuu22 kkotbi777 kook0613 ksb0219 lalalov2 leeaeae123 leeeunmimi2 leeyuin1 likeastar77 likecho lineage282 lorins2002 lovable12 love0098 love0410 lovelypower77 lovemeimscared lovepit lovesong2 lululu7777 luv135 maby33 mayonz melona0 merryxmas77 mini10062 mini2121 minllor5 missedyou moem9e9 mozzzi mscrew33 muse62 N19g61m5apilut na2ppeum na2ppueum naras2 nemu00 nobleinc nyangnyang1004 o111na obzee7 ohhanna okzzzz onlyone521 orange19890220 pandaclass pandaex parkeil123 podo0311 pupu28 pyey3380 qkeksms3 qkrchfhd90 qtqtpt486 qwas33 qwasop12y qwe1204 qwe1240 qwer00725 raindropx redholic377 rico0210 rlacowls5 rmrm1313 rmrm1813 roaaa10 romantic09 rona000 rose2002 rud9281 saone451 senllaurent seozzidooboo sexymin12 sexyrain2918 Sharon9sea sia0001 simle1001 siyun0813 sksnrnrp11 slime97 smile1001 smile1027 so2so2so sonming52 soocute13 soraa3 soso621 soye52 sseerrii0201 sssna777 starsh2802 stuiliillive suee2332 sumin2005 sxleeluvsyou syxx12 teenylizzy tenz8s tess00 thgml1212 tjfflddl7 tyy750ii unauna99 uoan2xoak3j0skq uxaonn vip000 vowoa777 vvvv1212 Vvvv1212 vvvvvv11 wintersnowwin wjdwlsdud91 wltn9818 won110 xxaaop y0ur1n12486 yami1009 yamimm yasexy ye990628 yepyeppp yoda111 youha1004 yourare youvely22 yunini0624 yxyxyyy zlzzlz19 zmalqp6666 zoahakdlf zoozoo1119 zxc1002011 zzeongi2 zzudyy";

# 使用grep命令获取group1和group2中的重复元素，并组成一个新的数组
#userIds=($(echo "$watchIds ${freeIds[@]}" | tr ' ' '\n' | sort | uniq -d))
# 提取在线关注用户数组
userIds=()
for id in $watchIds; do
    for freeId in "${freeIds[@]}"; do
        if [[ "$id" == "$freeId" ]]; then
            userIds+=("$id")
            break
        fi
    done
done

# 输出元素
echo "监控中在线主播：${userIds[@]}"
#
#afreeca gusdk2362  sol3712 m0m099  namuh0926 
#pop162cm
#flex golaniyule0
#? lovether

echo -e `date` >> $logfile


for userId in ${userIds[@]}; do
    if grep -q "${userId}" data.txt; then
        echo "The UID $userId exists in data.txt"
    else
        json=`curl -sSL --connect-timeout 5 --retry-delay 3 --retry 3 -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" -H 'x-device-info:{"t":"webMobile","v":"1.0","ui":24631221}' -H "cookie:${cookie}" -X POST  "${pdapi}/v1/live/play?action=watch&userId=${userId}"` 
        hls=`echo $json| jq -r .PlayList.hls[0].url`
        img=`echo $json| jq -r .media.ivsThumbnail`
        startTime=`echo "$json"| jq -r .media.startTime`
        echo "开始获取直播源"
        if [ -n "$hls"  ] &&  [ "$hls" != null ]; then
            echo "${userId}获取成功。"
            echo "直播源：${hls}"
            
            echo "$userId 推送到TG"
            text="<b>@kbjba 提醒你！！！！</b>\n\n#Panda 主播 #${userId} 在线\n\n本场开播时间：$startTime（韩国时间快1小时）\n\n<a href='${m3u8site}/pandalive.html?url=${userId}'>直达地址</a>\n\n<a href='https://www.pandalive.co.kr/live/play/${userId}'>直播间链接</a>\n\n_"
            #text=$(echo "${text}" | sed 's/-/\\\\-/g')
            curl -H 'Content-Type: application/json' -d "{\"chat_id\": \"@kbjol\", \"caption\":\"$text\", \"photo\":\"$img\"}" "https://api.telegram.org/${bot}/sendPhoto?parse_mode=HTML"                
            echo -e "$userId $hls">> data.txt
            echo -e "添加$userId $hls">> $logfile
        else 
            echo "$userId 获取直播源失败！"
            echo "错误提示：$json "
        fi
    fi
    echo "-----------`date`--------------"
    sleep 2
done   
 

