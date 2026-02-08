# WSL+ubuntu环境下的Tensorrt配置

> 参考网址：https://blog.csdn.net/qq_40102732/article/details/135182310
>
> 和参考的网址有一点出入，但是大差不差

## NVIDIA驱动安装

在WIN主机上直接使用NVIDIA APP安装即可，安装WSL的ubuntu之后，在Linxu使用`nvidia-smi`发现可以正常显示即可，WIN下面使用这个命令也是正常的。

![image-20260130182343093](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130182343093.png)

**要注意，驱动有支持的cuda的最高版本，后续安装cuda toolkit、cudnn、tensorrt、pytorch的版本号都要一致！！！**

## cuda安装

### 安装

由于驱动支持的最高cuda版本是12.9，而且pytorch支持12.8比较多，所以，下面我都以**cuda12.8**为基准。

**注意，WSL的cuda和普通的linux不一样，NVIDIA开发了专门的cuda驱动。**

点进对应cuda toolkit版本选择的网址:[CUDA Toolkit Archive | NVIDIA Developer](https://developer.nvidia.com/cuda-toolkit-archive)

![image-20260130182849350](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130182849350.png)

![image-20260130183138826](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130183138826.png)

按照我的框框来，不能选错了，下面的命令执行一遍即可，注意当前所在的文件夹，安装后会残余一个安装包。

```bash
wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb
sudo dpkg -i cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb
sudo cp /var/cuda-repo-wsl-ubuntu-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
sudo apt-get update
sudo apt-get -y install cuda-toolkit-12-8
```

### 验证

下面的文件夹会出现，说明cuda安装成功了。

![image-20260130183526182](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130183526182.png)

### 系统环境配置

```bash
# 直接在终端运行
sudo touch /etc/profile.d/cuda.sh
echo 'export PATH=/usr/local/cuda/bin/:$PATH' | sudo tee -a /etc/profile.d/cuda.sh
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64/:/usr/lib/wsl/lib/:$LD_LIBRARY_PATH' | sudo tee -a /etc/profile.d/cuda.sh

# 下面的追加到~/.bashrc这个文件里面，最后再source ~/.bashrc一下
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}	# 修改cuda版本为自己下载的
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}	# 修改cuda版本为自己下载的
export CUDA_HOME=/usr/local/cuda-12.8	# 修改cuda版本为自己下载的
```

### nvcc验证

终端输入`nvcc -V`，如果显示下面的样子则正常安装。

![image-20260130183916272](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130183916272.png)

## cudnn安装

### 安装

cudnn选择对应的tar包进行安装。进入到cudnn的官方下载网址:[Log in | NVIDIA Developer](https://developer.nvidia.com/rdp/cudnn-download)，勾选I agree，最新的版本已经到了9.18，但是按照原来的教程，我还是安装8.9版本的。

进入官网，划到最下面，选择往期版本。我选择8.9版本，可以看到其对cuda12.x版本都适配。

![image-20260130184512769](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130184512769.png)

![image-20260130184409726](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130184409726.png)

![image-20260130184550189](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130184550189.png)

将其放入一个特定文件夹下，我放入`/root/NVIDIA`下面。然后执行下面的命令。

```bash
tar -xvf cudnn-linux-x86_64-8.9.7.29_cuda12-archive.tar.xz	# 根据下载的包名自行修改
sudo cp cudnn-*-archive/include/cudnn*.h /usr/local/cuda/include
sudo cp -P cudnn-*-archive/lib/libcudnn* /usr/local/cuda/lib64 
sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*
```

### 验证

验证是否安装成功，输入如下命令，显示如下图即安装成功。

```bash
cat /usr/local/cuda/include/cudnn_version.h | grep CUDNN_MAJOR -A 2
```

![image-20260130185004806](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130185004806.png)

可以看到显示的版本是8.9，这个是cudnn的版本，与tar包显示一致，安装成功。

## TensorRT安装

TensorRT选择对应的tar包进行安装，进入到TensorRT官方下载网址[Log in | NVIDIA Developer](https://developer.nvidia.com/tensorrt/download)，点击勾选I agree。

可以看到最新版本已经到10了，这里我们安装的就是最新版本10.15。

![image-20260130185404071](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130185404071.png)

![image-20260130185512843](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130185512843.png)

![image-20260130185527927](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130185527927.png)

将下载的包复制到`/root/NVIDIA`文件夹下面，然后解压进行配置。

```bash
tar -xzvf TensorRT-10.15.1.29.Linux.x86_64-gnu.cuda-12.9.tar.gz
```

解压之后有如下的文件夹，其中python的文件夹里面有三种whl文件，如果你的py项目需要用到TensorRT，那么你还需要安装whl依赖，如果你的项目是cpp，那么把它解压好放这不动就行。（假装这里的tmp文件夹是NVIDIA文件夹）

![image-20260130185739696](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130185739696.png)

将TensorRT 下的lib绝对路径添加到系统环境中(根据自己的安装目录来)

```
# 通过nano ~/.bashrc把下面命令追加到启动脚本，实现将tensorrt的库加入系统环境变量，再source ~/.bashrc
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/NVIDIA/TensorRT-10.15.1.29/lib
```

###  解压后的目录结构

TensorRT 解压后的目录结构是标准的 SDK 布局，各目录作用如下：

| 目录           | 作用                                                         | 重要性            |
| -------------- | ------------------------------------------------------------ | ----------------- |
| **`bin/`**     | 命令行工具目录，包含 `trtexec` 等实用程序。`trtexec` 可直接加载 ONNX/UFF 模型进行推理测试，无需编写代码 [[4]] | ⭐ 常用工具        |
| **`doc/`**     | 官方文档，包含 API 参考、开发指南、发行说明等 PDF/HTML 格式文档 | 📚 参考资料        |
| **`include/`** | C++ 头文件（`.h`），用于 C++ 开发时 `#include <NvInfer.h>` 等。编译 C++ 项目时需指定此路径为 `-I` 参数 | ⚙️ C++ 开发必需    |
| **`lib/`**     | **核心共享库目录**，包含 `libnvinfer.so`、`libnvinfer_plugin.so` 等 TensorRT 运行时库。Python/C++ 程序运行时需通过 `LD_LIBRARY_PATH` 加载此目录 [[5]] | ⚠️ **运行时必需**  |
| **`python/`**  | Python wheel 包（`.whl`），包含 `tensorrt`、`tensorrt_lean`、`tensorrt_dispatch` 三个组件，用于 Python API 调用 | 🐍 Python 开发必需 |
| **`targets/`** | **多架构支持目录**，包含不同硬件平台的库文件（如 `x86_64-linux-gnu`、`aarch64-linux-gnu` 等）。在交叉编译或嵌入式开发（如 Jetson）时使用 [[22]] | 🎯 特定场景需要    |

**关键使用说明**

1. **运行时依赖**  
   即使通过 pip/pixi 安装了 Python wheel，**仍需将 `lib/` 目录加入系统库路径**，否则会报 `libnvinfer.so: cannot open shared object file` 错误：
   
   ```bash
   export LD_LIBRARY_PATH=/path/to/TensorRT-10.15.1.29/lib:$LD_LIBRARY_PATH
   ```
   
2. **C++ 开发配置**  
   编译 C++ 项目时需指定：
   ```bash
   -I/path/to/TensorRT/include    # 头文件路径
   -L/path/to/TensorRT/lib        # 库文件路径
   -lnvinfer -lnvinfer_plugin     # 链接库
   ```

3. **`targets/` 目录的特殊性**  
   - 在 x86_64 服务器/PC 上，通常直接使用根目录的 `lib/` 和 `include/`
   - 在 Jetson 等 ARM 设备上，可能需要从 `targets/aarch64-linux-gnu/` 复制对应文件到系统路径

4. **完整部署建议**  
   生产环境中建议将 `lib/` 下的 `.so` 文件复制到系统库目录（如 `/usr/local/lib`），并将 `include/` 头文件复制到 `/usr/local/include`，然后运行 `ldconfig` 刷新缓存。

### cpp环境安装

略

### py环境安装

TensorRT解压之后是下面的文件。其中cp311是py版本号，你的py环境是什么就安装哪一个。

![image-20260130190422297](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130190422297.png)

#### pip或其他conda环境（未测试）

使用pip命令即可安装。

```bash
cd python
pip install tensorrt-10.15.1.29-cp311-none-linux_x86_64.whl
pip install tensorrt_dispatch-10.15.1.29-cp311-none-linux_x86_64.whl
pip install tensorrt_lean-10.15.1.29-cp311-none-linux_x86_64.whl
```

之后，这个环境就可以使用TensorRT了。

#### pixi环境

需要参考下面的命令来进行安装。

```bash
cd ~/NVIDIA/TensorRT-10.15.1.29/python
# 安装 lean
pixi add --pypi "tensorrt_lean @ file://$(pwd)/tensorrt_lean-10.15.1.29-cp311-none-linux_x86_64.whl"
# 安装 dispatch
pixi add --pypi "tensorrt_dispatch @ file://$(pwd)/tensorrt_dispatch-10.15.1.29-cp311-none-linux_x86_64.whl"
# 安装主包
pixi add --pypi "tensorrt @ file://$(pwd)/tensorrt-10.15.1.29-cp311-none-linux_x86_64.whl"
```

### cpp执行测试

test_tensorrt.cpp代码如下：

```cpp
#include <iostream>
#include <NvInfer.h>
#include <NvInferRuntime.h>
#include <cuda_runtime.h>

// TensorRT Logger
class Logger : public nvinfer1::ILogger {
public:
    void log(Severity severity, const char* msg) noexcept override {
        if (severity <= Severity::kWARNING) {
            std::cout << "[TensorRT] " << msg << std::endl;
        }
    }
};

int main() {
    std::cout << "========== TensorRT 10 验证测试 ==========" << std::endl;
    
    // 1. 打印版本信息
    std::cout << "\n[1] 版本信息:" << std::endl;
    std::cout << "  TensorRT 版本: " << NV_TENSORRT_MAJOR << "." 
              << NV_TENSORRT_MINOR << "." 
              << NV_TENSORRT_PATCH << std::endl;
    
    // 检查 CUDA
    int cudaVersion;
    cudaRuntimeGetVersion(&cudaVersion);
    std::cout << "  CUDA Runtime 版本: " << cudaVersion / 1000 << "." 
              << (cudaVersion % 1000) / 10 << std::endl;
    
    // 检查 GPU
    int deviceCount;
    cudaGetDeviceCount(&deviceCount);
    std::cout << "  可用 GPU 数量: " << deviceCount << std::endl;
    
    if (deviceCount > 0) {
        cudaDeviceProp prop;
        cudaGetDeviceProperties(&prop, 0);
        std::cout << "  GPU 0: " << prop.name << std::endl;
    }
    
    // 2. 创建 Builder
    std::cout << "\n[2] 创建 TensorRT Builder..." << std::endl;
    Logger logger;
    nvinfer1::IBuilder* builder = nvinfer1::createInferBuilder(logger);
    if (!builder) {
        std::cerr << "❌ 创建 Builder 失败!" << std::endl;
        return -1;
    }
    std::cout << "  ✅ Builder 创建成功" << std::endl;
    
    // 3. 创建网络定义 (TensorRT 10.x 新方式 - 不需要 flags)
    std::cout << "\n[3] 创建网络定义..." << std::endl;
    nvinfer1::INetworkDefinition* network = builder->createNetworkV2(0);
    if (!network) {
        std::cerr << "❌ 创建网络失败!" << std::endl;
        return -1;
    }
    std::cout << "  ✅ 网络定义创建成功" << std::endl;
    
    // 4. 添加简单的输入层
    std::cout << "\n[4] 添加网络层..." << std::endl;
    nvinfer1::ITensor* input = network->addInput(
        "input", nvinfer1::DataType::kFLOAT, nvinfer1::Dims4{1, 3, 224, 224});
    if (!input) {
        std::cerr << "❌ 添加输入失败!" << std::endl;
        return -1;
    }
    std::cout << "  ✅ 输入层添加成功: [1, 3, 224, 224]" << std::endl;
    
    // 5. 添加 Identity 层 (简单测试)
    nvinfer1::IIdentityLayer* identity = network->addIdentity(*input);
    if (!identity) {
        std::cerr << "❌ 添加 Identity 层失败!" << std::endl;
        return -1;
    }
    identity->getOutput(0)->setName("output");
    network->markOutput(*identity->getOutput(0));
    std::cout << "  ✅ Identity 层添加成功" << std::endl;
    
    // 6. 创建构建配置
    std::cout << "\n[5] 创建构建配置..." << std::endl;
    nvinfer1::IBuilderConfig* config = builder->createBuilderConfig();
    if (!config) {
        std::cerr << "❌ 创建配置失败!" << std::endl;
        return -1;
    }
    
    // 设置内存池限制
    config->setMemoryPoolLimit(nvinfer1::MemoryPoolType::kWORKSPACE, 1ULL << 30);
    std::cout << "  ✅ 配置创建成功 (工作空间: 1GB)" << std::endl;
    
    // 7. 构建引擎
    std::cout << "\n[6] 构建序列化引擎..." << std::endl;
    nvinfer1::IHostMemory* serializedEngine = builder->buildSerializedNetwork(*network, *config);
    if (!serializedEngine) {
        std::cerr << "❌ 构建引擎失败!" << std::endl;
        return -1;
    }
    std::cout << "  ✅ 引擎构建成功! 大小: " << serializedEngine->size() << " bytes" << std::endl;
    
    // 8. 创建运行时并反序列化
    std::cout << "\n[7] 创建运行时..." << std::endl;
    nvinfer1::IRuntime* runtime = nvinfer1::createInferRuntime(logger);
    if (!runtime) {
        std::cerr << "❌ 创建运行时失败!" << std::endl;
        return -1;
    }
    
    nvinfer1::ICudaEngine* engine = runtime->deserializeCudaEngine(
        serializedEngine->data(), serializedEngine->size());
    if (!engine) {
        std::cerr << "❌ 反序列化引擎失败!" << std::endl;
        return -1;
    }
    std::cout << "  ✅ 引擎反序列化成功" << std::endl;
    
    // 9. 创建执行上下文
    std::cout << "\n[8] 创建执行上下文..." << std::endl;
    nvinfer1::IExecutionContext* context = engine->createExecutionContext();
    if (!context) {
        std::cerr << "❌ 创建上下文失败!" << std::endl;
        return -1;
    }
    std::cout << "  ✅ 执行上下文创建成功" << std::endl;
    
    // 10. 打印绑定信息 (TensorRT 10 新 API)
    std::cout << "\n[9] 绑定信息:" << std::endl;
    int numIOTensors = engine->getNbIOTensors();
    for (int i = 0; i < numIOTensors; i++) {
        const char* name = engine->getIOTensorName(i);
        nvinfer1::TensorIOMode mode = engine->getTensorIOMode(name);
        nvinfer1::Dims dims = engine->getTensorShape(name);
        
        std::cout << "  [" << i << "] " << name 
                  << " (" << (mode == nvinfer1::TensorIOMode::kINPUT ? "INPUT" : "OUTPUT") << ")"
                  << " 形状: [";
        for (int j = 0; j < dims.nbDims; j++) {
            std::cout << dims.d[j];
            if (j < dims.nbDims - 1) std::cout << ", ";
        }
        std::cout << "]" << std::endl;
    }
    
    // 11. 简单推理测试
    std::cout << "\n[10] 执行推理测试..." << std::endl;
    
    // 分配 GPU 内存
    float* d_input;
    float* d_output;
    size_t inputSize = 1 * 3 * 224 * 224 * sizeof(float);
    size_t outputSize = 1 * 3 * 224 * 224 * sizeof(float);
    
    cudaMalloc(&d_input, inputSize);
    cudaMalloc(&d_output, outputSize);
    
    // 设置输入输出地址 (TensorRT 10 新 API)
    context->setTensorAddress("input", d_input);
    context->setTensorAddress("output", d_output);
    
    // 创建 CUDA 流
    cudaStream_t stream;
    cudaStreamCreate(&stream);
    
    // 执行推理
    bool status = context->enqueueV3(stream);
    cudaStreamSynchronize(stream);
    
    if (status) {
        std::cout << "  ✅ 推理执行成功!" << std::endl;
    } else {
        std::cerr << "  ❌ 推理执行失败!" << std::endl;
    }
    
    // 清理 CUDA 资源
    cudaFree(d_input);
    cudaFree(d_output);
    cudaStreamDestroy(stream);
    
    // 清理 TensorRT 资源
    std::cout << "\n[11] 清理资源..." << std::endl;
    delete context;
    delete engine;
    delete runtime;
    delete serializedEngine;
    delete config;
    delete network;
    delete builder;
    
    std::cout << "\n========================================" << std::endl;
    std::cout << "✅ TensorRT 10 C++ 验证完成!" << std::endl;
    std::cout << "========================================" << std::endl;
    
    return 0;
}

```

CMakeLists.txt内容如下：

```cmake
cmake_minimum_required(VERSION 3.18)
project(tensorrt10_test LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置 TensorRT 路径
set(TENSORRT_ROOT "/root/NVIDIA/TensorRT-10.15.1.29" CACHE PATH "TensorRT root")

# 查找 CUDA Toolkit (正确方式)
find_package(CUDAToolkit REQUIRED)

# 打印调试信息
message(STATUS "CUDA Toolkit 版本: ${CUDAToolkit_VERSION}")
message(STATUS "CUDA 库路径: ${CUDAToolkit_LIBRARY_DIR}")
message(STATUS "TensorRT 路径: ${TENSORRT_ROOT}")

# 头文件路径
include_directories(
    ${CUDAToolkit_INCLUDE_DIRS}
    ${TENSORRT_ROOT}/include
)

# TensorRT 库路径
link_directories(
    ${TENSORRT_ROOT}/lib
)

# 创建可执行文件
add_executable(test_tensorrt test_tensorrt.cpp)

# 链接库
target_link_libraries(test_tensorrt
    nvinfer
    CUDA::cudart
)

```

编译命令如下：

```bash
# 清理旧的构建
cd /root/NVIDIA/test/cppTest
rm -rf build
mkdir build && cd build
# 重新配置
cmake .. -DTENSORRT_ROOT=/root/NVIDIA/TensorRT-10.15.1.29
# 编译
make -j$(nproc)
# 运行
./test_tensorrt
```

正常运行结果如下：

![image-20260130191555276](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130191555276.png)

### py执行测试

```bash
# 下载测试用 ONNX 模型（以 ResNet50 为例）
wget https://github.com/onnx/models/raw/main/vision/classification/resnet/model/resnet50-v2-7.onnx -O /tmp/resnet50.onnx
```

testTRT.py代码如下：

```python
#!/usr/bin/env python3
"""
TensorRT 10 安装验证脚本
测试模型: /tmp/resnet50.onnx
"""

import sys
import numpy as np

def check_tensorrt():
    """检查TensorRT安装"""
    print("=" * 50)
    print("TensorRT 10 安装验证")
    print("=" * 50)
    
    # 1. 导入检查
    print("\n[1/5] 检查TensorRT导入...")
    try:
        import tensorrt as trt
        print(f"  ✓ TensorRT 导入成功")
        print(f"  ✓ TensorRT 版本: {trt.__version__}")
    except ImportError as e:
        print(f"  ✗ TensorRT 导入失败: {e}")
        return False
    
    # 2. 检查CUDA
    print("\n[2/5] 检查CUDA支持...")
    try:
        import pycuda.driver as cuda
        import pycuda.autoinit
        print(f"  ✓ PyCUDA 可用")
        print(f"  ✓ CUDA 设备: {cuda.Device(0).name()}")
    except Exception as e:
        print(f"  ! PyCUDA 不可用 (可选): {e}")
    
    # 3. 创建Logger和Builder
    print("\n[3/5] 创建TensorRT组件...")
    try:
        logger = trt.Logger(trt.Logger.WARNING)
        builder = trt.Builder(logger)
        print(f"  ✓ Logger 创建成功")
        print(f"  ✓ Builder 创建成功")
        print(f"  ✓ 最大线程数: {builder.max_threads}")
    except Exception as e:
        print(f"  ✗ 组件创建失败: {e}")
        return False
    
    # 4. 解析ONNX模型
    print("\n[4/5] 解析ONNX模型...")
    onnx_path = "/tmp/resnet50.onnx"
    
    try:
        network = builder.create_network(
            1 << int(trt.NetworkDefinitionCreationFlag.EXPLICIT_BATCH)
        )
        parser = trt.OnnxParser(network, logger)
        
        with open(onnx_path, 'rb') as f:
            if not parser.parse(f.read()):
                print(f"  ✗ ONNX解析失败:")
                for i in range(parser.num_errors):
                    print(f"    - {parser.get_error(i)}")
                return False
        
        print(f"  ✓ ONNX模型解析成功: {onnx_path}")
        print(f"  ✓ 网络输入数: {network.num_inputs}")
        print(f"  ✓ 网络输出数: {network.num_outputs}")
        
        for i in range(network.num_inputs):
            inp = network.get_input(i)
            print(f"    输入[{i}]: {inp.name}, shape={inp.shape}, dtype={inp.dtype}")
        for i in range(network.num_outputs):
            out = network.get_output(i)
            print(f"    输出[{i}]: {out.name}, shape={out.shape}, dtype={out.dtype}")
            
    except FileNotFoundError:
        print(f"  ✗ 模型文件不存在: {onnx_path}")
        return False
    except Exception as e:
        print(f"  ✗ 模型解析失败: {e}")
        return False
    
    # 5. 构建引擎
    print("\n[5/5] 构建TensorRT引擎...")
    try:
        config = builder.create_builder_config()
        config.set_memory_pool_limit(trt.MemoryPoolType.WORKSPACE, 1 << 30)
        
        # 添加优化配置文件处理动态维度
        profile = builder.create_optimization_profile()
        
        for i in range(network.num_inputs):
            inp = network.get_input(i)
            inp_name = inp.name
            inp_shape = inp.shape
            
            if -1 in inp_shape:
                print(f"  - 检测到动态输入: {inp_name}, shape={inp_shape}")
                
                min_shape = tuple(1 if d == -1 else d for d in inp_shape)
                opt_shape = tuple(4 if d == -1 else d for d in inp_shape)
                max_shape = tuple(16 if d == -1 else d for d in inp_shape)
                
                print(f"    min_shape: {min_shape}")
                print(f"    opt_shape: {opt_shape}")
                print(f"    max_shape: {max_shape}")
                
                profile.set_shape(inp_name, min_shape, opt_shape, max_shape)
        
        config.add_optimization_profile(profile)
        
        if builder.platform_has_fast_fp16:
            print(f"  ✓ 平台支持FP16加速")
        
        print(f"  - 正在构建引擎 (可能需要几分钟)...")
        
        serialized_engine = builder.build_serialized_network(network, config)
        
        if serialized_engine is None:
            print(f"  ✗ 引擎构建失败")
            return False
        
        # ============== 修复: 使用 .nbytes 而不是 len() ==============
        engine_size = serialized_engine.nbytes
        print(f"  ✓ 引擎构建成功")
        print(f"  ✓ 序列化引擎大小: {engine_size / 1024 / 1024:.2f} MB")
        
        # 反序列化测试
        runtime = trt.Runtime(logger)
        engine = runtime.deserialize_cuda_engine(serialized_engine)
        
        if engine is None:
            print(f"  ✗ 引擎反序列化失败")
            return False
            
        print(f"  ✓ 引擎反序列化成功")
        print(f"  ✓ 引擎层数: {engine.num_layers}")
        
        # 可选: 保存引擎到文件
        # with open("/tmp/resnet50.engine", "wb") as f:
        #     f.write(serialized_engine)
        # print(f"  ✓ 引擎已保存到: /tmp/resnet50.engine")
        
    except Exception as e:
        print(f"  ✗ 引擎构建失败: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    # 完成
    print("\n" + "=" * 50)
    print("✓ TensorRT 10 安装验证通过!")
    print("=" * 50)
    return True


if __name__ == "__main__":
    success = check_tensorrt()
    sys.exit(0 if success else 1)

```

正确执行结果如下：

![image-20260130191943495](./WSL+ubuntu%E7%8E%AF%E5%A2%83%E4%B8%8B%E7%9A%84Tensorrt%E9%85%8D%E7%BD%AE.assets/image-20260130191943495.png)

## 卸载（全都未测试）

### cuda卸载

```bash
sudo apt-get --purge remove "*cuda*" "*cublas*" "*cufft*" "*cufile*" "*curand*" \
 "*cusolver*" "*cusparse*" "*gds-tools*" "*npp*" "*nvjpeg*" "nsight*" 
sudo apt-get autoremove
```

### cudnn卸载

```bash
sudo apt-get purge libcudnn8
sudo apt-get purge libcudnn8-dev
 
# or
sudo apt-get --purge remove "*cublas*" "*cufft*" "*curand*" "*cusolver*" "*cusparse*" "*npp*" "*nvjpeg*" "cuda*" "nsight*" 
 
cd /usr/local/cuda-xx.x/bin/
sudo ./cuda-uninstaller
sudo rm -rf /usr/local/cuda-xx.x
 
# 若安装了cuda只是想卸载cudnn, (xx.x为安装的cuda版本)
sudo rm /usr/local/cuda-xx.x/include/cudnn*
sudo rm /usr/local/cuda-xx.x/lib64/libcudnn*
```

### TensorRT卸载

```bash
#（因为有可能下载python对用的tensorrt，所以会有pip的卸载)
sudo apt-get purge "libnvinfer*"
sudo apt-get purge "nv-tensorrt-repo*"
sudo apt-get purge graphsurgeon-tf onnx-graphsurgeon
pip3 uninstall tensorrt
pip3 uninstall uff
pip3 uninstall graphsurgeon
pip3 uninstall onnx-graphsurgeon
python3 -m pip uninstall nvidia-tensorrt
```

