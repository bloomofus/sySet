

```bash
# 压缩
zip -e -r test.zip test/ # -e是指加密码 -r是指递归
# 解压
unzip test.zip
unzip archive.zip -d /path/to/destination/
```

注意，会把软链接的内容一起压缩。
