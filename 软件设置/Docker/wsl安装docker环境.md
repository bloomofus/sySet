# wsl安装docker环境

## 安装wsl环境

```bat
 wsl --import dockerTest "D:\WorkSpace\WSL\dockerTest" "E:\Download\ubuntu24notorch.tar" --version 2 
```

## 安装docker教程

安装全程设置vpn为全局模式

docker engine参考网址：https://docs.docker.com/engine/install/ubuntu/

## 卸载冲突包

```shell
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
```

如果之前安装过docker，跟着官网的安装教程

## 使用apt仓库安装

```shell
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
```

### 安装最新版本

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 安装特定版本

列出版本列表

```bash
apt list --all-versions docker-ce

docker-ce/noble 5:29.2.1-1~ubuntu.24.04~noble <arch>
docker-ce/noble 5:29.2.0-1~ubuntu.24.04~noble <arch>
...
```

选择特定版本安装

```bash
VERSION_STRING=5:29.2.1-1~ubuntu.24.04~noble
sudo apt install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-buildx-plugin docker-compose-plugin
```

## 验证安装

查看运行状态

```bash
sudo systemctl status docker
```

重启docker服务

```bash
sudo systemctl start docker
```

安装hello-world镜像

```bash
sudo docker run hello-world
```

## docker换源

上面的验证大概率出错。

换源参考教程：https://cloud.tencent.cn/developer/article/2620210

创建换源文件：

```bash
sudo mkdir -p /etc/docker/
sudo nano /etc/docker/daemon.json
```

修改换源文件：

```bash
{ 
  "registry-mirrors" : 
    [ 
      "https://docker.m.daocloud.io",
      "https://docker.xuanyuan.me", 
      "https://docker.1ms.run"
    ] 
}
```

重启docker服务：

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 附录

#### Docker Desktop 和 Docker Engine 的区别是什么？

**Docker Desktop（桌面版）**

- Docker Engine（核心引擎）
- GUI 管理界面
- Windows/macOS 集成（WSL2 backend、共享文件系统、图形设置等）
- 自动更新、网络桥接、资源限制配置界面

**Docker Engine（Ubuntu版）**

- 纯 Linux 原生 Docker（最接近服务器生产环境）
- 没有 GUI
- 配置靠命令行和配置文件