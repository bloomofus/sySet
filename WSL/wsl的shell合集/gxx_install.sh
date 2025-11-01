#!/bin/bash

# 确保脚本出错时停止
set -e

# 刷新 sudo 权限（让用户输一次密码）
sudo -v

# 更新并安装依赖
sudo apt update
sudo apt install -y gcc g++ gdb cmake

echo "✅ 开发工具安装完成！"
