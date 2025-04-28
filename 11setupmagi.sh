#! /bin/bash

set -euo pipefail

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
    pwd -P
)" || exit 1

git clone https://github.com/SandAI-org/MAGI-1.git magi
# Create a new environment
conda create -n magi python==3.10.12

# Install pytorch
conda install pytorch==2.1.0 torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
# or
# pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu121

# Install other dependencies
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --force-reinstall --user

# Install ffmpeg
conda install -c conda-forge ffmpeg=4.4

# Install MagiAttention, for more information, please refer to https://github.com/SandAI-org/MagiAttention#

git clone https://github.com/SandAI-org/MagiAttention.git
cd MagiAttention
git submodule update --init --recursive
pip install --no-build-isolation .
# 安装时提示： RuntimeError: magi_attention is only supported on CUDA 12.3 and above。
# 因此不能安装。

echo "▂▂▂▂▂▂▂▂▂▂ 操作完成 ▂▂▂▂▂▂▂▂▂▂"
