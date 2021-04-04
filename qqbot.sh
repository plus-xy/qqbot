#!/bin/bash


#定义几个颜色
purple()                           #基佬紫
{
    echo -e "\\033[35;1m${*}\\033[0m"
}
tyblue()                           #天依蓝
{
    echo -e "\\033[36;1m${*}\\033[0m"
}
green()                            #原谅绿
{
    echo -e "\\033[32;1m${*}\\033[0m"
}
yellow()                           #鸭屎黄
{
    echo -e "\\033[33;1m${*}\\033[0m"
}
red()                              #姨妈红
{
    echo -e "\\033[31;1m${*}\\033[0m"
}
blue()                             #蓝色
{
    echo -e "\\033[34;1m${*}\\033[0m"
}


#检查基本命令
check_base_command()
{
    local i
    local temp_command_list=('bash' 'true' 'false' 'exit' 'echo' 'test' 'free' 'sort' 'sed' 'awk' 'grep' 'cut' 'cd' 'rm' 'cp' 'mv' 'head' 'tail' 'uname' 'tr' 'md5sum' 'tar' 'cat' 'find' 'type' 'command' 'kill' 'pkill' 'wc' 'ls' 'mktemp')
    for i in ${!temp_command_list[@]}
    do
        if ! command -V "${temp_command_list[$i]}" > /dev/null; then
            red "命令\"${temp_command_list[$i]}\"未找到"
            red "不是标准的Linux系统"
            exit 1
        fi
    done
}

#判断包管理类型
if [[ "$(type -P apt)" ]]; then
    if [[ "$(type -P dnf)" ]] || [[ "$(type -P yum)" ]]; then
        red "同时存在apt和yum/dnf"
        red "不支持的系统！"
        exit 1
    fi
    pack_manger="apt"
elif [[ "$(type -P dnf)" ]]; then
    pack_manger="dnf"
elif [[ "$(type -P yum)" ]]; then
    pack_manger="yum"
else
    red "apt yum dnf命令均不存在"
    red "不支持的系统"
    exit 1
fi

#判断系统架构
case "$(uname -m)" in
    'amd64' | 'x86_64')
        machine='amd64'
        ;;
    'armv5tel' | 'armv6l' | 'armv7' | 'armv7l')
        machine='arm'
        ;;
    'armv8' | 'aarch64')
        machine='arm64'
        ;;
    *)
        machine=''
        ;;
esac

#更新系统
read -p '是否要更新源(可能会花费较长时间)[y/n]:'  yn1

if [ "$yn1" == "y" ]; then
$pack_manger update
else
red "若组件安装失败请更新系统！"
sleep 1s
fi

#安装下载组件

blue "检查wget中..."

wget --help >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
red "您未安装wget,正在为您安装"
$pack_manger install -y wget
else
red "wget已存在"
fi

blue "检查git中..."

git --version >/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
red "您未安装git,正在为您安装"
$pack_manger install -y git
else
red "git已存在"
fi


get_cq(){

tyblue "获取go-cqhttp_linux_$machine.tar.gz"
mkdir ~/qqbot
wget -O ~/qqbot/go-cqhttp_linux_$machine.tar.gz https://github.com/Mrs4s/go-cqhttp/releases/download/v1.0.0-beta1/go-cqhttp_linux_$machine.tar.gz
tar -xvzf ~/qqbot/go-cqhttp_linux_$machine.tar.gz -C ~/qqbot

}

get_cq2(){

tyblue "获取cq-picsearcher-bot.git"
git clone https://github.com/Tsuk1ko/cq-picsearcher-bot.git
cd cq-picsearcher-bot
cp config.default.jsonc config.jsonc
cd ~

}


