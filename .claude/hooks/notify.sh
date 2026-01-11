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
# Note: terminal-notifierは「[」で始まるメッセージを正しく処理できないため
# メッセージの形式を変更
if [ "$HOOK_EVENT" = "stop" ]; then
    TITLE="Claude Code"
    BODY="Task Completed: $PROJECT ($TIMESTAMP)"
    SOUND="Tink"
elif [ "$HOOK_EVENT" = "notification" ]; then
    TITLE="Claude Code"
    if echo "$MESSAGE" | grep -qi "permission"; then
        BODY="Permission Required: $PROJECT ($TIMESTAMP)"
    else
        BODY="Input Required: $PROJECT ($TIMESTAMP)"
    fi
    SOUND="Glass"
else
    exit 0
fi

# OSC 9/777でWezTermに通知
printf '\033]9;%s: %s\007' "$TITLE" "$BODY"
printf '\033]777;notify;%s;%s\007' "$TITLE" "$BODY"

# 音を鳴らす
SOUND_FILE="/System/Library/Sounds/${SOUND}.aiff"
if [ -f "$SOUND_FILE" ]; then
    afplay "$SOUND_FILE" &
fi

# terminal-notifierで通知（クリックでWezTermをアクティベート）
if command -v terminal-notifier &> /dev/null; then
    exec /opt/homebrew/bin/terminal-notifier \
        -title "$TITLE" \
        -message "$BODY" \
        -activate "com.github.wez.wezterm" \
        < /dev/null 2>/dev/null
fi

exit 0
