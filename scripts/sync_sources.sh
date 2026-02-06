#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SRC_JSON="$ROOT/sources/sources.json"
UPSTREAM_DIR="$ROOT/upstream"
OUT_DIR="$ROOT/skills"

mkdir -p "$UPSTREAM_DIR" "$OUT_DIR"

python3 - <<'PY'
import json, os, re, subprocess, shutil
from pathlib import Path

root = Path.cwd()
conf = json.loads((root / 'sources' / 'sources.json').read_text('utf-8'))
up_dir = root / 'upstream'
out_dir = root / 'skills'

# Your rule:
# - your own skills live at: skills/<skill-name>/SKILL.md  (no grouping)
# - synced from GitHub repos live at: skills/<repoName>/<skill-name>/...

protected = {
  'README.md','INDEX.md','_inventory','_inventory.json',
  # legacy/local buckets (keep, don't touch)
  'openclaw-installed','clawd-skills','openclaw-system'
}

sources = conf['sources']

DEBUG_REDACT = os.environ.get('DEBUG_REDACT') == '1'
WATCH_SUFFIXES = {
    'skills/openclaw-skills/ezbreadsniper/lifepath/src/services/storyGenerator.js',
    'skills/openclaw-skills/musallat-dev/musallat-bot/skill.md',
    'skills/openclaw-skills/wysh3/mrc-monitor/scripts/monitor.py',
}

# GitHub Secret Scanning 会对“像密钥的字符串”报警。
# 这里在同步后做一次脱敏，确保仓库里不包含真实密钥/样例密钥。
REDACTION_RULES: list[tuple[str, re.Pattern[str], str]] = [
    ('Alibaba AccessKey ID', re.compile(r'\bLTAI[0-9A-Za-z]{12,}\b'), '<ALIBABA_ACCESS_KEY_ID_REDACTED>'),
    ('Google API Key', re.compile(r'AIza[0-9A-Za-z_-]{35}'), '<GOOGLE_API_KEY_REDACTED>'),
    ('Google OAuth Client ID', re.compile(r'\b\d{6,}-[0-9A-Za-z_]{10,}\.apps\.googleusercontent\.com\b'), '<GOOGLE_OAUTH_CLIENT_ID_REDACTED>'),
    ('Google OAuth Client Secret', re.compile(r'GOCSPX-[0-9A-Za-z_-]{10,}'), '<GOOGLE_OAUTH_CLIENT_SECRET_REDACTED>'),
    ('Google Refresh Token', re.compile(r'(?:\b1//[0-9A-Za-z_-]{20,}\b|\bya29\.[0-9A-Za-z_-]{20,}\b)'), '<GOOGLE_REFRESH_TOKEN_REDACTED>'),
    ('Groq API Key', re.compile(r'\bgsk_[0-9A-Za-z_-]{20,}\b'), '<GROQ_API_KEY_REDACTED>'),
    ('Slack Token', re.compile(r'xox[baprs]-[0-9A-Za-z-]{10,}'), '<SLACK_TOKEN_REDACTED>'),
    ('Stripe Secret Key', re.compile(r'\b(?:sk|rk|pk)_(?:live|test)_[0-9A-Za-z]{10,}\b'), '<STRIPE_KEY_REDACTED>'),
    ('Stripe Webhook Secret', re.compile(r'\bwhsec_[0-9A-Za-z]{10,}\b'), '<STRIPE_WEBHOOK_SECRET_REDACTED>'),
    ('Tailscale Key', re.compile(r'\btskey-[0-9A-Za-z_-]{20,}\b'), '<TAILSCALE_KEY_REDACTED>'),
    ('Telegram Bot Token', re.compile(r'\b\d{8,10}:[0-9A-Za-z_-]{35}\b'), '<TELEGRAM_BOT_TOKEN_REDACTED>'),
    # Some repos intentionally include this marker as an example/test string; it triggers secret scanners.
    ('Private Key Marker', re.compile(r'-{5}BEGIN PRIVATE KEY-{5}'), '<PRIVATE_KEY_REDACTED>'),
]

