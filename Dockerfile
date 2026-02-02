# 使用官方推荐的基础镜像
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# 替换国内源
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# 1. 安装 RoboTwin 必须的系统库 (显式包含 Vulkan 和 ffmpeg)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl build-essential sudo ca-certificates \
    libgl1-mesa-glx libosmesa6-dev libglew-dev \
    libvulkan1 mesa-vulkan-drivers vulkan-tools \
    libglib2.0-0 libsm6 libxext6 libxrender-dev \
    ffmpeg x11-apps \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装最新版 Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py312_24.11.1-0-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh
ENV PATH=/opt/conda/bin:$PATH

# 3. 创建基础环境
RUN conda create -n robotwin python=3.10 -y && \
    conda run -n robotwin pip install --no-cache-dir --upgrade pip setuptools wheel

# 4. 设置 NVIDIA 核心环境变量 (关键：开启图形权限)
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics,display

WORKDIR /app/workspace

# 默认进入环境
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "robotwin", "/bin/bash"]