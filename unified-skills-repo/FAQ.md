# 常见问题 (FAQ)

## 关于 Git Submodules

### Q: 什么是 Git Submodules？

**A:** Git Submodules 允许您将一个 Git 仓库作为另一个 Git 仓库的子目录。这对于管理依赖项（如本项目的 skills）非常有用，因为：

- 保持原始仓库的完整历史
- 可以独立更新每个子模块
- 自动跟踪上游更改

### Q: 为什么使用 Submodules 而不是直接复制文件？

**A:** 

| 方式 | 优点 | 缺点 |
|------|------|------|
| **Submodules** | 自动同步、保留历史、可追溯 | 学习曲线、需要额外命令 |
| **直接复制** | 简单、直接 | 无法自动更新、丢失历史 |
| **Fork** | 完全控制 | 需要手动同步、维护负担 |

### Q: 子模块更新后如何获取更改？

**A:** 运行以下命令：

```bash
# 更新所有子模块
git submodule update --remote

# 或者使用脚本
./scripts/update-all.sh
```

### Q: 如何切换到子模块的特定版本？

**A:**

```bash
cd skills/anthropics
git checkout v1.0.0  # 或特定的 commit
cd ../..
git add skills/anthropics
git commit -m "chore: pin anthropics to v1.0.0"
```

## 关于同步

### Q: 自动同步是如何工作的？

**A:** 本仓库配置了 GitHub Actions，每天自动：

1. 检查所有子模块的远程仓库
2. 拉取最新的更改
3. 创建 Pull Request（推荐）或直接提交

### Q: 可以自定义同步频率吗？

**A:** 可以！编辑 `.github/workflows/sync-skills.yml`：

```yaml
# 当前：每天 UTC 00:00
schedule:
  - cron: '0 0 * * *'

# 改为：每小时
schedule:
  - cron: '0 * * * *'

# 改为：每周一
schedule:
  - cron: '0 0 * * 1'
```

### Q: 同步失败怎么办？

**A:** 检查以下几点：

1. **网络连接**：确保能访问 GitHub
2. **权限**：检查 GitHub Token 是否有足够权限
3. **子模块状态**：运行 `git submodule status` 检查状态
4. **手动更新**：尝试 `git submodule update --init --force`

## 关于使用

### Q: 如何在 Claude Code 中使用这些 skills？

**A:** 有几种方式：

**方式 1: 直接安装**
```bash
claude skills install ./skills/anthropics/algorithmic-art
```

**方式 2: 复制到 Claude Code 目录**
```bash
cp -r skills/anthropics/* ~/.claude/skills/
```

**方式 3: 创建符号链接**
```bash
ln -s $(pwd)/skills/anthropics/algorithmic-art ~/.claude/skills/
```

### Q: 如何在 Cursor 中使用？

**A:**

```bash
# 复制到 Cursor 的 skills 目录
cp -r skills/anthropics/* ~/.cursor/skills/

# 或者特定 skill
cp -r skills/superpowers/test-driven-development ~/.cursor/skills/
```

### Q: 可以在其他 AI 工具中使用吗？

