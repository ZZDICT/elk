#!/bin/bash
# **********************************************************
# * File Name     : elk2.0.sh
# * Author        : Elk
# * Email         : zzdict@gmail.com / elk_deer@foxmail.com
# * Create time   : 2024-04-25 10:12
# * Description   : centos7菜单工具箱
# **********************************************************
start_time=$(date +%s)
keep_going=true
echo -e "\033[0;31m初始化中......\033[0m"

Application_package="epel-release wget mpg123 alsa-utils coreutils"
for i in $Application_package;do
	# 检查包是否已安装
	if ! rpm -q $i &> /dev/null;then
		yum -y install $i &> /dev/null
	fi
done

#下载
mkdir -p /net/{music,sound_effect}/
if [ ! -f /net/music/yinyue.mp3 ] ;then 
	wget -O /net/music/yinyue.mp3 https://www.kumeiwp.com/wj/161525/2023/09/28/2e5ec32a66e1318b88ad522c45197ba8.mp3 &> /dev/null
fi
if [ ! -f /net/sound_effect/tishi.wav ] ;then
	wget -O /net/sound_effect/tishi.wav https://downsc.chinaz.net/Files/DownLoad/sound1/202405/xm2727.wav &> /dev/null
fi
if [ ! -f /net/sound_effect/baibai.wav ];then
	wget -O /net/sound_effect/baibai.wav https://downsc.chinaz.net/Files/DownLoad/sound1/202310/y2165.wav &> /dev/null
fi

