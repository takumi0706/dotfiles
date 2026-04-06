# shellcheck shell=bash
# IDE環境起動コマンド
# 使い方: ide [directory]
ide() {
  local dir="${1:-.}"
  dir="$(cd "$dir" && pwd)" || return 1

  # WezTerm内で実行されているか確認
  if [ -z "$WEZTERM_PANE" ]; then
    echo "Error: This command must be run inside WezTerm" >&2
    return 1
  fi

  # ワークスペース名 (ディレクトリ名ベース)
  local ws_name
  ws_name="ide-$(basename "$dir")"
  local socket_name="nvim-ide-${ws_name//[^a-zA-Z0-9]/_}"
  local nvim_socket="/tmp/${socket_name}.sock"

  # 既存ソケットを削除 (前回の異常終了の残り)
  [ -S "$nvim_socket" ] && rm -f "$nvim_socket"

  # 下パネルを作成 (30%)
  local bottom_pane_id
  bottom_pane_id=$(wezterm cli split-pane --bottom --percent 30 --cwd "$dir" --pane-id "$WEZTERM_PANE")

  # Neovimをフォアグラウンドで起動 (このペインで)
  wezterm cli activate-pane --pane-id "$WEZTERM_PANE"
  nvim --listen "$nvim_socket" "$dir"

  # Neovim終了後: 下パネルを閉じる
  if [ -n "$bottom_pane_id" ]; then
    wezterm cli send-text --pane-id "$bottom_pane_id" --no-paste $'\x03' 2>/dev/null
    wezterm cli send-text --pane-id "$bottom_pane_id" "exit\n" 2>/dev/null
  fi

  # ソケットクリーンアップ
  [ -S "$nvim_socket" ] && rm -f "$nvim_socket"
}
