#!/bin/bash

set -e

# 安装 archiso 及依赖
pacman -Sy --needed --noconfirm archiso || { echo "安装 archiso 失败"; exit 1; }

# 创建工作目录
mkdir -p /tmp/work

# 构建 ISO
mkarchiso -v -w /tmp/work -o "./output" . || { echo "mkarchiso 构建失败"; exit 1; }

# 赋予 ISO 可执行权限
chmod +x ./output/*.iso || { echo "chmod 失败"; exit 1; }

echo "构建成功"
exit 0
