#!/bin/bash
check_exit() {
    local exit_code=$1
    local error_msg=$2
    if [ $exit_code -ne 0 ]; then
        echo "❌ 错误：$error_msg (退出码: $exit_code)" >&2
        exit $exit_code
    fi
}

# 找不到安装脚本提示
not_found_script() {
    log_error "未找到安装脚本: $1"
}

set -euxo pipefail  # 启用严格模式：-e(错误退出) -u(变量检查) -x(打印命令) -o pipefail(管道错误检测)
trap 'echo "错误发生在命令: $BASH_COMMAND, 行号: $LINENO, 退出状态: $?" >&2; exit 1' ERR  # 错误时输出调试信息[11](@ref)

basefolder="/workspace"

# 安装 ngrok
echo "安装 ngrok..."
if command -v ngrok &> /dev/null; then
    echo "ngrok 已安装"
else
    echo "ngrok 未安装，开始安装..."
    curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
        | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
        && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
        | tee /etc/apt/sources.list.d/ngrok.list \
        && apt update \
        && apt install ngrok
fi

echo "▂▂▂▂▂▂▂▂▂▂ 安装totch torchvision torchaudio CUDA121 ▂▂▂▂▂▂▂▂▂▂"
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu121 --upgrade --force-reinstall
check_exit $? "安装totch torchvision torchaudio CUDA121失败"

echo "▂▂▂▂▂▂▂▂▂▂ 设置工作目录 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder" || { echo "目录切换失败: $basefolder"; exit 1; }

echo "▂▂▂▂▂▂▂▂▂▂ 安装comfyui ▂▂▂▂▂▂▂▂▂▂"
if [ -d "$basefolder/ComfyUI" ]; then
    echo "更新现有的 ComfyUI 安装..."
    cd "$basefolder/ComfyUI"
    git pull
    check_exit $? "更新ComfyUI失败"
else
    echo "克隆 ComfyUI 仓库..."
    git clone https://github.com/comfyanonymous/ComfyUI.git ComfyUI
    check_exit $? "克隆ComfyUI仓库失败"
fi

echo "▂▂▂▂▂▂▂▂▂▂ 更新ComfyUI依赖 ▂▂▂▂▂▂▂▂▂▂"
if [ -d "$basefolder/ComfyUI" ]; then
   cd $basefolder/ComfyUI
   pip install -r ./requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --force-reinstall --user
   check_exit $? "更新ComfyUI依赖失败"
   pip install aria2
   echo "更新ComfyUI依赖成功"
fi

echo "▂▂▂▂▂▂▂▂▂▂ 安装models ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/ComfyUI/models/" || exit
cp -Rfv  $basefolder/ComfyUI-Install-CloudStudio/models/* $basefolder/ComfyUI/models
pip install ultralytics --upgrade --force-reinstall
pip install -U numba
pip install -U pymatting

echo "✅ 安装完成"