# key/value 型的（无固定前缀），只在“字段名”附近替换值
KV_REDACTIONS: list[tuple[str, re.Pattern[str], str]] = [
    (
        'Alibaba AccessKey Secret (kv)',
        re.compile(r"(?i)(['\\\"]?AccessKeySecret['\\\"]?\s*[:=]\s*['\\\"])([^'\\\"]{8,})(['\\\"])"),
        r'\1<ALIBABA_ACCESS_KEY_SECRET_REDACTED>\3',
    ),
    (
        'Alibaba AccessKey ID (kv)',
        re.compile(r"(?i)(['\\\"]?AccessKeyId['\\\"]?\s*[:=]\s*['\\\"])([^'\\\"]{8,})(['\\\"])"),
        r'\1<ALIBABA_ACCESS_KEY_ID_REDACTED>\3',
    ),
    (
        'Lark App Secret (kv)',
        re.compile(r"(?i)(['\\\"]?app_secret['\\\"]?\s*[:=]\s*['\\\"])([^'\\\"]{8,})(['\\\"])"),
        r'\1<LARK_APP_SECRET_REDACTED>\3',
    ),
    (
        'Google Client Secret (kv)',
        re.compile(r"(?i)(['\\\"]?client_secret['\\\"]?\s*[:=]\s*['\\\"])([^'\\\"]{8,})(['\\\"])"),
        r'\1<GOOGLE_OAUTH_CLIENT_SECRET_REDACTED>\3',
    ),
]

PRIVATE_KEY_BLOCK = re.compile(
    r'-{5}BEGIN PRIVATE KEY-{5}.*?-{5}END PRIVATE KEY-{5}',
    flags=re.DOTALL,
)

VERIFY_RULES: list[tuple[str, re.Pattern[str]]] = [
    ('Alibaba AccessKey ID', re.compile(r'\bLTAI[0-9A-Za-z]{12,}\b')),
    ('Google API Key', re.compile(r'AIza[0-9A-Za-z_-]{35}')),
    ('Google OAuth Client ID', re.compile(r'\b\d{6,}-[0-9A-Za-z_]{10,}\.apps\.googleusercontent\.com\b')),
    ('Google OAuth Client Secret', re.compile(r'GOCSPX-[0-9A-Za-z_-]{10,}')),
    ('Google Refresh Token', re.compile(r'(?:\b1//[0-9A-Za-z_-]{20,}\b|\bya29\.[0-9A-Za-z_-]{20,}\b)')),
    ('Groq API Key', re.compile(r'\bgsk_[0-9A-Za-z_-]{20,}\b')),
    ('Slack Token', re.compile(r'xox[baprs]-[0-9A-Za-z-]{10,}')),
    ('Stripe Secret Key', re.compile(r'\b(?:sk|rk|pk)_(?:live|test)_[0-9A-Za-z]{10,}\b')),
    ('Stripe Webhook Secret', re.compile(r'\bwhsec_[0-9A-Za-z]{10,}\b')),
    ('Tailscale Key', re.compile(r'\btskey-[0-9A-Za-z_-]{20,}\b')),
    ('Telegram Bot Token', re.compile(r'\b\d{8,10}:[0-9A-Za-z_-]{35}\b')),
    ('Private Key Marker', re.compile(r'-{5}BEGIN PRIVATE KEY-{5}')),
]

GOOGLE_API_KEY_RX = re.compile(r'AIza[0-9A-Za-z_-]{35}')

TEXT_EXTS = {
    '',  # allow extension-less scripts/configs
    '.md', '.txt', '.json', '.yaml', '.yml', '.toml', '.env',
    '.js', '.ts', '.mjs', '.cjs', '.py', '.sh', '.bash',
    '.html', '.css', '.xml',
    '.ini', '.cfg', '.conf', '.properties',
    '.csv', '.tsv',
    '.ps1', '.bat',
}

SKIP_DIR_NAMES = {
    '.git', 'node_modules', 'dist', 'build', '__pycache__',
}

SKIP_FILE_NAMES = {
    '.DS_Store',
}

SKIP_EXTS = {
    '.png', '.jpg', '.jpeg', '.gif', '.webp', '.svg', '.ico',
    '.ttf', '.otf', '.woff', '.woff2',
    '.pdf', '.zip', '.gz', '.tgz', '.tar',
    '.mp3', '.mp4', '.mov', '.wav',
    '.alias',
}

def should_skip_path(p: Path) -> bool:
    parts = set(p.parts)
    if parts & SKIP_DIR_NAMES:
        return True
    if p.name in SKIP_FILE_NAMES:
        return True
    ext = p.suffix.lower()
    if ext in SKIP_EXTS:
        return True
    # only treat as text if extension is known (or no extension)
    if ext not in TEXT_EXTS:
        return True
    return False

def is_binary(data: bytes) -> bool:
    return b'\x00' in data

