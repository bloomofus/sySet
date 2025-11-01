# win 的 powershell 设置函数或者别名

比如说，使用`db`代表`dotnet build`，使用`dr`代表`dotnet run`

**powershell**

```shell
# 打开配置文件
notepad $PROFILE
# 设置别名
# Set-Alias db dotnet build 不能这样写，只能Set-Alias db dotnet
# 添加shell函数
function db { dotnet build @args }
function dr { dotnet run @args }
# 退出文件并且source（在pwsh里面）
. $PROFILE
```

**cmd**就别麻烦老东西了

**gitbash**和 linux 类似，使用`nano ~/.bashrc`即可编辑。

```bash
# dotnet 快捷命令
db() { dotnet build "$@"; }
dr() { dotnet run "$@"; }
dc() { dotnet clean "$@"; }

# git 快捷别名（可选）
alias gs='git status'
alias ga='git add'
```

**附录**

gitbash 文件快捷命令参考

```bash
# dotnet 快捷命令
dn() { dotnet new console -o "$@"; }
db() { dotnet build "$@"; }
dr() { dotnet run "$@"; }
dc() { dotnet clean "$@"; }

# git 快捷别名（可选）
alias gi='git init'
alias gii='touch .gitignore'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gpp='git push'
alias gp='git pull'
alias gb='git branch'

# 编辑.bashrc快捷命令
alias sb='source ~/.bashrc'
alias nb='nano ~/.bashrc'

# python快捷命令
alias p='python'
```