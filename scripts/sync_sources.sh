#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SRC_JSON="$ROOT/sources/sources.json"
UPSTREAM_DIR="$ROOT/upstream"
OUT_DIR="$ROOT/skills"

mkdir -p "$UPSTREAM_DIR" "$OUT_DIR"

python3 - <<'PY'
import json, os, subprocess, shutil
from pathlib import Path

root = Path('/Users/liam/project/github_repositories/All-skills')
conf = json.loads((root/'sources/sources.json').read_text('utf-8'))
up_dir = root/'upstream'
out_dir = root/'skills'

# Your rule:
# - your own skills live at: skills/<skill-name>/SKILL.md  (no grouping)
# - synced from GitHub repos live at: skills/<repoName>/<category>/<skill-name>/...

protected = {
  'README.md','INDEX.md','_inventory','_inventory.json',
  # legacy/local buckets (keep, don't touch)
  'openclaw-installed','clawd-skills','openclaw-system'
}

sources = conf['sources']

# remove old synced repo/category outputs (only the repoName folders we manage)
managed_repo_names = sorted({s['dest']['repoName'] for s in sources})
for repo_name in managed_repo_names:
    tgt = out_dir/repo_name
    if tgt.exists():
        shutil.rmtree(tgt)


def run(cmd, cwd=None):
    subprocess.check_call(cmd, cwd=cwd)

for s in sources:
    sid = s['id']
    repo = s['repo']
    ref = s.get('ref')  # optional; if missing or invalid, we fall back to origin default branch
    path = s.get('path','.')

    dest_repo = s['dest']['repoName']
    dest_cat = s['dest']['category']

    local = up_dir/sid.replace('/','__').replace(':','__')
    def get_default_branch(repo_dir: Path) -> str:
        # origin/HEAD -> refs/remotes/origin/<branch>
        try:
            out = subprocess.check_output(
                ['git','-C',str(repo_dir),'symbolic-ref','refs/remotes/origin/HEAD'],
                text=True
            ).strip()
            return out.rsplit('/',1)[-1]
        except Exception:
            return 'main'

    if not local.exists():
        run(['git','clone','--filter=blob:none','--no-checkout',repo,str(local)])

    run(['git','-C',str(local),'sparse-checkout','init','--cone'])
    # cone mode expects directories; allow '.'
    if path == '.':
        run(['git','-C',str(local),'sparse-checkout','set','.'])
    else:
        run(['git','-C',str(local),'sparse-checkout','set',path])

    branch = ref or get_default_branch(local)

    # fetch + checkout (fallback to default branch if configured branch doesn't exist)
    try:
        run(['git','-C',str(local),'fetch','origin',branch])
        run(['git','-C',str(local),'checkout',branch])
        run(['git','-C',str(local),'pull','--ff-only','origin',branch])
    except subprocess.CalledProcessError:
        branch = get_default_branch(local)
        run(['git','-C',str(local),'fetch','origin',branch])
        run(['git','-C',str(local),'checkout',branch])
        run(['git','-C',str(local),'pull','--ff-only','origin',branch])

    src_root = local if path == '.' else (local/path)
    if not src_root.exists():
        raise SystemExit(f"Source path not found for {sid}: {src_root}")

    dest_root = out_dir/dest_repo/dest_cat
    dest_root.mkdir(parents=True, exist_ok=True)

    # copy: each first-level entry under the declared source path -> skills/<repoName>/<category>/...
    for child in sorted(src_root.iterdir()):
        name = child.name
        if name.startswith('.git'):
            continue
        dest = dest_root/name
        if child.is_dir():
            shutil.copytree(
                child,
                dest,
                dirs_exist_ok=True,
                ignore=shutil.ignore_patterns('.git','node_modules','dist','build','__pycache__','.DS_Store')
            )
        else:
            # allow repos like awesome lists to bring in README/docs under category/root
            shutil.copy2(child, dest)

# rebuild INDEX.md (grouped)
out_idx = out_dir/'INDEX.md'
lines=[]
lines.append('# Skills 清单（All-skills）\n\n')
lines.append('## 你的 skills（不分类）\n')

managed_repo_names = sorted({s['dest']['repoName'] for s in sources})

user_skills=[]
for p in sorted(out_dir.iterdir()):
    if not p.is_dir() or p.name in protected or p.name in managed_repo_names or p.name.startswith('_'):
        continue
    if (p/'SKILL.md').exists():
        user_skills.append(p.name)
if user_skills:
    for n in user_skills:
        lines.append(f'- ✅ **{n}**\n')
else:
    lines.append('- （暂无；你直接创建 `skills/<skill-name>/SKILL.md` 即可）\n')

lines.append('\n---\n')
lines.append('## 同步来源（按 GitHub 仓库 → 分类 → skill）\n')

for repo_name in managed_repo_names:
    rp = out_dir/repo_name
    if not rp.exists():
        continue
    cats = [c for c in sorted(rp.iterdir()) if c.is_dir() and not c.name.startswith('.')]
    lines.append(f'### {repo_name}/\n')
    for cat in cats:
        skills=[]
        for p in sorted([x for x in cat.iterdir() if x.is_dir()]):
            has = any(True for _ in p.rglob('SKILL.md')) or any(True for _ in p.rglob('skill.md'))
            if has:
                skills.append(p.name)
        lines.append(f'- 分类：**{cat.name}**（识别到技能目录：{len(skills)}）\n')
        if skills:
            for n in skills[:120]:
                lines.append(f'  - ✅ {n}\n')
        else:
            lines.append('  - ⚠️ 该分类下未识别到 SKILL.md（可能是集合/文档仓库）\n')
    lines.append('\n')

out_idx.write_text(''.join(lines), encoding='utf-8')
PY
