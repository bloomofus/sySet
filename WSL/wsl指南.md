# 前言

安装wsl，并且使用深度学习环境。

推荐步骤：

1. 阅读`使用Rootfs安装wsl`这一章安装wsl环境，安装好进入wsl系统之后，运行换源脚本`apt_update.sh`，然后执行`apt update`，关于登录用户？荐直接root登录。
2. 使用`pixi_install.sh`脚本一键安装pixi环境，记得提前加脚本可执行权限。
3. （也可以使用`miniforge_install.sh`一键安装conda环境，当然还是推荐pixi环境。）
4. 使用`torch_install.sh`脚本，一键添加一个深度学习测试项目，其位置在`~/pyRepo/torchTest`或者说`/root/pyRepo/torchTest`，注意pytorch安装需要挂梯子。
5. 进入`torchTest`文件夹，使用`pp`进入pixi环境，执行`p mnist_classify.py`或者`p iris_classify.py`进行测试。

# 使用MS Store安装wsl

先安装wsl，参考教程【从0开始安装wsl】https://www.bilibili.com/video/BV18VGPzVEzo?vd_source=98bf64b2be1ca9719f9458964489580f 推荐ubuntu2404lts。（控制面板-更改程序与功能-勾选虚拟机平台、wsl、Hyper-v->微软商店下载安装->设置用户名密码->换源）

设置好密码之后，使用vscode远程连接ubuntu，开发cpp就使用对应的vscode配置，然后安装插件到wsl2，开发py，也是一样，需要安装conda。

# 安装miniconda

## 下载安装包及安装

```bash
sudo apt update && sudo apt upgrade -y
```

```bash
# 进入家目录
cd ~
# 下载最新版 Miniconda（Python 3.10+，64位）
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
```

```bash
bash miniconda.sh -b -p $HOME/miniconda3
```

参数说明：
- `-b`：batch 模式（静默安装，无需交互）
- `-p $HOME/miniconda3`：指定安装路径为 `~/miniconda3`

---

## conda设置

```bash
# 初始化 conda（会修改 ~/.bashrc）
$HOME/miniconda3/bin/conda init bash
```

```bash
source ~/.bashrc
```

现在你应该能看到命令行前缀变成 `(base)`，表示 conda 已激活：
```bash
(base) mzz-wsl@laptop:~$
```

```bash
# 检查 conda 版本
conda --version
# 检查 Python 版本（由 Miniconda 提供）
python --version
# 查看环境列表
conda info --envs
```

---

## 优化设置（可选）

### 禁用自动激活 base 环境（推荐）

每次打开终端都自动进入 `(base)` 可能影响性能或与其他工具冲突：
```bash
conda config --set auto_activate_base false
```
需要时手动激活：
```bash
conda activate base
```

### 设置国内镜像（加速下载，可选）

```bash
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --set show_channel_urls yes
```

### 快速进出base（推荐）

```bash
nano ~/.bashrc  
```

在文件末尾添加以下函数，使得输入cenv能够进出conda环境。

```bash
# Conda 快速切换 base 环境
cenv() {
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        conda deactivate
    else
        conda activate base	# 环境名称可编辑
    fi
}
```

> 💡 说明：
>
> - `$CONDA_DEFAULT_ENV` 是 Conda 激活环境后设置的环境变量。
> - 当处于 `base` 或其他环境时，该变量非空；未激活时为空。

```bash
source ~/.bashrc 
```

## 卸载 Miniconda

1. 删除安装目录：
   ```bash
   rm -rf ~/miniconda3
   ```
2. 清理 `~/.bashrc` 中 conda 相关内容（或运行）：
   ```bash
   conda init --reverse  # 如果之前初始化过
   ```
3. 手动检查并删除残留：
   ```bash
   rm -rf ~/.conda
   ```

# 安装Pytorch

## Win主机已安装 NVIDIA GPU 驱动

如果在wsl系统里， `nvidia-smi` 能显示 GPU 信息，说明 **WSL 已成功访问 GPU**！

---

## 安装pytorch(pip)（已测试）

## 安装 pytorch(conda)（未测试）（二选一）

