#!/usr/bin/env python3
"""
Stop Hook: ドキュメント更新の必要性をチェック

作業完了時に実行され、コード変更があった場合に
ドキュメント監査を促す。
"""
import json
import sys
import subprocess
from pathlib import Path


def get_git_root():
    """現在のディレクトリの git root を取得"""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            return Path(result.stdout.strip())
    except Exception:
        pass
    return None


def get_changed_files(git_root):
    """git で変更されたファイルを取得"""
    try:
        result = subprocess.run(
            ["git", "diff", "--name-only", "HEAD"],
            capture_output=True,
            text=True,
            cwd=git_root,
        )

        if result.returncode == 0:
            files = [f for f in result.stdout.strip().split("\n") if f]
            return files
    except Exception:
        pass
    return []


def find_project_docs(git_root):
    """プロジェクト内のドキュメントファイルを検出"""
    doc_patterns = [
        "README.md",
        "README.mdx",
        "CHANGELOG.md",
        "CHANGELOG.txt",
        "CONTRIBUTING.md",
        ".claude/CLAUDE.md",
    ]

    found_docs = []
    for pattern in doc_patterns:
        doc_path = git_root / pattern
        if doc_path.exists():
            found_docs.append(str(pattern))

    docs_dir = git_root / "docs"
    if docs_dir.exists() and docs_dir.is_dir():
        for md_file in docs_dir.rglob("*.md"):
            found_docs.append(str(md_file.relative_to(git_root)))

    return found_docs


def is_code_change(files):
    """コード変更かどうかを判定（ドキュメントのみの変更を除外）"""
    code_extensions = {
        ".py",
        ".js",
        ".ts",
        ".tsx",
        ".jsx",
        ".go",
        ".rs",
        ".java",
        ".kt",
        ".swift",
        ".c",
        ".cpp",
        ".h",
        ".lua",
        ".sh",
        ".zsh",
        ".bash",
        ".json",
        ".yaml",
        ".yml",
        ".toml",
    }

    for f in files:
        ext = Path(f).suffix.lower()
        if ext in code_extensions and not f.endswith(".md"):
            return True
    return False


def main():
    try:
        json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    git_root = get_git_root()
    if not git_root:
        sys.exit(0)

    changed_files = get_changed_files(git_root)

    if not changed_files:
        sys.exit(0)

    if not is_code_change(changed_files):
        sys.exit(0)

    project_docs = find_project_docs(git_root)

    if not project_docs:
        sys.exit(0)

    docs_list = "\n".join(f"- {doc}" for doc in project_docs[:5])
    changed_list = "\n".join(f"- {f}" for f in changed_files[:5])
    extra_files = (
        f"... 他 {len(changed_files) - 5} ファイル" if len(changed_files) > 5 else ""
    )

    output = {
        "decision": "block",
        "reason": f"""コード変更が検出されました。ドキュメントの更新が必要か確認してください。

変更されたファイル:
{changed_list}
{extra_files}

プロジェクト内のドキュメント:
{docs_list}

documentation-auditor Skill を使用して、ドキュメントの更新が必要か確認してください。
更新が不要な場合は、その旨をユーザーに伝えてください。""",
    }

    print(json.dumps(output, ensure_ascii=False))


if __name__ == "__main__":
    main()
