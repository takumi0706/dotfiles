#!/usr/bin/env python3
"""
Claude Code 通知フック

WezTermへのOSC 9通知とterminal-notifier（フォールバック）を使用して
Claude Codeのイベントをデスクトップ通知します。
"""
import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

# 通知サウンド設定
SOUNDS = {
    "notification": "Glass",  # 入力待ち: 注意喚起
    "stop": "Tink",          # 完了: 控えめ
}


def get_project_name(cwd: str) -> str:
    """作業ディレクトリからプロジェクト名を取得"""
    if not cwd:
        return "Unknown"
    return Path(cwd).name


def get_timestamp() -> str:
    """現在時刻を取得（HH:MM形式）"""
    return datetime.now().strftime("%H:%M")


def send_osc_notification(title: str, message: str) -> bool:
    """
    OSC 9/777エスケープシーケンスでWezTermに通知を送信

    OSC 9形式: \\033]9;message\\007
    OSC 777形式: \\033]777;notify;title;body\\007
    """
    try:
        tty = os.ttyname(sys.stdout.fileno())
        with open(tty, "w") as terminal:
            terminal.write(f"\033]9;{title}: {message}\007")
            terminal.write(f"\033]777;notify;{title};{message}\007")
            terminal.flush()
        return True
    except (OSError, AttributeError):
        try:
            sys.stdout.write(f"\033]9;{title}: {message}\007")
            sys.stdout.write(f"\033]777;notify;{title};{message}\007")
            sys.stdout.flush()
            return True
        except Exception:
            pass
    return False


def send_terminal_notifier(title: str, message: str, sound: str) -> bool:
    """terminal-notifierでmacOS通知センターに通知を送信"""
    try:
        subprocess.run(
            [
                "terminal-notifier",
                "-title",
                title,
                "-message",
                message,
                "-sound",
                sound,
                "-group",
                "claude-code",
            ],
            check=True,
            capture_output=True,
            timeout=5,
        )
        return True
    except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
        return False


def send_afplay_sound(sound: str) -> None:
    """afplayでシステムサウンドを再生（フォールバック）"""
    sound_path = f"/System/Library/Sounds/{sound}.aiff"
    if Path(sound_path).exists():
        try:
            subprocess.Popen(
                ["afplay", sound_path],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except Exception:
            pass


def build_message(
    event_type: str, project: str, ts: str, msg: str | None = None
) -> tuple[str, str]:
    """
    通知のタイトルとメッセージを生成

    Returns:
        tuple[str, str]: (title, message)
    """
    if event_type == "stop":
        return (
            "Claude Code - Task Completed",
            f"[{project}] タスクが完了しました ({ts})",
        )
    elif event_type == "notification":
        if msg and "permission" in msg.lower():
            return (
                "Claude Code - Input Required",
                f"[{project}] 権限の確認が必要です ({ts})",
            )
        return (
            "Claude Code - Input Required",
            f"[{project}] 入力待ちです ({ts})",
        )
    return ("Claude Code", f"[{project}] {msg or 'Event'} ({ts})")


def main() -> None:
    # 標準入力からJSON読み込み
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)

    event = data.get("hook_event_name", "").lower()
    cwd = data.get("cwd", "")
    msg = data.get("message", "")

    # stop_hook_activeがtrueの場合は無限ループ防止のためスキップ
    if data.get("stop_hook_active", False):
        sys.exit(0)

    # 未知のイベントはスキップ
    if event not in ("stop", "notification"):
        sys.exit(0)

    # 通知情報を生成
    project = get_project_name(cwd)
    ts = get_timestamp()
    title, message = build_message(event, project, ts, msg)
    sound = SOUNDS.get(event, "Glass")

    # OSC 9で通知を送信
    send_osc_notification(title, message)

    # terminal-notifierでも通知（フォールバック兼サウンド再生）
    if not send_terminal_notifier(title, message, sound):
        send_afplay_sound(sound)

    sys.exit(0)


if __name__ == "__main__":
    main()
