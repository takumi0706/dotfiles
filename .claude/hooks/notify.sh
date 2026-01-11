#!/bin/bash
#
# Claude Code 通知フック
# WezTermへのOSC通知とterminal-notifier（フォールバック）を使用
#

# 標準入力からJSONを読み込み
INPUT=$(cat)

# jqがなければ終了
if ! command -v jq &> /dev/null; then
    exit 0
fi

# JSONからデータを抽出
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // ""' | tr '[:upper:]' '[:lower:]')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
MESSAGE=$(echo "$INPUT" | jq -r '.message // ""')
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# stop_hook_activeがtrueの場合はスキップ
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

# 未知のイベントはスキップ
if [ "$HOOK_EVENT" != "stop" ] && [ "$HOOK_EVENT" != "notification" ]; then
    exit 0
fi

# プロジェクト名を取得
PROJECT=$(basename "$CWD")
if [ -z "$PROJECT" ]; then
    PROJECT="Unknown"
fi

# タイムスタンプを取得
TIMESTAMP=$(date +"%H:%M")

# イベントに応じたタイトルとメッセージを生成
if [ "$HOOK_EVENT" = "stop" ]; then
    TITLE="Claude Code - Task Completed"
    BODY="[$PROJECT] タスクが完了しました ($TIMESTAMP)"
    SOUND="Tink"
elif [ "$HOOK_EVENT" = "notification" ]; then
    TITLE="Claude Code - Input Required"
    if echo "$MESSAGE" | grep -qi "permission"; then
        BODY="[$PROJECT] 権限の確認が必要です ($TIMESTAMP)"
    else
        BODY="[$PROJECT] 入力待ちです ($TIMESTAMP)"
    fi
    SOUND="Glass"
else
    exit 0
fi

# OSC 9/777でWezTermに通知
printf '\033]9;%s: %s\007' "$TITLE" "$BODY"
printf '\033]777;notify;%s;%s\007' "$TITLE" "$BODY"

# terminal-notifierで通知（フォールバック）
if command -v terminal-notifier &> /dev/null; then
    terminal-notifier -title "$TITLE" -message "$BODY" -sound "$SOUND" &
fi

exit 0
