参考教程：https://www.youtube.com/watch?v=OduvBIulpA4

win确认连接蓝牙会生成一个key，ubuntu生成蓝牙秘钥也会生成一个key。蓝牙设备基于电脑的MAC和key来判断能不能连接成功，两个都对了，就可以连接。

第一步，在win下面删除蓝牙设备。

第二步，进入ubuntu，连接蓝牙设备，生成蓝牙秘钥之后，确认连接，这样蓝牙设备就可以在Ubuntu使用了。但是不可以在win使用。

第三步，进入win，尝试连接蓝牙设备，直到正常连接上，点击确认连接。

第四步，进入Ubuntu，**不要去连接蓝牙**，复制win的key到ubuntu的key。

```bash
cd /media/mzz/系统/Windows/System32/config  # 别的电脑按需修改
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

