在 Ubuntu（或其他基于 GNOME 的 Linux 桌面环境）中，给一个可执行文件创建快捷方式，通常是通过创建一个 **.desktop** 文件（也称为“桌面入口”）来实现的。这个文件本质上是一个文本文件，遵循 freedesktop.org 的 Desktop Entry 规范。

以下是详细步骤：

---

### ✅ 方法一：创建桌面快捷方式（适用于桌面或应用程序菜单）

#### 1. 创建 .desktop 文件

假设你的可执行文件路径是：  
`/home/yourusername/myapp/myprogram`

你可以创建一个 `.desktop` 文件，比如：  
`~/.local/share/applications/myprogram.desktop`

> 💡 说明：
> - 放在 `~/.local/share/applications/` 下的 `.desktop` 文件会出现在“应用程序菜单”中。
> - 如果你想在桌面上显示图标，也可以复制一份到 `~/Desktop/`（但需注意桌面图标功能在较新 GNOME 中默认禁用，可能需要启用）。

#### 2. 编辑 .desktop 文件内容

使用文本编辑器（如 `nano` 或 `gedit`）创建并编辑文件：

```bash
nano ~/.local/share/applications/myprogram.desktop
```

填入以下内容（根据你的实际情况修改）：

```ini
[Desktop Entry]
Name=My Program
Comment=Run my custom program
Exec=/home/yourusername/myapp/myprogram
Icon=/home/yourusername/myapp/icon.png
Terminal=false
Type=Application
Categories=Utility;
StartupNotify=true
```

字段说明：

- `Name`：快捷方式显示的名称。
- `Exec`：要执行的命令或可执行文件路径（建议使用绝对路径）。
- `Icon`：可选，图标路径（可以是 PNG、SVG 或图标名称，如 `firefox`）。
- `Terminal=false`：是否在终端中运行。如果程序是图形界面，设为 `false`；如果是命令行工具，设为 `true`。
- `Type=Application`：固定写法。
- `Categories`：用于在应用程序菜单中分类（如 `Utility;Development;Game;` 等）。

#### 3. 赋予可执行权限

```bash
chmod +x ~/.local/share/applications/myprogram.desktop
```

> ⚠️ 注意：`.desktop` 文件本身必须有可执行权限，否则 GNOME 不会信任它。

#### 4. 刷新或重启应用菜单

通常保存后稍等几秒，就可以在“应用程序菜单”（按 Super 键搜索）中找到你的快捷方式。

---

### ✅ 方法二：在桌面创建快捷方式（仅限启用桌面图标的情况）

如果你使用的是 **Ubuntu 20.04+ 默认 GNOME 桌面**，默认**不支持桌面图标**。但如果你安装了扩展（如 “Desktop Icons NG (DING)”），可以这样做：

1. 将上面创建的 `.desktop` 文件复制到桌面：

```bash
cp ~/.local/share/applications/myprogram.desktop ~/Desktop/
```

2. 确保它有执行权限：

```bash
chmod +x ~/Desktop/myprogram.desktop
```

3. 首次双击时，系统可能会提示“Untrusted Application Launcher”，点击“Trust and Launch”即可。

---

### ✅ 补充：如果可执行文件依赖环境变量或工作目录

你可以在 `Exec` 中使用 shell 命令包装：

```ini
Exec=sh -c "cd /home/yourusername/myapp && ./myprogram"
```

或者写一个启动脚本，再让 `.desktop` 调用该脚本。

---

### ✅ 验证是否成功

- 打开“应用程序菜单”（按 `Super` 键），搜索你设置的 `Name`。
- 或在终端运行：  
  ```bash
  gtk-launch myprogram.desktop
  ```

---

如有需要，也可以使用图形工具（如 **Alacarte**，即“主菜单”编辑器）来创建快捷方式：

```bash
sudo apt install alacarte
alacarte
```

然后在“新建项目”中填写名称、命令、图标等。

---

希望这能帮到你！如果你提供具体的可执行文件路径和用途，我可以给出更定制化的 `.desktop` 示例。