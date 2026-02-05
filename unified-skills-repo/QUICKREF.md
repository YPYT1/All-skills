# 快速参考卡片

Unified Skills Repository 的常用命令速查表。

## 🚀 快速开始

```bash
# 克隆（包含所有子模块）
git clone --recursive https://github.com/yourusername/unified-skills.git

# 首次设置
./setup.sh

# 更新所有 skills
./scripts/update-all.sh
```

## 📦 子模块管理

| 命令 | 说明 |
|------|------|
| `git submodule status` | 查看所有子模块状态 |
| `git submodule update --init` | 初始化子模块 |
| `git submodule update --remote` | 更新到远程最新 |
| `git submodule add <url> <path>` | 添加新子模块 |
| `git submodule deinit -f <path>` | 移除子模块 |

## 🔄 同步操作

```bash
# 同步所有来源
./scripts/sync-skills.sh

# 同步特定来源
./scripts/sync-skills.sh anthropics

# 更新并提交
./scripts/update-all.sh --commit
```

## 📁 目录结构

```
skills/
├── anthropics/           # 官方 Anthropic Skills
│   └── skills/
├── superpowers/          # obra/superpowers
│   └── skills/
├── antigravity/          # sickn33/antigravity
├── planning-with-files/  # OthmanAdi/planning
├── composio/             # ComposioHQ/awesome
├── openai/               # openai/skills
└── voltagent/            # VoltAgent/openclaw
```

## 🛠️ 在 AI 工具中使用

### Claude Code
```bash
# 安装单个 skill
claude skills install ./skills/anthropics/algorithmic-art

# 复制所有
mkdir -p ~/.claude/skills
cp -r skills/anthropics/skills/* ~/.claude/skills/
```

### Cursor
```bash
mkdir -p ~/.cursor/skills
cp -r skills/anthropics/skills/* ~/.cursor/skills/
```

### 其他工具
```bash
# 导出到统一目录
./scripts/sync-skills.sh

# 使用导出目录
ls skills-export/
```

## 🔧 故障排除

| 问题 | 解决方案 |
|------|----------|
| 子模块为空 | `git submodule update --init --recursive` |
| 更新失败 | `git submodule update --remote --force` |
| 权限错误 | 检查 GitHub Token 权限 |
| 同步失败 | 检查 `scripts/sync-config.json` |

## 📝 常用配置

### 修改同步频率
编辑 `.github/workflows/sync-skills.yml`：

```yaml
# 每天
- cron: '0 0 * * *'

# 每小时
- cron: '0 * * * *'

# 每周一
- cron: '0 0 * * 1'
```

### 添加新来源
```bash
git submodule add https://github.com/user/repo.git skills/new-source

# 更新配置
vim scripts/sync-config.json
```

## 🎯 推荐 Skills

### 开发工作流
- `superpowers/test-driven-development`
- `superpowers/systematic-debugging`
- `superpowers/subagent-driven-development`

### 文档处理
- `anthropics/docx`
- `anthropics/pdf`
- `anthropics/pptx`
- `anthropics/xlsx`

### 规划管理
- `planning-with-files`
- `superpowers/writing-plans`
- `superpowers/executing-plans`

### 创意生成
- `anthropics/algorithmic-art`
- `anthropics/canvas-design`
- `anthropics/theme-factory`

## 📊 统计命令

```bash
# 统计 skills 数量
find skills -name "SKILL.md" | wc -l

# 按来源统计
for dir in skills/*/; do
    echo "$dir: $(find "$dir" -name "SKILL.md" | wc -l)"
done

# 查看子模块提交
git submodule foreach 'echo $name && git log --oneline -3'
```

## 🔗 相关链接

- [Agent Skills 规范](https://agentskills.io/)
- [Git Submodules 文档](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Claude Skills 文档](https://support.claude.com/en/articles/12512176-what-are-skills)

---

**提示**: 将此文件保存为书签，方便快速查阅！
