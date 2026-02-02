#!/bin/bash

# open terminal color
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /root/.bashrc
source /root/.bashrc 

# inside conda env
conda init
# 强制初始化 Conda 路径（不要只依赖 source .bashrc）
CONDA_PATH=$(conda info --base)
source "$CONDA_PATH/etc/profile.d/conda.sh"
source /root/.bashrc 
conda activate robotwin

# download uesful tools
sudo apt-get update
sudo apt-get install -y unzip

# run install script
cd /app/workspace/Robotwin/RoboTwin
bash script/_install.sh
bash script/_download_assets.sh