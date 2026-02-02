#!/bin/bash

IMAGE_NAME="robotwin_base"
CONTAINER_NAME="robotwin_dev"

# 1. 获取宿主机 Docker0 IP (用于转发 Clash 代理)
# 假设你的 Clash 开启了 Allow LAN，端口为 7890
PROXY_IP=$(ip addr show docker0 | grep -Po 'inet \K[\d.]+')
PROXY_URL="http://$PROXY_IP:7890"

# check if RoboTwin folder exists
if [ ! -d "./RoboTwin" ]; then
    git clone https://github.com/RoboTwin-Platform/RoboTwin.git
fi

# 2. 检查 Docker 镜像是否存在
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "未发现基础镜像 $IMAGE_NAME，开始构建..."
    docker build -t $IMAGE_NAME . 
    echo "基础镜像构建完成。"
fi

# 3. 允许 X11 转发（用于显示 GUI 窗口）
xhost +local:docker > /dev/null

# 4. 检查容器状态
RUNNING=$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)

if [ "$RUNNING" == "true" ]; then
    echo "容器 $CONTAINER_NAME 正在运行，正在进入..."
    docker exec -it $CONTAINER_NAME /bin/bash
elif [ "$RUNNING" == "false" ]; then
    echo "容器 $CONTAINER_NAME 已存在但未启动，正在启动并进入..."
    docker start $CONTAINER_NAME
    docker exec -it $CONTAINER_NAME /bin/bash
else
    echo "正在创建并启动开发容器 $CONTAINER_NAME..."
    # 第一次运行，配置所有开发环境所需的映射
    docker run -it \
        --name $CONTAINER_NAME \
        --gpus all \
        --network host \
        --privileged \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v "$(pwd):/app/workspace/Robotwin" \
        -v /usr/share/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d \
        -v /etc/vulkan/icd.d:/etc/vulkan/icd.d \
        -e http_proxy="$PROXY_URL" \
        -e https_proxy="$PROXY_URL" \
        -e no_proxy="localhost,127.0.0.1" \
        -e NVIDIA_DRIVER_CAPABILITIES=all \
        $IMAGE_NAME
fi