**A:** 可以！只要工具支持 Agent Skills 标准（[agentskills.io](https://agentskills.io/)），就可以使用这些 skills。

## 关于添加新来源

### Q: 如何添加私有仓库作为子模块？

**A:**

```bash
# 使用 SSH URL
git submodule add git@github.com:yourorg/private-skills.git skills/private

# 或者使用 HTTPS + Token
git submodule add https://token@github.com/yourorg/private-skills.git skills/private
```

### Q: 可以添加非 GitHub 的仓库吗？

**A:** 可以！支持任何 Git 仓库：

```bash
# GitLab
git submodule add https://gitlab.com/user/skills.git skills/gitlab

# Bitbucket
git submodule add https://bitbucket.org/user/skills.git skills/bitbucket

# 自建 Git 服务器
git submodule add https://git.yourcompany.com/skills.git skills/company
```

### Q: 如何移除一个子模块？

**A:**

```bash
# 1. 移除子模块条目
git submodule deinit -f skills/source-name
rm -rf .git/modules/skills/source-name

# 2. 从工作区移除
git rm -f skills/source-name

# 3. 提交更改
git commit -m "chore: remove skills/source-name submodule"
```

## 关于故障排除

### Q: 克隆后子模块目录为空？

**A:** 运行初始化命令：

```bash
git submodule update --init --recursive

# 或者
./scripts/init-submodules.sh
```

### Q: 子模块处于 "detached HEAD" 状态？

**A:** 这是正常的。子模块默认指向特定的 commit，而不是分支。要更新到最新：

```bash
git submodule update --remote
```

### Q: 出现 "fatal: not a git repository" 错误？

**A:** 确保您在正确的目录中：

```bash
# 检查当前目录
pwd

# 确保有 .git 目录
ls -la .git

# 如果没有，先初始化
git init
```

### Q: 如何清理并重新开始？

**A:**

```bash
# 1. 移除所有子模块
for dir in skills/*/; do
    git submodule deinit -f "$dir" 2>/dev/null || true
    rm -rf ".git/modules/$dir" 2>/dev/null || true
    git rm -f "$dir" 2>/dev/null || true
done

# 2. 清理 .gitmodules
rm -f .gitmodules

# 3. 重新运行设置
./setup.sh
```

## 关于性能

### Q: 子模块太多会影响性能吗？

**A:** 通常不会，但：

- **克隆时间**：首次克隆会下载所有子模块
- **磁盘空间**：每个子模块占用独立空间
- **更新速度**：取决于网络和各仓库大小

优化建议：
- 使用 `--depth 1` 进行浅克隆（如果需要）
- 定期清理不需要的子模块
- 使用 `git submodule update --init --recursive --jobs 4` 并行初始化

### Q: 可以只克隆特定的子模块吗？

**A:** 可以：

```bash
# 克隆时不初始化子模块
git clone --no-recurse-submodules https://github.com/your/unified-skills.git

# 只初始化特定的子模块
git submodule update --init skills/anthropics
```

## 关于许可证

### Q: 这些 skills 的许可证是什么？

**A:** 每个 skill 来源有自己的许可证：

| 来源 | 许可证 |
|------|--------|
| anthropics/skills | Apache 2.0 |
| obra/superpowers | MIT |
| sickn33/antigravity-awesome-skills | MIT |
| OthmanAdi/planning-with-files | MIT |
| ComposioHQ/awesome-claude-skills | (查看仓库) |
| openai/skills | (查看仓库) |
| VoltAgent/awesome-openclaw-skills | (查看仓库) |

### Q: 可以商用这些 skills 吗？

**A:** 取决于具体 skill 的许可证：

- **Apache 2.0**: 可以商用，需要保留版权声明
- **MIT**: 可以商用，需要保留版权声明
- **其他**: 请查看原仓库的许可证

## 其他问题

### Q: 如何贡献新的 skill？

**A:** 这取决于 skill 的来源：

1. **添加到现有来源**：向原仓库提交 PR
2. **添加新来源**：向本仓库提交 PR 添加子模块
3. **创建自己的 skill**：创建新仓库，然后添加为子模块

### Q: 有推荐的 skill 组合吗？

**A:** 根据使用场景：

**Web 开发:**
- `anthropics/frontend-design`
- `superpowers/test-driven-development`
- `superpowers/systematic-debugging`

**文档处理:**
- `anthropics/docx`
- `anthropics/pdf`
- `anthropics/pptx`
- `anthropics/xlsx`

**项目管理:**
- `planning-with-files`
- `superpowers/writing-plans`
- `superpowers/executing-plans`

### Q: 如何获取帮助？

**A:**

- **GitHub Issues**: 报告 bug 或请求功能
- **GitHub Discussions**: 一般讨论和问题
- **原仓库**: 特定 skill 的问题请查看原仓库

---

还有其他问题？欢迎提交 Issue 或 Discussion！
