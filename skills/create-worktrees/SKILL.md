---
name: create-worktrees
description: Creates git worktrees for all open PRs or specific branches, handling branches with slashes, cleaning up stale worktrees, and supporting custom branch creation for development.
version: 1.0.0
author: evmts
source: Claude Code Marketplace
keywords: claude-code,ai,assistant
---

# create-worktrees

Creates git worktrees for all open PRs or specific branches, handling branches with slashes, cleaning up stale worktrees, and supporting custom branch creation for development.

## 来源信息

- **原始平台**: Claude Code
- **市场来源**: Claude Code Marketplace
- **原始名称**: create-worktrees
- **版本**: 1.0.0
- **作者**: evmts
- **关键词**: 无

## 功能描述

# Git Worktree Commands

This documentation provides two main bash scripts for Git worktree management:

## 1. Create Worktrees for All Open PRs
- Uses GitHub CLI to fetch open pull requests
- Creates git worktrees for each PR branch
- Handles branch names with slashes
- Includes an optional cleanup script for stale worktrees

## 2. Interactive Branch and Worktree Creation
- Prompts for a new branch name
- Validates branch name
- Creates a worktree in a `./tree/` directory
- Supports creating branches from different base commits

## Key Features
- Error handling
- Directory management
- Flexible branch creation options
- Streamlined Git workflow by making branch and worktree management more efficient

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
