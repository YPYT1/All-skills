#!/bin/bash

# Unified Skills Repository - 初始化子模块脚本
# 用法: ./scripts/init-submodules.sh

set -e

echo "🚀 初始化 Unified Skills Repository 子模块..."
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查是否在 git 仓库中
if [ ! -d ".git" ]; then
    echo -e "${RED}错误: 当前目录不是 git 仓库${NC}"
    echo "请先运行: git init"
    exit 1
fi

# 初始化并更新所有子模块
echo -e "${YELLOW}📦 正在初始化子模块...${NC}"
git submodule update --init --recursive

echo ""
echo -e "${GREEN}✅ 子模块初始化完成!${NC}"
echo ""

# 显示已初始化的子模块
echo "📋 已初始化的子模块列表:"
git submodule status | while read line; do
    commit=$(echo $line | awk '{print $1}')
    path=$(echo $line | awk '{print $2}')
    name=$(basename $path)
    echo "  ✓ $name ($commit)"
done

echo ""
echo "📝 使用说明:"
echo "  - 查看所有 skills: ls skills/"
echo "  - 更新所有 skills: ./scripts/update-all.sh"
echo "  - 同步到统一目录: ./scripts/sync-skills.sh"
