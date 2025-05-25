#!/bin/bash
set -euo pipefail  # 启用严格错误检测
trap 'echo "错误发生在命令: $BASH_COMMAND, 行号: $LINENO, 退出状态: $?" >&2; exit 1' ERR  # 捕获未处理异常[9,10](@ref)

# 错误处理函数
check_exit() {
    local exit_code=$1
    local error_msg=$2
    if [ $exit_code -ne 0 ]; then
        echo "❌ 错误：$error_msg (退出码: $exit_code)" >&2
        exit $exit_code
    fi
}

basefolder="/workspace"

conda install -c "nvidia/label/cuda-12.4.0" cudatoolkit=12.4 cudnn=8.9.4 -y

# 安装PyTorch（自动选择CUDA版本）
echo "▂▂▂▂▂▂▂▂▂▂ 安装PyTorch ▂▂▂▂▂▂▂▂▂▂"
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124 \
    || check_exit $? "PyTorch安装失败"

# 设置工作目录
echo "▂▂▂▂▂▂▂▂▂▂ 克隆MAGI仓库 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder" || check_exit $? "目录切换失败: $basefolder"
git clone https://github.com/SandAI-org/MAGI-1.git magi \
    || check_exit $? "仓库克隆失败"

# 安装依赖项（使用清华镜像）
echo "▂▂▂▂▂▂▂▂▂▂ 安装Python依赖 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/magi" || check_exit $? "进入magi目录失败"
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --force-reinstall --user \
    || check_exit $? "依赖安装失败"

# 安装FFmpeg（使用conda-forge源）
echo "▂▂▂▂▂▂▂▂▂▂ 安装FFmpeg ▂▂▂▂▂▂▂▂▂▂"
conda install -c conda-forge ffmpeg=4.4 -y \
    || check_exit $? "FFmpeg安装失败"

# 条件化安装MagiAttention（CUDA版本检查）
echo "▂▂▂▂▂▂▂▂▂▂ 安装MagiAttention ▂▂▂▂▂▂▂▂▂▂"
if nvidia-smi | grep -q "CUDA Version: 12.3"; then
    cd "$basefolder" || check_exit $? "返回工作目录失败"
    git clone https://github.com/SandAI-org/MagiAttention.git \
        || check_exit $? "MagiAttention克隆失败"
    cd MagiAttention || check_exit $? "进入MagiAttention目录失败"
    git submodule update --init --recursive \
        || check_exit $? "子模块更新失败"
    pip install --no-build-isolation . \
        || check_exit $? "MagiAttention编译安装失败"
else
    echo "⚠️ 跳过MagiAttention安装：需要CUDA 12.3+ (当前版本低于要求)"
fi

echo "✅ 所有操作完成"