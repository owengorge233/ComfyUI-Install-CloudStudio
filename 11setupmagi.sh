#! /bin/bash

set -euo pipefail

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
    pwd -P
)" || exit 1

git clone https://github.com/SandAI-org/MAGI-1
# Create a new environment
conda create -n magi python==3.10.12

# Install pytorch
conda install pytorch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 pytorch-cuda=12.4 -c pytorch -c nvidia

# Install other dependencies
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --force-reinstall --user

# Install ffmpeg
conda install -c conda-forge ffmpeg=4.4

# Install MagiAttention, for more information, please refer to https://github.com/SandAI-org/MagiAttention#
git clone git@github.com:SandAI-org/MagiAttention.git
cd MagiAttention
git submodule update --init --recursive
pip install --no-build-isolation .

echo "▂▂▂▂▂▂▂▂▂▂ 操作完成 ▂▂▂▂▂▂▂▂▂▂"
