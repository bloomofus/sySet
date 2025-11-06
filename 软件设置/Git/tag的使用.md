## 添加tag以及comment

给最新的提交添加tag

```bash
git tag <tagname>
git tag -a <tagname> -m "your message"
# 例如
git tag v1.0
git tag -a v1.0 -m "Release version 1.0"
```

给历史提交添加tag

```bash
git tag <tagname> <commit-hash>
git tag -a <tagname> <commit-hash> -m "your message"
# 例如
git tag v1.0 abc123f
```

## 推送tag

推送tag到远程仓库

```bash
# 推送单个
git push origin <tagname>
# 推送所有
git push origin --tags
```

## 查看管理tag

```bash
# 查看所有tag
git tag
# 查看特定tag的详细信息
git show <tagname>
# 删除本地tag
git tag -d <tagname>
# 删除远程tag
git push origin --delete <tagname>
```

```bash
# 推送所有本地tags到远程,这会将你本地所有的tags推送到远程仓库，包括新增的tags。
git push origin --tags
```

```bash
# 删除远程tags,如果在本地删除了某些tags，你也需要手动删除远程对应的tags
# 删除本地tag
git tag -d <tagname>
# 删除远程tag
git push origin --delete <tagname>
```

```bash
# 强制同步本地和远程tags
# 获取远程所有tags
git fetch --all --tags
# 删除远程存在但本地不存在的tags（需要手动对比）
git tag # 列出本地tags
git ls-remote --tags origin # 列出远程tags
git push origin --delete <remotetag-only> # 手动删除远程独有的tags
推送所有本地tags
git push origin --tags
```



## 回滚、分支

回滚到某个tag

```bash
git checkout <tagname>
```

创建一个新分支基于该tag

```bash
git checkout -b <branchname> <tagname>
```

