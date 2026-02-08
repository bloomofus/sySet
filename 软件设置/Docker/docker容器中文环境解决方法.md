# docker容器中文解决方法

在 Docker 里的 Ubuntu 容器“中文支持”通常分成三块：**中文编码/Locale（必须）**、**中文字体（需要显示中文时）**、**中文输入法（只有 GUI/远程桌面才需要）**。下面按常见需求给你一套可直接用的做法。

------

## 1) 让容器默认使用 UTF-8 中文 Locale（最常用、必做）

```bash
apt-get update
apt-get install -y locales language-pack-zh-hans

# 生成中文 UTF-8 locale
locale-gen zh_CN.UTF-8
update-locale LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8

# 让当前 shell 生效（可选）
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

locale
```

你希望看到类似：

- `LANG=zh_CN.UTF-8`
- `LC_ALL=zh_CN.UTF-8`

> 说明：`language-pack-zh-hans` 主要补齐中文相关语言包；真正决定编码的是 `zh_CN.UTF-8` 这个 locale。

------

## 2) 写进 Dockerfile构建中文环境镜像

```dockerfile
FROM ubuntu:24.04

# 提前设置环境变量（影响后续所有命令）
ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# 单层完成：系统更新 → 安装软件 → 配置 locale → Git 设置 → 别名注入 → 清理缓存
RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        locales \
        language-pack-zh-hans \
        neofetch \
        git \
        nano \
    && locale-gen zh_CN.UTF-8 \
    \
    # Git 全局配置
    && git config --global user.email "3108482097@qq.com" \
    && git config --global user.name "mzz" \
    && git config --global core.quotepath false \
    && git config --global core.editor "nano" \
    \
    # 注入 Git 快捷别名（系统级，所有用户生效）
    && cat >> /etc/bash.bashrc << 'EOF'

# >>> 自定义 Git 快捷命令 >>>
alias gi='git init'
alias gii='touch .gitignore'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gpp='git push'
alias gp='git pull'
alias gb='git branch'
alias gres='git restore .'          # 放弃工作区修改
alias gcl_list='git clean -n -d'    # 预览将删除的未跟踪文件
alias gcl_del='git clean -f -d'     # 删除未跟踪文件
# <<< 自定义 Git 快捷命令 <<<

# 快捷命令
alias cc='clear'
alias sb='source ~/.bashrc'
nb() { nano ~/.bashrc && source ~/.bashrc; }  # 修改后自动重载

EOF


# 可选：验证构建结果
CMD ["bash"]
```

进入该文件目录，构建镜像：

```bash
docker build -t ubuntu-cn .
```

## 附录：安装中文字体

容器里很多时候“编码正确但显示成方框/乱码”，原因是**没字体**。

### 安装常用中文字体

```bash
apt-get update
apt-get install -y fonts-noto-cjk
fc-cache -fv
```

常见替代/补充：

- `fonts-wqy-zenhei`（文泉驿）
- `fonts-noto-cjk`（覆盖广，推荐）

------

