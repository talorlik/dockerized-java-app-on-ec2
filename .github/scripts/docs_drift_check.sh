#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "Running docs drift checks..."
python3 <<'PY'
import pathlib
import re
import sys

root = pathlib.Path(".")
doc_files = [root / "README.md"] + [p for p in (root / "docs").rglob("*") if p.is_file()]
doc_files = [
    p for p in doc_files
    if p.as_posix() != "docs/auxiliary/operations_guide/DOC_SOURCE_OF_TRUTH_MATRIX.md"
]

forbidden = [
    (r"https://java\.talorlik\.com:8443", "legacy public endpoint on :8443"),
    (r"HTTPS `8443`", "legacy ALB listener docs on 8443"),
    (r"Merge to `main`", "outdated workflow trigger narrative"),
    (r"main merges", "outdated workflow trigger narrative"),
    (r"pull request touching `infra/\*\*`", "outdated infra-plan trigger narrative"),
    (r"--type String --overwrite --value sha-", "release params should be SecureString in docs"),
]

required = [
    (r"workflow_dispatch:", root / ".github/workflows/ci.yml", "ci manual trigger"),
    (r"workflow_call:", root / ".github/workflows/ci.yml", "ci reusable gate trigger"),
    (r"workflow_dispatch:", root / ".github/workflows/infra-plan.yml", "infra-plan manual trigger"),
    (r"workflow_dispatch:", root / ".github/workflows/infra-apply.yml", "infra-apply manual trigger"),
    (r"workflow_dispatch:", root / ".github/workflows/app-deploy.yml", "app-deploy manual trigger"),
]

failed = False

for pattern, label in forbidden:
    rx = re.compile(pattern)
    hits = []
    for file in doc_files:
        try:
            text = file.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        for idx, line in enumerate(text.splitlines(), 1):
            if rx.search(line):
                hits.append((file.as_posix(), idx, line.strip()))
    if hits:
        failed = True
        print(f"ERROR: Found forbidden drift token: {label}")
        for path, ln, line in hits[:20]:
            print(f"  {path}:{ln}: {line}")
        print()

for pattern, file, label in required:
    rx = re.compile(pattern)
    try:
        text = file.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        text = ""
    if not rx.search(text):
        failed = True
        print(f"ERROR: Missing expected canonical signal: {label} ({file.as_posix()})")

if failed:
    print("Docs drift check failed.")
    sys.exit(1)

print("Docs drift checks passed.")
PY
