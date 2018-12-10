#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

[[ $(id -u) != 0 ]] && echo -e " \n请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

# 检测方法
if [[ -f /usr/bin/apt-get || -f /usr/bin/yum ]] && [[ -f /bin/systemctl ]]; then

	if [[ -f /usr/bin/yum ]]; then

		cmd="yum"

	fi

else

	echo -e " \n……这个 ${red}脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}\n" && exit 1

fi
if [[ $sys_bit == "i386" || $sys_bit == "i686" ]]; then
	brook="brook_linux_386"
elif [[ $sys_bit == "x86_64" ]]; then
	brook="brook"
else
	echo -e " \n……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}\n" && exit 1
fi

config() {
	echo
	_random=$RANDOM
	while :; do
		echo -e "请输入 Brook 端口 ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(默认端口: ${cyan}$_random$none):")" port
		[ -z "$port" ] && port=$_random
		case $port in
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			echo
			echo
			echo -e "$yellow Brook 端口 = $cyan$port$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac
	done

	echo
	while :; do
		echo -e "请输入 Brook 密码"
		read -p "$(echo -e "(默认密码: ${cyan}biaojiaozhen123$none):")" pass
		[ -z "$pass" ] && pass="biaojiaozhen123"
		case $pass in
		*)
			echo
			echo
			echo -e "$yellow Brook 密码 = $cyan$pass$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac
	done

	echo
	pause
}
_download() {
	[[ ! $(command -v wget) ]] && $cmd install wget -y
	ver=$(curl -s https://api.github.com/repos/txthinking/brook/releases/latest | grep 'tag_name' | cut -d\" -f4)
	_link="https://github.com/txthinking/Brook/releases/download/$ver/$brook"
	if ! wget --no-check-certificate --no-cache -O "/usr/bin/brook" $_link; then
		echo -e "$red 下载 Brook 失败！$none" && exit 1
	fi
	if [[ -f /usr/bin/brook ]]; then
		chmod +x /usr/bin/brook
		cat >/lib/systemd/system/brook.service <<-EOF
[Unit]
Description=brook Service
After=network.target
Wants=network.target
[Service]
Type=simple
PIDFile=/var/run/brook.pid
ExecStart=/usr/bin/brook server -l :$port -p $pass
Restart=always
[Install]
WantedBy=multi-user.target
		EOF

		systemctl enable brook
		systemctl start brook
	else
		echo -e "\n$red 安装出错...$none\n" && exit 1
	fi
}
info() {
	get_ip
	clear
	echo
	echo "........... Brook 安装成功 .........."
	echo
	echo -e " 服务器地址: ${cyan}$ip$none"
	echo
	echo -e " 端口: ${cyan}$port$none"
	echo
	echo -e " 密码: ${cyan}$pass$none"
	echo
}
install() {
	config
	try_enable_bbr
	_download
	info
}

uninstall() {
	if [[ -f /usr/bin/brook ]]; then
		brook_pid=$(pgrep "brook")
		[[ $brook_pid ]] && systemctl stop brook
		systemctl disable brook >/dev/null 2>&1
		rm -rf /usr/bin/brook
		rm -rf /lib/systemd/system/brook.service
		echo -e " \n$green卸载完成...$none\n" && exit 1
	else
		echo -e " \n$red你貌似毛有安装 brook...$none\n" && exit 1
	fi
}

}
get_ip() {
	ip=$(curl -s ipinfo.io/ip)
}
pause() {

	read -rsp "$(echo -e "按$green Enter 回车键 $none继续....或按$red Ctrl + C $none取消.")" -d $'\n'
	echo
}
error() {

	echo -e "\n$red 输入错误！$none\n"

}
clear
while :; do
	echo
	echo "........... Brook 一键安装脚本 by n0rva .........."
	echo
	echo "帮助说明: 见我发给你的微信笔记教程"
	echo
	echo " 1. 安装"
	echo
	echo " 2. 卸载"
	echo
	read -p "请选择 [1-2]:" choose
	case $choose in
	1)
		install
		break
		;;
	2)
		uninstall
		break
		;;
	*)
		error
		;;
	esac
done
