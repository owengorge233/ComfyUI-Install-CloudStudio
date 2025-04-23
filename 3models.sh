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
    # "v1-5-pruned-emaonly-fp16.safetensors | https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/resolve/main/v1-5-pruned-emaonly.safetensors?download=true | ${basefolder}/ComfyUI/models/checkpoints"

    ##########  Flux Fp8 组合， 需32GB vram
    # "flux1-dev-fp8.safetensors | https://huggingface.co/Kijai/flux-fp8/resolve/main/flux1-dev-fp8-e4m3fn.safetensors?download=true | ${basefolder}/ComfyUI/models/unet"
    # "clip_l.safetensors | https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true | ${basefolder}/ComfyUI/models/clip"
    # "t5xxl_fp8_e4m3fn.safetensors | https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors?download=true | ${basefolder}/ComfyUI/models/clip"
    # # 这个模型需授权下载。可手动下载，然后上传到 /workspace/ComfyUI/models/vae目录下
    # # "ae.safetensors  | https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors?download=true | ${basefolder}/ComfyUI/models/vae"
    # "flux-vae-bf16.safetensors  | https://huggingface.co/Kijai/flux-fp8/resolve/main/flux-vae-bf16.safetensors?download=true | ${basefolder}/ComfyUI/models/vae"
    # "diffusion_pytorch_model.safetensors  | https://huggingface.co/InstantX/FLUX.1-dev-Controlnet-Union/resolve/main/diffusion_pytorch_model.safetensors?download=true | ${basefolder}/ComfyUI/models/controlnet"

    ######### Flux GGUF 组合
    # "flux1-dev-Q4_K_S.gguf | https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q4_K_S.gguf?download=true | ${basefolder}/ComfyUI/models/unet"
    # "clip_l.safetensors | https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true | ${basefolder}/ComfyUI/models/clip"
    # "t5-v1_1-xxl-encoder-Q4_K_S.gguf | https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-Q4_K_S.gguf?download=true | ${basefolder}/ComfyUI/models/clip"
    # "flux-vae-bf16.safetensors  | https://huggingface.co/Kijai/flux-fp8/resolve/main/flux-vae-bf16.safetensors?download=true | ${basefolder}/ComfyUI/models/vae"
    "raulc0399_FLUX.1_dev_openpose.safetensors  | https://huggingface.co/raulc0399/flux_dev_openpose_controlnet/resolve/main/model.safetensors?download=true | ${basefolder}/ComfyUI/models/controlnet"
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