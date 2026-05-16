# ElvaraOS

[![Release](https://img.shields.io/github/v/release/EveGlowLuna/ElvaraOS?style=flat-square)](https://github.com/EveGlowLuna/ElvaraOS/releases)
[![Build Status](https://img.shields.io/github/actions/workflow/status/EveGlowLuna/ElvaraOS/build.yml?style=flat-square)](https://github.com/EveGlowLuna/ElvaraOS/actions/workflows/build.yml)
[![License](https://img.shields.io/badge/license-GPLv3-blue?style=flat-square)](https://github.com/EveGlowLuna/ElvaraOS/blob/main/LICENSE)

官网：https://elvaraos.eveglowsite.top

ElvaraOS 是一个基于 Arch Linux 的 LiveCD 发行版，提供图形化安装器和开箱即用的中文桌面体验。

## 项目结构

```
ElvaraOS/
├── airootfs/          # Live 系统根文件系统覆盖层
│   ├── etc/           # 系统配置（hostname, systemd, fcitx5, 网络等）
│   └── root/          # root 用户文件
├── efiboot/           # systemd-boot UEFI 启动配置
├── grub/              # GRUB BIOS 启动配置
├── syslinux/          # Syslinux BIOS 启动配置
├── .github/workflows/ # GitHub Actions CI/CD 流水线
├── build.sh           # 完整构建脚本（克隆依赖 + mkarchiso）
├── build-personal.sh  # 本地构建脚本（用于开发时测试新功能）
├── build-workflow.sh  # CI 构建脚本
├── profiledef.sh      # archiso 配置文件
├── packages.x86_64    # 软件包清单（216 个包）
├── pacman.conf        # 构建用 pacman 配置
└── publish_info.md    # 发布说明
```

## 构建要求

- Arch Linux 系统（或 archlinux:latest Docker 容器）
- `archiso` 包（`mkarchiso` 命令）
- `dotnet-sdk`（用于构建 ElvaraOSTools）
- `python`、`git`

## 构建 ISO

### Docker / CI 构建（推荐）

```bash
sudo pacman -S archiso
bash build.sh
```

构建产物位于 `./out/` 目录。

### 本地构建（开发测试）

```bash
bash build-personal.sh
```

构建产物位于 `./output/` 目录。

## 引导方式

| 模式 | 引导程序 |
|------|----------|
| BIOS | Syslinux + GRUB（回退） |
| UEFI | systemd-boot |

## 默认桌面环境

- **Cinnamon**（自 v2.0 起，此前为 GNOME）
- 安装器内置多种桌面选项（KDE、GNOME、Niri、Labwc、Hyprland 等）

## 相关项目

- **[ElvaraInstaller](https://github.com/EveGlowLuna/ElvaraInstaller)** — 图形化 Arch Linux 安装器，提供 Qt GUI 和 CLI 双界面，支持 UEFI/BIOS、分区、引导配置、桌面环境选择等
- **[ElvaraOS-Toolbox](https://github.com/EveGlowLuna/ElvaraOS-Toolbox)** — 系统管理工具箱（基于 Avalonia UI / .NET），包括包管理增强、NVIDIA 工具、系统维护、systemd 服务管理等
- **[ElvaraOS-Website](https://github.com/EveGlowLuna/ElvaraOS-Website)** — 项目官网源码（Vue 3 + Vite）

## 下载

最新 ISO 可从 [GitHub Releases](https://github.com/EveGlowLuna/ElvaraOS/releases) 获取，或访问 [官网](https://elvaraos.eveglowsite.top) 了解更多信息。

## 许可证

GNU General Public License v3.0
