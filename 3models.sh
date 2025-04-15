#!/bin/bash
check_exit() {
    local exit_code=$1
    local error_msg=$2
    if [ $exit_code -ne 0 ]; then
        echo "❌ 错误：$error_msg (退出码: $exit_code)" >&2
        exit $exit_code
    fi
}

set -euxo pipefail  # 启用严格模式：-e(错误退出) -u(变量检查) -x(打印命令) -o pipefail(管道错误检测)
trap 'echo "错误发生在命令: $BASH_COMMAND, 行号: $LINENO, 退出状态: $?" >&2; exit 1' ERR  # 错误时输出调试信息[11](@ref)

basefolder="/workspace"
echo "▂▂▂▂▂▂▂▂▂▂ 设置工作目录 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder" || { echo "目录切换失败: $basefolder"; exit 1; }

echo "▂▂▂▂▂▂▂▂▂▂ 安装Flux-schnell ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/ComfyUI/models/unet" || exit
wget -O flux1-schnell-Q4_K_S.gguf https://huggingface.co/city96/FLUX.1-schnell-gguf/resolve/main/flux1-schnell-Q4_K_S.gguf?download=true
check_exit $? "安装Flux-schnell失败"
wget -O t5-v1_1-xxl-encoder-Q4_K_S.gguf https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/blob/main/t5-v1_1-xxl-encoder-Q4_K_S.gguf?download=true
check_exit $? "安装t5-v1_1-xxl-encoder-Q4_K_S.gguf失败"

echo "▂▂▂▂▂▂▂▂▂▂ 安装vae ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/ComfyUI/models/vae" || exit
wget -O ae.safetensors https://huggingface.co/black-forest-labs/FLUX.1-schnell/blob/main/ae.safetensors?download=true
check_exit $? "ae.safetensors失败"

echo "✅ 所有组件安装完成"
