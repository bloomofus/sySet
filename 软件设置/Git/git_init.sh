 sudo apt install -y git
 
 # add global user
 git config --global user.email "3108482097@qq.com"
 git config --global user.name "mzz"
 
 # add chinese support
 git config --global core.quotepath false
 
 # change default editor to nano
 git config --global core.editor "nano"
 
 # gen ssh pubkey
 ssh-keygen -t ed25519 -C "3108482097@qq.com"
 
cat >> ~/.bashrc << 'EOF'

# >>> 自定义git快捷命令 >>>
alias gi='git init'
alias gii='touch .gitignore'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gpp='git push'
alias gp='git pull'
alias gb='git branch'
alias gres='git restore .' # 放弃工作区修改
alias gcl_list='git clean -n -d' # 查看将要删除的未跟踪文件
alias gcl_del='git clean -f -d' # 删除未跟踪文件
# <<< 自定义git快捷命令 <<<

EOF