sudo amixer sset 'Master' 100% unmute &> /dev/null && \
sudo amixer sset 'PCM' 100% unmute &> /dev/null && \
sudo amixer sset 'Line' 100% unmute &> /dev/null && \
sudo amixer sset 'CD' 100% unmute &> /dev/null && \
sudo amixer sset 'Mic' 100% unmute &> /dev/null && \
sudo amixer sset 'Mic Boost (+20dB)' 100% unmute &> /dev/null && \
sudo amixer sset 'Video' 100% unmute &> /dev/null && \
sudo amixer sset 'Phone' 100% unmute &> /dev/null && \
sudo amixer set 'S/PDIF' unmute &> /dev/null && \
sudo amixer sset 'Aux' 100% unmute &> /dev/null && \
# 定义一个函数，用于杀死mpg123进程
stop_music() {
  # 杀死所有mpg123进程
  pkill mpg123
  exit
}
# 捕获SIGINT（Ctrl+C）信号，并调用stop_music函数
trap 'stop_music' SIGINT
# 获取所有音乐文件的列表并随机排列
files=($(ls /net/music/* | shuf))
# 循环播放每个文件
for file in "${files[@]}"; do
    mpg123 --loop -1 -f 1500 -q "$file" &
done
MPG123_PID=$!

while $keep_going; do
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE="\033[34m" 
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'

BOLD='\033[1m'
FLASH='\033[5m'
RESET='\033[0m'
ITALIC="\033[3m"
UNDERLINE="\033[4m"
REVERSE="\033[7m"
HIDDEN="\033[8m"

BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_MAGENTA="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"
clear
TOP_BORDER="${MAGENTA}${BOLD}******************${FLASH} ELK ${RESET}${MAGENTA}******************${RESET}"
echo -e "$TOP_BORDER"
echo -e "${BOLD}${YELLOW}  [1].  防火墙DOWN${RESET}"
echo -e "${BOLD}${YELLOW}  [2].  临时关闭SELinux${RESET}"
echo -e "${BOLD}${YELLOW}  [3].  配置SELinux永久关闭${RESET}"
echo -e "${BOLD}${YELLOW}  [4].  配置阿里源${RESET}"
echo -e "${BOLD}${YELLOW}  [5].  配置本地源${RESET}"
echo -e "${BOLD}${YELLOW}  [6].  一键安装常用工具包与系统分析工具${RESET}"
echo -e "${BOLD}${YELLOW}  [7].  自定义静态IP${RESET}"
echo -e "${BOLD}${YELLOW}  [8].  MySQL-8.0${RESET}"
echo -e "${BOLD}${YELLOW}  [9].  MySQL-5.7${RESET}"
echo -e "${BOLD}${YELLOW}  [10]. 创建MySQL远程账户${RESET}"
echo -e "${BOLD}${YELLOW}  [11]. Fuck工具${RESET}"
echo -e "${BOLD}${YELLOW}  [12]. 设置时区并同步时间${RESET}"
echo -e "${BOLD}${YELLOW}  [13]. 设置系统最大打开文件数${RESET}"
echo -e "${BOLD}${YELLOW}  [14]. 系统内核优化${RESET}"
echo -e "${BOLD}${YELLOW}  [15]. 减少SWAP使用${RESET}"
echo -e "${RED}${BOLD}  [q]. 退出${RESET}"
BOTTOM_BORDER="${MAGENTA}*************${FLASH} Automation2.0 ${RESET}${MAGENTA}*************${RESET}"
echo -e "$BOTTOM_BORDER"
aplay /net/sound_effect/tishi.wav &> /dev/null &
read -p "$(echo -e "${BOLD}${MAGENTA}*请选择模块>>>${RESET}")" num1
	case $num1 in
		1)
			sudo systemctl stop firewalld
			sudo systemctl disable firewalld
			echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		2)
			sudo setenforce 0
			echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		3)
			sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
			echo -e "${GREEN}${FLASH}Successful${RESET}"
			# 设置默认值
			default='r'
			aplay /net/sound_effect/tishi.wav &> /dev/null
			read -t 30 -p "已修改/etc/selinux/config配置文件，按r立即重启[默认30秒自动重启]:" R
			# 如果用户没有输入或者仅仅是按了回车键（-z "$R" 检测变量R是否为空）
			if [ -z "$R" ]; then
				R=$default
			fi
			if [ "$R" = "r" ]; then
				sudo reboot		
			else
				echo "已输入 '$R'，不执行重启操作。"
			fi
			echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		4)
		    rm -rf /etc/yum.repos.d/*
			curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
			curl -o /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo
			yum clean all
			yum makecache
			echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		5)
IP=10.36.178.200
grep "$IP" /etc/hosts
if [ $? -ne 0 ];then
echo "$IP package.qf.com" >> /etc/hosts
fi
if [ ! -d /etc/yum.repos.d/backup ];then
mkdir /etc/yum.repos.d/backup
fi
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/
cat > /etc/yum.repos.d/qfedu.repo << EOF
[mybase]
name=mybase
baseurl=http://package.qf.com/base
enabled=1
gpgcheck=0

[myepel]
name=myepel
baseurl=http://package.qf.com/epel
enabled=1
gpgcheck=0

[myextras]
name=extras
baseurl=http://package.qf.com/extras
enabled=1
gpgcheck=0

[myupdates]
name=myupdates
baseurl=http://package.qf.com/updates
enabled=1
gpgcheck=0

[docker-ce-stable]
name=docker-ce-stable
baseurl=http://package.qf.com/docker-ce-stable
enabled=1
gpgcheck=0

[kubernetes]
name=kubernetes
baseurl=http://package.qf.com/kubernetes
enabled=1
gpgcheck=0

[mysql-5.7-community]
name=mysql-5.7-community
baseurl=http://package.qf.com/mysql-5.7-community
enabled=1
gpgcheck=0

[mysql-connectors-community]
name=mysql-connectors-community
baseurl=http://package.qf.com/mysql-connectors-community/
enabled=1
gpgcheck=0

[mysql-tools-community]
name=mysql-tools-community
baseurl=http://package.qf.com/mysql-tools-community/
enabled=1
gpgcheck=0

[remi-safe]
name=remi-safe
baseurl=http://package.qf.com/remi-safe
enabled=1
gpgcheck=0
EOF
echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
		;;
		6)
		yum install -y wget vim zip unzip ntpdate epel-release lrzsz tree net-tools lsof sysstat iostat gcc make autoconf > /dev/null
		echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
		;;
			
		7)
		
sudo sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=static/g' /etc/sysconfig/network-scripts/ifcfg-ens33
	
sed -i 's/^ONBOOT=.*/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-ens33
			aplay /net/sound_effect/tishi.wav &> /dev/null
			read -p "*请输入你的IP : " ipdz
			aplay /net/sound_effect/tishi.wav &> /dev/null
			read -p "*请输入你的子网掩码 : " zwym
			aplay /net/sound_effect/tishi.wav &> /dev/null
			read -p "*请输入你的网关 : " wg
			aplay /net/sound_effect/tishi.wav &> /dev/null
			read -p "*请输入你的DNS1 : " dns1
			cat >> /etc/sysconfig/network-scripts/ifcfg-ens33 <<EOF
IPADDR=$ipdz
NETMASK=$zwym
GATEWAY=$wg
DNS1=$dns1
EOF
			systemctl restart network
			echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		8)
			sudo yum remove mysql-server -y && sudo yum autoremove -y
            sudo yum remove *mysql* -y
			sudo rm -rf /var/lib/mysql/ 
			sudo rm -rf /etc/mysql/ 
			
			yum install -y yum-utils > /dev/null
			yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm > /dev/null
			yum-config-manager --enable mysql80-community > /dev/null
			yum-config-manager --disable mysql57-community > /dev/null
			yum install -y mysql-server
			systemctl start mysqld && systemctl enable mysqld
			mysqladmin -p"`awk '/temporary password/{p=$NF}END{print p}' /var/log/mysqld.log`" password 'TianPFh@123'
			mysql -p'TianPFh@123' -e "UNINSTALL COMPONENT 'file://component_validate_password'"
			mysqladmin -p'TianPFh@123' password '1234'
			echo -e "${RED}${BOLD}${ITALIC}root密码：1234${RESET}"
			echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		9)
			sudo yum remove mysql-server -y && sudo yum autoremove -y
            sudo yum remove *mysql* -y
			sudo rm -rf /var/lib/mysql/ 
			sudo rm -rf /etc/mysql/
			
			yum install -y yum-utils > /dev/null
			yum install -y https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm
			
			yum-config-manager --disable mysql80-community > /dev/null
			yum-config-manager --enable mysql57-community > /dev/null
			
			yum install -y mysql-server 
			systemctl start mysqld && systemctl enable mysqld
			mysqladmin -p"`awk '/temporary password/{p=$NF}END{print p}' /var/log/mysqld.log`" password 'TianPFh@123'
			echo "validate-password=off" >> /etc/my.cnf
			systemctl restart mysqld
			mysqladmin -p'TianPFh@123' password '1234'
			echo -e "${RED}${BOLD}${ITALIC}root密码：1234${RESET}"
			echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		10)
			aplay /net/sound_effect/tishi.wav &> /dev/null
			read -p "*请输入你的MySQL密码：" pwd
			# 检查'root'@'%'用户是否已经存在  
			user_exists=$(mysql -p"${pwd}" -Nse "SELECT COUNT(*) FROM mysql.user WHERE User='root' AND Host='%';")
			if [ "$user_exists" -eq 0 ]; then
				mysql -p"${pwd}" -e "CREATE USER 'root'@'%' IDENTIFIED BY 'Qwe+123456'"  
				mysql -p"${pwd}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'"  
				mysql -p"${pwd}" -e "FLUSH PRIVILEGES"  
				echo -e "${RED}${BOLD}远程账户： root    密码： Qwe+123456${RESET}"  
				echo -e "${RED}${BOLD}请自行登录该远程账户，使用下述提示语修改密码,保证安全!${RESET}"  
				echo -e "${RED}${BOLD}ALTER USER 'root'@'%' IDENTIFIED BY '你要更改的密码';${RESET}"  
				echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"  
			else  
				aplay /net/sound_effect/tishi.wav &> /dev/null
				read -p "*已存在root远程用户，请输入一个用户名再创建：" useryc
				mysql -p"${pwd}" -e "CREATE USER "${useryc}"@'%' IDENTIFIED BY 'Qwe+123456'"  
				mysql -p"${pwd}" -e "GRANT ALL PRIVILEGES ON *.* TO "${useryc}"@'%'"  
				mysql -p"${pwd}" -e "FLUSH PRIVILEGES"  
				echo -e "${RED}${BOLD}远程账户： ${useryc}    密码： Qwe+123456${RESET}"  
				echo -e "${RED}${BOLD}请自行登录该远程账户，使用下述提示语修改密码,保证安全!${RESET}"  
				echo -e "${RED}${BOLD}ALTER USER '"${useryc}"'@'%' IDENTIFIED BY '你要更改的密码';${RESET}"  
				echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			fi
			;;
		11)
			echo -e "${RED}因用户使用仓库不一，若失败请先执行模块4。正在安装中.....${RESET}"
			sleep 5
			sudo yum install python3 -y && sudo yum install gcc python3-devel -y &> /dev/null
			pip3 install thefuck
			eval $(thefuck --alias)
			echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		12)
			yum install -y ntpdate &> /dev/null
			timedatectl set-timezone Asia/Shanghai
			yum -y install chrony &> /dev/null
			systemctl start chronyd
			systemctl enable chronyd
			echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		13)
			if ! grep "* soft nofile 65535" /etc/security/limits.conf &>/dev/null; then
