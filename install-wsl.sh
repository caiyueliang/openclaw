#!/bin/bash
# OpenClaw WSL 安装脚本
# 在 Ubuntu WSL 中运行此脚本

set -e

echo "🚀 OpenClaw WSL 安装脚本"
echo "=========================="

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查是否在 WSL 中
if [[ ! -f /proc/version ]] || ! grep -q "microsoft" /proc/version; then
    echo -e "${YELLOW}警告: 看起来你不在 WSL 环境中${NC}"
    read -p "是否继续? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}步骤 1/6: 更新系统包...${NC}"
sudo apt-get update
sudo apt-get upgrade -y

echo -e "${GREEN}步骤 2/6: 安装必要的依赖...${NC}"
sudo apt-get install -y curl git build-essential

echo -e "${GREEN}步骤 3/6: 安装 Node.js 22...${NC}"
if ! command -v node &> /dev/null || [[ $(node -v | cut -d'v' -f2 | cut -d'.' -f1) -lt 22 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo -e "${YELLOW}Node.js 已安装，跳过...${NC}"
fi

echo -e "${GREEN}步骤 4/6: 安装 pnpm...${NC}"
if ! command -v pnpm &> /dev/null; then
    npm install -g pnpm
else
    echo -e "${YELLOW}pnpm 已安装，跳过...${NC}"
fi

echo -e "${GREEN}步骤 5/6: 检查项目目录...${NC}"
# 如果项目已经在 Windows 目录中，创建符号链接
WINDOWS_PROJECT="/mnt/e/PythonProject/openclaw"
WSL_PROJECT="$HOME/openclaw"

if [[ -d "$WINDOWS_PROJECT" ]]; then
    echo -e "${YELLOW}检测到 Windows 项目目录: $WINDOWS_PROJECT${NC}"
    if [[ ! -d "$WSL_PROJECT" ]]; then
        ln -s "$WINDOWS_PROJECT" "$WSL_PROJECT"
        echo -e "${GREEN}已创建符号链接: $WSL_PROJECT -> $WINDOWS_PROJECT${NC}"
    fi
    cd "$WSL_PROJECT"
else
    echo -e "${YELLOW}未找到 Windows 项目目录，将克隆新仓库...${NC}"
    if [[ ! -d "$WSL_PROJECT" ]]; then
        git clone https://github.com/openclaw/openclaw.git "$WSL_PROJECT"
    fi
    cd "$WSL_PROJECT"
fi

echo -e "${GREEN}步骤 6/6: 安装项目依赖并构建...${NC}"
echo -e "${YELLOW}这可能需要一些时间...${NC}"

# 安装依赖
echo "📦 安装依赖..."
pnpm install

# 构建 UI
echo "🎨 构建 UI..."
pnpm ui:build

# 构建项目
echo "🔨 构建项目..."
pnpm build

echo ""
echo -e "${GREEN}✅ 安装完成!${NC}"
echo ""
echo "你可以通过以下命令运行 OpenClaw:"
echo "  cd $WSL_PROJECT"
echo "  pnpm openclaw onboard --install-daemon"
echo ""
echo "或者进入项目目录:"
echo "  cd $WSL_PROJECT"
echo ""
