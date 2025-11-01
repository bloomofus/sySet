参考教程：https://www.youtube.com/watch?v=OduvBIulpA4

```bash
# 文件管理器找到C系统盘/Windows/System32/config/,右键打开终端
chntpw -e SYSTEM
cd ControlSet001
cd Services
cd BTHPORT
cd Parameter
cd Keys
cd 60f26275b975 # 别的电脑按需修改
ls # 会展示所连接的蓝牙设备
hex 蓝牙设备MAC # 复制对应的key
```

```bash
sudo su
cd /var/lib/bluetooth/
ls
cd 60\:F2\:62\:75\:B9\:75/	# 别的电脑按需修改
ls # 会展示所连接的蓝牙设备
cd 蓝牙设备MAC # 移动到对应的蓝牙设备文件夹
nano info # 修改这个文件，key修改为上面复制的key，不留空格
```

```bash
# 重启蓝牙的指令，设置不出现音量输出选项可以使用这个
sudo systemctl restart bluetooth
```

