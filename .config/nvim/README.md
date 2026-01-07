# Neovim Configuration

モダンなNeovim設定（Lua）。IntelliJからの移行を意識した設計。

## Requirements

- Neovim >= 0.9
- JetBrainsMono Nerd Font（WezTermで設定済み）
- ripgrep, fd（Telescope用）
- lazygit（Git UI用）

```bash
brew install neovim ripgrep fd lazygit
```

## Quick Start

1. dotfilesのインストールスクリプトを実行してシンボリックリンクを作成
2. Neovimを起動: `nvim`
3. プラグインが自動インストールされる（初回は数分かかる）
4. `:Mason` でLSPサーバーをインストール

## Key Bindings

**Leader key: Space**

### Essential（最初に覚えるべきキー）

| キー | 操作 | 説明 |
|------|------|------|
| `i` | 挿入モード開始 | テキスト入力を開始 |
| `Esc` | ノーマルモードに戻る | 編集を終了 |
| `:w` | 保存 | ファイルを保存 |
| `:q` | 終了 | Neovimを終了 |
| `<Space>e` | ファイルツリー | サイドバーの表示/非表示 |
| `<Space>ff` | ファイル検索 | プロジェクト内のファイルを検索 |
| `<Space>fg` | テキスト検索 | プロジェクト全体をgrep検索 |
| `h/j/k/l` | カーソル移動 | 左/下/上/右 |

### IntelliJ対応表

| IntelliJ | Neovim | 説明 |
|----------|--------|------|
| Shift×2 | `<Space>ff` | ファイル検索 |
| Cmd+Shift+F | `<Space>fg` | テキスト検索 |
| Cmd+B | `gd` | 定義へジャンプ |
| Cmd+Option+B | `gi` | 実装へジャンプ |
| Option+F7 | `gr` | 参照を検索 |
| Shift+F6 | `<Space>rn` | リネーム |
| Option+Enter | `<Space>ca` | コードアクション |
| Cmd+1 | `<Space>e` | ファイルツリー |
| Cmd+Option+L | `<Space>lf` | フォーマット |
| Cmd+K | `<Space>gg` | Git操作（LazyGit） |

### 移動

| キー | 操作 |
|------|------|
| `w` / `b` | 単語単位で前/後ろに移動 |
| `0` / `$` | 行頭/行末 |
| `gg` / `G` | ファイル先頭/末尾 |
| `Ctrl+d` / `Ctrl+u` | 半ページ下/上スクロール |
| `{` / `}` | 段落単位で移動 |

### 編集

| キー | 操作 |
|------|------|
| `dd` | 行を削除 |
| `yy` | 行をコピー |
| `p` | 貼り付け |
| `u` | 元に戻す |
| `Ctrl+r` | やり直し |
| `ciw` | 単語を変更（change in word） |
| `di"` | ダブルクォート内を削除 |
| `gc` | コメントトグル（選択範囲） |

### ウィンドウ

| キー | 操作 |
|------|------|
| `<Space>sv` | 縦分割 |
| `<Space>sh` | 横分割 |
| `<Space>sc` | ウィンドウを閉じる |
| `Ctrl+h/j/k/l` | ウィンドウ間移動 |

### バッファ（タブ）

| キー | 操作 |
|------|------|
| `Tab` / `Shift+Tab` | 次/前のバッファ |
| `<Space>bd` | バッファを閉じる |
| `<Space><Space>` | バッファ一覧 |

### Git

| キー | 操作 |
|------|------|
| `<Space>gg` | LazyGit を開く |
| `<Space>gs` | hunkをステージ |
| `<Space>gr` | hunkをリセット |
| `<Space>gp` | hunkをプレビュー |
| `]h` / `[h` | 次/前のhunkへ移動 |

### LSP

| キー | 操作 |
|------|------|
| `gd` | 定義へジャンプ |
| `gr` | 参照を検索 |
| `gi` | 実装へジャンプ |
| `K` | ホバー（ドキュメント表示） |
| `<Space>ca` | コードアクション |
| `<Space>rn` | シンボルをリネーム |
| `<Space>lf` | フォーマット |
| `[d` / `]d` | 前/次の診断（エラー）へ移動 |

## Theme

**デフォルト**: Catppuccin Mocha（WezTermと統一）

### テーマ切り替え

- `<Space>tc` - Telescopeでプレビュー付き選択
- `:colorscheme tokyonight` - Tokyo Nightに切り替え
- `:colorscheme kanagawa` - Kanagawaに切り替え
- `:colorscheme catppuccin` - Catppuccinに戻す

## Plugins

| カテゴリ | プラグイン | 説明 |
|---------|------------|------|
| 管理 | lazy.nvim | プラグインマネージャー |
| テーマ | catppuccin, tokyonight, kanagawa | カラースキーム |
| LSP | nvim-lspconfig, mason.nvim | 言語サーバー |
| 補完 | nvim-cmp, LuaSnip | コード補完 |
| 構文 | nvim-treesitter | ハイライト・インデント |
| 検索 | telescope.nvim | ファジーファインダー |
| ファイラー | neo-tree.nvim | ファイルエクスプローラー |
| Git | gitsigns.nvim, lazygit.nvim | Git統合 |
| UI | lualine.nvim, bufferline.nvim | ステータスライン・タブ |
| 補助 | which-key.nvim | キーバインドヘルプ |
| 編集 | nvim-autopairs, Comment.nvim | 自動括弧・コメント |

## Commands

| コマンド | 説明 |
|----------|------|
| `:Lazy` | プラグインマネージャーを開く |
| `:Mason` | LSPサーバーマネージャーを開く |
| `:checkhealth` | 設定の健全性チェック |
| `:Tutor` | Vimチュートリアル（日本語可） |

## Tips for Beginners

1. **which-keyを活用**: Spaceキーを押して待つとキーバインドが表示される
2. **モード意識**: Normal（操作）/ Insert（入力）/ Visual（選択）の3モードを意識
3. **hjkl移動**: 矢印キーよりhjklに慣れると効率的
4. **ドットコマンド**: `.` で直前の操作を繰り返せる
5. **`:Tutor`**: 内蔵チュートリアルで練習

## Troubleshooting

### プラグインがインストールされない
```vim
:Lazy sync
```

### LSPが動かない
```vim
:Mason
" 必要な言語サーバーをインストール
" TypeScript: ts_ls
" Lua: lua_ls
```

### TreesitterのパーサーエラーMake
```vim
:TSUpdate
```