cat >> /etc/security/limits.conf << EOF
* soft nofile 65535   #软限制
* hard nofile 65535   #硬限制
EOF
			fi
echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		14)
cat >> /etc/sysctl.conf << EOF
net.ipv4.tcp_syncookies = 1             #防范SYN洪水攻击，0为关闭
net.ipv4.tcp_max_tw_buckets = 20480     #此项参数可以控制TIME_WAIT套接字的最大数量，避免Squid服务器被大量的TIME_WAIT套接字拖死
net.ipv4.tcp_max_syn_backlog = 20480    #表示SYN队列的长度，默认为1024，加大队列长度为8192，可以容纳更多等待连接的网络连接数
net.core.netdev_max_backlog = 262144    #每个网络接口 接受数据包的速率比内核处理这些包的速率快时，允许发送到队列的数据包的最大数目
net.ipv4.tcp_fin_timeout = 20           #FIN-WAIT-2状态的超时时间，避免内核崩溃
EOF
echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		15)
			echo "0" > /proc/sys/vm/swappiness
			echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			;;
		q)
			echo -e "${GREEN}${FLASH}${BOLD}${ITALIC}Successful${RESET}"
			kill $MPG123_PID
			keep_going=false
			;;
		*)
			echo -e "${RED}${FLASH}${BOLD}${ITALIC}无效输入，请选择正确的模块代号！${RESET}"
			sleep 2
		;;
	esac
	if [ "$keep_going" = 'true' ]; then
		read -p "$(echo -e "${BLUE}${BOLD}${UNDERLINE}${ITALIC}是否${GREEN}${BOLD}${UNDERLINE}${ITALIC}继续${MAGENTA}${BOLD}${UNDERLINE}${ITALIC}执行${CYAN}${BOLD}${UNDERLINE}${ITALIC}脚本${BOLD}${UNDERLINE}${ITALIC}${BLUE}？${RED}${BOLD}${UNDERLINE}${ITALIC}(y/n):${RESET}") " select
			if [ "$select" != "y" ]; then
			kill $MPG123_PID
			keep_going="false"
		fi
	fi
