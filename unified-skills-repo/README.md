# Unified Skills Repository

一个集中管理多个来源的 AI Agent Skills 的仓库，支持自动同步更新。

## 仓库结构

```
.
├── README.md                 # 本文件
├── skills/                   # 所有 skills 的汇总目录
│   ├── anthropics/          # 来自 anthropics/skills
│   ├── superpowers/         # 来自 obra/superpowers
│   ├── antigravity/         # 来自 sickn33/antigravity-awesome-skills
│   ├── planning-with-files/ # 来自 OthmanAdi/planning-with-files
│   ├── composio/            # 来自 ComposioHQ/awesome-claude-skills
│   ├── openai/              # 来自 openai/skills
│   └── voltagent/           # 来自 VoltAgent/awesome-openclaw-skills
├── scripts/                  # 同步脚本
│   ├── init-submodules.sh   # 初始化子模块
│   ├── update-all.sh        # 更新所有 skills
│   └── sync-skills.sh       # 同步 skills 到统一目录
└── .gitmodules              # Git 子模块配置
```

## 支持的 Skills 来源

| 来源仓库 | Skills 路径 | 说明 |
|---------|------------|------|
| [anthropics/skills](https://github.com/anthropics/skills) | `skills/` | 官方 Anthropic Skills |
| [obra/superpowers](https://github.com/obra/superpowers) | `skills/` | TDD、调试等开发方法论 |
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 根目录 | 600+ 通用 skills |
| [OthmanAdi/planning-with-files](https://github.com/OthmanAdi/planning-with-files) | `skills/` | Manus 风格的规划 workflow |
| [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) | `skills/` | Composio 集成 skills |
| [openai/skills](https://github.com/openai/skills) | `skills/` | OpenAI Codex skills |
| [VoltAgent/awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills) | `skills/` | OpenClaw skills |

## 快速开始

### 1. 克隆仓库（包含子模块）

```bash
# 克隆时一并初始化所有子模块
git clone --recursive https://github.com/yourusername/unified-skills.git

# 或者分步执行
git clone https://github.com/yourusername/unified-skills.git
cd unified-skills
git submodule update --init --recursive
```

### 2. 初始化 Skills 目录结构

```bash
./scripts/init-submodules.sh
```

### 3. 更新所有 Skills 到最新版本

```bash
./scripts/update-all.sh
```

## 自动同步更新

### 方法一：GitHub Actions 自动更新（推荐）

本仓库配置了 GitHub Actions，每天自动检查并更新所有子模块：

- **触发条件**：每天 UTC 00:00 自动运行，或手动触发
- **更新内容**：拉取所有上游仓库的最新更改
- **自动提交**：如有更新，自动创建 PR 或直接提交

查看配置：`.github/workflows/sync-skills.yml`

### 方法二：本地手动更新

```bash
# 更新所有子模块
git submodule update --remote

# 更新特定子模块
git submodule update --remote skills/anthropics

# 提交更新
git add .
git commit -m "chore: sync skills from upstream"
git push
```

### 方法三：使用脚本更新

```bash
# 更新所有并同步到统一目录
./scripts/sync-skills.sh
```

## 添加新的 Skills 来源

### 1. 添加为 Git Submodule

```bash
# 添加新的子模块
git submodule add https://github.com/username/repo.git skills/new-source

# 提交更改
git add .gitmodules skills/new-source
git commit -m "feat: add new skills source from username/repo"
```

### 2. 配置同步规则

编辑 `scripts/sync-config.json`，添加新来源的同步配置：

```json
{
  "sources": [
    {
      "name": "new-source",
      "path": "skills/new-source",
      "skillSubdirs": ["skills"],
      "exclude": ["docs", "tests"]
    }
  ]
}
```

## Skills 使用方式

### Claude Code

```bash
# 安装所有 skills
claude skills install ./skills/anthropics/algorithmic-art

# 或者复制到 Claude Code 的 skills 目录
cp -r skills/anthropics/* ~/.claude/skills/
```

### Cursor

```bash
# 复制到 Cursor 的 skills 目录
cp -r skills/anthropics/* ~/.cursor/skills/
```

### 其他 AI 工具

根据不同工具的要求，将对应的 skill 文件夹复制到指定位置即可。

## 目录映射详情

### anthropics/skills → skills/anthropics/

| 原路径 | 映射后路径 |
|-------|-----------|
| `skills/algorithmic-art/` | `skills/anthropics/algorithmic-art/` |
| `skills/brand-guidelines/` | `skills/anthropics/brand-guidelines/` |
| `skills/docx/` | `skills/anthropics/docx/` |
| `skills/pdf/` | `skills/anthropics/pdf/` |
| `skills/pptx/` | `skills/anthropics/pptx/` |
| `skills/xlsx/` | `skills/anthropics/xlsx/` |

### obra/superpowers → skills/superpowers/

| 原路径 | 映射后路径 |
|-------|-----------|
| `skills/brainstorming/` | `skills/superpowers/brainstorming/` |
| `skills/test-driven-development/` | `skills/superpowers/test-driven-development/` |
| `skills/systematic-debugging/` | `skills/superpowers/systematic-debugging/` |

### sickn33/antigravity-awesome-skills → skills/antigravity/

| 原路径 | 映射后路径 |
|-------|-----------|
| `brainstorming/` | `skills/antigravity/brainstorming/` |
| `web-development/` | `skills/antigravity/web-development/` |

## 贡献指南

1. **Fork 本仓库**
2. **添加新的 Skills 来源**：按照上述步骤添加子模块
3. **测试同步**：运行 `./scripts/sync-skills.sh` 确保正常工作
4. **提交 PR**：描述新增的 skills 来源和用途

## 许可证

本仓库本身使用 MIT 许可证。各个 skills 的许可证请查看原仓库：

- [anthropics/skills - Apache 2.0](https://github.com/anthropics/skills/blob/main/LICENSE)
- [obra/superpowers - MIT](https://github.com/obra/superpowers/blob/main/LICENSE)
- [sickn33/antigravity-awesome-skills - MIT](https://github.com/sickn33/antigravity-awesome-skills/blob/main/LICENSE)

## 相关链接

- [Agent Skills 规范](https://agentskills.io/)
- [Claude Skills 文档](https://support.claude.com/en/articles/12512176-what-are-skills)
- [Git Submodules 文档](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
