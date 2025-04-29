#! /bin/bash

export PS1="\u@\h:\w\$ "

set -euo pipefail

conda create --name comfyui python=3.12 -y
conda create --name fluxgym python=3.12 -y

NGROK_TOKEN=""
SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1
    pwd -P
)" || exit 1

target_dir="$(dirname "$SCRIPT_DIR")"

ngroktokens_file="$SCRIPT_DIR/ngroktokens.txt"

echo 'export HF_ENDPOINT=https://hf-mirror.com' >> ~/.bashrc

# 检查文件存在性
if [ ! -f "$ngroktokens_file" ]; then
    echo "错误：ngrok token文件 $ngroktokens_file 不存在" >&2
else
  # 读取首行非空内容
  while IFS= read -r line || [ -n "$line" ]; do
      if [ -n "$line" ]; then
          NGROK_TOKEN="$line"
          break
      fi
  done < <(head -n 1 "$ngroktokens_file")  # [6,7](@ref)

  # 验证令牌有效性
  if [ -z "$NGROK_TOKEN" ]; then
      echo "错误：未找到有效的令牌" >&2
  else
    export NGROK_TOKEN
    echo "export NGROK_TOKEN=\"$NGROK_TOKEN\"" >> ~/.bashrc
  fi
fi

set +u
source ~/.bashrc
set -u

pip install -U huggingface_hub

# 修复 apt update 失败问题
cp /etc/apt/sources.list /etc/apt/sources.list.bak.`date +'%F-%T'`
sed -i 's/http:\/\/mirrors.cloud.tencent.com/https:\/\/mirrors.cloud.tencent.com/g' /etc/apt/sources.list

# 支持通过 ssh 方式 clone github 仓库
apt update -y && apt install -y socat

# +x 所有的.sh
echo "▂▂▂▂▂▂▂▂▂▂ 开始+x shell脚本 ▂▂▂▂▂▂▂▂▂▂"
[ -d "$target_dir" ] || { echo "错误：目录 $target_dir 不存在" >&2; exit 1; }

find "$target_dir" -type f -name "*.sh" -print0 | xargs -0 -P 4 -I{} sh -c '
    file="{}"
    chmod -v +x "$file"
'

echo "▂▂▂▂▂▂▂▂▂▂ 操作完成 ▂▂▂▂▂▂▂▂▂▂"
