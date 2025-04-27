#! /bin/bash

export PS1="\u@\h:\w\$ "

set -euo pipefail

CPOLAR_TOKEN=""
SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
    pwd -P
)" || exit 1

target_dir="$(dirname "$SCRIPT_DIR")"

cpolartokens_file="$SCRIPT_DIR/cpolartokens.txt"

# 检查文件存在性
if [ ! -f "$cpolartokens_file" ]; then
    echo "错误：cpolar token文件 cpolartokens_file 不存在" >&2
else
  # 读取首行非空内容
  while IFS= read -r line || [ -n "$line" ]; do
      if [ -n "$line" ]; then
          CPOLAR_TOKEN="$line"
          break
      fi
  done < <(head -n 1 "$cpolartokens_file")  # [6,7](@ref)

  # 验证令牌有效性
  if [ -z "$CPOLAR_TOKEN" ]; then
      echo "错误：未找到有效的令牌" >&2
      exit 1
  fi
fi

cd "$SCRIPT_DIR"
./cpolar authtoken $CPOLAR_TOKEN
./cpolar http 8188