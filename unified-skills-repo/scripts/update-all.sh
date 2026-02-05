#!/bin/bash

# Unified Skills Repository - 更新所有子模块脚本
# 用法: ./scripts/update-all.sh [--commit]

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

AUTO_COMMIT=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --commit)
            AUTO_COMMIT=true
            shift
            ;;
        *)
            echo "未知参数: $1"
            echo "用法: $0 [--commit]"
            exit 1
            ;;
    esac
done

echo "🔄 更新所有 Skills 子模块..."
echo ""

# 更新所有子模块到远程最新版本
echo -e "${YELLOW}📥 正在从远程拉取更新...${NC}"
git submodule update --remote

echo ""
echo -e "${GREEN}✅ 子模块更新完成!${NC}"
echo ""

# 显示更新摘要
echo "📊 更新摘要:"
echo ""
git submodule status | while read line; do
    commit=$(echo $line | awk '{print $1}')
    path=$(echo $line | awk '{print $2}')
    name=$(basename $path)
    echo -e "${BLUE}$name:${NC}"
    echo "  路径: $path"
    echo "  提交: ${commit:0:8}"
    
    # 检查是否有更新
    cd "$path"
    if git log --oneline HEAD...HEAD@{1} 2>/dev/null | grep -q .; then
        echo -e "  状态: ${GREEN}已更新${NC}"
        echo "  最近的提交:"
        git log --oneline -3 HEAD 2>/dev/null | sed 's/^/    /' || echo "    (无法获取提交历史)"
    else
        echo -e "  状态: 无变化"
    fi
    cd - > /dev/null
    echo ""
done

# 自动提交（如果指定了 --commit）
if [ "$AUTO_COMMIT" = true ]; then
    echo -e "${YELLOW}📝 正在提交更新...${NC}"
    git add .
    if git diff --cached --quiet; then
        echo -e "${YELLOW}⚠️ 没有需要提交的更改${NC}"
    else
        git commit -m "chore: sync skills from upstream repositories

$(date '+%Y-%m-%d %H:%M:%S')

Updated skills from:
$(git submodule status | awk '{print "- " $2}' | sed 's/skills\///')"
        echo -e "${GREEN}✅ 已自动提交更新${NC}"
    fi
fi

echo ""
echo "🎉 所有操作完成!"
echo ""
echo "💡 提示:"
echo "  - 运行 ./scripts/sync-skills.sh 同步到统一目录"
echo "  - 运行 git push 推送更改到远程"
