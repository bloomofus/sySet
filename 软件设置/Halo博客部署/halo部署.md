# Windows 部署 Halo 博客完整指南

## 选择部署方式

| 方式   | 难度 | 推荐场景       |
| ------ | ---- | -------------- |
| Docker | ⭐⭐   | 推荐，环境隔离 |
| JAR 包 | ⭐⭐   | 不想装 Docker  |

---

## 方式一：Docker 部署（推荐）

### 步骤 1：安装 Docker Desktop

1. 下载：https://www.docker.com/products/docker-desktop/
2. 安装后重启电脑
3. 打开 Docker Desktop 确保运行中

---

### 步骤 2：创建目录结构

```powershell
# 在你想要的位置创建目录，比如 D 盘
mkdir D:\halo
cd D:\halo
```

---

### 步骤 3：创建 docker-compose.yml

在 `D:\halo` 目录下创建 `docker-compose.yml` 文件：

```yaml
version: "3"

services:
  halo:
    image: halohub/halo:2.20
    container_name: halo
    restart: always
    volumes:
      - ./halo2:/root/.halo2
    ports:
      - "8090:8090"
    environment:
      - SPRING_SQL_INIT_PLATFORM=h2
      - HALO_SECURITY_INITIALIZER_SUPERADMINPASSWORD=your_password123
```

> ⚠️ 把 `your_password123` 改成你自己的密码（至少8位，包含字母和数字）

---

### 步骤 4：启动 Halo

```powershell
cd D:\halo
docker-compose up -d
```

等待下载完成后，访问：**http://localhost:8090**

---

## 方式二：JAR 包直接运行

### 步骤 1：安装 JDK 21+

1. 下载：https://adoptium.net/
2. 选择 **JDK 21 LTS** → Windows → x64 → .msi
3. 安装（默认选项即可）

验证安装：
```powershell
java -version
```

---

### 步骤 2：下载 Halo

从 GitHub 下载最新版：
```
https://github.com/halo-dev/halo/releases
```

下载 `halo-2.x.x.jar` 文件，放到 `D:\halo\` 目录

---

### 步骤 3：创建配置文件

在 `D:\halo\` 下创建 `application.yaml`：

```yaml
server:
  port: 8090

spring:
  sql:
    init:
      platform: h2

halo:
  security:
    initializer:
      superadminusername: admin
      superadminpassword: your_password123
```

---

### 步骤 4：启动 Halo

```powershell
cd D:\halo
java -jar halo-2.20.0.jar
```

访问：**http://localhost:8090**

---

## 首次访问配置

1. 打开浏览器访问 `http://localhost:8090`

2. 进入初始化页面：
   - 设置站点名称
   - 创建管理员账号

3. 完成后进入后台：`http://localhost:8090/console`

---

## 常用命令

```powershell
# Docker 方式
docker-compose up -d      # 启动
docker-compose down       # 停止
docker-compose logs -f    # 查看日志
docker-compose restart    # 重启

# JAR 方式 - 后台运行（创建 start.bat）
@echo off
start /b java -jar halo-2.20.0.jar > halo.log 2>&1
```

---

## 可能遇到的问题

### 端口被占用
```powershell
# 查看 8090 端口占用
netstat -ano | findstr "8090"

# 修改 docker-compose.yml 中的端口，比如改成 8091:8090
```

### Docker 启动失败
- 确保 Docker Desktop 正在运行
- 检查 WSL2 是否已安装（Docker 会提示）

---

需要我帮你解决部署过程中遇到的具体问题吗？