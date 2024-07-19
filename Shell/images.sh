#!/bin/bash
# **********************************************************
# * File Name     : images.sh
# * Author        : Elk
# * Email         : zzdict@gmail.com / elk_deer@foxmail.com
# * Create time   : 2024-07-18 19:33
# * Description   : 镜像自动打包导入
# **********************************************************
# 判断是否安装tar和zip工具
if ! command -v tar &> /dev/null || ! command -v zip &> /dev/null; then
    sudo yum install -y tar zip &> /dev/null
fi

# 存储目录
mkdir -p /opt/images_data
output_dir="/opt/images_data"

# 打包镜像
function save_image {
    docker images --format "{{.Repository}} {{.Tag}} {{.ID}}" | while read -r line; do
        # 分离出仓库和标签
        repository=$(echo "$line" | awk '{print $1}' | awk -F '/' '{print $NF}')
        tag=$(echo "$line" | awk '{print $2}')
        id=$(echo "$line" | awk '{print $3}')
        
        # 构建完整的镜像名称
        full_image_name="$repository:$tag"
        
		        # 检查镜像是否为 <none>，如果是则跳过
        if [ "$repository" = "<none>" ]; then
			tput bold
			tput setaf 5
            echo "跳过 <none> repository: $tag"
			tput sgr0
            continue
        fi
		
        # 打包镜像
        docker save -o "${output_dir}/${full_image_name}.tar.gz" "$full_image_name"
        if [ $? -eq 0 ]; then
			tput bold
			tput setaf 2
            echo "$full_image_name Successfully"
			tput sgr0
        else
			tput bold
			tput blink
			tput setaf 1
            echo "$full_image_name Fail"
			tput sgr0
        fi
    done
}

# 导入镜像
load_image () {
    # 指定镜像包所在的目录
    image_dir="/opt/images_data"
    # 导入所有镜像包
    for image_file in "${image_dir}"/*.tar.gz; do
        if [ -f "$image_file" ]; then
            # 提取镜像名称和标签，假设文件名为 image_name:tag.tar.gz
            image_name=$(basename "$image_file" .tar.gz)
            
            # 导入镜像
            docker load -i "$image_file"
            if [ $? -eq 0 ]; then
				tput bold
				tput setaf 2
                echo "镜像 $image_name 成功导入"
				tput sgr0
            else
				tput bold
				tput setaf 1
                echo "镜像 $image_name 导入失败"
				tput sgr0
            fi
        else
			tput bold
			tput setaf 5
            echo "镜像文件 $image_file 不存在"
			tput sgr0
        fi
    done
}

# 提示用户选择操作，直到输入正确
while true; do
    tput bold
    tput smul
    tput setaf 3
    tput setab 0
    read -p "请选择操作：$(tput setaf 6) 1.打包镜像 $(tput setaf 4)2.导入镜像 $(tput setaf 2)q.退出：" select
	tput sgr0
    case "$select" in
        1)
            save_image
            break
            ;;
        2)
            load_image
            break
            ;;
		q)
		    exit 
		    ;;
        *)
			tput bold
			tput setaf 5
			tput blink
            echo "输入错误，请输入 1 或 2"
			tput bel
			tput sgr0
            ;;
    esac
done
