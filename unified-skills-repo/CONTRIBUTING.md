# 贡献指南

感谢您对 Unified Skills Repository 的兴趣！本文档将帮助您了解如何为这个项目做出贡献。

## 贡献方式

### 1. 添加新的 Skills 来源

如果您发现了一个新的 skills 仓库，可以通过以下步骤添加：

#### 步骤 1: Fork 本仓库

点击 GitHub 上的 "Fork" 按钮创建您自己的副本。

#### 步骤 2: 添加子模块

```bash
# 克隆您的 fork
git clone https://github.com/yourusername/unified-skills.git
cd unified-skills

# 添加新的子模块
git submodule add https://github.com/username/new-skills-repo.git skills/new-source

# 初始化子模块
git submodule update --init skills/new-source
```

#### 步骤 3: 更新配置

编辑 `scripts/sync-config.json`，添加新来源的配置：

```json
{
  "name": "new-source",
  "displayName": "New Skills Source",
  "repo": "https://github.com/username/new-skills-repo",
  "localPath": "skills/new-source",
  "skillPaths": ["skills"],
  "exclude": ["docs", "tests"],
  "description": "简短描述"
}
```

#### 步骤 4: 测试

```bash
# 测试更新
./scripts/update-all.sh

# 测试同步
./scripts/sync-skills.sh new-source
```

#### 步骤 5: 提交 PR

```bash
git add .
git commit -m "feat: add new skills source from username/new-skills-repo"
git push origin main
```

然后在 GitHub 上创建 Pull Request。

### 2. 改进同步脚本

如果您发现同步脚本有问题或可以改进：

1. 修改 `scripts/` 目录下的相关脚本
2. 确保脚本在 macOS 和 Linux 上都能正常运行
3. 添加适当的错误处理
4. 更新文档
5. 提交 PR

### 3. 更新文档

文档改进总是受欢迎的：

- 修复拼写错误或语法问题
- 添加更多示例
- 改进说明的清晰度
- 添加翻译（如果需要）

### 4. 报告问题

如果您发现问题，请通过 GitHub Issues 报告：

1. 检查是否已有类似的问题
2. 使用问题模板（如果有）
3. 提供尽可能多的细节：
   - 操作系统和版本
   - Git 版本
   - 错误信息
   - 复现步骤

## 开发指南

### 项目结构

```
.
├── .github/workflows/     # GitHub Actions 配置
├── scripts/               # 同步和管理脚本
├── skills/                # Git 子模块目录
├── .gitmodules           # 子模块配置
├── .gitignore            # Git 忽略规则
├── CONTRIBUTING.md        # 本文件
├── LICENSE               # 许可证
└── README.md             # 项目说明
```

### 脚本说明

| 脚本 | 用途 |
|------|------|
| `setup.sh` | 首次设置，初始化所有子模块 |
| `scripts/init-submodules.sh` | 初始化子模块 |
| `scripts/update-all.sh` | 更新所有子模块到最新 |
| `scripts/sync-skills.sh` | 同步 skills 到统一目录 |

### 测试脚本

在提交 PR 之前，请确保：

```bash
# 1. 脚本可以正常执行
chmod +x scripts/*.sh setup.sh

# 2. 更新脚本正常工作
./scripts/update-all.sh

# 3. 同步脚本正常工作
./scripts/sync-skills.sh

# 4. 没有语法错误
bash -n scripts/*.sh setup.sh
```

## 代码规范

### Shell 脚本

- 使用 `#!/bin/bash` shebang
- 添加 `set -e` 使脚本在错误时退出
- 使用有意义的变量名
- 添加注释说明复杂逻辑
- 使用颜色代码提高可读性

### JSON 配置

- 使用 2 空格缩进
- 保持字段顺序一致
- 添加描述性注释（如果支持）

### Git 提交信息

使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

- `feat:` 新功能
- `fix:` 修复问题
- `docs:` 文档更新
- `style:` 代码格式（不影响功能）
- `refactor:` 代码重构
- `perf:` 性能优化
- `test:` 测试相关
- `chore:` 构建/工具相关

示例：
```
feat: add new skills source from awesome-ai/skills

Added submodule for awesome-ai/skills repository which contains
100+ skills for web development and data analysis.
```

## 审核流程

1. **提交 PR** 后，维护者会进行审核
2. **自动化测试** 会运行（如果有）
3. **代码审核** 可能会提出修改建议
4. **合并** 后更改会进入主分支

## 行为准则

- 保持友好和尊重
- 接受建设性批评
- 关注对社区最有利的事情
- 尊重不同的观点和经验

## 许可证

通过贡献代码，您同意您的贡献将在 MIT 许可证下发布。

## 联系方式

- GitHub Issues: 报告问题或请求功能
- GitHub Discussions: 一般讨论

感谢您的贡献！🎉
