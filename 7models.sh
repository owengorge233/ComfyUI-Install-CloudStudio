#!/bin/bash

# 错误处理函数
check_exit() {
    local exit_code=$1
    local error_msg=$2
    if [ $exit_code -ne 0 ]; then
        echo "❌ 错误：$error_msg (退出码: $exit_code)" >&2
        exit $exit_code
    fi
}

# 启用严格模式
set -euxo pipefail
trap 'echo "错误发生在命令: $BASH_COMMAND, 行号: $LINENO, 退出状态: $?" >&2; exit 1' ERR

# 基础目录设置
basefolder="/workspace"

# 文件列表（使用 | 分隔三个参数）
files=(
    # 格式："保存的文件名 | 下载链接 | 目标目录"
    ##########  Flux Fp8 组合， 需32GB vram
    "flux1-dev.sft | https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors?download=true | ${basefolder}/fluxgym/models/unet"
    "clip_l.safetensors | https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true | ${basefolder}/fluxgym/models/clip"
    # 需手动下载
    # "ae.safetensors  | https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors?download=true | ${basefolder}/fluxgym/models/vae"
)

echo "▂▂▂▂▂▂▂▂▂▂ 开始批量下载 ▂▂▂▂▂▂▂▂▂▂"

for entry in "${files[@]}"; do
    # 清理参数并分割
    clean_entry=$(echo "$entry" | tr -s ' ' | xargs)
    IFS='|' read -r filename url target_dir <<< "$clean_entry"

    # 移除两端空格
    filename=$(echo "$filename" | xargs)
    url=$(echo "$url" | xargs)
    target_dir=$(echo "$target_dir" | xargs)

    # 构建完整路径
    target_dir="${target_dir%/}"  # 移除目录末尾的/
    save_path="${target_dir}/${filename}"

    echo "▄▄▄▄▄▄▄▄▄▄ 处理文件：$filename ▄▄▄▄▄▄▄▄▄▄"
    echo "下载链接：$url"
    echo "存储位置：$save_path"

    # 创建目标目录
    mkdir -p "$target_dir"
    check_exit $? "目录创建失败：$target_dir"

    # 下载文件（关键修改点：强制覆盖）
    wget --progress=bar:force -O "$save_path" "$url"
    check_exit $? "文件下载失败：$filename"

    echo "✅ 已保存到：$save_path"
done

echo "✅ 所有文件下载完成"