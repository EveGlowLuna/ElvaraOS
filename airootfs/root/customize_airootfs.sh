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
systemctl enable lightdm
systemctl enable NetworkManager
systemctl enable bluetooth

# 创建 go 缓存目录
mkdir -p /build/go-cache
chmod 777 /build/go-cache

mkdir -p /home/liveuser
cp -rT /etc/skel /home/liveuser
mkdir -p /home/liveuser/Desktop
mkdir -p /home/liveuser/.config/systemd/user/graphical-session.target.wants
ln -sf /home/liveuser/.config/systemd/user/trust-installer-desktop.service \
    /home/liveuser/.config/systemd/user/graphical-session.target.wants/trust-installer-desktop.service
chown -R liveuser:liveuser /home/liveuser
echo "liveuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/liveuser

groupadd -r autologin 2>/dev/null || true
gpasswd -a liveuser autologin

gpasswd -a liveuser video
gpasswd -a liveuser audio
gpasswd -a liveuser input
gpasswd -a liveuser storage

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

cat > /etc/lightdm/lightdm.conf << 'EOF'
[Seat:*]
autologin-user=liveuser
autologin-user-timeout=0
user-session=cinnamon
EOF

# 确保 LightDM autologin PAM 配置存在
if [ ! -f /etc/pam.d/lightdm-autologin ]; then
cat > /etc/pam.d/lightdm-autologin << 'EOF'
#%PAM-1.0
auth        required    pam_env.so
auth        required    pam_permit.so
auth        optional    pam_gnome_keyring.so
account     include     system-local-login
session     include     system-local-login
session     optional    pam_gnome_keyring.so auto_start
EOF
fi

sed -i 's/#zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=zh_CN.UTF-8' > /etc/locale.conf

# 设置 Plymouth 主题
cp /usr/share/pixmaps/elvara-logo-text.png /usr/share/plymouth/themes/elvara/elvara-logo-text.png
plymouth-set-default-theme -R elvara

# 注册系统图标到图标主题，供 Cinnamon 设置"关于"页面使用
mkdir -p /usr/share/icons/hicolor/256x256/apps
mkdir -p /usr/share/icons/hicolor/scalable/apps
cp /usr/share/pixmaps/elvara.png /usr/share/icons/hicolor/256x256/apps/elvara.png
cp /usr/share/pixmaps/elvara.svg /usr/share/icons/hicolor/scalable/apps/elvara.svg
cp /usr/share/pixmaps/elvara-logo-text.svg /usr/share/icons/hicolor/scalable/apps/elvara-text.svg
cp /usr/share/pixmaps/elvara-logo-text-dark.svg /usr/share/icons/hicolor/scalable/apps/elvara-text-dark.svg
cp /usr/share/pixmaps/elvara-logo-text.png /usr/share/icons/hicolor/256x256/apps/elvara-text.png
cp /usr/share/pixmaps/elvara-logo-text-dark.png /usr/share/icons/hicolor/256x256/apps/elvara-text-dark.png

# 替换 Arch Linux 图标
cp /usr/share/pixmaps/elvara.png /usr/share/pixmaps/archlinux-logo.png
cp /usr/share/pixmaps/elvara.svg /usr/share/pixmaps/archlinux-logo.svg
cp /usr/share/pixmaps/elvara-logo-text.svg /usr/share/pixmaps/archlinux-logo-text.svg
cp /usr/share/pixmaps/elvara-logo-text-dark.svg /usr/share/pixmaps/archlinux-logo-text-dark.svg

chmod +x /home/liveuser/桌面/elvara-installer.desktop
chmod +x /home/liveuser/Desktop/elvara-installer.desktop

chown -R liveuser:liveuser /home/liveuser

exit 0