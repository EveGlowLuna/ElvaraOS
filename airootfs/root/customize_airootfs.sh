#!/bin/bash

set -e

sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# pacman -Syu --noconfirm

# 启用 earlyoom 服务
systemctl enable earlyoom

# 创建 go 缓存目录
mkdir -p /tmp/go-cache
chmod 777 /tmp/go-cache

# 安装 yay
cd /tmp
git clone https://aur.archlinux.org/yay.git
chown -R nobody:nobody yay
cd yay
# 构建
sudo -u nobody env GOPROXY=https://goproxy.cn,direct GOCACHE=/tmp/go-cache GOPATH=/tmp/go-cache makepkg --noconfirm
# 安装（用 root，不需要密码）
pacman -U --noconfirm yay-*.pkg.tar.zst
cd ..
rm -rf yay

# 强制 GDM 使用 X11
cat > /etc/gdm/custom.conf << 'EOF'
[daemon]
WaylandEnable=false
DefaultSession=gnome-xorg.desktop
EOF

sed -i 's/#zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=zh_CN.UTF-8' > /etc/locale.conf

# 为 live 用户复制配置
if [ -d /etc/skel/.config ]; then
    cp -r /etc/skel/.config /home/arch/
    chown -R arch:arch /home/arch/.config
fi

if [ -f /etc/skel/.bashrc ]; then
    cp /etc/skel/.bashrc /home/arch/
    chown arch:arch /home/arch/.bashrc
fi