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
if [ -d "$basefolder/ComfyUI" ]; then
    echo "错误：ComfyUI 目录已存在，请手动备份或迁移后重试。"
    exit 1
fi

if [ -d "$basefolder/ComfyUI-Install-CloudStudio/utils/init.sh" ]; then
    echo "错误：utils/init.sh不存在"
    exit 1
fi

# 导入初始化脚本
source "$basefolder/ComfyUI-Install-CloudStudio/utils/init.sh"

# 初始化环境
init_script

echo "▂▂▂▂▂▂▂▂▂▂ 设置工作目录 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder" || { echo "目录切换失败: $basefolder"; exit 1; }

echo "▂▂▂▂▂▂▂▂▂▂ 安装comfyui ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/ComfyUI-Install-CloudStudio" || exit

# 安装comfyui
install_1="comfyui_setup_mini.sh"
log_info "启动 ComfyUI 安装程序..."
if [ -f "./scripts/$install_1" ]; then
    log_info "$install_1 已找到"
    bash "./scripts/$install_1"
else
    not_found_script "$install_1"
    exit 1
fi

echo "▂▂▂▂▂▂▂▂▂▂ 安装totch torchvision torchaudio CUDA128 ▂▂▂▂▂▂▂▂▂▂"
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128 --upgrade --force-reinstall
check_exit $? "安装totch torchvision torchaudio CUDA128失败"

echo "▂▂▂▂▂▂▂▂▂▂ 安装models ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/ComfyUI/models/" || exit
cp -Rfv  $basefolder/ComfyUI-Install-CloudStudio/models/* $basefolder/ComfyUI/models

cd "$basefolder/ComfyUI/models/clip" || exit
#wget -O clip_l.safetensors https://www.modelscope.cn/models/livehouse/clip_l/resolve/master/clip_l.safetensors
check_exit $? "安装clip_l.safetensors失败"
#wget -O t5xxl_fp8_e4m3fn.safetensors https://www.modelscope.cn/models/zc0501/t5xxl_fp8/resolve/20250322200338/t5xxl_fp8_e4m3fn.safetensors
check_exit $? "安装t5xxl_fp8_e4m3fn.safetensors失败"

echo "▂▂▂▂▂▂▂▂▂▂ 安装ComfyUI GGUF支持 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/ComfyUI/custom_nodes" || exit
git clone --progress https://github.com/city96/ComfyUI-GGUF comfyui-gguf
check_exit $? "ComfyUI GGUF克隆失败"
pip install --no-cache-dir -r "$basefolder/ComfyUI/custom_nodes/comfyui-gguf/requirements.txt"
check_exit $? "ComfyUI GGUF依赖安装失败"

echo "✅ 安装完成"
