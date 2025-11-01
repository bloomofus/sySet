#!/bin/bash

set -e  # 遇到错误立即退出

echo "🚀 开始安装 Miniforge（conda-forge 发行版）..."

# 1. 安装必要依赖
echo "📦 安装系统依赖..."
sudo apt update -y
sudo apt install -y wget curl bzip2



# 2. 设置安装路径
mkdir -p ~/download/
mkdir -p ~/apps/
MINIFORGE_DIR="$HOME/apps/miniforge3"
MINIFORGE_SCRIPT="$HOME/download/miniforge3-install.sh"

# 3. 如果已存在，询问是否覆盖
if [ -d "$MINIFORGE_DIR" ]; then
    echo "⚠️  检测到 Miniforge 已安装在 $MINIFORGE_DIR"
    read -p "是否重新安装？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 安装已取消。"
        exit 1
    fi
    rm -rf "$MINIFORGE_DIR"
fi

# 4. 下载 Miniforge 安装脚本
echo "📥 下载 Miniforge 安装脚本..."
wget -O "$MINIFORGE_SCRIPT" "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"

# 5. 静默安装 Miniforge
echo "⚙️  安装 Miniforge 到 $MINIFORGE_DIR ..."
bash "$MINIFORGE_SCRIPT" -b -p "$MINIFORGE_DIR"

# 6. 初始化 conda（针对当前用户的默认 shell）
echo "🔧 初始化 conda..."
"$MINIFORGE_DIR/bin/conda" init "$(basename "$SHELL")" --quiet

# 7. 重新加载 shell 配置
echo "🔁 重新加载 shell 配置..."
source "$HOME/.bashrc" 2>/dev/null || source "$HOME/.zshrc" 2>/dev/null || echo "⚠️  无法自动加载配置，请手动运行: source ~/.bashrc"

# 8. 配置 conda-forge 为默认频道
echo "🌐 配置 conda 使用 conda-forge 频道..."
"$MINIFORGE_DIR/bin/conda" config --add channels conda-forge --force
"$MINIFORGE_DIR/bin/conda" config --set channel_priority strict --force

# 9. 清理安装脚本
rm -f "$MINIFORGE_SCRIPT"

# 10. 验证安装
echo "✅ Miniforge 安装完成！"
echo "🧪 验证 conda 版本："
"$MINIFORGE_DIR/bin/conda" --version
echo "🐍 Python 版本："
"$MINIFORGE_DIR/bin/python" --version


###########快速切换
cat >> ~/.bashrc << 'EOF'

# >>> miniforge 快速切换环境 >>>
cenv() {
    if [[ $# -eq 0 ]]; then
        # 无参数：切换环境
        if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
            conda deactivate
        else
            conda activate base
        fi
    else
        # 有参数：激活指定环境
        conda activate "$1"
    fi
}
# <<< miniforge 快速切换环境 <<<

EOF

echo ""
echo "💡 提示："
echo "   - 请打开新终端，或运行 'source ~/.bashrc'（或 ~/.zshrc）以激活 conda。"
echo "   - 默认会自动激活 (base) 环境。如需关闭：conda config --set auto_activate_base false"
echo "   - 使用cenv+环境名可以快速切换环境，后面不加参数表示进入base环境，如果已在环境中，则会退出环境"
echo "   - 已经在虚拟环境里面最好先退出再进入新的虚拟环境，以防shell嵌套"