（从官网直接复制的命令`pip3 install torch torchvision`是有效的）

```bash
# 创建环境
conda create -n torch python=3.10 -y
conda activate torch

# 从官方渠道安装 PyTorch（自动包含 CUDA 支持）
# 访问 https://pytorch.org/get-started/locally/ 获取最新命令
# 例如（CUDA 12.1）：
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
###############使用官网的命令安装是pip，conda安装没试过
```

> ✅ 这样安装的 PyTorch **自带 CUDA 运行时**，不需要你手动配置 `LD_LIBRARY_PATH`！

```python
python -c "import torch; print(torch.cuda.is_available())"
```
---

## 补充说明

| 项目             | 说明                                                         |
| ---------------- | ------------------------------------------------------------ |
| **CUDA 驱动**    | 由 Windows 主机提供，WSL 自动共享                            |
| **CUDA Toolkit** | WSL 中安装的是“用户态库”，用于编译（如写 `.cu` 文件）        |
| **深度学习框架** | 推荐通过 `conda` 或 `pip` 安装 **预编译的 CUDA 版本**，避免自己编译 |
| **cuDNN**        | PyTorch/TensorFlow 的 Conda 包已包含，无需单独安装           |

# WSL使用代理

> 使用此设置之后，wsl的网络跟随主机变化。
>
> 参考：https://juejin.cn/post/7396934542958067723

在 windows 的`C:\User\<你的用户名>\` 下创建一个`.wslconfig`，内部写入如下内容

```ini
[experimental]
autoMemoryReclaim=gradual  
networkingMode=mirrored
dnsTunneling=true
firewall=true
autoProxy=true
```

写完后保存，重启 wsl 即可

```arduino
wsl --shutdown
```

再次启动 wsl，不再弹出上述提示。

# Pixi包管理器安装使用

执行此命令`curl -fsSL https://pixi.sh/install.sh | sh`再`source ~/.bashrc`一下，就安装好了。

设置命令补全`echo 'eval "$(pixi completion --shell bash)"' >> ~/.bashrc`，再`source ~/.bashrc`一下。

添加conda依赖包，`pixi add opencv`，默认软件包来源是conda-forge。

添加pypi依赖包，相当于pip安装，`pixi add --pypi pygame`。

从别的项目复制环境？复制粘贴一份toml，再`pixi i`或者`pixi install`就行。

toml示例。

```sh
[workspace]
channels =  ["conda-forge"]
name = "03PixiTest"
platforms = ["linux-64"]
version = "0.1.0"

[tasks]

[dependencies]
python = "3.11.*"
numpy = ">=2.3.3,<3"
pandas = ">=2.3.3,<3"
jupyter = ">=1.1.1,<2"
matplotlib = ">=3.10.6,<4"
scipy = ">=1.16.2,<2"
requests = ">=2.32.5,<3"
opencv = ">=4.12.0,<5"
scikit-learn = ">=1.7.2,<2"
marimo = ">=0.16.5,<0.17"

[pypi-dependencies]
torch = { version = "==2.7.1", index = "https://download.pytorch.org/whl/cu128" }
torchvision = { version = "==0.22.1", index = "https://download.pytorch.org/whl/cu128" }
torchaudio={ version="==2.7.1",index="https://download.pytorch.org/whl/cu128"}
pygame = ">=2.6.1, <3"
```

安装pytorch。需要挂梯子。wsl代理是否已经设置？

使用官方的命令，把`pip install`替换成`pixi add --pypi`就行。或者修改toml文件。

```
在toml文件里面添加pypi的库依赖。
[pypi-dependencies]
torch = { version = "==2.7.1", index = "https://download.pytorch.org/whl/cu128" }
torchvision = { version = "==0.22.1", index = "https://download.pytorch.org/whl/cu128" }
torchaudio={ version="==2.7.1",index="https://download.pytorch.org/whl/cu128"}
pygame = ">=2.6.1, <3" 
然后再使用pixi i或者pixi install就会自动下载toml里面的依赖。
```

删除库`pixi remove numpy` `pixi remove --pypi pygame`

查看已安装库`pixi list`

# Yazi终端文件管理器使用

