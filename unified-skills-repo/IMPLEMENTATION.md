# 实现说明

本文档详细说明 Unified Skills Repository 的技术实现细节。

## 架构概述

```
┌─────────────────────────────────────────────────────────────┐
│                    Unified Skills Repository                 │
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  GitHub     │  │   Local     │  │   Export    │         │
│  │  Actions    │  │   Scripts   │  │   Directory │         │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘         │
│         │                │                │                │
│         ▼                ▼                ▼                │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Git Submodules (skills/)                │  │
│  │                                                      │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐            │  │
│  │  │anthropics│ │superpowers│ │antigravity│ ...      │  │
│  │  └──────────┘ └──────────┘ └──────────┘            │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Git Submodules 详解

### 为什么选择 Submodules？

| 方案 | 自动同步 | 保留历史 | 空间效率 | 维护成本 |
|------|----------|----------|----------|----------|
| Git Submodules | ✅ | ✅ | ✅ | 中 |
| Git Subtree | ✅ | ✅ | ✅ | 高 |
| 手动复制 | ❌ | ❌ | ❌ | 低 |
| Fork + Sync | 部分 | ✅ | ✅ | 高 |

### Submodules 工作原理

```
主仓库 (.git)
├── .gitmodules          # 子模块配置
├── skills/
│   ├── anthropics/      # → https://github.com/anthropics/skills
│   ├── superpowers/     # → https://github.com/obra/superpowers
│   └── ...
└── .git/modules/        # 子模块的 Git 数据
    ├── skills/anthropics/
    ├── skills/superpowers/
    └── ...
```

### 配置文件 (.gitmodules)

```ini
[submodule "skills/anthropics"]
    path = skills/anthropics
    url = https://github.com/anthropics/skills.git
    branch = main
```

### 关键命令

```bash
# 初始化（首次）
git submodule update --init --recursive

# 更新到远程最新
git submodule update --remote

# 更新特定子模块
git submodule update --remote skills/anthropics

# 查看状态
git submodule status
```

## 同步机制

### 自动同步 (GitHub Actions)

```yaml
# .github/workflows/sync-skills.yml
on:
  schedule:
    - cron: '0 0 * * *'  # 每天 UTC 00:00

jobs:
  sync:
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
      
      - run: git submodule update --remote
      
      - uses: peter-evans/create-pull-request@v5
        with:
          title: '🔄 Sync Skills from Upstream'
```

### 本地同步脚本

```bash
# scripts/update-all.sh
#!/bin/bash
git submodule update --remote

# 可选：自动提交
if [ "$AUTO_COMMIT" = true ]; then
    git add .
    git commit -m "chore: sync skills"
    git push
fi
```

## 目录结构映射

### 不同来源的结构差异

```
# anthropics/skills
skills/
├── algorithmic-art/
├── brand-guidelines/
└── docx/

# obra/superpowers
skills/
├── brainstorming/
├── test-driven-development/
└── systematic-debugging/

# sickn33/antigravity-awesome-skills (根目录)
brainstorming/
web-development/
docs/
```

### 统一映射策略

```json
{
  "sources": [
    {
      "name": "anthropics",
      "skillPaths": ["skills"],      // 从 skills/ 子目录提取
      "exclude": ["template"]        // 排除 template 目录
    },
    {
      "name": "antigravity",
      "skillPaths": ["."],           // 从根目录提取
      "exclude": ["docs", "scripts"] // 排除非 skill 目录
    }
  ]
}
```

## 导出机制

### 导出流程

```
skills/anthropics/skills/    →    skills-export/anthropics/
skills/superpowers/skills/   →    skills-export/superpowers/
skills/antigravity/          →    skills-export/antigravity/ (排除 docs/)
```

### 实现代码

```bash
# scripts/sync-skills.sh
sync_source() {
    local source_name=$1
    local source_path=$2
    local skill_paths=$3
    local exclude=$4
    
    for skill_path in $skill_paths; do
        full_path="$source_path/$skill_path"
        
        # 复制并排除
        rsync -av --exclude={$exclude} \
            "$full_path/" \
            "$OUTPUT_DIR/$source_name/"
    done
}
```

## 冲突处理

### 同名 Skill 处理

当不同来源有同名 skill 时：

1. **保留来源前缀**：`anthropics/brainstorming` vs `antigravity/brainstorming`
2. **配置优先级**：在 `sync-config.json` 中设置优先级
3. **手动选择**：导出后手动选择需要的版本

### 更新冲突

```bash
# 强制更新（丢弃本地更改）
git submodule update --remote --force

# 保留本地更改
git submodule update --remote --rebase

# 合并更改
git submodule update --remote --merge
```

## 性能优化

### 克隆优化

```bash
# 浅克隆（节省空间）
git submodule update --init --depth 1

# 并行克隆
git submodule update --init --jobs 4
```

### 更新优化

```bash
# 只更新特定子模块
git submodule update --remote skills/anthropics

# 批量更新（后台）
for dir in skills/*/; do
    (cd "$dir" && git pull) &
done
wait
```

## 安全考虑

### 子模块安全

1. **只读访问**：子模块默认只读，防止意外修改
2. **签名验证**：可启用 GPG 签名验证
3. **来源审查**：只添加可信来源

### GitHub Actions 安全

```yaml
permissions:
  contents: write      # 需要写入权限来创建 PR
  pull-requests: write # 需要 PR 权限

# 使用最小权限原则
```

## 扩展性设计

### 添加新来源

1. **添加子模块**：
```bash
git submodule add <url> skills/new-source
```

2. **更新配置**：
```json
{
  "name": "new-source",
  "skillPaths": ["skills"],
  "exclude": []
}
```

3. **测试**：
```bash
./scripts/sync-skills.sh new-source
```

### 自定义同步逻辑

```bash
# 在 sync-skills.sh 中添加自定义逻辑
case "$source_name" in
    "custom-source")
        # 自定义同步逻辑
        custom_sync "$source_path"
        ;;
esac
```

## 故障排查

### 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 子模块为空 | 未初始化 | `git submodule update --init` |
| 更新失败 | 网络/权限 | 检查网络和 token |
| 同步失败 | 配置错误 | 检查 sync-config.json |
| 冲突 | 本地修改 | `git submodule update --force` |

### 调试模式

```bash
# 启用详细输出
export GIT_TRACE=1
./scripts/update-all.sh

# 检查子模块状态
git submodule status --recursive

# 查看子模块日志
git submodule foreach 'git log --oneline -5'
```

## 未来改进

### 可能的增强

1. **增量同步**：只同步更改的文件
2. **选择性同步**：根据标签/类别选择 skills
3. **版本锁定**：支持锁定到特定版本
4. **依赖管理**：处理 skills 之间的依赖关系
5. **Web 界面**：可视化浏览和管理 skills

### 技术债务

- 当前依赖 `jq` 进行 JSON 解析，考虑内置替代方案
- 同步脚本可以进一步优化性能
- 需要更多测试覆盖

## 参考资源

- [Git Submodules 官方文档](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Agent Skills 规范](https://agentskills.io/)
