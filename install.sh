#! /bin/bash
# Copyright (C) ZeroShell Project

[ -z "$url" ] && url="https://fastly.jsdelivr.net/gh/zhiern/ZeroShell@master"
type bash &>/dev/null && shtype=bash || shtype=sh
echo='echo -e'
[ -n "$(echo -e | grep e)" ] && {
	echo "\033[31m不支持dash环境安装！请先输入bash命令后再运行安装命令！\033[0m"
	exit
}

echo "***********************************************"
echo "**                 欢迎使用                  **"
echo "**                ZeroShell                  **"
echo "**                            by  oppen321   **"
echo "***********************************************"

# 内置工具
dir_avail() {
	df $2 $1 | awk '{ for(i=1;i<=NF;i++){ if(NR==1){ arr[i]=$i; }else{ arr[i]=arr[i]" "$i; } } } END{ for(i=1;i<=NF;i++){ print arr[i]; } }' | grep -E 'Ava|可用' | awk '{print $2}'
}

setconfig() {
	configpath=$ZERODIR/configs/ZeroShell.cfg
	[ -n "$(grep ${1} $configpath)" ] && sed -i "s#${1}=.*#${1}=${2}#g" $configpath || echo "${1}=${2}" >>$configpath
}

webget() {
	# 参数【$1】代表下载目录，【$2】代表在线地址
	if curl --version >/dev/null 2>&1; then
		[ "$3" = "echooff" ] && progress='-s' || progress='-#'
		[ -z "$4" ] && redirect='-L' || redirect=''
		result=$(curl -w %{http_code} --connect-timeout 5 $progress $redirect -ko $1 $2)
		[ -n "$(echo $result | grep -e ^2)" ] && result="200"
	else
		if wget --version >/dev/null 2>&1; then
			[ "$3" = "echooff" ] && progress='-q' || progress='-q --show-progress'
			[ "$4" = "rediroff" ] && redirect='--max-redirect=0' || redirect=''
			certificate='--no-check-certificate'
			timeout='--timeout=3'
			wget $progress $redirect $certificate $timeout -O $1 $2
			[ $? -eq 0 ] && result="200"
		fi
	fi
}

error_down() {
	$echo "请参考 \033[32mhttps://github.com/oppen321/ZeroShell/blob/master/README.md"
	$echo "\033[33m使用其他安装源重新安装！\033[0m"
}

gettar() {
	webget /tmp/ZeroShell.tar.gz "$url/bin/ZeroShell.tar.gz"
	if [ "$result" != "200" ]; then
		$echo "\033[33m文件下载失败！\033[0m"
		error_down
		exit 1
	else
		$ZERODIR/start.sh stop 2>/dev/null
		echo -----------------------------------------------
		echo 开始解压文件！
		mkdir -p $ZERODIR >/dev/null
		tar -zxf '/tmp/ZeroShell.tar.gz' -C $ZERODIR/ || tar -zxf '/tmp/ZeroShell.tar.gz' --no-same-owner -C $ZERODIR/
		if [ -s $ZERODIR/init.sh ]; then
			. $ZERODIR/init.sh >/dev/null || $echo "\033[33m初始化失败，请尝试本地安装！\033[0m"
		else
			rm -rf /tmp/ZeroShell.tar.gz
			$echo "\033[33m文件解压失败！\033[0m"
			error_down
			exit 1
		fi
	fi
}
