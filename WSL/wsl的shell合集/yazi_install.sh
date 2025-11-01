#!/bin/bash

# 检查 wget 是否成功
if ! wget "https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-x86_64-unknown-linux-gnu.zip"; then
    echo "❌ 下载失败！" >&2
    exit 1
fi

#  安装 unzip（如果需要）
if ! command -v unzip &> /dev/null; then
    echo "📦 安装 unzip..."
    sudo apt update && sudo apt install -y unzip
fi

# 解压安装包后删除
unzip yazi-x86_64-unknown-linux-gnu.zip
rm yazi-x86_64-unknown-linux-gnu.zip
mkdir -p ~/apps/yazi/
mv yazi-x86_64-unknown-linux-gnu ~/apps/yazi/

# 添加环境变量
mkdir -p ~/.local/bin
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
fi
cp ~/apps/yazi/yazi-x86_64-unknown-linux-gnu/yazi ~/.local/bin/
source ~/.profile

echo "✅ Yazi 安装完成！"
echo "👉 请运行 'source ~/.profile' 立即生效，或重新打开终端。"
echo "👉 然后运行 'yazi' 启动！"