下载安装文件`wget https://github.com/sxyazi/yazi/releases/download/nightly/yazi-x86_64-unknown-linux-gnu.zip`

解压`sudo apt install unzip` `unzip yazi-x86_64-unknown-linux-gnu.zip` 解压后的目录就是最终安装目录，解压好就安装好。

删除安装包` rm yazi-x86_64-unknown-linux-gnu.zip`

## 添加到用户path

确保目录存在？

`mkdir -p ~/.local/bin`
`export PATH="$HOME/.local/bin:$PATH"`
 `cp ./yazi-x86_64-unknown-linux-gnu/yazi ~/.local/bin/`(yazi默认有可执行权限)

确保 PATH 生效`source ~/.profile `

确认版本号`yazi --version`

## 添加到全局path（和添加到用户path二选一）

`sudo cp ./yazi /usr/local/bin`

## 快捷键

| 快捷键   | 功能               |
| -------- | ------------------ |
| tab      | 查看属性           |
| d加enter | 删除文件或者文件夹 |
|          |                    |

# Linux小技巧

## 使用cc代替clear命令

```sh
echo "alias cc='clear'" >> ~/.bashrc
source ~/.bashrc
```



# 使用Rootfs安装wsl

## 安装步骤

### 安装之前

确保这个设置好了`控制面板-更改程序与功能-勾选虚拟机平台、wsl、Hyper-v`

### 安装文件下载

ubuntu2404的安装链接`https://cdimages.ubuntu.com/ubuntu-wsl/noble/daily-live/current/noble-wsl-amd64.wsl`得到一个文件`noble-wsl-amd64.wsl`

(大多数情况下，`.wsl` 文件其实是 **tar 归档文件**，只是扩展名改成了 `.wsl`)

(镜像列表链接`https://cdimages.ubuntu.com/ubuntu-wsl/`)

### 安装系统

确认 WSL2 已启用，在 PowerShell（管理员）中运行`wsl --set-default-version 2`
安装系统：
`wsl --import Ubuntu-24.04 "C:\WSL\Ubuntu2404" "C:\path\to\noble-wsl-amd64.wsl" --version 2`

>  说明：
>
> Ubuntu-24.04：你给这个 WSL 发行版起的名字（可自定义，如 noble）
> C:\WSL\Ubuntu2404：WSL 系统文件存放的目录（会自动创建）
> C:\path\to\noble-wsl-amd64.wsl：你下载的 .wsl 文件的完整路径
> --version 2：确保使用 WSL2

### 设置默认用户（可选）

（我认为可以不用选，直接root）

导入后，默认会以 root 用户启动。你需要设置一个普通用户并设为默认。启动系统`wsl -d Ubuntu-24.04`。
在 WSL 中创建用户（假设用户名为 yourname）：`adduser yourname`
赋予 sudo 权限（Ubuntu/Debian）：`usermod -aG sudo yourname ` 
创建 /etc/wsl.conf 文件（可选但推荐）：`sudo nano /etc/wsl.conf`

添加以下内容，让 WSL 自动使用你指定的用户登录：

```ini
[user]
default=yourname
```

（如果还是想要以root进入系统，那么`default=root`即可）

关闭 WSL，在 PowerShell 中运行：`wsl --terminate Ubuntu-24.04`
然后重新启动：`wsl -d Ubuntu-24.04`
现在应该以 yourname 用户登录了。

### 设置wsl代理

没设置的一定要设置，不然挂不上梯子。

### 换源

(我提供了ubuntu2404的一键换源脚本)

#### 修改文件1

查看版本代号` cat /etc/apt/sources.list.d/ubuntu.sources |grep Suites`

（想查看具体的版本可以使用`apt`安装`neofetch`）

前往清华镜像站`https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/`

根据版本代号，复制对应的代码到对应的文件即可。比如我的是`ubuntu2404`，就把`/etc/apt/sources.list.d/ubuntu.sources`这个文件清空，再复制粘贴清华的镜像代码。

然后更新软件源`sudo apt update`（经过实验，挂梯子更新软件源会失败，不是操作的问题）

