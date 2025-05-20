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

$basefolder/ComfyUI-Install-CloudStudio/copydir.sh -s $basefolder/aimodels -d $basefolder/ComfyUI/models

# 文件列表（使用 | 分隔三个参数）
files=(
    # 格式："保存的文件名 | 下载链接 | 目标目录"
    #"v1-5-pruned-emaonly-fp16.safetensors | https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/resolve/main/v1-5-pruned-emaonly.safetensors?download=true | ${basefolder}/ComfyUI/models/checkpoints"
    #"ae.safetensors  | https://huggingface.co/receptektas/black-forest-labs-ae_safetensors/resolve/main/ae.safetensors?download=true | ${basefolder}/ComfyUI/models/vae"

    #### 图片打标？失败
    #"dreamshaper_8.safetensors | https://civitai.com/api/download/models/128713?type=Model&format=SafeTensor&size=pruned&fp=fp16 | ${basefolder}/ComfyUI/models/checkpoints"
    #"Qwen-1_8B.Q4_K_S.gguf | https://huggingface.co/mradermacher/Qwen-1_8B-GGUF/resolve/main/Qwen-1_8B.Q4_K_S.gguf?download=true | ${basefolder}/ComfyUI/models/LLavacheckpoints/files_for_qwen2vl"
    #"Qwen2-VL-7B-Instruct-Q4_K_M.gguf | https://huggingface.co/lmstudio-community/Qwen2-VL-7B-Instruct-GGUF/resolve/main/Qwen2-VL-7B-Instruct-Q4_K_M.gguf?download=true | ${basefolder}/ComfyUI/models/LLavacheckpoints/files_for_qwen2vl"
    #"llava-v1.6-mistral-7b.Q3_K.gguf | https://huggingface.co/cjpais/llava-1.6-mistral-7b-gguf/resolve/main/llava-v1.6-mistral-7b.Q3_K.gguf?download=true | ${basefolder}/ComfyUI/models/LLavacheckpoints"
    #"mmproj-model-f16.gguf | https://huggingface.co/cjpais/llava-1.6-mistral-7b-gguf/resolve/main/mmproj-model-f16.gguf?download=true | ${basefolder}/ComfyUI/models/LLavacheckpoints"

    ######### Flux GGUF 组合
    #"flux1-dev-Q4_K_S.gguf | https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q4_K_S.gguf?download=true | ${basefolder}/ComfyUI/models/unet"
    #"clip_l-flux.safetensors | https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true | ${basefolder}/ComfyUI/models/clip"
    #"t5-v1_1-xxl-encoder-Q4_K_S.gguf | https://huggingface.co/city96/t5-v1_1-xxl-encoder-gguf/resolve/main/t5-v1_1-xxl-encoder-Q4_K_S.gguf?download=true | ${basefolder}/ComfyUI/models/clip"
    #"flux-vae-bf16.safetensors  | https://huggingface.co/Kijai/flux-fp8/resolve/main/flux-vae-bf16.safetensors?download=true | ${basefolder}/ComfyUI/models/vae"
    #"flux.1_dev_openpose.safetensors  | https://huggingface.co/raulc0399/flux_dev_openpose_controlnet/resolve/main/model.safetensors?download=true | ${basefolder}/ComfyUI/models/controlnet"

    ##########  Flux Fp8 组合， 需32GB vram
    "flux1-dev-fp8.safetensors | https://huggingface.co/Kijai/flux-fp8/resolve/main/flux1-dev-fp8-e4m3fn.safetensors?download=true | ${basefolder}/ComfyUI/models/unet"
    "clip_l-flux.safetensors | https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors?download=true | ${basefolder}/ComfyUI/models/clip"
    "t5xxl_fp8_e4m3fn.safetensors | https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors?download=true | ${basefolder}/ComfyUI/models/clip"
    "flux-vae-bf16.safetensors  | https://huggingface.co/Kijai/flux-fp8/resolve/main/flux-vae-bf16.safetensors?download=true | ${basefolder}/ComfyUI/models/vae"
    "diffusion_pytorch_model.safetensors  | https://huggingface.co/InstantX/FLUX.1-dev-Controlnet-Union/resolve/main/diffusion_pytorch_model.safetensors?download=true | ${basefolder}/ComfyUI/models/controlnet/InstantX/FLUX.1-dev-Controlnet-Union"
    "512-inpainting-ema.safetensors | https://huggingface.co/stabilityai/stable-diffusion-2-inpainting/resolve/main/512-inpainting-ema.safetensors?download=true | ${basefolder}/ComfyUI/models/checkpoints"

    ################### 换装
    #"sigclip_vision_patch14_384.safetensors | https://huggingface.co/Comfy-Org/sigclip_vision_384/resolve/main/sigclip_vision_patch14_384.safetensors?download=true | ${basefolder}/ComfyUI/models/clip"
    #"t5xxl_fp16.safetensors | https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors?download=true | ${basefolder}/ComfyUI/models/clip"
    #"ViT-L-14-TEXT-detail-improved-hiT-GmP-HF.safetensors | https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-TEXT-detail-improved-hiT-GmP-HF.safetensors?download=true  | ${basefolder}/ComfyUI/models/clip"
    #"ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors | https://huggingface.co/zer0int/CLIP-GmP-ViT-L-14/resolve/main/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors?download=true  | ${basefolder}/ComfyUI/models/clip"
    #"Flux.1-Turbo-8-step-Lora_alpha.safetensors | https://huggingface.co/alimama-creative/FLUX.1-Turbo-Alpha/resolve/main/diffusion_pytorch_model.safetensors?download=true  | ${basefolder}/ComfyUI/models/loras/alimama-creative"
    #"Flux.1-Turbo-8-step-Lora_beta.safetensors | https://huggingface.co/alimama-creative/FLUX.1-dev-Controlnet-Inpainting-Beta/resolve/main/diffusion_pytorch_model.safetensors?download=true  | ${basefolder}/ComfyUI/models/loras/alimama-creative"
    #"comfyui_subject_lora16.safetensors | https://huggingface.co/ali-vilab/ACE_Plus/resolve/main/subject/comfyui_subject_lora16.safetensors?download=true  | ${basefolder}/ComfyUI/models/loras/ACE_Plus"

    # 这个模型需授权下载。可手动下载，然后上传到 /workspace/ComfyUI/models/vae目录下
    # "flux1-fill-dev.safetensors | https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev/resolve/main/flux1-fill-dev.safetensors?download=true | ${basefolder}/ComfyUI/models/unet"

    ######### 视频
    #"clip_l-HY.safetensors | https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/text_encoders/clip_l.safetensors?download=true | ${basefolder}/ComfyUI/models/text_encoders"
    #"pytorch_model.bin | https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/pytorch_model.bin?download=true | ${basefolder}/ComfyUI/models/clip/openai/clip-vit-large-patch14"
    #"model.safetensors | https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/model.safetensors?download=true?download=true | ${basefolder}/ComfyUI/models/clip/openai/clip-vit-large-patch14"
    #"preprocessor_config.json | https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/preprocessor_config.json?download=true | ${basefolder}/ComfyUI/models/clip/openai/clip-vit-large-patch14"
    #"config.json | https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/config.json?download=true | ${basefolder}/ComfyUI/models/clip/openai/clip-vit-large-patch14"
    #"tokenizer.json | https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/tokenizer.json?download=true | ${basefolder}/ComfyUI/models/clip/openai/clip-vit-large-patch14"
    #"tokenizer_config.json | https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/tokenizer_config.json?download=true | ${basefolder}/ComfyUI/models/clip/openai/clip-vit-large-patch14"
    #"special_tokens_map.json | https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/special_tokens_map.json?download=true | ${basefolder}/ComfyUI/models/clip/openai/clip-vit-large-patch14"
    #"vocab.json | https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/vocab.json?download=true | ${basefolder}/ComfyUI/models/clip/openai/clip-vit-large-patch14"
    #"merges.txt | https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/merges.txt?download=true | ${basefolder}/ComfyUI/models/clip/openai/clip-vit-large-patch14"
    #"hyvid_I2V_lora_embrace.safetensors | https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hyvid_I2V_lora_embrace.safetensors?download=true | ${basefolder}/ComfyUI/models/loras"
    #"hunyuan_video_I2V-Q4_K_S.gguf | https://huggingface.co/Kijai/HunyuanVideo_comfy/resolve/main/hunyuan_video_I2V-Q4_K_S.gguf?download=true | ${basefolder}/ComfyUI/models/unet"
    #"Llama-3-8B-Instruct-GGUF-Q4_K_M.gguf | https://huggingface.co/thesven/Llama-3-8B-Instruct-GGUF-Q4_K_M/resolve/main/Llama-3-8B-Instruct-GGUF-Q4_K_M.gguf?download=true | ${basefolder}/ComfyUI/models/unet"
    #"hunyuan_video_vae_bf16.safetensors  | https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/vae/hunyuan_video_vae_bf16.safetensors?download=true | ${basefolder}/ComfyUI/models/vae"
    #"llava_llama3_fp8_scaled.safetensors | https://huggingface.co/calcuis/hunyuan-gguf/resolve/main/llava_llama3_fp8_scaled.safetensors?download=true | ${basefolder}/ComfyUI/models/text_encoders"
    #"llava_llama3_vision.safetensors | https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/clip_vision/llava_llama3_vision.safetensors?download=true | ${basefolder}/ComfyUI/models/clip_vision"
    #"hunyuan_video_v2_replace_image_to_video_720p_bf16.safetensors | https://huggingface.co/Comfy-Org/HunyuanVideo_repackaged/resolve/main/split_files/diffusion_models/hunyuan_video_v2_replace_image_to_video_720p_bf16.safetensors?download=true  | ${basefolder}/ComfyUI/models/diffusion_models"
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

    if [ -f "$save_path" ]; then
        echo "⏩ 文件已存在，跳过下载"
        continue  # 跳过当前循环的后续操作
    fi

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