done
aplay /net/sound_effect/baibai.wav &> /dev/null
clear
end_time=$(date +%s)
execution_time=$(( end_time - start_time ))
cat <<`EOF`
v2.0                                                                ,----, 
         ,----,       ,----,                                      ,/   .`| 
       .'   .`|     .'   .`|    ,---,       ,---,  ,----..      ,`   .'  : 
    .'   .'   ;  .'   .'   ;  .'  .' `\  ,`--.' | /   /   \   ;    ;     / 
  ,---, '    .',---, '    .',---.'     \ |   :  :|   :     :.'___,/    ,'  
  |   :     ./ |   :     ./ |   |  .`\  |:   |  '.   |  ;. /|    :     |   
  ;   | .'  /  ;   | .'  /  :   : |  '  ||   :  |.   ; /--` ;    |.';  ;   
  `---' /  ;   `---' /  ;   |   ' '  ;  :'   '  ;;   | ;    `----'  |  |   
    /  ;  /      /  ;  /    '   | ;  .  ||   |  ||   : |        '   :  ;   
   ;  /  /--,   ;  /  /--,  |   | :  |  ''   :  ;.   | '___     |   |  '   
  /  /  / .`|  /  /  / .`|  '   : | /  ; |   |  ''   ; : .'|    '   :  |   
./__;       :./__;       :  |   | '` ,/  '   :  |'   | '/  :    ;   |.'    
|   :     .' |   :     .'   ;   :  .'    ;   |.' |   :    /     '---'      
;   |  .'    ;   |  .'      |   ,.'      '---'    \   \ .'                 
`---'        `---'          '---'                  `---`                                                                                            
`EOF`
echo -e "执行耗时：${BOLD}${UNDERLINE}${RED}$execution_time${RESET} 秒"