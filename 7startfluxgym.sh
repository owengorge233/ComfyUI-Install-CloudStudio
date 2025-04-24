#!/bin/bash
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
project_dir="$basefolder/fluxgym"

echo "▂▂▂▂▂▂▂▂▂▂ 环境状态检测 ▂▂▂▂▂▂▂▂▂▂"
# 安全检测虚拟环境变量
if [ -n "${VIRTUAL_ENV:-}" ]; then
    echo "🔄 检测到当前处于虚拟环境中，正在退出..."
    deactivate || check_exit $? "虚拟环境退出失败"
    echo "✅ 已退出原虚拟环境"
fi

echo "▂▂▂▂▂▂▂▂▂▂ 激活目标虚拟环境 ▂▂▂▂▂▂▂▂▂▂"
if [ -d "$project_dir/fluxgym_env" ]; then
    source "$project_dir/fluxgym_env/bin/activate" || check_exit $? "虚拟环境激活失败"
    echo "✅ 已激活虚拟环境：$(which python)"
else
    check_exit 1 "虚拟环境不存在：$project_dir/fluxgym_env"
fi

echo "▂▂▂▂▂▂▂▂▂▂ 进入项目目录 ▂▂▂▂▂▂▂▂▂▂"
cd "$project_dir" || check_exit $? "目录切换失败: $project_dir"

echo "▂▂▂▂▂▂▂▂▂▂ 执行应用 ▂▂▂▂▂▂▂▂▂▂"
if [ -f "app.py" ]; then
    python app.py || check_exit $? "应用执行失败"
else
    check_exit 1 "应用文件不存在：$project_dir/app.py"
fi

echo "✅ 应用执行完成"