#!/usr/bin/env bash
set -ue

is_ci() {
  [ "${CI:-}" = "true" ] || [ "${GITHUB_ACTIONS:-}" = "true" ]
}

helpmsg() {
  command echo "Usage: $0 [--help | -h]" 0>&2
  command echo ""
}

link_to_homedir() {
  command echo "backup old dotfiles..."
  if [ ! -d "$HOME/.dotbackup" ];then
    command echo "$HOME/.dotbackup not found. Auto Make it"
    command mkdir "$HOME/.dotbackup"
  fi

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  local dotdir
  dotdir=$(dirname "${script_dir}")
  if [[ "$HOME" != "$dotdir" ]];then
    for f in "$dotdir"/.??*; do
      [[ $(basename "$f") == ".git" ]] && continue
      [[ $(basename "$f") == ".claude" ]] && continue
      if [[ -L "$HOME/$(basename "$f")" ]];then
        command rm -f "$HOME/$(basename "$f")"
      fi
      if [[ -e "$HOME/$(basename "$f")" ]];then
        command mv "$HOME/$(basename "$f")" "$HOME/.dotbackup"
      fi
      command ln -snf "$f" "$HOME"
    done
  else
    command echo "same install src dest"
  fi
}

link_claude_config() {
  command echo "linking claude config..."

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  local dotdir
  dotdir=$(dirname "${script_dir}")

  # ~/.claudeディレクトリがなければ作成
  if [ ! -d "$HOME/.claude" ]; then
    command mkdir -p "$HOME/.claude"
  fi

  # hooksディレクトリがなければ作成
  if [ ! -d "$HOME/.claude/hooks" ]; then
    command mkdir -p "$HOME/.claude/hooks"
  fi

  # skillsディレクトリがなければ作成
  if [ ! -d "$HOME/.claude/skills" ]; then
    command mkdir -p "$HOME/.claude/skills"
  fi

  # 個別ファイルをシンボリックリンク
  for f in "$dotdir/.claude/CLAUDE.md" "$dotdir/.claude/settings.json"; do
    if [ -f "$f" ]; then
      local file_basename
      file_basename=$(basename "$f")
      # 既存ファイルをバックアップ
      if [ -e "$HOME/.claude/$file_basename" ] && [ ! -L "$HOME/.claude/$file_basename" ]; then
        command mv "$HOME/.claude/$file_basename" "$HOME/.dotbackup/"
      fi
      # 既存シンボリックリンクを削除
      if [ -L "$HOME/.claude/$file_basename" ]; then
        command rm -f "$HOME/.claude/$file_basename"
      fi
      command ln -snf "$f" "$HOME/.claude/$file_basename"
    fi
  done

  # hooksディレクトリ内のファイルをシンボリックリンク
  if [ -d "$dotdir/.claude/hooks" ]; then
    for f in "$dotdir/.claude/hooks/"*; do
      if [ -f "$f" ]; then
        local hook_basename
        hook_basename=$(basename "$f")
        if [ -L "$HOME/.claude/hooks/$hook_basename" ]; then
          command rm -f "$HOME/.claude/hooks/$hook_basename"
        fi
        if [ -e "$HOME/.claude/hooks/$hook_basename" ] && [ ! -L "$HOME/.claude/hooks/$hook_basename" ]; then
          command mv "$HOME/.claude/hooks/$hook_basename" "$HOME/.dotbackup/"
        fi
        command ln -snf "$f" "$HOME/.claude/hooks/$hook_basename"
      fi
    done
  fi

  # skillsディレクトリ内のサブディレクトリをシンボリックリンク
  if [ -d "$dotdir/.claude/skills" ]; then
    for skill_dir in "$dotdir/.claude/skills/"*/; do
      if [ -d "$skill_dir" ]; then
        local skill_name
        skill_name=$(basename "$skill_dir")
        if [ -L "$HOME/.claude/skills/$skill_name" ]; then
          command rm -f "$HOME/.claude/skills/$skill_name"
        fi
        if [ -e "$HOME/.claude/skills/$skill_name" ] && [ ! -L "$HOME/.claude/skills/$skill_name" ]; then
          command mv "$HOME/.claude/skills/$skill_name" "$HOME/.dotbackup/"
        fi
        command ln -snf "$skill_dir" "$HOME/.claude/skills/$skill_name"
      fi
    done
  fi
}

while [ $# -gt 0 ];do
  case ${1} in
    --debug|-d)
      set -uex
      ;;
    --help|-h)
      helpmsg
      exit 1
      ;;
    *)
      ;;
  esac
  shift
done

link_to_homedir
link_claude_config

if ! is_ci; then
  git config --global include.path "$HOME/.gitconfig_shared"
fi

command echo -e "\e[1;36m Install completed!!!! \e[m"
