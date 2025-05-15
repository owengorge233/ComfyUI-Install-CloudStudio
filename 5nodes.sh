#! /bin/bash
check_exit() {
    local exit_code=$1
    local error_msg=$2
    if [ $exit_code -ne 0 ]; then
        echo "❌ 错误：$error_msg (退出码: $exit_code)" >&2
        exit $exit_code
    fi
}

set -euxo pipefail
trap 'echo "错误发生在命令: $BASH_COMMAND, 行号: $LINENO, 退出状态: $?" >&2; exit 1' ERR

basefolder="/workspace"

echo "▂▂▂▂▂▂▂▂▂▂ 设置工作目录 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder" || { echo "目录切换失败: $basefolder"; exit 1; }

# 定义项目数组（URL|目录名|pip选项）
projects=(
    "https://github.com/Comfy-Org/ComfyUI-Manager.git | comfyui-manager"
    "https://github.com/city96/ComfyUI-GGUF | comfyui-gguf"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack | ComfyUI-Impact-Subpack"
    "https://github.com/rgthree/rgthree-comfy | rgthree-comfy"
    "https://github.com/chrisgoringe/cg-use-everywhere | cg-use-everywhere"
    "https://github.com/PowerHouseMan/ComfyUI-AdvancedLivePortrait | ComfyUI-AdvancedLivePortrait"
    "https://github.com/ltdrdata/comfyui-unsafe-torch | comfyui-unsafe-torch"
    "https://github.com/kijai/ComfyUI-HunyuanVideoWrapper | ComfyUI-HunyuanVideoWrapper"
     "https://github.com/gokayfem/ComfyUI_VLM_nodes.git | ComfyUI_VLM_nodes"
#     "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite | ComfyUI-VideoHelperSuite"
     "https://github.com/WASasquatch/was-node-suite-comfyui | was-node-suite-comfyui"
     "https://github.com/spacepxl/ComfyUI-Image-Filters | ComfyUI-Image-Filters"
     "https://github.com/cubiq/ComfyUI_essentials | ComfyUI_essentials"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts | ComfyUI-Custom-Scripts"
 # 换装
     "https://github.com/kijai/ComfyUI-KJNodes | ComfyUI-KJNodes"
     "https://github.com/lldacing/ComfyUI_Patches_ll | ComfyUI_Patches_ll"
 # 换装end
 #   "https://github.com/AlekPet/ComfyUI_Custom_Nodes_AlekPet | ComfyUI_Custom_Nodes_AlekPet"
 #   "https://github.com/pythongosssss/ComfyUI-WD14-Tagger | ComfyUI-WD14-Tagger"
 #   "https://github.com/LarryJane491/Lora-Training-in-Comfy | Lora-Training-in-Comfy"
 #   "https://github.com/pollockjj/ComfyUI-MultiGPU | ComfyUI-MultiGPU"
 #   "https://github.com/pamparamm/ComfyUI-ppm | ComfyUI-ppm"
 #   "https://github.com/attashe/ComfyUI-FluxRegionAttention | ComfyUI-FluxRegionAttention"
 #   "https://github.com/facok/ComfyUI-TeaCacheHunyuanVideo | ComfyUI-TeaCacheHunyuanVideo"
 #   "https://github.com/LarryJane491/Image-Captioning-in-ComfyUI | Image-Captioning-in-ComfyUI"
 #   "https://github.com/daxcay/ComfyUI-DataSet | ComfyUI-DataSet"
 #   "https://github.com/MieMieeeee/ComfyUI-CaptionThis | ComfyUI-CaptionThis"
 #   "https://github.com/madtunebk/ComfyUI-ControlnetAux | ComfyUI-ControlnetAux"
 #   "https://github.com/Cyber-BCat/ComfyUI_Auto_Caption | ComfyUI_Auto_Caption"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack | ComfyUI-Impact-Pack | --upgrade --force-reinstall"
)

echo "▂▂▂▂▂▂▂▂▂▂ 开始批量安装 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/ComfyUI/custom_nodes" || exit

# 处理 ComfyUI_UltimateSDUpscale（需求2）
upscale_dir="ComfyUI_UltimateSDUpscale"
if [ -d "$upscale_dir" ]; then
    echo "✅ $upscale_dir 已存在，跳过克隆"
else
    echo "▄▄▄▄▄▄▄▄▄▄ 克隆 UltimateSDUpscale ▄▄▄▄▄▄▄▄▄▄"
    git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale --recursive
    check_exit $? "UltimateSDUpscale 克隆失败"
fi

# 安装主项目（需求1）
for project in "${projects[@]}"; do
    IFS='|' read -r url raw_dir raw_pip <<< "$project"
    url=$(echo "$url" | xargs)
    dir_name=$(echo "$raw_dir" | xargs)
    pip_options=$(echo "$raw_pip" | xargs)

    # 自动生成目录名（如果未指定）
    [ -z "$dir_name" ] && dir_name=$(basename "$url" .git)

    echo "▄▄▄▄▄▄▄▄▄▄ 处理 $dir_name ▄▄▄▄▄▄▄▄▄▄"

    # 判断安装类型
    if [ -n "$pip_options" ]; then
        # 强制安装模式
        if [ -d "$dir_name" ]; then
            echo "⚠️ 检测到强制安装选项，删除旧目录: $dir_name"
            rm -rf "$dir_name"
        fi
        echo "克隆仓库: $url"
        git clone --progress "$url" "$dir_name"
        check_exit $? "$dir_name 克隆失败"
    else
        # 普通安装模式
        if [ -d "$dir_name" ]; then
            echo "✅ 目录已存在，跳过克隆: $dir_name"
        else
            echo "克隆仓库: $url"
            git clone --progress "$url" "$dir_name"
            check_exit $? "$dir_name 克隆失败"
        fi
    fi

    # 安装依赖
    if [ -f "$dir_name/requirements.txt" ]; then
        echo "安装Python依赖..."
        pip_cmd="pip install --no-cache-dir"
        [ -n "$pip_options" ] && pip_cmd+=" $pip_options"
        eval "$pip_cmd -r $dir_name/requirements.txt"
        check_exit $? "$dir_name 依赖安装失败"
    else
        echo "⚠️ 未找到 requirements.txt，跳过依赖安装"
    fi
done

echo "✅ 所有项目安装完成"