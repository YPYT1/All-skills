#!/bin/bash

# Unified Skills Repository - 高级同步脚本
# 根据不同来源的配置，同步 skills 到统一目录结构
# 用法: ./scripts/sync-skills.sh [source-name]

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

CONFIG_FILE="scripts/sync-config.json"
OUTPUT_DIR="skills-export"

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}错误: 配置文件不存在: $CONFIG_FILE${NC}"
    exit 1
fi

# 解析 JSON 的辅助函数 (需要 jq)
parse_json() {
    jq -r "$1" "$CONFIG_FILE"
}

# 检查 jq 是否安装
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️ 警告: jq 未安装，将使用基本同步模式${NC}"
    USE_JQ=false
else
    USE_JQ=true
fi

# 同步单个来源
sync_source() {
    local source_name=$1
    local source_path=$2
    local skill_paths=$3
    local exclude_patterns=$4
    
    echo -e "${BLUE}📂 同步来源: $source_name${NC}"
    
    if [ ! -d "$source_path" ]; then
        echo -e "${RED}  ✗ 目录不存在: $source_path${NC}"
        return 1
    fi
    
    local target_dir="$OUTPUT_DIR/$source_name"
    mkdir -p "$target_dir"
    
    # 遍历所有 skill 路径
    for skill_path in $skill_paths; do
        local full_path="$source_path/$skill_path"
        
        if [ ! -d "$full_path" ]; then
            echo -e "${YELLOW}  ⚠️ 路径不存在: $full_path${NC}"
            continue
        fi
        
        # 复制 skills，排除指定目录
        echo "  📁 从 $skill_path 复制..."
        
        # 构建排除参数
        local exclude_args=""
        for pattern in $exclude_patterns; do
            exclude_args="$exclude_args --exclude=$pattern"
        done
        
        # 使用 rsync 或 cp 复制
        if command -v rsync &> /dev/null; then
            rsync -av --ignore-existing $exclude_args "$full_path/" "$target_dir/" 2>/dev/null || true
        else
            # 使用 cp 的替代方案
            find "$full_path" -maxdepth 1 -type d | while read dir; do
                local dirname=$(basename "$dir")
                if [[ ! " $exclude_patterns " =~ " $dirname " ]]; then
                    if [ ! -d "$target_dir/$dirname" ]; then
                        cp -r "$dir" "$target_dir/" 2>/dev/null || true
                    fi
                fi
            done
        fi
    done
    
    echo -e "${GREEN}  ✓ $source_name 同步完成${NC}"
    echo ""
}

# 主函数
main() {
    local specific_source=$1
    
    echo "🔄 Unified Skills 同步工具"
    echo "=========================="
    echo ""
    
    # 创建输出目录
    mkdir -p "$OUTPUT_DIR"
    
    if [ "$USE_JQ" = true ]; then
        # 使用 jq 解析配置
        local sources=$(parse_json '.sources[].name')
        
        for source in $sources; do
            # 如果指定了特定来源，则跳过其他
            if [ -n "$specific_source" ] && [ "$source" != "$specific_source" ]; then
                continue
            fi
            
            local localPath=$(parse_json ".sources[] | select(.name == \"$source\") | .localPath")
            local skillPaths=$(parse_json ".sources[] | select(.name == \"$source\") | .skillPaths[]")
            local exclude=$(parse_json ".sources[] | select(.name == \"$source\") | .exclude[]")
            
            sync_source "$source" "$localPath" "$skillPaths" "$exclude"
        done
    else
        # 基本模式：直接同步所有子模块
        echo -e "${YELLOW}使用基本同步模式...${NC}"
        echo ""
        
        for dir in skills/*/; do
            if [ -d "$dir" ]; then
                local name=$(basename "$dir")
                
                # 如果指定了特定来源，则跳过其他
                if [ -n "$specific_source" ] && [ "$name" != "$specific_source" ]; then
                    continue
                fi
                
                echo -e "${BLUE}📂 同步来源: $name${NC}"
                
                local target_dir="$OUTPUT_DIR/$name"
                mkdir -p "$target_dir"
                
                # 尝试找到 skills 子目录
                if [ -d "$dir/skills" ]; then
                    cp -r "$dir/skills/"* "$target_dir/" 2>/dev/null || true
                    echo -e "${GREEN}  ✓ 从 skills/ 子目录复制${NC}"
                else
                    # 复制整个目录（排除特定文件）
                    find "$dir" -maxdepth 1 -type d ! -name ".git" ! -name "docs" ! -name "scripts" | \
                        while read subdir; do
                            local subname=$(basename "$subdir")
                            if [ "$subname" != "$name" ] && [ ! -d "$target_dir/$subname" ]; then
                                cp -r "$subdir" "$target_dir/" 2>/dev/null || true
                            fi
                        done
                    echo -e "${GREEN}  ✓ 从根目录复制${NC}"
                fi
                echo ""
            fi
        done
    fi
    
    # 生成汇总报告
    echo ""
    echo "📊 同步汇总报告"
    echo "==============="
    echo ""
    
    local total_dirs=0
    for dir in "$OUTPUT_DIR"/*/; do
        if [ -d "$dir" ]; then
            local name=$(basename "$dir")
            local count=$(find "$dir" -maxdepth 1 -type d | wc -l)
            count=$((count - 1))  # 减去自身
            echo -e "${BLUE}$name:${NC} $count skills"
            total_dirs=$((total_dirs + count))
        fi
    done
    
    echo ""
    echo -e "${GREEN}总计: $total_dirs skills${NC}"
    echo ""
    echo "📁 导出目录: $OUTPUT_DIR/"
    echo ""
    echo "💡 提示:"
    echo "  - 导出目录可用于发布或分发"
    echo "  - 原仓库结构保持不变"
    echo "  - 使用 ./scripts/update-all.sh 更新子模块"
}

# 显示帮助
show_help() {
    echo "Unified Skills 同步工具"
    echo ""
    echo "用法:"
    echo "  $0                    # 同步所有来源"
    echo "  $0 <source-name>      # 同步指定来源"
    echo "  $0 --help             # 显示帮助"
    echo ""
    echo "可用的来源:"
    
    if [ "$USE_JQ" = true ]; then
        parse_json '.sources[] | "  - " + .name + ": " + .description'
    else
        for dir in skills/*/; do
            if [ -d "$dir" ]; then
                echo "  - $(basename "$dir")"
            fi
        done
    fi
}

# 主入口
case "${1:-}" in
    --help|-h)
        show_help
        ;;
    *)
        main "$1"
        ;;
esac
