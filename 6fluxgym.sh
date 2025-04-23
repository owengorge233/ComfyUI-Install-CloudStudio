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
cd "$basefolder" || check_exit $? "目录切换失败: $basefolder"

echo "▂▂▂▂▂▂▂▂▂▂ 下载 Fluxgym ▂▂▂▂▂▂▂▂▂▂"
if [ ! -d "$basefolder/fluxgym" ]; then
    git clone https://github.com/cocktailpeanut/fluxgym || check_exit $? "fluxgym 克隆失败"
else
    echo "✅ fluxgym 目录已存在，跳过克隆"
fi

cd "$basefolder/fluxgym" || check_exit $? "目录切换失败: $basefolder/fluxgym"

echo "▂▂▂▂▂▂▂▂▂▂ 下载 sd-scripts ▂▂▂▂▂▂▂▂▂▂"
if [ ! -d "$basefolder/fluxgym/sd-scripts" ]; then
    git clone -b sd3 https://github.com/kohya-ss/sd-scripts || check_exit $? "sd-scripts 克隆失败"
else
    echo "✅ sd-scripts 目录已存在，跳过克隆"
fi

echo "▂▂▂▂▂▂▂▂▂▂ 安装Fluxgym ▂▂▂▂▂▂▂▂▂▂"
# 创建虚拟环境
if [ ! -d "$basefolder/fluxgym/fluxgym_env" ]; then
    python -m venv "$basefolder/fluxgym/fluxgym_env" || check_exit $? "虚拟环境创建失败"
else
    echo "✅ 虚拟环境已存在，跳过创建"
fi

# 激活虚拟环境
source "$basefolder/fluxgym/fluxgym_env/bin/activate" || check_exit $? "虚拟环境激活失败"

# 安装 sd-scripts 依赖
cd "$basefolder/fluxgym/sd-scripts" || check_exit $? "目录切换失败: sd-scripts"
pip install --no-cache-dir -r requirements.txt || check_exit $? "sd-scripts 依赖安装失败"

# 安装 fluxgym 依赖
cd "$basefolder/fluxgym" || check_exit $? "目录切换失败: fluxgym"
pip install --no-cache-dir -r requirements.txt || check_exit $? "fluxgym 依赖安装失败"

echo "✅ 所有项目安装完成"