peizhi(){

read -p "请输入管理者QQ" admin

read -p "是否自动同意好友申请[y/n]" autoAddFriendp
if [ "$autoAddFriendp" == "y" ]; then
autoAddFriend=true
else
autoAddFriend=flase
fi

read -p "是否自动同意好友申请[y/n]" autoAddGroupp
if [ "$autoAddGroupp" == "y" ]; then
autoAddGroup=true
else
autoAddGroup=flase
fi

read -p "是否启用涩图功能[y/n]" setup
if [ "$setu" == "y" ]; then
setu=true
read -p "请设置涩图多少秒撤回[数字]" deleteTime
read -p "请设置涩图多少秒撤回[数字]" cdt
else
setu=flase
deleteTime=60
cdt=60
fi

read -p "是否允许涩图功能私聊使用[y/n]" allowPMp
if [ "$setu" == "y" ]; then
allowPM=true
else
allowPM=flase
fi
red "获取涩图api\n请到https://api.lolicon.app/#/setu?id=apikey获取\n没有将无法使用涩图功能"
sleep 2s
read -p "请输入涩图api(没有请按回车):" setuapi
red "获取搜图api\n请到https://saucenao.com/user.php获取\n没有将影响搜图功能"
sleep 2s
read -p "请输入saucenaoapi(没有请按回车)" saucenaoApiKey

cat > ~/cq-picsearcher-bot/config.jsonc << EOF

{
  // momocow/node-cq-websocket 配置，请参考 https://git.io/JkK9A
  "cqws": {
    "host": "127.0.0.1",
    "port": 6700,
    "enableAPI": true,
    "enableEvent": true,
    "accessToken": "",
    "reconnection": true,
    "reconnectionAttempts": 10,
    "reconnectionDelay": 5000
  },
  // 机器人配置
  "bot": {
    // 调试模式，启用时只会响应来自 admin 的发言，方便独自测试，并且会为所有搜图行为默认添加 --debug 参数
    "debug": false,
    // 管理者QQ，请务必设置
    "admin": $admin,
    // 是否开启私聊监听
    "enablePM": true,
    // 是否开启群消息监听
    "enableGM": true,
    // 是否自动同意好友申请（false 则忽略，但不会拒绝）
    "autoAddFriend": $autoAddFriend,
    // 根据问题回答同意好友申请，详情请查看“wiki-配置文件说明”
    "addFriendAnswers": [],
    // 是否自动同意入群申请（false 则忽略，但不会拒绝，并且可以用命令手动允许，详情请查看“wiki-配置文件说明”）
    "autoAddGroup": $autoAddGroup,
    // 隐藏所有搜索结果的缩略图
    "hideImg": false,
    // saucenao 得到低相似度结果时隐藏结果缩略图（包括 ascii2d 和 nhentai）
    "hideImgWhenLowAcc": false,
    // whatanime 得到 R18 结果时隐藏结果缩略图
    "hideImgWhenWhatanimeR18": false,
    // saucenao 默认搜索库，可选值：["all", "pixiv", "danbooru", "doujin", "anime"]
    "saucenaoDefaultDB": "all",
    // saucenao 相似度低于这个百分比将被认定为相似度过低
    "saucenaoLowAcc": 60,
    // 是否在 saucenao 超额时自动换用 ascii2d
    "useAscii2dWhenQuotaExcess": true,
    // 是否在 saucenao 相似度过低时自动使用 ascii2d
    "useAscii2dWhenLowAcc": true,
    // 是否在 saucenao 搜索失败时自动使用 ascii2d
    "useAscii2dWhenFailed": true,
    // saucenao 搜到本子时是否进一步去 nhentai 搜索
    "getDojinDetailFromNhentai": true,
    // 每名用户每日搜索次数限制
    "searchLimit": 30,
    // 搜图模式超时时间（秒），0 则无超时（不推荐，使用者不清楚容易造成困惑）
    "searchModeTimeout": 60,
    // 在群内使用搜图功能时，只通过私聊发送搜图结果
    "pmSearchResult": false,
    // 若结果消息有多条，采用合并转发方式发送搜图结果（仅在群内有效）
    "groupForwardSearchResult": true,
    // 大部分请求所使用的代理，支持 http(s):// 和 socks://
    "proxy": "",
    // 检查更新间隔（小时），0 则关闭
    "checkUpdate": 24,
    // 是否忽略QQ官方机器人 (2854196300 ≤ qq ≤ 2854216399)
    "ignoreOfficialBot": true,
    // 搜图结果缓存，开启可节约 API 调用
    "cache": {
      // 是否启用
      "enable": true,
      // 缓存时间（秒）
      "expire": 172800
    },
    // 复读相关功能
    "repeat": {
      // 是否启用
      "enable": true,
      // 当检测到某个群有这么多次相同发言后会概率参与复读
      "times": 3,
      // 复读概率（百分比 0~100）
      "probability": 40,
      // 平时直接复读的概率（百分比 0~100）
      "commonProb": 0.2
    },
    // setu 相关功能，部分配置的详细说明请查看“wiki-附加功能-setu”以了解更多
    "setu": {
      // 是否启用
      "enable": $setu,
      // APIKEY
      "apikey": "$setuapi",
      // 反和谐方式（0：关闭，1：轻微修改，2：旋转）
      "antiShielding": 1,
      // 是否允许私聊使用
      "allowPM": $allowPM,
      // P站图本地反代端口，若端口冲突请修改此项
      "pximgServerPort": 60233,
      // 设置使用的P站本地反代服务地址
      "usePximgAddr": "",
      // 设置使用的P站在线反代服务地址
      "pximgProxy": "",
      // 是否发送 master1200 大小的图片，以节省流量或加快发送速度，关闭时将发送原图
      "size1200": false,
      // 发送后这么多秒自动撤回（0 则不撤回，-1 为发送闪照）
      "deleteTime": $deleteTime,
      // 群内使用冷却时间（秒），每名用户独立，0 则无冷却，私聊无 cd
      "cd": $cd,
      // 每名用户每日次数限制
      "limit": 30,
      // 群组白名单
      "whiteGroup": [],
      // 仅允许白名单群使用（与上面的私聊使用是独立的）
      "whiteOnly": false,
      // 白名单群组的群内使用冷却时间（秒），每名用户独立，0 则无冷却
      "whiteCd": 0,
      // 白名单群组内发送后这么多秒自动撤回（0 则不撤回，-1 为发送闪照）
      "whiteDeleteTime": 0,
      // 只允许在白名单群组中发送 r18 setu
      "r18OnlyInWhite": true
    },
    // 正则表达式相关设置
    "regs": {
      // 开启搜图模式
      "searchModeOn": "^开启搜[图圖]模式$",
      // 关闭搜图模式
      "searchModeOff": "^关闭搜图模式$",
      // setu，如果要支持 r18 和关键词参数需要使用捕获组，请查看“wiki-附加功能-setu”以了解更多
      "setu": "^.*[来來发發给給][张張个個幅点點份]?(?<r18>[Rr]18的?)?(?<keyword>.*?)?的?[涩蛇污色瑟][图圖]|^--setu$"
    },
    // 回复相关设置（设为空字符串将不会回复）
    "replys": {
      // 机器人被私聊和@却没有命中任何指令时的默认回复
      "default": "必须要发送图片我才能帮你找噢_(:3」」\n支持批量！",
      // 调试模式下他人私聊或@时的回复
      "debug": "维护升级中，暂时不能使用，抱歉啦~",
      // 个人搜索次数到达上限
      "personLimit": "您今天搜的图太多辣！休息一下明天再来搜罢~",
      // 搜索失败
      "failed": "搜索失败惹 QAQ\n有可能是服务器网络爆炸，请重试一次，或尝试二次截图后发送",
      // 这张图正在被搜索
      "searching": "该图已在搜索中",
      // 开启搜图模式
      "searchModeOn": "了解～请发送图片吧！支持批量噢！\n如想退出搜索模式请发送“关闭搜图模式”",
      // 已经开启搜图模式
      "searchModeAlreadyOn": "您已经在搜图模式下啦！\n如想退出搜索模式请发送“关闭搜图模式”",
      // 关闭搜图模式
      "searchModeOff": "搜图模式已关闭",
      // 已经关闭搜图模式
      "searchModeAlreadyOff": "にゃ～",
      // 搜图模式超时
      "searchModeTimeout": "由于超时，已为您自动退出搜图模式，以后要记得说“关闭搜图模式”来退出搜图模式噢",
      // setu 冷却中
      "setuLimit": "乖，要懂得节制噢 →_→",
      // setu 请求错误
      "setuError": "瑟图服务器爆炸惹_(:3」∠)_",
      // 其他不满足发送 setu 的条件
      "setuReject": "很抱歉，该功能暂不开放_(:3」」",
      // setu API 调用达到上限
      "setuQuotaExceeded": ""
    },
    // OCR 相关设置，请查看“wiki-附加功能-OCR文字识别”以了解更多
    "ocr": {
      // 使用的 OCR 服务，可选值：["ocr.space", "baidubce", "tencent", "qq"]，qq 需要 go-cqhttp
      "use": "ocr.space",
      "ocr.space": {
        "defaultLANG": "eng",
        "apikey": ""
      },
      "baidubce": {
        "useApi": "accurate_basic",
        "apiKey": "",
        "secretKey": ""
      },
      "tencent": {
        "SecretId": "",
        "SecretKey": "",
        "Region": "ap-beijing",
        "useApi": ["GeneralBasicOCR", "GeneralFastOCR", "GeneralAccurateOCR"]
      }
    },
    // 明日方舟公开招募计算器设置
    "akhr": {
      // 是否启用
      "enable": false,
      // 使用的 OCR 服务，可选值同上面的 bot.ocr.use
      "ocr": "ocr.space"
    },
    // 定时提醒功能设置，请查看“wiki-附加功能-定时提醒”以了解更多
    "reminder": {
      // 是否启用
      "enable": false,
      // 仅私聊使用
      "onlyPM": false,
      // 仅管理者(bot.admin)使用
      "onlyAdmin": false
    },
    // 哔哩哔哩相关功能
    "bilibili": {
      // 检测到小程序时是否鄙视
      "despise": false,
      // 是否获取并输出视频信息
      "getVideoInfo": true,
      // 是否获取并输出动态内容
      "getDynamicInfo": false,
      // 是否获取并输出专栏信息
      "getArticleInfo": false,
      // 是否获取并输出直播间信息
      "getLiveRoomInfo": false
    },
    // 语言库（自动回复），请查看“wiki-附加功能-语言库（自动回复）”以了解更多
    "corpus": []
  },
  // saucenao 自定义 host，格式：[protocol://]host[:port]
  "saucenaoHost": "saucenao.com",
  // saucenao APIKEY，必填，否则无法使用 saucenao 搜图
  "saucenaoApiKey": "$saucenaoApiKey",
  // whatanime 自定义 host，格式：[protocol://]host[:port]
  "whatanimeHost": "trace.moe",
  // whatanime Token，选填
  "whatanimeToken": "",
  // ascii2d 自定义 host，格式：[protocol://]host[:port]
  "ascii2dHost": "ascii2d.net"
}

EOF

}

