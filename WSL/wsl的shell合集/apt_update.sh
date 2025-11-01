#!/bin/bash

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本"
    exit 1
fi

# 定义文件路径
SOURCES_LIST="/etc/apt/sources.list"
UBUNTU_SOURCES="/etc/apt/sources.list.d/ubuntu.sources"

# 写入新的源列表内容到 sources.list
cat > "$SOURCES_LIST" << 'EOF'
# 阿里源
deb http://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse

# 华为源（二选一即可）
# deb https://mirrors.huaweicloud.com/ubuntu/ noble main restricted universe multiverse
# deb https://mirrors.huaweicloud.com/ubuntu/ noble-updates main restricted universe multiverse
# deb https://mirrors.huaweicloud.com/ubuntu/ noble-backports main restricted universe multiverse
# deb https://mirrors.huaweicloud.com/ubuntu/ noble-security main restricted universe multiverse
EOF


# 更新清华镜像
cat > "$UBUNTU_SOURCES" << 'EOF'
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
# Types: deb-src
# URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
# Suites: noble noble-updates noble-backports
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# Types: deb-src
# URIs: http://security.ubuntu.com/ubuntu/
# Suites: noble-security
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# 预发布软件源，不建议启用

# Types: deb
# URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
# Suites: noble-proposed
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# # Types: deb-src
# # URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
# # Suites: noble-proposed
# # Components: main restricted universe multiverse
# # Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

echo "sources.list 已更新为阿里源（华为源已注释）"
echo "如需使用华为源，请编辑 /etc/apt/sources.list 文件取消注释对应的行"
echo "ubuntu.sources已更换为清华镜像"
echo "建议运行 'apt update' 更新软件包列表"