> **（换源后下载失败，复制粘贴问语言大模型）**

#### 修改文件2

`sudo nano /etc/apt/sources.list`

```ini
# 阿里源
deb http://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse

# 华为源（二选一即可）
deb https://mirrors.huaweicloud.com/ubuntu/ noble main restricted universe multiverse
deb https://mirrors.huaweicloud.com/ubuntu/ noble-updates main restricted universe multiverse
deb https://mirrors.huaweicloud.com/ubuntu/ noble-backports main restricted universe multiverse
deb https://mirrors.huaweicloud.com/ubuntu/ noble-security main restricted universe multiverse
```




## wsl操作命令

| 命令                          | 功能                    |
| ----------------------------- | ----------------------- |
| wsl -l                        | 列表查看wsl所安装的系统 |
| wsl -l -v                     | 更详细                  |
| wsl -d Ubuntu24-test          | 启动该系统              |
| wsl --terminate Ubuntu24-test | 关闭指定系统            |
| wsl --unregister Ubuntu-20.04 | 删除指定系统            |

## 删除wsl里的系统

```sh
wsl -l -v	# 系统列个表
wsl --unregister Ubuntu-20.04 # 删除指定系统
```

从 Microsoft Store 卸载应用（可选但推荐）
虽然 `--unregister` 已删除 Linux 系统，但 Store 应用图标可能还在。你可以：

- 打开 **Microsoft Store**
- 点击右上角头像 → “我的库”
- 找到 “Ubuntu 20.04” → 点击“卸载”
- 或通过 PowerShell 卸载：`Get-AppxPackage *Ubuntu20.04* | Remove-AppxPackage`（未测试）

# 导出已有的wsl环境

## 导出环境

首先`wsl --shutdownn`关闭虚拟机，然后导出`ubuntu24`为即将导出的环境的名字。

```shell
wsl --export ubuntu24 D:\Download\ubuntu24tar
```

## 导入环境

```shell
wsl --import ubuntu24Test "E:\WSL\ubuntu24Test" "D:\Download\ubuntu24.tar" --version 2
```

# 附录-torch安装检查

```py
# 鸢尾花分类
import torch
import torch.nn as nn
import torch.optim as optim
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from torch.utils.data import TensorDataset, DataLoader

# 1. 自动选择设备：优先 CUDA → MPS（Apple Silicon）→ CPU
def get_device():
    if torch.cuda.is_available():
        return torch.device('cuda')
    elif torch.backends.mps.is_available():  # Apple Silicon (M1/M2)
        return torch.device('mps')
    else:
        return torch.device('cpu')

device = get_device()
print(f"Using device: {device}")

# 2. 加载数据
iris = load_iris()
X = iris.data
y = iris.target

# 3. 划分训练集和测试集
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# 4. 标准化
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# 5. 转换为 PyTorch 张量并迁移到设备
X_train_tensor = torch.tensor(X_train, dtype=torch.float32).to(device)
y_train_tensor = torch.tensor(y_train, dtype=torch.long).to(device)
X_test_tensor = torch.tensor(X_test, dtype=torch.float32).to(device)
y_test_tensor = torch.tensor(y_test, dtype=torch.long).to(device)

# 6. 数据加载器
train_dataset = TensorDataset(X_train_tensor, y_train_tensor)
train_loader = DataLoader(train_dataset, batch_size=16, shuffle=True)

# 7. 定义模型
class IrisNet(nn.Module):
    def __init__(self, input_dim=4, hidden_dim=10, output_dim=3):
        super(IrisNet, self).__init__()
        self.fc1 = nn.Linear(input_dim, hidden_dim)
        self.fc2 = nn.Linear(hidden_dim, output_dim)
        self.relu = nn.ReLU()

    def forward(self, x):
        x = self.relu(self.fc1(x))
        x = self.fc2(x)
        return x

model = IrisNet().to(device)  # 模型也迁移到设备

# 8. 损失函数和优化器
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.01)

# 9. 训练
epochs = 100
for epoch in range(epochs):
    model.train()
    total_loss = 0
    for inputs, labels in train_loader:
        inputs, labels = inputs.to(device), labels.to(device)  # 确保在设备上
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        total_loss += loss.item()
    if (epoch + 1) % 20 == 0:
        print(f'Epoch [{epoch+1}/{epochs}], Loss: {total_loss/len(train_loader):.4f}')

# 10. 评估
model.eval()
with torch.no_grad():
    X_test_tensor = X_test_tensor.to(device)
    y_test_tensor = y_test_tensor.to(device)
    outputs = model(X_test_tensor)
    _, predicted = torch.max(outputs, 1)
    accuracy = (predicted == y_test_tensor).float().mean()
    print(f'Test Accuracy: {accuracy.item() * 100:.2f}%')
```

