#!/usr/bin/env python3
"""
GitHub CLI (gh) コマンドの実行前確認フック

Exit codes:
  0 - 正常終了（JSONを出力した場合はその指示に従う、出力なしはデフォルト許可フロー）
  1 - エラー（Claudeにエラーメッセージが表示される）
  2 - ツール呼び出しをブロック（stderrのメッセージがClaudeに表示される）

permissionDecision:
  "allow" - 自動承認（ユーザー確認なし）
  "ask"   - ユーザーに確認ダイアログを表示
  "deny"  - 拒否（Claudeに理由が表示される）
"""
import json
import sys


def main():
    # 標準入力からJSON読み込み
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})
    command = tool_input.get("command", "")

    # gh コマンド以外はスルー（デフォルト許可フローに任せる）
    if tool_name != "Bash" or not command.startswith("gh "):
        sys.exit(0)

    # 読み取り専用コマンドは自動承認
    read_only_patterns = [
        "gh pr view",
        "gh pr list",
        "gh pr status",
        "gh pr diff",
        "gh pr checks",
        "gh issue view",
        "gh issue list",
        "gh issue status",
        "gh repo view",
        "gh repo list",
        "gh api",
        "gh auth status",
        "gh auth token",
        "gh run view",
        "gh run list",
        "gh run watch",
        "gh release view",
        "gh release list",
        "gh search",
        "gh browse",
    ]

    for pattern in read_only_patterns:
        if command.startswith(pattern):
            output = {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "allow",
                    "permissionDecisionReason": "読み取り専用コマンド - 自動承認",
                }
            }
            print(json.dumps(output))
            sys.exit(0)

    # 書き込み系コマンドは確認を求める
    write_patterns = [
        "gh pr create",
        "gh pr comment",
        "gh pr merge",
        "gh pr close",
        "gh pr reopen",
        "gh pr edit",
        "gh pr review",
        "gh issue create",
        "gh issue comment",
        "gh issue close",
        "gh issue reopen",
        "gh issue edit",
        "gh issue delete",
        "gh repo create",
        "gh repo delete",
        "gh repo edit",
        "gh repo fork",
        "gh release create",
        "gh release delete",
        "gh release edit",
        "gh run cancel",
        "gh run rerun",
        "gh gist create",
        "gh gist edit",
        "gh gist delete",
    ]

    for pattern in write_patterns:
        if command.startswith(pattern):
            output = {
                "hookSpecificOutput": {
                    "hookEventName": "PreToolUse",
                    "permissionDecision": "ask",
                    "permissionDecisionReason": f"GitHub書き込み操作の確認: {pattern}",
                }
            }
            print(json.dumps(output))
            sys.exit(0)

    # 未知のghコマンドはデフォルトで確認を求める（安全側に倒す）
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": f"未分類のghコマンド: {command[:50]}",
        }
    }
    print(json.dumps(output))
    sys.exit(0)


if __name__ == "__main__":
    main()
