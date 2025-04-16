#! /bin/bash
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

# 定义项目数组（URL+目录名）
projects=(
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts ComfyUI-Custom-Scripts"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack ComfyUI-Impact-Pack"
    "https://github.com/PowerHouseMan/ComfyUI-AdvancedLivePortrait ComfyUI-AdvancedLivePortrait"
    "https://github.com/rgthree/rgthree-comfy rgthree-comfy"
    "https://github.com/AlekPet/ComfyUI_Custom_Nodes_AlekPet ComfyUI_Custom_Nodes_AlekPet"
    "https://github.com/ssitu/ComfyUI_UltimateSDUpscale ComfyUI_UltimateSDUpscale"
    "https://github.com/pythongosssss/ComfyUI-WD14-Tagger"
    "https://github.com/chrisgoringe/cg-use-everywhere"
    "https://github.com/LarryJane491/Lora-Training-in-Comfy"
    "https://github.com/pollockjj/ComfyUI-MultiGPU"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
    "https://github.com/pamparamm/ComfyUI-ppm"
    "https://github.com/attashe/ComfyUI-FluxRegionAttention"
    "https://github.com/facok/ComfyUI-TeaCacheHunyuanVideo"
    "https://github.com/LarryJane491/Image-Captioning-in-ComfyUI"
    "https://github.com/daxcay/ComfyUI-DataSet"
    "https://github.com/MieMieeeee/ComfyUI-CaptionThis"
    "https://github.com/madtunebk/ComfyUI-ControlnetAux"
    "https://github.com/Cyber-BCat/ComfyUI_Auto_Caption"
)

echo "▂▂▂▂▂▂▂▂▂▂ 开始批量安装 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/ComfyUI/custom_nodes" || exit

for project in "${projects[@]}"; do
    # 分割URL和目录名
    url=$(echo "$project" | awk '{print $1}')
    dir_name=$(echo "$project" | awk '{print $2}')

    # 自动生成目录名（如果未指定）
    if [ -z "$dir_name" ]; then
        dir_name=$(basename "$url" .git)
    fi

    echo "▄▄▄▄▄▄▄▄▄▄ 安装 $dir_name ▄▄▄▄▄▄▄▄▄▄"

    # 克隆仓库
    git clone --progress "$url" "$dir_name"
    check_exit $? "$dir_name 克隆失败"

    # 安装依赖
    if [ -f "$dir_name/requirements.txt" ]; then
        pip install --no-cache-dir -r "$dir_name/requirements.txt"
        check_exit $? "$dir_name 依赖安装失败"
    else
        echo "⚠️ $dir_name 未找到 requirements.txt，跳过依赖安装"
    fi
done

echo "✅ 所有项目安装完成"