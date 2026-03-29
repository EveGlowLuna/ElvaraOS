#!/bin/bash
# build.sh - 在当前目录构建 Arch Linux ISO

# 定义工作目录和输出目录
WORK_DIR="/tmp/work"
OUT_DIR="./out"

# 清理旧目录（避免冲突）
echo "清理旧的工作目录和输出目录..."
sudo rm -rf "$WORK_DIR" "$OUT_DIR"

# 运行 mkarchiso（需要 root 权限）
echo "开始构建 ISO，需要 root 权限..."
sudo mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" .

# 检查构建结果
if [ $? -eq 0 ]; then
    echo "构建成功！ISO 文件位于 $OUT_DIR 目录下。"
    echo "正在将输出文件权限改为当前用户..."
    sudo chown -R "$USER":"$USER" "$OUT_DIR"
    echo "完成。"
else
    echo "构建失败，请检查错误信息。"
    exit 1
fi
