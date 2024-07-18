#!/bin/bash
# **********************************************************
# * File Name     : rocky_linux
# * Author        : Elk
# * Email         : zzdict@gmail.com / elk_deer@foxmail.com
# * Create time   : 2024-06-15 20:12
# * Description   : Rocky_linux9.4装机脚本，系统版本区别不大，都可执行
# **********************************************************
# 检查是否以 root 用户运行脚本
if [ "$(id -u)" -ne 0 ]; then
  tput bold
  tput setaf 1
  tput setaf 3
  echo "请以 root 用户运行此脚本。"
  tput sgr0
  exit 1
fi

# 启用网络接口
enable_network_interface() {
  local interface=$1
  if ip link set "$interface" up; then
    tput bold
	tput setaf 2
    echo "网络接口 $interface 已启用。"
	tput sgr0
  else
    tput bold
	tput setaf 1
    echo "无法启用网络接口 $interface，请检查接口名称。"
	tput sgr0
    exit 1
  fi
}

# 配置 YUM 源
configure_yum_repos() {
  sed -e 's|^mirrorlist=|#mirrorlist=|g' \
      -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
      -i.bak \
      /etc/yum.repos.d/Rocky-*.repo	  
  tput bold
  tput setaf 2
  echo "YUM 源配置已更新。"
  tput sgr0
  dnf makecache
  yum -y install epel-release
}

# 停止和禁用防火墙，禁用 SELinux
configure_security() {
  systemctl stop firewalld && systemctl disable firewalld
  firewall-cmd --reload
  tput bold
  tput setaf 2
  echo "防火墙已停止并禁用。"
  tput sgr0
  sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  tput bold
  tput setaf 2
  echo "SELinux 已禁用。"
  tput sgr0
}

# 检查并安装chrony，进行时间同步
function install_and_sync_time_with_chrony() {
    # 检查是否已经安装chrony
    if ! command -v chronyd &>/dev/null; then
        sudo dnf install -y chrony &> /dev/null
        # 检查安装是否成功
        if ! command -v chronyd &>/dev/null; then
            tput bold
            tput setaf 1
            echo "安装 chrony 失败。请检查您的包管理器并重试。"
            tput sgr0
            exit 1
        else
            tput bold
            tput setaf 2
            echo "chrony 安装成功。"
            tput sgr0
        fi
    else
        tput bold
        tput setaf 2
        echo "chrony 已安装。"
        tput sgr0
    fi

    # 确保安装其他必要的软件包
    sudo dnf install -y vim wget unzip tar lrzsz &> /dev/null
    if [ $? -eq 0 ]; then
        tput bold
        tput setaf 2
        echo "其他软件包安装成功。"
        tput sgr0
    else
        tput bold
        tput setaf 1
        echo "安装其他软件包失败。"
        tput sgr0
        exit 1
    fi


    # 启动 chronyd 服务并启用开机启动
    if sudo systemctl enable --now chronyd && sudo systemctl restart chronyd; then
        tput bold
        tput setaf 2
		echo "chronyd 服务已成功启动并设置为开机启动。"
		tput sgr0
    else
		tput bold
		tput setaf 1
        echo "启动或启用 chronyd 服务失败。请检查 systemctl 状态。"
		tput sgr0
        exit 1
    fi

    # 强制同步时间
    sudo chronyc -a makestep
	tput bold
    tput setaf 2
    echo "时间同步已成功完成。"
	tput sgr0
}


# 自定义 IP 地址
configure_ip_address() {
  tput bold
  tput blink
  tput setaf 1
  read -p "******输入你要设置的IP >>>  : " ip_a
  tput sgr0
  tput bold
  tput blink
  tput setaf 6
  read -p "******输入你要设置的网关>>> : " gat
  tput sgr0
  tput bold
  tput blink
  tput setaf 3
  read -p "******输入你要设置的DNS>>>  : " dnns
  tput sgr0

  # 判断当前连接的名字
  connection_name=$(nmcli -t -f NAME,DEVICE con show --active | grep -E "ens33|Wired connection 1" | cut -d: -f1)

  if [[ "$connection_name" == "ens33" ]]; then
    # 针对 ens33 连接进行配置
    nmcli con mod "ens33" ipv4.method manual ipv4.addresses "${ip_a}/24" ipv4.gateway "${gat}" ipv4.dns "${dnns}" autoconnect yes
  elif [[ "$connection_name" == "Wired connection 1" ]]; then
    # 针对 Wired connection 1 连接进行配置
    nmcli con mod "Wired connection 1" ipv4.method manual ipv4.addresses "${ip_a}/24" ipv4.gateway "${gat}" ipv4.dns "${dnns}" autoconnect yes
  else
	tput bold
	tput setaf 1
    echo "无法识别的网络连接名称：$connection_name"
	tput sgr0
    return 1
  fi

  tput setab 5
  tput setaf 15
  tput bold
  echo "IP 地址配置成功，即将重启系统。"
  tput sgr0

  nmcli con up "$connection_name"
  reboot
}


# 主函数
main() {
  local interface="ens33"
  enable_network_interface "$interface"
  configure_yum_repos
  configure_security
  install_and_sync_time_with_chrony
  configure_ip_address "$interface"
}

# 调用主函数
main
