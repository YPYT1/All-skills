---
name: create-pull-request
description: Provides comprehensive PR creation guidance with GitHub CLI, enforcing title conventions, following template structure, and offering concrete command examples with best practices.
version: 1.0.0
author: liam-hq
source: Claude Code Marketplace
keywords: claude-code,ai,assistant
---

# create-pull-request

Provides comprehensive PR creation guidance with GitHub CLI, enforcing title conventions, following template structure, and offering concrete command examples with best practices.

## 来源信息

- **原始平台**: Claude Code
- **市场来源**: Claude Code Marketplace
- **原始名称**: create-pull-request
- **版本**: 1.0.0
- **作者**: liam-hq
- **关键词**: 无

## 功能描述

# GitHub CLI Pull Request Creation Guide

This guide provides comprehensive instructions for creating pull requests using GitHub CLI.

## Prerequisites
- Installing GitHub CLI
- Authenticating with GitHub

## Key Features
- Detailed instructions for creating pull requests
- Best practices for PR titles and descriptions
- Example commands for PR management
- Tips for using templates
- Additional GitHub CLI PR commands

## Example PR Creation Command
```bash
gh pr create --title "✨(scope): Your descriptive title" --body-file <(echo -e "## Issue\n\n- resolve:\n\n## Why is this change needed?\nYour description here.") --base main --draft
```

## Best Practices
- Use consistent template structure
- Follow conventional commit formats
- Maintain clear, structured pull request descriptions
- Include proper scope and descriptive titles

## 使用方法

1. **自动触发**: Codex 会根据任务描述自动选择并使用此技能
2. **手动指定**: 在提示中提及技能名称或相关关键词
3. **斜杠命令**: 使用 `/skills` 命令查看并选择可用技能

## 兼容性

- ✅ Codex CLI
- ✅ Codex IDE 扩展
- ✅ 基于 Agent Skills 开放标准

---
*此技能由 Claude Code 插件自动转换，已适配 Codex 官方技能系统*
