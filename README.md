# Docker 自动安装脚本

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg )](https://opensource.org/licenses/MIT )
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green.svg )](https://www.gnu.org/software/bash/ )

一个智能的 Docker 和 Docker Compose 自动化安装脚本，支持多种国内镜像源和双模式安装。

## ✨ 功能特性

- **多镜像源支持**：官方源、阿里云、腾讯云、中科大、清华大学
- **双模式安装**：交互式菜单和命令行参数两种方式
- **智能权限检测**：自动识别 sudo 环境，无需手动切换
- **完整安装流程**：从卸载旧版本到验证安装的一站式解决方案
- **用户友好**：彩色输出、清晰的提示信息、别名支持

## 🚀 支持的镜像源

| 镜像源 | 命令行参数 | 别名 | 推荐度 |
|--------|------------|------|--------|
| 官方源 | `official` | `docker` | ⭐⭐ |
| 阿里云 | `aliyun` | `ali` | ⭐⭐⭐⭐⭐ |
| 腾讯云 | `tencent` | - | ⭐⭐⭐⭐ |
| 中科大 | `ustc` | - | ⭐⭐⭐⭐ |
| 清华大学 | `tsinghua` | `thu` | ⭐⭐⭐⭐ |

## 📋 系统要求

- **操作系统**：Debian、Ubuntu 及其衍生版本
- **架构**：支持 `amd64`、`arm64`、`armhf` 等主流架构
- **权限**：root 用户或具有 sudo 权限的用户
- **网络**：能够访问所选镜像源

## 🔧 快速开始

### 方式一：交互式安装（推荐新手）

```bash
# 下载脚本
wget https://raw.githubusercontent.com/cybaijie/docker-install-script/main/docker-install.sh 

# 赋予执行权限
chmod +x docker-install.sh

# 运行脚本
sudo ./docker-install.sh
```

运行后会出现镜像源选择菜单，输入数字即可开始安装。

### 方式二：命令行参数安装（推荐进阶用户）

```bash
# 阿里云镜像源（推荐）
sudo ./docker-install.sh aliyun

# 或使用中科大镜像源
sudo ./docker-install.sh ustc

# 使用别名
sudo ./docker-install.sh ali    # 阿里云
sudo ./docker-install.sh thu    # 清华大学
```

### 方式三：一键安装（无需保存脚本）

```bash
# 一键安装（默认交互模式）
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/cybaijie/docker-install-script/main/docker-install.sh)"

# 一键安装 + 指定镜像源（无交互）
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/cybaijie/docker-install-script/main/docker-install.sh)" bash aliyun
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/cybaijie/docker-install-script/main/docker-install.sh)" bash ustc
```

**特点**：脚本不保存到本地，直接执行，适合快速部署和临时使用。

## 📖 使用方法

### 命令行参数

```bash
sudo ./docker-install.sh [OPTIONS]

OPTIONS:
  official    使用官方 Docker 源
  aliyun      使用阿里云镜像源（推荐）
  tencent     使用腾讯云镜像源
  ustc        使用中科大镜像源
  tsinghua    使用清华大学镜像源
  -h, --help  显示帮助信息
```

### 安装示例

```bash
# 示例 1：使用阿里云镜像源快速安装
sudo ./docker-install.sh aliyun

# 示例 2：使用中科大镜像源
sudo ./docker-install.sh ustc

# 示例 3：查看帮助信息
./docker-install.sh --help
```

## 🔍 安装流程

1. **环境检测**：检查系统和用户权限
2. **源选择**：根据参数或交互选择镜像源
3. **清理旧版本**：卸载可能冲突的旧 Docker 版本
4. **安装依赖**：安装必要的系统包
5. **添加密钥**：添加 Docker 官方 GPG 密钥
6. **配置源**：写入对应的 apt 源列表
7. **安装 Docker**：安装 Docker CE 和 CLI
8. **安装 Compose**：安装最新版 Docker Compose
9. **用户配置**：可选地将当前用户加入 docker 组
10. **启动服务**：启动并设置 Docker 开机自启
11. **验证安装**：运行 hello-world 容器测试

## 💡 使用提示

安装完成后，你可以：

```bash
# 查看 Docker 版本
docker --version

# 查看 Docker Compose 版本
docker-compose --version

# 运行测试容器
docker run --rm hello-world

# 无需 sudo 使用 Docker（需注销重新登录）
docker ps
```

## ❓ 常见问题

### Q1: 脚本支持哪些 Linux 发行版？
**A**: 支持所有使用 `apt` 包管理器的 Debian/Ubuntu 系统及其衍生版本。

### Q2: 如何卸载 Docker？
**A**: 使用以下命令卸载：
```bash
sudo apt-get remove -y docker-ce docker-ce-cli containerd.io docker-compose
```

### Q3: 安装后为什么还需要 sudo？
**A**: 需要将用户添加到 docker 组并重新登录才能免 sudo 使用：
```bash
sudo usermod -aG docker $USER
# 然后注销并重新登录
```

### Q4: 如何切换镜像源？
**A**: 重新运行脚本选择不同的镜像源即可，脚本会自动处理配置更新。

### Q5: 提示 "curl: command not found" 怎么办？
**A**: 先安装 curl：
```bash
sudo apt-get update && sudo apt-get install -y curl
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发计划
- [ ] 支持更多 Linux 发行版（CentOS/RHEL）
- [ ] 添加 Docker 版本选择功能
- [ ] 支持离线安装模式
- [ ] 添加安装日志记录

## 📄 许可证

本项目基于 [MIT License](LICENSE) 开源。

## 🔗 相关链接

- [Docker 官方文档](https://docs.docker.com/ )
- [Docker Compose 文档](https://docs.docker.com/compose/ )
- [阿里云镜像站](https://developer.aliyun.com/mirror/ )
- [中科大镜像站](https://mirrors.ustc.edu.cn/ )
- [清华大学镜像站](https://mirrors.tuna.tsinghua.edu.cn/ )

---

<div align="center">
  ⭐ 如果这个项目对你有帮助，请给个 Star！
</div>

---

**免责声明**：本脚本仅供学习和自动化安装使用，使用前请务必备份重要数据。作者不对使用本脚本造成的任何损失负责。
