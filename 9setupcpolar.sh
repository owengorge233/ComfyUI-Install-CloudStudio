#!/bin/bash
check_exit() {
    local exit_code=$1
    local error_msg=$2
    if [ $exit_code -ne 0 ]; then
        echo "❌ 错误：$error_msg (退出码: $exit_code)" >&2
        exit $exit_code
    fi
}

set -euxo pipefail  # 启用严格模式[8](@ref)
trap 'echo "错误发生在命令: $BASH_COMMAND, 行号: $LINENO, 退出状态: $?" >&2; exit 1' ERR

basefolder="/workspace"

echo "▂▂▂▂▂▂▂▂▂▂ 设置工作目录 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/ComfyUI-Install-CloudStudio" || check_exit $? "目录切换失败: $basefolder"

echo "▂▂▂▂▂▂▂▂▂▂ 下载CPolar ▂▂▂▂▂▂▂▂▂▂"
wget -O cpolar-stable-linux-amd64.zip --tries=3 --timeout=60 https://www.cpolar.com/static/downloads/releases/3.3.18/cpolar-stable-linux-amd64.zip \
|| check_exit $? "文件下载失败[6,7](@ref)"

echo "▂▂▂▂▂▂▂▂▂▂ 解压文件 ▂▂▂▂▂▂▂▂▂▂"
unzip -q cpolar-stable-linux-amd64.zip || check_exit $? "解压失败[9,11](@ref)"

echo "▂▂▂▂▂▂▂▂▂▂ 设置执行权限 ▂▂▂▂▂▂▂▂▂▂"
chmod +x ./cpolar || check_exit $? "权限设置失败"

echo "▂▂▂▂▂▂▂▂▂▂ 清理安装包 ▂▂▂▂▂▂▂▂▂▂"
rm -v cpolar-stable-linux-amd64.zip || check_exit $? "文件删除失败"

echo "✅ 所有操作完成"