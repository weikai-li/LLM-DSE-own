# 新用户快速设置指南

## 项目运行逻辑说明

**这个项目是做什么的？**

简单说就是：用 AI（LLM）来自动优化芯片设计。AI 会生成各种优化参数（比如并行度、流水线配置等），然后实际编译测试这些设计，看哪个效果最好，不断迭代优化。

**为什么需要这么复杂的设置？**

问题出在工具链上。这个项目需要用到两个工具，但它们用的 Python 版本不一样：

1. **Merlin Compiler**：用来编译和测试芯片设计的工具。但它很老，只能用 Python 2.7（Python 2 在 2020 年就停止维护了）。

2. **你的主程序**：用 Python 3 写的，负责调用 AI、分析结果、生成新的优化策略。

这两个工具不能放在同一个 Python 环境里（会冲突），所以需要隔离。解决方案是用 Docker 容器：把 Merlin 和它的 Python 2.7 环境打包在容器里，你的 Python 3 程序也在容器内运行，但用不同的 Python 版本，通过文件系统共享数据。

但是，在服务器上通常没有 root 权限，不能直接运行 Docker。所以用 **Apptainer**（不需要 root 权限），它可以直接运行 Docker 镜像。

**重要提示**：Docker 镜像 `ghcr.io/ucla-vast/hls-vast-lab:latest` 已经在服务器上安装，可以共享使用，你不需要自己下载。

**⚠️ 重要：配置路径**：在运行前，**必须**修改 `merlin.sh` 和 `setup.sh` 中的路径，否则无法运行！
- `merlin.sh`：修改 bind mount 路径，将 `/data/jx4237data` 改为你的项目路径
- `setup.sh`：修改 `VENV_DIR` 和 `WORK_DIR` 为你的实际路径

**具体怎么运行的？**

当你运行 `source ./merlin.sh` 时：
- Apptainer 启动一个容器（里面装着 Merlin 和 Python 2.7）
- 容器可以访问你本地的文件：
  - `/data/xilinx` → Vitis HLS（用来做最终编译）
  - 你的项目目录 → 你的代码
- 在容器内运行 `source ./setup.sh`，设置好环境：
  - `python` → Python 2.7（给 Merlin 用）
  - `python3` → Python 3（给你的代码用）

然后你运行 `python3 main.py`，整个流程是：
1. Python 3 程序调用 AI 生成优化参数
2. 调用 Merlin（用 Python 2.7）编译代码
3. Merlin 调用 Vitis HLS 做最终编译
4. 读取结果，再调用 AI 继续优化

**简单总结**：容器里装着 Merlin（Python 2.7），你在容器里运行 Python 3 程序，它们通过文件系统互相配合。

## 关键文件说明

### `merlin.sh` - 启动容器
- **作用**：用 Apptainer 运行 Docker 镜像（包含 Merlin 编译器）
- **需要修改**：bind mount 路径中的项目目录路径
- **关键路径**：
  - `xilinx_path=/data/xilinx` - Vitis HLS 路径（共享，通常不需要改）
  - `imagename="docker://ghcr.io/ucla-vast/hls-vast-lab:latest"` - Docker 镜像（共享）
- **不需要 sudo**：Apptainer 不需要 root 权限

### `setup.sh` - 容器内环境配置
- **作用**：在容器内设置 Python 路径和工具路径
- **需要修改**：`VENV_DIR` 和 `WORK_DIR` 路径
- **关键路径**：
  - `VENV_DIR` - 虚拟环境路径（必须配置）
  - `WORK_DIR` - 工作目录（必须配置）

## 新用户步骤

1. **修改路径配置**

   如果你的项目在不同位置（例如 `/data/hw5432/LLM-DSE-own`），需要修改：

   **`merlin.sh` 第 20 行**（需要修改**两处**）：
   ```bash
   # 原配置
   apptainer exec ... --bind /data/jx4237data:/data/jx4237data "$imagename" bash -c "cd /data/jx4237data/LLM-DSE-own && /bin/bash"
   
   # 修改为（假设你的项目在 /data/hw5432/LLM-DSE-own）
   apptainer exec ... --bind /data/hw5432:/data/hw5432 "$imagename" bash -c "cd /data/hw5432/LLM-DSE-own && /bin/bash"
   ```
   **注意**：bind mount 的两边路径都要改（格式：`主机路径:容器内路径`），且 `cd` 后面的路径也要改。

   **`setup.sh` 第 14 行**（虚拟环境路径）：
   ```bash
   # 原配置
   VENV_DIR="/data/jx4237data/LLM-DSE-own/.venv"
   
   # 修改为（根据你的虚拟环境位置）
   VENV_DIR="/data/你的路径/LLM-DSE-own/.venv"  # 如果在项目目录下
   # 或者
   VENV_DIR="$HOME/.venv-llm-dse"  # 如果在 home 目录下（需要确保 /home 被 bind mount）
   ```
   **⚠️ 重要**：虚拟环境路径必须在 bind mount 的路径内，否则容器内访问不到！

   **`setup.sh` 第 40 行**（工作目录）：
   ```bash
   # 原配置
   export WORK_DIR=/data/jx4237data/LLM-DSE-own/work
   
   # 修改为
   export WORK_DIR=/data/你的路径/LLM-DSE-own/work
   ```

   **不需要修改**（共享资源）：
   - Vitis HLS 路径（`/data/xilinx`）- 所有用户共享
   - Docker 镜像名称 ghcr.io/ucla-vast/hls-vast-lab:latest - 所有用户共享

2. **创建虚拟环境**
   ```bash
   python3 -m venv ~/.venv-llm-dse  # 或项目目录下的 .venv
   source ~/.venv-llm-dse/bin/activate
   pip install -r requirements.txt
   ```

3. **创建 `.env` 文件**
   ```bash
   cp .env_example .env
   # 填入你的 OpenAI API key
   ```

4. **首次运行**（自动下载镜像，约 19GB，需要 10-30 分钟）
   ```bash
   source ./merlin.sh
   # 等待进入容器（提示符变为 Apptainer>）
   # 在容器内运行：
   source ./setup.sh
   # 验证环境：
   python --version    # 应该显示 Python 2.7.18
   python3 --version   # 应该显示 Python 3.x
   python3 -c "import tiktoken; print('OK')"  # 测试依赖是否正常
   ```
   **⚠️ 重要**：`setup.sh` 必须在**容器内**运行，不是在容器外！

