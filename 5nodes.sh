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
#    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack | ComfyUI-Impact-Subpack | --upgrade --force-reinstall"
#    "https://github.com/rgthree/rgthree-comfy | rgthree-comfy | --upgrade --force-reinstall"
#    "https://github.com/chrisgoringe/cg-use-everywhere | cg-use-everywhere | --upgrade --force-reinstall"
#    "https://github.com/PowerHouseMan/ComfyUI-AdvancedLivePortrait | ComfyUI-AdvancedLivePortrait"
#    "https://github.com/ltdrdata/ComfyUI-Impact-Pack | ComfyUI-Impact-Pack | --upgrade --force-reinstall"
#     "https://github.com/ltdrdata/comfyui-unsafe-torch | comfyui-unsafe-torch"
     "https://github.com/WASasquatch/was-node-suite-comfyui | was-node-suite-comfyui"
     "https://github.com/spacepxl/ComfyUI-Image-Filters | ComfyUI-Image-Filters"
     "https://github.com/cubiq/ComfyUI_essentials | ComfyUI_essentials"
 #   "https://github.com/pythongosssss/ComfyUI-Custom-Scripts | ComfyUI-Custom-Scripts"
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
)

echo "▂▂▂▂▂▂▂▂▂▂ 开始批量安装 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/ComfyUI/custom_nodes" || exit

# 安装 ComfyUI_UltimateSDUpscale
git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale --recursive

for project in "${projects[@]}"; do
    # 分割字段并去除首尾空格
    IFS='|' read -r url dir_name pip_options <<< "$project"
    url=$(echo "$url" | xargs)              # 过滤 URL 首尾空格[9,10](@ref)
    dir_name=$(echo "$dir_name" | xargs)    # 过滤目录名首尾空格[5,11](@ref)
    pip_options=$(echo "$pip_options" | xargs)  # 过滤选项首尾空格[6,7](@ref)

    # 自动生成目录名（如果未指定）
    if [ -z "$dir_name" ]; then
        dir_name=$(basename "$url" .git)
    fi

    echo "▄▄▄▄▄▄▄▄▄▄ 安装 $dir_name ▄▄▄▄▄▄▄▄▄▄"

    # 克隆仓库（路径含空格时自动处理[1,4](@ref)）
    git clone --progress "$url" "$dir_name"
    check_exit $? "$dir_name 克隆失败"

    # 动态应用 pip 选项
    if [ -f "$dir_name/requirements.txt" ]; then
        if [ -n "$pip_options" ]; then
            echo "应用 pip 选项: $pip_options"
            pip install $pip_options --no-cache-dir -r "$dir_name/requirements.txt"
        else
            pip install --no-cache-dir -r "$dir_name/requirements.txt"
        fi
        check_exit $? "$dir_name 依赖安装失败"
    else
        echo "⚠️ $dir_name 未找到 requirements.txt，跳过依赖安装"
    fi
done

echo "✅ 所有项目安装完成"