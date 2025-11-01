#!/bin/bash

# 安装 Pixi
curl -fsSL https://pixi.sh/install.sh | sh

# 添加补全
echo 'eval "$(pixi completion --shell bash)"' >> ~/.bashrc

# 添加自定义函数和别名
cat >> ~/.bashrc << 'EOF'

# >>> Pixi 快速切换环境 >>>
alias p='python'
pp() {
    if [[ -n "${PIXI_EXE}" ]]; then
        exit
    else
        pixi shell
    fi
}
# <<< Pixi 快速切换环境 <<<
EOF


echo "✅ Pixi 已安装并配置完成！"
echo "👉 请重新打开终端，或运行 'pp' 进入或者退出 Pixi 环境。"
echo "进入pixi环境之后，使用'p'即可取代'python'命令"
