cat >> ~/.bashrc << 'EOF'

# >>> 自定义快捷命令 >>>
alias cc='clear'
alias sb='source ~/.bashrc'
nb() { nano ~/.bashrc && source ~/.bashrc; }  # 修改后自动重载
# <<< 自定义快捷命令 <<<

EOF
