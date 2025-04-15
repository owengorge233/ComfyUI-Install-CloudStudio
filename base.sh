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

echo "▂▂▂▂▂▂▂▂▂▂ 清理旧环境 ▂▂▂▂▂▂▂▂▂▂"
rm -rfv ComfyUI  # 显示删除详情
rm -rfv aitools  # 显示删除详情

echo "▂▂▂▂▂▂▂▂▂▂ 下载ComfyUI基础安装器 ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/" || exit
git clone --progress https://github.com/aigem/aitools.git aitools
check_exit $? "下载ComfyUI基础安装器失败"
cd "$basefolder/aitools" || exit
git pull
check_exit $? "下载ComfyUI基础安装器失败"

echo "▂▂▂▂▂▂▂▂▂▂ 安装ComfyUI ▂▂▂▂▂▂▂▂▂▂"
cd "$basefolder/aitools"
chmod +x *.sh
./aitools.sh
check_exit $? "安装ComfyUI失败"


echo "✅ 安装完成"
