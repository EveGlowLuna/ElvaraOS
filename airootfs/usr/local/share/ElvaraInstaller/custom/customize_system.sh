#!/usr/bin/env bash

sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i 's/#Color/Color/' /etc/pacman.conf

reflector --country China --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

mkdir -p /build/go-cache
chmod 777 /build/go-cache

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

systemctl enable earlyoom
systemctl enable gdm
systemctl enable NetworkManager
systemctl enable bluetooth

git clone https://github.com/EveGlowLuna/ElvaraOS.git ElvaraCustom
cd ElvaraCustom/airootfs
cp etc/default/* /etc/default/
cp etc/profile.d/fcitx5.sh /etc/profile.d/
cp -a etc/skel/.config /etc/skel
rm  /etc/skel/.config/systemd/user/trust-installer-desktop.service

username=$(find /home -maxdepth 1 -mindepth 1 -type d -printf "%f\n" -quit)
target_dir="/home/${username}/.local/"
mkdir -p "$target_dir"
cp -a etc/skel/.local/ "$target_dir"

rm /etc/os-release
cp etc/os-release /etc/os-release

cd ..

mkdir -p /tmp/dconf-profile
mkdir -p "/home/${username}/.config/dconf"
cp root/dconf-settings.txt /tmp/dconf-profile/user.ini
dconf compile "/home/${username}/.config/dconf/user" /tmp/dconf-profile
cp usr/local/bin/ElvaraOSTools /usr/local/bin/ElvaraOSTools
cp -a usr/local/share/applications/* /usr/local/share/applications/
cp -a usr/local/share/gnome-shell/* /usr/local/share/gnome-shell/
cp -a usr/local/share/pixmaps/* /usr/local/share/pixmaps/

cd ../..

rm -rf ElvaraCustom

exit 0
