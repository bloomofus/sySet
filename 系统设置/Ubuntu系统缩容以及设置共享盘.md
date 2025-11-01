# 用 Ubuntu Live USB + GParted 安全缩小 ext4 分区

## 所需准备

1. **一个空 U 盘（≥4GB）**
2. **Ubuntu ISO 镜像**（推荐最新 LTS 版，如 Ubuntu 22.04 或 24.04）  
   下载地址：https://ubuntu.com/download/desktop
3. **写盘工具**（如 [Rufus](https://rufus.ie/)（Windows）、[BalenaEtcher](https://www.balena.io/etcher/)（跨平台））
4. **重要数据已备份！**（任何分区操作都有风险）

## 制作 Ubuntu Live USB

1. 插入 U 盘。
2. 用 Rufus 或 Etcher 将 Ubuntu ISO 写入 U 盘。
   - Rufus 设置建议：
     - 分区方案：**GPT**（如果你的电脑是 UEFI 启动）或 **MBR**（Legacy BIOS）
     - 文件系统：默认即可
3. 写入完成后，U 盘就变成了可启动的 Ubuntu Live 系统。

## 从 Live USB 启动

1. 插入 Live USB，重启电脑。
2. 开机时按启动菜单键（通常是 F12、F10、Esc 等，不同品牌不同）。
3. 选择从你的 U 盘启动（如 “USB: SanDisk…”）。
4. 进入 Ubuntu 启动菜单，选择 **“Try Ubuntu”**（试用 Ubuntu，不安装）。

## 打开 GParted，缩小 Ubuntu 的 ext4 分区

- 桌面左下角“Show Applications” → 搜索 **GParted**。

- 目标：从 Ubuntu 的主分区（通常是 `/dev/nvme0n1p2` 或 `/dev/sda2`）中释放出未分配空间。

1. **确认磁盘和分区**  
   - 在 GParted 顶部选择正确的磁盘（如 `/dev/sda` 或 `/dev/nvme0n1`）。
   - 找到你的 Ubuntu 系统分区：
     - 类型：**ext4**
     - 大小：比如 500GB
     - 挂载点：在 Live 环境中应显示为 **未挂载（unmounted）**（✅ 安全！）

2. **检查文件系统错误（重要！）**  
   右键该 ext4 分区 → **“Check”** → Apply。  
   这会修复潜在的文件系统问题，避免缩小失败。

3. **缩小分区**  
   - 右键 ext4 分区 → **“Resize/Move”**
   - 在弹出窗口中：
     - **拖动右侧滑块向左**，或直接在 “New Size” 输入你希望保留的大小（例如：原 500GB → 改为 400GB）
     - 确保 **“Free Space Following”** 显示你想要释放的空间（如 100GB）
     - ⚠️ **不要移动“Free Space Preceding”**（即不要改变分区起始位置），否则可能破坏引导！
   - 点击 “Resize/Move”

4. **应用更改**  
   - 点击 GParted 工具栏上的 ✔️ **“Apply All Operations”**
   - 确认操作 → 等待完成（时间取决于数据量，可能几分钟到几十分钟）
   - 完成后你会看到一块 **“unallocated”（未分配）** 空间

> ✅ 成功标志：ext4 分区变小了，右侧出现灰色未分配区域。

## 创建 NTFS 共享分区

1. 右键 **未分配空间** → “New”
2. 设置：
   - File system: **ntfs**
   - Label: `SharedData`（可自定义）
   - 其他默认
3. 点击 “Add”
4. 再次点击 ✔️ **Apply**
5. 等待创建完成

## 重启并测试双系统

1. 关闭 GParted，点击桌面右上角关机 → **Restart**
2. 拔掉 Live USB
3. **先启动 Ubuntu**：
   - 检查系统是否正常
   - 打开终端，查看新分区：
     ```bash
     lsblk -f
     ```
   - 如果创建了 NTFS 分区，尝试挂载：
     ```bash
     sudo mkdir /mnt/shared
     sudo mount /dev/sda3 /mnt/shared  # 替换为你的分区
     ```
4. **再启动 Windows**：
   - 如果你已在 GParted 创建了 NTFS 分区，Windows 会自动识别（可能需分配盘符）
   - 如果没创建，可在 Windows 磁盘管理中将未分配空间新建为 NTFS 卷

## 如果 GRUB 引导损坏了怎么办？

极少数情况下（如误操作移动了分区），Ubuntu 可能无法启动。修复方法：

1. 再次用 Ubuntu Live USB 启动
2. 打开终端，执行：
   ```bash
   sudo add-apt-repository ppa:yannubuntu/boot-repair -y
   sudo apt install boot-repair -y
   boot-repair
   ```
3. 选择 **“Recommended repair”**，按提示操作即可自动修复 GRUB。

# 设置开机自动挂载

## 确认分区的 **UUID**（推荐）或设备名

 **不要用 `/dev/sda3` 这类设备名**！因为硬盘顺序可能变化（比如插了U盘后，`sda` 变成 `sdb`），导致挂载失败甚至挂错盘。
**UUID 是分区的唯一标识，永不改变**，强烈推荐使用。 

### 查看分区 UUID：

```bash
sudo blkid
```

输出示例：

```bash
/dev/sda1: UUID="1234-5678" TYPE="vfat" PARTUUID="..."

/dev/sda2: UUID="abcd1234-5678-90ef-ghij-klmnopqrstuv" TYPE="ext4"

/dev/sda3: UUID="E4F8A12D3C9B8765" TYPE="ntfs"   # ← 这就是你的共享分区！
```

记下你的 NTFS 分区的 **UUID**（如 `E4F8A12D3C9B8765`）和 **TYPE**（应为 `ntfs`）。

> 💡 如果是 NVMe 硬盘，设备名可能是 `/dev/nvme0n1p3`，但 UUID 一样可用。 

## 创建挂载点（如果还没创建）

```bash
sudo mkdir -p /mnt/shared
```

> `-p` 表示如果目录已存在也不报错。 

## 编辑 `/etc/fstab` 文件

```bash
sudo nano /etc/fstab
```

在文件**末尾添加一行**（替换为你的 UUID）：

```bash
UUID=E4F8A12D3C9B8765  /mnt/shared  ntfs-3g  defaults,uid=1000,gid=1000,umask=022,windows_names,errors=remount-ro  0  2
```

|                |                                                              |
| -------------- | ------------------------------------------------------------ |
| `UUID=...`     | 分区的唯一标识（从`blkid`获取）                              |
| `/mnt/shared`  | 挂载点（你创建的目录）                                       |
| `ntfs-3g`      | 文件系统类型（NTFS 必须用`ntfs-3g`才能读写）                 |
| `defaults,...` | 挂载选项（关键！）                                           |
| `0`            | 是否用`dump`备份（0 = 不备份）                               |
| `2`            | 开机时是否用`fsck`检查（NTFS 通常设为`0`或`2`，`2`表示非根分区检查） |

挂载选项说明（`defaults,uid=1000,...`）：

- `defaults`：包含 `rw,suid,dev,exec,auto,nouser,async` 等默认选项
- `uid=1000`：指定挂载后文件的**所有者用户 ID**（通常是你的用户）
- `gid=1000`：指定**用户组 ID**
- `umask=022`：设置权限掩码（结果：文件权限 644，目录 755）
- `windows_names`：禁止创建 Windows 禁用的文件名（如 `CON`, `AUX` 等）
- `errors=remount-ro`：出错时自动重新挂载为只读，防止数据损坏

> 🔍 如何确认你的 `uid` 和 `gid`？ 
>
> ```bash
>id
> # 输出示例：uid=1000(alice) gid=1000(alice)
>```

# 常用命令

```bash
lsblk -f	# -f可加可不加，可以查看磁盘分区情况
```

