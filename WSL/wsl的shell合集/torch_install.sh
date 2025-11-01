#!/bin/bash

# 我将创建一个文件夹~/pyRepo/torchTest/
# 这个文件夹是torch的测试项目，使用pixi环境


set -euo pipefail  # 严格错误处理：遇到错误立即退出，未定义变量报错，管道错误传播

# 配置
PROJECT_DIR="$HOME/pyRepo/torchTest"

echo "🚀 正在设置 PyTorch 测试项目..."

# 创建项目目录（如果不存在）
mkdir -p "$PROJECT_DIR"

# 检查是否已在项目目录中，避免重复初始化
if [[ ! -f "$PROJECT_DIR/pixi.toml" ]]; then
    echo "📁 初始化 Pixi 项目..."
    cd "$PROJECT_DIR"
    pixi init
else
    echo "ℹ️  检测到已有 Pixi 项目，跳过初始化..."
    cd "$PROJECT_DIR"
fi

# 安装 Conda 包
echo "📦 安装 Conda 依赖 (numpy, matplotlib)..."
pixi add numpy matplotlib scikit-learn

# 安装 PyPI 包
echo "📦 安装 PyPI 依赖 (torch, torchvision)..."
pixi add --pypi torch torchvision

# 添加测试文件1
cat > ~/pyRepo/torchTest/iris_classify.py << 'EOF'
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
EOF


# 添加测试文件2
cat > ~/pyRepo/torchTest/mnist_classify.py << 'EOF'
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
EOF


echo "✅ 项目设置完成！"
echo "💡 使用以下命令激活环境并开始工作："
echo "   cd $PROJECT_DIR"
echo "   pixi shell"