def redact_content(text: str) -> tuple[str, list[str]]:
    changed_rules: list[str] = []

    new_text = PRIVATE_KEY_BLOCK.sub('<PRIVATE_KEY_REDACTED>', text)
    if new_text != text:
        changed_rules.append('Private Key Block')
        text = new_text

    for name, rx, replacement in REDACTION_RULES:
        new_text = rx.sub(replacement, text)
        if new_text != text:
            changed_rules.append(name)
            text = new_text

    for name, rx, replacement in KV_REDACTIONS:
        new_text = rx.sub(replacement, text)
        if new_text != text:
            changed_rules.append(name)
            text = new_text

    return text, changed_rules

def redact_tree(root_dir: Path) -> None:
    touched = 0
    changed = 0
    for p in root_dir.rglob('*'):
        if p.is_dir():
            continue
        if should_skip_path(p):
            continue
        try:
            data = p.read_bytes()
        except Exception:
            continue
        if len(data) > 1_500_000:
            continue
        if is_binary(data):
            continue
        text = data.decode('utf-8', errors='ignore')
        if DEBUG_REDACT:
            p_posix = p.as_posix()
            if any(p_posix.endswith(suf) for suf in WATCH_SUFFIXES):
                print(f'[debug] before GoogleAPI matches={len(GOOGLE_API_KEY_RX.findall(text))} file={p_posix}')
        new_text, rules = redact_content(text)
        touched += 1
        if not rules:
            continue
        try:
            p.write_text(new_text, encoding='utf-8')
        except Exception:
            continue
        if DEBUG_REDACT:
            p_posix = p.as_posix()
            if any(p_posix.endswith(suf) for suf in WATCH_SUFFIXES):
                print(f'[debug] after  GoogleAPI matches={len(GOOGLE_API_KEY_RX.findall(new_text))} file={p_posix}')
        changed += 1
    print(f'[redact] scanned={touched} changed={changed} root={root_dir}')

def verify_tree(root_dir: Path) -> None:
    hits: list[tuple[str, str]] = []
    for p in root_dir.rglob('*'):
        if p.is_dir():
            continue
        if should_skip_path(p):
            continue
        try:
            data = p.read_bytes()
        except Exception:
            continue
        if len(data) > 1_500_000:
            continue
        if is_binary(data):
            continue
        text = data.decode('utf-8', errors='ignore')
        for name, rx in VERIFY_RULES:
            if rx.search(text):
                hits.append((name, str(p)))
                break
    if hits:
        print('[redact][verify] Remaining secret-like patterns found (file paths only):')
        for name, fp in hits[:100]:
            print(f'- {name}: {fp}')
        raise SystemExit(f'Redaction incomplete: {len(hits)} file(s) still match secret patterns.')

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

    dest_root = out_dir/dest_repo
    dest_root.mkdir(parents=True, exist_ok=True)

    # copy: each first-level entry under the declared source path -> skills/<repoName>/...
    for child in sorted(src_root.iterdir()):
        name = child.name
        if name.startswith('.git'):
            continue
        dest = dest_root/name
        if dest.exists():
            raise SystemExit(f"Destination already exists (name collision): {dest}")
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
lines.append('## 同步来源（按 GitHub 仓库 → skill）\n')

for repo_name in managed_repo_names:
    rp = out_dir/repo_name
    if not rp.exists():
        continue
    skills=[]
    for p in sorted([x for x in rp.iterdir() if x.is_dir() and not x.name.startswith('.')]):
        has = any(True for _ in p.rglob('SKILL.md')) or any(True for _ in p.rglob('skill.md'))
        if has:
            skills.append(p.name)
    lines.append(f'### {repo_name}/（识别到技能目录：{len(skills)}）\n')
    if skills:
        for n in skills[:120]:
            lines.append(f'- ✅ {n}\n')
    else:
        lines.append('- ⚠️ 未识别到 SKILL.md（可能是集合/文档仓库）\n')
    lines.append('\n')

out_idx.write_text(''.join(lines), encoding='utf-8')

# rebuild _inventory.json (user skills only; repo-relative paths)
user_inventory = []
for p in sorted(out_dir.iterdir()):
    if not p.is_dir() or p.name in protected or p.name in managed_repo_names or p.name.startswith('_'):
        continue
    if (p/'SKILL.md').exists():
        user_inventory.append({'name': p.name, 'path': f'skills/{p.name}'})

(out_dir/'_inventory.json').write_text(
    json.dumps({'count': len(user_inventory), 'skills': user_inventory}, ensure_ascii=False, indent=2) + '\n',
    encoding='utf-8',
)

# redact secrets-like strings in managed outputs (avoid touching user-owned folders)
for repo_name in managed_repo_names:
    tgt = out_dir / repo_name
    if tgt.exists():
        redact_tree(tgt)
        verify_tree(tgt)
PY
