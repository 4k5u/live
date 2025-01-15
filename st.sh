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
userIds="Yaikun0-0 Riri__oo Xyebobs supassra_sp yoyoqueen yuanyuannnn Doreen-666  bee-my embez-damdang Mia826 insgirl bella-175 AngryBirds00 Lucky-Anna001 -O_mei- stripchat-yaoyao zhiyao99 duduluu YINGTao-168 Luli-bae __Amy__ Sunshineeve23 NANA-CC syy9999 sherry_niko Crystalovo moenymaker_taipei Gameyoyo A_sexydoll22 l1lpamp shuiduoduo-xz DUDU_MM Chaddy-12 bejeni-sweet tingting66 jin__ray lucky-uu -ov-er- Eden-top Sweet-Angel999 Monica-888 Smm555 -o-Sundae TuyetNhi2k6 TAOZI-BAOBei -Xiaoxue anna102 fafa-888 NOA_oO minion998 peichen6699 -ci_ci- Oo_Kaixin_oO -Aricia- wumeinv qqisjaujwhsdshzu -Xiaoxue regina0807 Jennie_Spa LoveJay520 168-Lucky badangelsjennyx fog- cuteeeeeeeeeee- IsMiMi 4inlv miaomijiang Aliceblush Asian2021 niunew ciara-yiyi JayPope elyn520520 kolll88 520-chuchu Sakura_Anne SAYA_JP Riri__oo Chaddy-12 May-Squirt Daji__-Baby_ Starry88 NOA_oO JP-YUNA tw_Sutew Li_Li_ -M_Hinano_ N_Hibiki nyakotan JP-MAI520- chuchu 172----95----student MeghanCollin 172-95-student kolll88 Asia-Lynn Witcher_DK MiaoMjiang8 cecilia0903 LOVE-Juan520- Glenda_1 raisy_000 Angel-Bei-bei Dolv_1o Ryo-sama IdaJonesy Daji-Lovely RoseVal Happy-_-puppy TuTu-1001 SexyModel-170cm grandeeney ii1liii1il asuna_love JessicaRewan sabrina_hk888 lucy_1811 EmiliaGuess Stbeautn_oO charming_NaNa21 Judy0523 StunnerBeauty-170cm M--I--A alicelebel Reaowna Akiyama_Key sigmasian Xenomy TefFfish Sime_Naughty SanySenise _PunPun18 BadAngels666 JP-KARIN 777YikuYiku Hahaha_ha2 Daji-520 San___San mikio_san AkiShina Sherry_niko Lucille_evans morphesoull";
#Ailen_baby  student-se
#Witcher_DK 777YikuYiku

for userId in ${userIds}; do
    json=$(curl -sSL --connect-timeout 5 --retry-delay 3 --retry 3 -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" -H 'x-device-info:{"t":"webMobile","v":"1.0","ui":24631221}' "https://zh.stripchat.com/api/front/v2/models/username/${userId}/cam")
    sid=$(echo $json | jq -r .cam.streamName)
    islive=$(echo $json | jq .cam.isCamAvailable)
    imgTimestamp=$(echo $json | jq -r .user.user.snapshotTimestamp)
    img="https://img.strpst.com/thumbs/${imgTimestamp}/${sid}_webp"
    echo "${islive}"
    echo "开始获取直播源"
    if [ "${islive}" == true ]; then
        echo "${userId}获取成功。"
        echo -e "$userId ">> online.txt
        hls="https://edge-hls.doppiocdn.live/hls/${sid}/master/${sid}_auto.m3u8"
        echo "直播源：$hls"

        if grep -q "${userId}" data.txt; then
            echo "The UID $userId exists in data.txt"
        else
            echo "$userId 推送到TG"
            text="<b>@kbjba 提醒你！！！！</b>\n\n#Stripchat 主播 #${userId} 在线\n\n<a href='${m3u8site}?url=${hls}'>让我康康！直播源地址</a>\n\n<a href='https://zh.stripol.com/${userId}'>直播间链接</a>\n\n_"
            #text=$(echo "${text}" | sed 's/-/\\\\-/g')
            #text=$(echo "${text}" | sed 's/_/\\\\_/g')
            curl -H 'Content-Type: application/json' -d "{\"chat_id\": \"@kbjol\", \"caption\":\"$text\", \"photo\":\"$img\"}" "https://api.telegram.org/${bot}/sendPhoto?parse_mode=HTML"
            echo -e "$userId $hls" >> data.txt
            echo -e "添加$userId $hls" >> $logfile
        fi
    else 
        echo "$userId 获取直播源失败！"
        echo "错误提示：$(echo $json | jq -r .user.user.statusChangedAt)"
    fi   
    echo "-----------`date`--------------"
    sleep 1
done

echo "开始检测失效房间"
bash check.sh
