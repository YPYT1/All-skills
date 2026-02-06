# Task Plan: 重构 skills 同步结构 + 清理泄露密钥

## Goal
把指定上游仓库的 skills **稳定同步**到 `skills/<仓库名>/<skill-name>/`，把你自写 skills 放在 `skills/<skill-name>/`；并修复 GitHub Actions 自动同步/自动 push；仓库内不再包含会触发 GitHub Secret Scanning 的真实密钥或“像密钥的字符串”。

## Current Phase
Phase 5

## Phases

### Phase 1: Requirements & Discovery
- [x] 明确同步来源（用户已给定 URL/目录）
- [x] 定位 Actions 失败入口（`.github/workflows/sync.yml` → `scripts/sync_sources.sh`）
- [x] 发现根因之一：同步脚本内硬编码本机绝对路径（Actions 会直接失败）
- [x] 初步扫描：当前仓库存在多处会触发 Secret Scanning 的“密钥样式”内容（主要在同步下来的 skills 文档/样例里）
- [x] 明确最终目录规范（以用户规则为准：上游二级、自己一级）
- [x] 记录关键发现到 findings.md
- **Status:** complete

### Phase 2: Planning & Structure
- [x] 定义统一的 sources 配置与同步规则
- [x] 设计“同步后脱敏/清理”步骤（避免 Secret Scanning）
- [x] 规划 inventory/index 生成逻辑（避免绝对路径）
- **Status:** complete

### Phase 3: Implementation
- [x] 修复 `scripts/sync_sources.sh`（去绝对路径、输出结构扁平化）
- [x] 更新 `sources/sources.json`（与新结构一致）
- [x] 加入脱敏脚本并集成到同步流程
- [x] 把本地 skills 恢复为一级：`skills/<skill-name>/`（与上游 repo 目录并存）
- **Status:** complete

### Phase 4: Testing & Verification
- [x] 本地运行 `bash scripts/sync_sources.sh` 验证可重入
- [x] 复跑密钥样式扫描：不再命中
- [x] 校验 `INDEX.md` / `_inventory.json` 内容与结构一致
- **Status:** complete

### Phase 5: Delivery
- [ ] 汇总改动点与后续需要你在 GitHub 上操作的事项（如需 rotate/revoke）
- **Status:** in_progress

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 上游 skills 输出结构改为 `skills/<repoName>/<skill-name>/`（去掉 `category` 层） | 匹配你原始定义，避免 `skills/<repo>/skills/<skill>` 这种“多一层”导致结构乱 |
| 同步后增加“脱敏/清理”步骤 | GitHub Secret Scanning 会对样例/模板里的密钥样式内容报警，需要在入库前去除 |
| 本地 skills 直接放到 `skills/<skill-name>/` | 对齐你的规则：自写/本地技能不再额外嵌套到 `_local/openclaw-installed` |
| `_inventory.json` 改为相对路径并随同步自动重建 | 避免绝对路径污染仓库，保持结构一致 |

## Errors Encountered
| Error | Resolution |
|-------|------------|
| `init-session.sh` 无执行权限 | 通过 `bash /Users/liam/.codex/skills/planning-with-files/scripts/init-session.sh` 运行成功 |