node_npm(){

node -v
if [ "$?" == "0" ]; then
	tyblue "nodejs已安装"
else
	red "nodejs未安装"
	curl -sL https://deb.nodesource.com/setup_12.x | bash -
	red "正在安装nodejs..."
	$pack_manger install -y nodejs
	node -v
	if [ "$?" == "0" ]; then
		tyblue "nodejs已安装"
	else
		red "nodejs安装失败，请更新系统后再试"
	fi
fi

}


install_bot(){

get_cq
get_cq2
node_npm
cd ~/cq-picsearcher-bot
npm i -g yarn
yarn
cd ~
peizhi
}

#运行go-cqhttp并获取二维码
get_prcode(){

rm ~/qqbot/nohup.out
green "日志文件为nohup.out[回车]"
nohup ~/qqbot/go-cqhttp &

}


#判断二维码是否存在并打印

prcode(){

grep '扫描二维码' ~/qqbot/nohup.out >/dev/null 2>/dev/null
if [ "$?" != "0" ]; then
	tcode=n
else
	tcode=y
	sleep 2s
	cat ~/qqbot/nohup.out
fi
}

#二维码循环
prcode_loop(){

while [ "$tcode" != "y" ]
do
	prcode
	sleep 3s
done

}

#判断是否登录
log_in_test(){

grep '登录成功' ~/qqbot/nohup.out >/dev/null 2>/dev/null
if [ "$?" != "0" ]; then
	guoqi=y
	log_in_try=y
	green "登录成功"
else
	log_in_try=n
	grep -e '已取消|已失效' ~/qqbot/nohup.out >/dev/null 2>/dev/null
	if [ "$?" == "0" ]; then
		red "二维码失效，请重新登录"
		guoqi=y
	else
		guoqi=n
	fi
fi
}
#登录检测循环
log_in_loop(){

while ["$guoqi" != "y" ]
do
	while [ "$log_in_try" != "y" ]
	do
		log_in_test
		sleep 3s
	done
done
}

#登录
log_in(){

tcode=""
log_in_try=""
guoqi=""
get_prcode
tyblue "正在生成二维码..."
sleep 10s
prcode_loop
sleep 2s
log_in_test
}

echo -e "\\n\\n\\n"
tyblue "------------------请选择功能--------------------"
tyblue"1.安装程序"
tyblue"2.登录"
tyblue"3.修改配置文件"
echo
choice=""
        while [ "$choice" != "1" ] && [ "$choice" != "2" ] && [ "$choice" != "3" ]
        do
            read -p "您的选择是：" choice
        done
if [ $choice -eq 1 ]; then
	install_bot
elif [ $choice -eq 2 ]; then
	log_in
elif [ $choice -eq 3 ]; then
	peizhi
fi