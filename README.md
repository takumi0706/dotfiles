# dotfiles

macOS 環境を [Nix](https://nixos.org/) (nix-darwin + home-manager + flakes) で宣言的に管理する dotfiles。

## セットアップ

```bash
git clone https://github.com/takumi0706/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash .bin/install.sh
```

`install.sh` が以下を順番に実行します:

1. Nix のインストール（[Determinate Systems](https://determinate.systems/) インストーラ）
2. `darwin-rebuild switch` で Nix 構成を適用
3. `setup.sh` でシンボリックリンク作成（`.claude/` 等）

## 構成

```
dotfiles/
├── flake.nix              # エントリポイント
├── flake.lock             # 依存バージョンのロック
├── nix/
│   ├── darwin.nix         # macOS システム設定 (nix-darwin)
│   └── home.nix           # ユーザー環境 (home-manager)
├── .bin/
│   ├── install.sh         # 初回セットアップ
│   └── setup.sh           # シンボリックリンク作成
├── .config/
│   ├── nvim/              # Neovim (Lua + lazy.nvim)
│   ├── wezterm/           # WezTerm ターミナル
│   ├── starship.toml      # Starship プロンプト
│   ├── codex/             # OpenAI Codex CLI 設定テンプレ (初回 switch で ~/.codex/ にコピー)
│   └── zsh/               # Zsh 補完・fzf・IDE関数・secrets テンプレ
├── .agents/skills/        # AI agent skills (Codex 等で共通利用)
├── .claude/               # Claude Code 設定
├── Makefile               # install / setup / switch / lint
└── .github/workflows/     # CI (lint + build check)
```

## 管理対象パッケージ

| カテゴリ | パッケージ |
|---------|-----------|
| CLI ツール | starship, fzf, fd, bat, neovim, lazygit, ripgrep, jq, direnv, codex |
| ランタイム | Node.js 22 (LTS) |
| フォント | JetBrainsMono Nerd Font |
| Lint (devShell) | shellcheck, stylua, taplo, ruff, jq |
| GUI アプリ | WezTerm（手動インストール） |

## よく使うコマンド

```bash
# Nix 構成を再適用
make switch

# シンボリックリンクを再作成
make setup

# Lint 実行（devShell 経由）
make lint

# flake.lock を更新
nix flake update
```

## アーキテクチャ対応

Apple Silicon (aarch64) と Intel (x86_64) の両方に対応しています。
`install.sh` / `Makefile` / `switch` alias が自動的にアーキテクチャを判定します。

| 構成名 | アーキテクチャ |
|--------|--------------|
| `default` | aarch64-darwin (Apple Silicon) |
| `default-x86` | x86_64-darwin (Intel) |

## dotfiles の設定変更

nvim / wezterm / starship / zsh の設定ファイルは `mkOutOfStoreSymlink` 経由で `~/.config/` に symlink されているため、編集すれば即反映されます。`make switch` が必要なのは Nix 宣言の変更 (パッケージ追加・削除や `programs.*` の変更など) のみです。

Codex の `config.toml` は dotfiles 側のファイルが「初期テンプレ」として `~/.codex/config.toml` にコピーされます (Codex 自身が `[projects.*]` 等の実行時状態を書き込むため symlink にできない)。テンプレを更新して反映したい場合は `rm ~/.codex/config.toml && make switch` してください。

## API キー / シークレット

`~/.config/zsh/secrets.zsh` に環境変数を export する形で管理します。
初回 `make switch` 時に `.config/zsh/secrets.zsh.example` から自動コピーされます (既存ファイルは上書きしません)。
このファイルは git 管理対象外です。Codex の API キー認証を使う場合は `OPENAI_API_KEY` をここで設定してください。
ChatGPT ログイン認証を使う場合は `codex login` を1度実行すれば `~/.codex/auth.json` が自動生成されます。
