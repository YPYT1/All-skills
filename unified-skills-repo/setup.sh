#!/bin/bash

# Unified Skills Repository - 快速设置脚本
# 一键初始化整个仓库

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo "🚀 Unified Skills Repository 快速设置"
echo "======================================"
echo ""

# 检查依赖
echo -e "${BLUE}🔍 检查依赖...${NC}"

if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git 已安装${NC}"

if command -v jq &> /dev/null; then
    echo -e "${GREEN}✓ jq 已安装${NC}"
else
    echo -e "${YELLOW}⚠️ jq 未安装 (可选，用于高级功能)${NC}"
fi

# 检查是否在 git 仓库中
if [ ! -d ".git" ]; then
    echo ""
    echo -e "${YELLOW}📦 初始化 Git 仓库...${NC}"
    git init
    git add .
    git commit -m "Initial commit: Unified Skills Repository setup"
fi

# 添加子模块
echo ""
echo -e "${BLUE}📦 添加 Skills 子模块...${NC}"

add_submodule() {
    local name=$1
    local url=$2
    local path=$3
    
    if [ -d "$path/.git" ]; then
        echo -e "${YELLOW}  ⚠️ $name 已存在，跳过${NC}"
    else
        echo -e "${BLUE}  📥 添加 $name...${NC}"
        git submodule add "$url" "$path" 2>/dev/null || {
            echo -e "${YELLOW}  ⚠️ $name 添加失败，可能已存在${NC}"
        }
    fi
}

# 添加各个子模块
add_submodule "anthropics" "https://github.com/anthropics/skills.git" "skills/anthropics"
add_submodule "superpowers" "https://github.com/obra/superpowers.git" "skills/superpowers"
add_submodule "antigravity" "https://github.com/sickn33/antigravity-awesome-skills.git" "skills/antigravity"
add_submodule "planning-with-files" "https://github.com/OthmanAdi/planning-with-files.git" "skills/planning-with-files"
add_submodule "composio" "https://github.com/ComposioHQ/awesome-claude-skills.git" "skills/composio"
add_submodule "openai" "https://github.com/openai/skills.git" "skills/openai"
add_submodule "voltagent" "https://github.com/VoltAgent/awesome-openclaw-skills.git" "skills/voltagent"

# 初始化子模块
echo ""
echo -e "${BLUE}🔄 初始化子模块...${NC}"
git submodule update --init --recursive

# 设置脚本权限
echo ""
echo -e "${BLUE}🔧 设置脚本权限...${NC}"
chmod +x scripts/*.sh 2>/dev/null || true

# 提交子模块配置
echo ""
echo -e "${BLUE}📝 提交配置...${NC}"
git add .gitmodules skills/
if ! git diff --cached --quiet; then
    git commit -m "chore: add skills submodules

Added submodules from:
- anthropics/skills
- obra/superpowers
- sickn33/antigravity-awesome-skills
- OthmanAdi/planning-with-files
- ComposioHQ/awesome-claude-skills
- openai/skills
- VoltAgent/awesome-openclaw-skills"
    echo -e "${GREEN}✓ 配置已提交${NC}"
else
    echo -e "${YELLOW}⚠️ 无更改需要提交${NC}"
fi

# 统计信息
echo ""
echo "📊 设置完成统计"
echo "==============="
echo ""

total_skills=0
for dir in skills/*/; do
    if [ -d "$dir" ]; then
        name=$(basename "$dir")
        
        # 计算 skills 数量
        if [ -d "$dir/skills" ]; then
            count=$(find "$dir/skills" -maxdepth 1 -type d | wc -l)
        else
            count=$(find "$dir" -maxdepth 1 -type d ! -path "$dir" ! -path "*/.git*" | wc -l)
        fi
        count=$((count - 1))
        
        echo -e "${GREEN}✓${NC} $name: ~$count skills"
        total_skills=$((total_skills + count))
    fi
done

echo ""
echo -e "${GREEN}总计: ~$total_skills skills${NC}"
echo ""

# 后续步骤
echo "🎉 设置完成!"
echo ""
echo "📖 后续步骤:"
echo ""
echo "1. 更新所有 skills 到最新版本:"
echo "   ./scripts/update-all.sh"
echo ""
echo "2. 同步到统一目录结构:"
echo "   ./scripts/sync-skills.sh"
echo ""
echo "3. 推送到远程仓库:"
echo "   git remote add origin <your-repo-url>"
echo "   git push -u origin main"
echo ""
echo "4. 启用 GitHub Actions 自动同步:"
echo "   - 在 GitHub 上创建仓库"
echo "   - 推送代码"
echo "   - 在 Settings > Actions > General 中启用 Actions"
echo ""
echo "📚 更多信息请查看 README.md"
