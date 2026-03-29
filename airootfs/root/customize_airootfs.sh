#!/bin/bash

set -e

sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

sed -i 's/^CheckSpace/#CheckSpace/' /etc/pacman.conf

pacman-key --init
pacman-key --populate archlinux

# 不需要
# pacman -Syu --noconfirm

# 启用服务
systemctl enable earlyoom
systemctl enable gdm
systemctl enable NetworkManager
systemctl enable bluetooth

# 创建 go 缓存目录
mkdir -p /build/go-cache
chmod 777 /build/go-cache

chmod +x /etc/skel/.local/share/gnome-shell/extensions/ding@rastersoft.com/app/ding.js
mkdir -p /home/liveuser
cp -rT /etc/skel /home/liveuser
mkdir -p /home/liveuser/Desktop
mkdir -p /home/liveuser/.config/systemd/user/graphical-session.target.wants
ln -sf /home/liveuser/.config/systemd/user/ding-fix-permissions.service \
    /home/liveuser/.config/systemd/user/graphical-session.target.wants/ding-fix-permissions.service
ln -sf /home/liveuser/.config/systemd/user/trust-installer-desktop.service \
    /home/liveuser/.config/systemd/user/graphical-session.target.wants/trust-installer-desktop.service
chown -R liveuser:liveuser /home/liveuser
echo "liveuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/liveuser

# 安装 yay
cd /tmp
git clone https://aur.archlinux.org/yay.git
chown -R nobody:nobody yay
cd yay
# 构建
sudo -u nobody env GOPROXY=https://goproxy.cn,direct GOCACHE=/build/go-cache GOPATH=/build/go-cache makepkg --noconfirm
# 安装（用 root，不需要密码）
pacman -U --noconfirm yay-*.pkg.tar.zst
cd ..
rm -rf yay

cat > /etc/gdm/custom.conf << 'EOF'
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=liveuser
EOF

sed -i 's/#zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=zh_CN.UTF-8' > /etc/locale.conf

# 设置 Plymouth 主题
cp /usr/share/pixmaps/elvara-logo-text.png /usr/share/plymouth/themes/elvara/elvara-logo-text.png
plymouth-set-default-theme -R elvara

# 注册系统图标到图标主题，供 GNOME 设置"关于"页面使用
mkdir -p /usr/share/icons/hicolor/256x256/apps
mkdir -p /usr/share/icons/hicolor/scalable/apps
cp /usr/share/pixmaps/elvara.png /usr/share/icons/hicolor/256x256/apps/elvara.png
cp /usr/share/pixmaps/elvara.svg /usr/share/icons/hicolor/scalable/apps/elvara.svg
cp /usr/share/pixmaps/elvara-logo-text.svg /usr/share/icons/hicolor/scalable/apps/elvara-text.svg
cp /usr/share/pixmaps/elvara-logo-text-dark.svg /usr/share/icons/hicolor/scalable/apps/elvara-text-dark.svg
cp /usr/share/pixmaps/elvara-logo-text.png /usr/share/icons/hicolor/256x256/apps/elvara-text.png
cp /usr/share/pixmaps/elvara-logo-text-dark.png /usr/share/icons/hicolor/256x256/apps/elvara-text-dark.png

# 确保 hicolor index.theme 完整，包含所有必要目录
cat > /usr/share/icons/hicolor/index.theme << 'EOF'
[Icon Theme]
Name=hicolor
Hidden=false
Comment=Fallback icon theme
Directories=256x256/apps,128x128/apps,96x96/apps,72x72/apps,64x64/apps,48x48/apps,36x36/apps,32x32/apps,24x24/apps,22x22/apps,16x16/apps,scalable/apps

[256x256/apps]
Size=256
Context=Applications
Type=Threshold
MinSize=256
MaxSize=256

[128x128/apps]
Size=128
Context=Applications
Type=Threshold
MinSize=128
MaxSize=128

[96x96/apps]
Size=96
Context=Applications
Type=Threshold
MinSize=96
MaxSize=96

[72x72/apps]
Size=72
Context=Applications
Type=Threshold
MinSize=72
MaxSize=72

[64x64/apps]
Size=64
Context=Applications
Type=Threshold
MinSize=64
MaxSize=64

[48x48/apps]
Size=48
Context=Applications
Type=Threshold
MinSize=48
MaxSize=48

[36x36/apps]
Size=36
Context=Applications
Type=Threshold
MinSize=36
MaxSize=36

[32x32/apps]
Size=32
Context=Applications
Type=Threshold
MinSize=32
MaxSize=32

[24x24/apps]
Size=24
Context=Applications
Type=Threshold
MinSize=24
MaxSize=24

[22x22/apps]
Size=22
Context=Applications
Type=Threshold
MinSize=22
MaxSize=22

[16x16/apps]
Size=16
Context=Applications
Type=Threshold
MinSize=16
MaxSize=16

[scalable/apps]
Size=48
Context=Applications
Type=Scalable
MinSize=1
MaxSize=512
EOF

echo "Updating icon cache for hicolor..."
gtk-update-icon-cache -f -t -v /usr/share/icons/hicolor/
# 替换 Arch Linux 图标
cp /usr/share/pixmaps/elvara.png /usr/share/pixmaps/archlinux-logo.png
cp /usr/share/pixmaps/elvara.svg /usr/share/pixmaps/archlinux-logo.svg
cp /usr/share/pixmaps/elvara-logo-text.svg /usr/share/pixmaps/archlinux-logo-text.svg
cp /usr/share/pixmaps/elvara-logo-text-dark.svg /usr/share/pixmaps/archlinux-logo-text-dark.svg

# 加载 dconf 设置，直接编译进用户数据库
# 将 keyfile 格式转换为 dconf 二进制数据库
mkdir -p /tmp/dconf-profile
mkdir -p /home/liveuser/.config/dconf
cp /root/dconf-settings.txt /tmp/dconf-profile/user.ini
dconf compile /home/liveuser/.config/dconf/user /tmp/dconf-profile

# 由于不知道是英文桌面还是中文，所以两个都要。（但livecd我之前每次都是中文）
chmod +x /home/liveuser/桌面/elvara-installer.desktop
chmod +x /home/liveuser/Desktop/elvara-installer.desktop

chown -R liveuser:liveuser /home/liveuser

exit 0