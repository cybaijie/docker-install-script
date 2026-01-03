#!/bin/bash

# Docker 安装脚本（支持 Debian/Ubuntu）
# 提供官方源、阿里云、腾讯云、中科大、清华大学五种选择
# 支持交互式选择和命令行参数两种方式

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 帮助信息
show_help() {
    echo -e "${BLUE}Docker 安装脚本 - 使用说明${NC}"
    echo ""
    echo -e "${GREEN}交互式安装:${NC}"
    echo "  sudo $0"
    echo ""
    echo -e "${GREEN}命令行参数安装:${NC}"
    echo "  sudo $0 [镜像源缩写]"
    echo ""
    echo -e "${GREEN}支持的镜像源缩写:${NC}"
    echo "  official  - 官方源 (docker)"
    echo "  aliyun    - 阿里云 (ali)"
    echo "  tencent   - 腾讯云"
    echo "  ustc      - 中科大"
    echo "  tsinghua  - 清华大学 (thu)"
    echo ""
    echo -e "${GREEN}示例:${NC}"
    echo "  sudo $0 aliyun"
    echo "  sudo $0 tencent"
    echo "  sudo $0 ustc"
}

# 智能权限检测
if [ "$EUID" -ne 0 ]; then 
    if command -v sudo &> /dev/null; then
        echo -e "${YELLOW}检测到当前用户非 root，将使用 sudo 重新执行脚本...${NC}"
        exec sudo "$0" "$@"
    else
        echo -e "${RED}错误：请使用 root 用户运行此脚本（当前系统未安装 sudo）${NC}"
        exit 1
    fi
fi

# 检查系统是否为 Debian/Ubuntu
if ! command -v lsb_release &> /dev/null; then
    echo -e "${YELLOW}正在安装 lsb-release...${NC}"
    apt-get update && apt-get install -y lsb-release
fi

# 获取系统版本
DEBIAN_VERSION=$(lsb_release -cs)
echo -e "${GREEN}检测到系统版本: $DEBIAN_VERSION${NC}"

# 镜像源配置
declare -A MIRROR_NAMES=(
    ["official"]="官方源"
    ["aliyun"]="阿里云"
    ["tencent"]="腾讯云"
    ["ustc"]="中科大"
    ["tsinghua"]="清华大学"
)

declare -A GPG_URLS=(
    ["official"]="https://download.docker.com/linux/debian/gpg"
    ["aliyun"]="https://mirrors.aliyun.com/docker-ce/linux/debian/gpg"
    ["tencent"]="https://mirrors.cloud.tencent.com/docker-ce/linux/debian/gpg"
    ["ustc"]="https://mirrors.ustc.edu.cn/docker-ce/linux/debian/gpg"
    ["tsinghua"]="https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian/gpg"
)

declare -A REPO_URLS=(
    ["official"]="https://download.docker.com/linux/debian"
    ["aliyun"]="https://mirrors.aliyun.com/docker-ce/linux/debian"
    ["tencent"]="https://mirrors.cloud.tencent.com/docker-ce/linux/debian"
    ["ustc"]="https://mirrors.ustc.edu.cn/docker-ce/linux/debian"
    ["tsinghua"]="https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian"
)

# 解析命令行参数
SELECTED_MIRROR=""
if [ $# -eq 1 ]; then
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        official|docker)
            SELECTED_MIRROR="official"
            ;;
        aliyun|ali)
            SELECTED_MIRROR="aliyun"
            ;;
        tencent)
            SELECTED_MIRROR="tencent"
            ;;
        ustc)
            SELECTED_MIRROR="ustc"
            ;;
        tsinghua|thu)
            SELECTED_MIRROR="tsinghua"
            ;;
        *)
            echo -e "${RED}错误：未知的镜像源 '$1'${NC}"
            echo -e "${YELLOW}运行 '$0 --help' 查看支持的镜像源${NC}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}通过命令行参数选择: ${MIRROR_NAMES[$SELECTED_MIRROR]}${NC}"
