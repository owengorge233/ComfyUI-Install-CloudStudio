#!/bin/bash

# 初始化参数变量
source_dir=""
target_dir=""

# 解析命令行参数
while getopts ":s:d:" opt; do
  case $opt in
    s)
      source_dir="$OPTARG"
      ;;
    d)
      target_dir="$OPTARG"
      ;;
    \?)
      echo "错误：无效选项 -$OPTARG"
      exit 1
      ;;
    :)
      echo "错误：选项 -$OPTARG 需要参数"
      exit 1
      ;;
  esac
done

# 检查必填参数
if [[ -z "$source_dir" || -z "$target_dir" ]]; then
  echo "用法：$0 -s 源目录 -d 目标目录"
  exit 1
fi

# 验证源目录是否存在
if [ ! -d "$source_dir" ]; then
  echo "错误：源目录 $source_dir 不存在"
  exit 1
fi

# 创建目标根目录
if [ ! -d "$target_dir" ]; then
  mkdir -p "$target_dir"
fi

# 递归复制并覆盖文件
echo "正在从 $source_dir 复制到 $target_dir ..."
find "$source_dir" -type f -print0 | while IFS= read -r -d '' file; do
  relative_path="${file#$source_dir/}"
  dest_file="$target_dir/$relative_path"
  mkdir -p "$(dirname "$dest_file")"

  if [ -f "$dest_file" ]; then
      echo "⏩ $dest_file 文件已存在，跳过下载"
      continue  # 跳过当前循环的后续操作
  fi

  cp -f "$file" "$dest_file"
  echo "已复制：$relative_path"
done

echo "操作完成！所有文件已覆盖至 $target_dir"