```py
# 手写字体识别
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms

# ----------------------------
# 1. 自动选择设备
# ----------------------------
def get_device():
    if torch.cuda.is_available():
        return torch.device('cuda')
    elif torch.backends.mps.is_available():  # Apple Silicon (M1/M2)
        return torch.device('mps')
    else:
        return torch.device('cpu')

device = get_device()
print(f"Using device: {device}")

# ----------------------------
# 2. 数据预处理与加载
# ----------------------------
transform = transforms.Compose([
    transforms.ToTensor(),  # 转为 [0,1] 的 tensor
    transforms.Normalize((0.1307,), (0.3081,))  # MNIST 的均值和标准差
])

# 下载训练集和测试集
train_dataset = datasets.MNIST(root='./data', train=True, download=True, transform=transform)
test_dataset = datasets.MNIST(root='./data', train=False, download=True, transform=transform)

train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=1000, shuffle=False)

# ----------------------------
# 3. 定义 CNN 模型
# ----------------------------
class MNISTNet(nn.Module):
    def __init__(self):
        super(MNISTNet, self).__init__()
        self.conv1 = nn.Conv2d(1, 32, kernel_size=3, stride=1, padding=1)
        self.conv2 = nn.Conv2d(32, 64, kernel_size=3, stride=1, padding=1)
        self.pool = nn.MaxPool2d(2, 2)
        self.fc1 = nn.Linear(64 * 7 * 7, 128)
        self.fc2 = nn.Linear(128, 10)
        self.relu = nn.ReLU()
        self.dropout = nn.Dropout(0.5)

    def forward(self, x):
        x = self.pool(self.relu(self.conv1(x)))  # [B, 32, 14, 14]
        x = self.pool(self.relu(self.conv2(x)))  # [B, 64, 7, 7]
        x = x.view(-1, 64 * 7 * 7)               # 展平
        x = self.relu(self.fc1(x))
        x = self.dropout(x)
        x = self.fc2(x)
        return x

model = MNISTNet().to(device)

# ----------------------------
# 4. 损失函数与优化器
# ----------------------------
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

# ----------------------------
# 5. 训练函数
# ----------------------------
def train(epoch):
    model.train()
    for batch_idx, (data, target) in enumerate(train_loader):
        data, target = data.to(device), target.to(device)
        optimizer.zero_grad()
        output = model(data)
        loss = criterion(output, target)
        loss.backward()
        optimizer.step()
        if batch_idx % 100 == 0:
            print(f'Train Epoch: {epoch} [{batch_idx * len(data)}/{len(train_loader.dataset)} '
                  f'({100. * batch_idx / len(train_loader):.0f}%)]\tLoss: {loss.item():.6f}')

# ----------------------------
# 6. 测试函数
# ----------------------------
def test():
    model.eval()
    test_loss = 0
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            output = model(data)
            test_loss += criterion(output, target).item()
            pred = output.argmax(dim=1, keepdim=True)
            correct += pred.eq(target.view_as(pred)).sum().item()

    test_loss /= len(test_loader)
    accuracy = 100. * correct / len(test_loader.dataset)
    print(f'\nTest set: Average loss: {test_loss:.4f}, Accuracy: {correct}/{len(test_loader.dataset)} ({accuracy:.2f}%)\n')
    return accuracy

# ----------------------------
# 7. 开始训练
# ----------------------------
epochs = 5
for epoch in range(1, epochs + 1):
    train(epoch)
    test()

print("🎉 训练完成！")
```

