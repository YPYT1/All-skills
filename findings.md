# Findings & Decisions

## Requirements
- **同步来源（仅以下这些，按你给的目录）：**
  - `ComposioHQ/awesome-claude-skills`（repo 根目录）
  - `obra/superpowers/tree/main/skills`
  - `K-Dense-AI/claude-scientific-skills/tree/main/scientific-skills`
  - `OthmanAdi/planning-with-files`（repo 根目录）
  - `anthropics/skills/tree/main/skills`
  - `sickn33/antigravity-awesome-skills/tree/main/skills`
  - `openai/skills/tree/main/skills/.curated`
  - `openai/skills/tree/main/skills/.experimental`
  - `openai/skills/tree/main/skills/.system`
  - `openclaw/skills/tree/main/skills`
- **目录规则（以你原始定义为准）：**
  - 上游同步：`skills/<仓库名>/<skill-name>/...`
  - 自己编写：`skills/<skill-name>/SKILL.md`（直接一级，不再额外套层）
- **自动化：**
  - GitHub Actions 定时同步并在有变更时自动 commit + push
- **安全：**
  - 仓库中不得包含真实密钥；同时尽量避免“像密钥的字符串”触发 Secret Scanning

## Research Findings
- **Actions 失败根因之一：** `scripts/sync_sources.sh` 内的 Python 代码硬编码了本机路径 `Path('/Users/liam/project/github_repositories/All-skills')`，在 GitHub Runner 上会找不到而直接失败。
- **当前结构偏乱：** 多数上游输出成了 `skills/<repoName>/<category>/<skill>`（例如 `superpowers/skills/*`），比你期望多一层。
- **Secret Scanning 告警：** 当前同步下来的 skills 中存在多处“密钥样式”内容（例如 Google API key、Slack token、Telegram bot token、Stripe key 等的样例/模板/文档片段），会触发 GitHub 的检测邮件。
- **库存文件问题：** `skills/_inventory.json` 目前是绝对路径且与当前目录不一致（疑似旧结构遗留），需要在重构后重新生成。
- **脱敏遗漏根因：** Google API Key 的正则写成了 `\\-_`，导致包含 `-`/`_` 的 key 无法匹配，从而漏脱敏；已修正为 `_-` 并验证命中归零。
- **当前仓库扫描结果：** 针对你邮件里列出的高风险 token 样式（Google/Slack/Stripe/Tailscale/Telegram/Groq/Alibaba 等），已在已跟踪文件里复扫到 **0 命中**（仅输出路径、不泄露内容）。

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| 同步输出改为扁平：`skills/<repoName>/<skill>` | 对齐你的规则，减少额外层级 |
| `openai/skills` 三个子目录合并输出到同一 `skills/openai-skills/` | 当前无重名冲突（curated/experimental/system 目录名不重叠），符合二级结构 |
| 同步后进行脱敏（redact） | 解决 GitHub Secret Scanning 告警，避免再次触发邮件/阻断 |
| `_inventory.json` 每次同步自动重建为相对路径 | 避免绝对路径写入仓库，且随结构变化保持一致 |
| 本地 skills 放回一级目录 | `skills/_local/openclaw-installed/*` 已迁移到 `skills/*`（避开与上游 `planning-with-files/` 的重名冲突） |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| `planning-with-files` 初始化脚本不可执行 | 改用 `bash` 直接运行 |

## Resources
- `sources/sources.json`（同步来源配置）
- `.github/workflows/sync.yml`（Actions 工作流）
- `scripts/sync_sources.sh`（同步实现，需要修复）