elif [ $# -gt 1 ]; then
    echo -e "${RED}错误：参数过多${NC}"
    echo -e "${YELLOW}运行 '$0 --help' 查看使用说明${NC}"
    exit 1
fi

# 交互式选择（当没有命令行参数时）
if [ -z "$SELECTED_MIRROR" ]; then
    echo -e "\n${YELLOW}请选择 Docker 镜像源：${NC}"
    echo "1) 官方源 (official) - 不推荐，可能较慢"
    echo "2) 阿里云 (aliyun) - 推荐"
    echo "3) 腾讯云 (tencent)"
    echo "4) 中科大 (ustc)"
    echo "5) 清华大学 (tsinghua)"
    read -p "请输入选项 (1-5): " choice

    case $choice in
        1) SELECTED_MIRROR="official" ;;
        2) SELECTED_MIRROR="aliyun" ;;
        3) SELECTED_MIRROR="tencent" ;;
        4) SELECTED_MIRROR="ustc" ;;
        5) SELECTED_MIRROR="tsinghua" ;;
        *)
            echo -e "${RED}无效选项，退出脚本${NC}"
            exit 1
            ;;
    esac
fi

# 输出选择的镜像源
echo -e "\n${GREEN}使用镜像源: ${MIRROR_NAMES[$SELECTED_MIRROR]}${NC}"

# 获取对应的URL
GPG_URL="${GPG_URLS[$SELECTED_MIRROR]}"
REPO_URL="${REPO_URLS[$SELECTED_MIRROR]}"

# 卸载旧版本 Docker（如果存在）
echo -e "\n${YELLOW}正在卸载旧版本 Docker...${NC}"
apt-get remove -y docker.io docker-doc docker-compose podman-docker containerd runc 2>/dev/null || true

# 安装必要的依赖包
echo -e "\n${YELLOW}正在安装依赖包...${NC}"
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 添加 Docker GPG 密钥
echo -e "\n${YELLOW}正在添加 Docker GPG 密钥...${NC}"
mkdir -p /usr/share/keyrings
if ! curl -fsSL "$GPG_URL" | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg; then
    echo -e "${RED}添加 GPG 密钥失败，请检查网络连接${NC}"
    exit 1
fi

# 添加 Docker 软件源
echo -e "\n${YELLOW}正在添加 Docker 软件源...${NC}"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] $REPO_URL $DEBIAN_VERSION stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新软件包列表
echo -e "\n${YELLOW}正在更新软件包列表...${NC}"
apt-get update

# 安装 Docker
echo -e "\n${YELLOW}正在安装 Docker...${NC}"
apt-get install -y docker-ce docker-ce-cli containerd.io

# 安装 Docker Compose
echo -e "\n${YELLOW}正在安装 Docker Compose...${NC}"
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest  | grep 'tag_name' | cut -d '"' -f 4)
curl -L "https://github.com/docker/compose/releases/download/ ${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 获取当前用户（智能检测）
CURRENT_USER=""
if [ -n "$SUDO_USER" ]; then
    CURRENT_USER="$SUDO_USER"
elif [ -n "$LOGNAME" ]; then
    CURRENT_USER="$LOGNAME"
fi

# 将当前用户添加到 docker 组（可选）
if [ -n "$CURRENT_USER" ] && id "$CURRENT_USER" &>/dev/null; then
    echo -e "\n${YELLOW}是否将用户 $CURRENT_USER 添加到 docker 组？(y/n)${NC}"
    read -p "选择: " add_user
    if [ "$add_user" = "y" ]; then
        /usr/sbin/usermod -aG docker "$CURRENT_USER"
        echo -e "${GREEN}用户 $CURRENT_USER 已添加到 docker 组${NC}"
        echo -e "${YELLOW}请注销并重新登录以使组更改生效${NC}"
    fi
fi

# 启动 Docker 服务
echo -e "\n${YELLOW}正在启动 Docker 服务...${NC}"
systemctl start docker
systemctl enable docker

# 验证安装
echo -e "\n${YELLOW}验证 Docker 安装...${NC}"
docker --version
docker-compose --version

# 运行测试容器
echo -e "\n${YELLOW}运行测试容器...${NC}"
docker run --rm hello-world

echo -e "\n${GREEN}✓ Docker 和 Docker Compose 安装成功！${NC}"
echo -e "\n${YELLOW}使用提示：${NC}"
echo "1. 运行 'docker --version' 查看 Docker 版本"
echo "2. 运行 'docker-compose --version' 查看 Docker Compose 版本"
echo "3. 如需免 sudo 使用 Docker，请注销并重新登录"
echo "4. 快速安装命令示例:"
echo "   sudo $0 aliyun"
echo "   sudo $0 ustc"
