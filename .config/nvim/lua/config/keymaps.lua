-- キーマップ設定
-- リーダーキーはSpace（options.luaで設定）

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 説明を追加するヘルパー関数
local function with_desc(description)
  return vim.tbl_extend("force", opts, { desc = description })
end

-- ===========================================
-- 基本操作
-- ===========================================

-- Escでハイライト解除
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", with_desc("検索ハイライト解除"))

-- 折り返し行での上下移動を改善
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- ファイル保存
keymap("n", "<leader>w", "<cmd>w<CR>", with_desc("ファイルを保存"))
keymap("n", "<leader>W", "<cmd>wa<CR>", with_desc("全ファイルを保存"))

-- 終了
keymap("n", "<leader>q", "<cmd>q<CR>", with_desc("終了"))
keymap("n", "<leader>Q", "<cmd>qa<CR>", with_desc("全て終了"))

-- 保存して終了
keymap("n", "<leader>x", "<cmd>x<CR>", with_desc("保存して終了"))

-- ===========================================
-- ウィンドウ管理
-- ===========================================

-- ウィンドウ分割
keymap("n", "<leader>sv", "<cmd>vsplit<CR>", with_desc("縦分割"))
keymap("n", "<leader>sh", "<cmd>split<CR>", with_desc("横分割"))
keymap("n", "<leader>sc", "<cmd>close<CR>", with_desc("ウィンドウを閉じる"))
keymap("n", "<leader>so", "<cmd>only<CR>", with_desc("他のウィンドウを閉じる"))

-- ウィンドウ間移動（WezTermのペイン移動と同じ感覚）
keymap("n", "<C-h>", "<C-w>h", with_desc("左のウィンドウへ"))
keymap("n", "<C-j>", "<C-w>j", with_desc("下のウィンドウへ"))
keymap("n", "<C-k>", "<C-w>k", with_desc("上のウィンドウへ"))
keymap("n", "<C-l>", "<C-w>l", with_desc("右のウィンドウへ"))

-- 矢印キーでウィンドウサイズ変更
keymap("n", "<C-Up>", "<cmd>resize +2<CR>", with_desc("ウィンドウを高くする"))
keymap("n", "<C-Down>", "<cmd>resize -2<CR>", with_desc("ウィンドウを低くする"))
keymap("n", "<C-Left>", "<cmd>vertical resize -2<CR>", with_desc("ウィンドウを狭くする"))
keymap("n", "<C-Right>", "<cmd>vertical resize +2<CR>", with_desc("ウィンドウを広くする"))

-- ===========================================
-- バッファ管理
-- ===========================================

-- バッファ移動
keymap("n", "<Tab>", "<cmd>bnext<CR>", with_desc("次のバッファ"))
keymap("n", "<S-Tab>", "<cmd>bprevious<CR>", with_desc("前のバッファ"))

-- バッファを閉じる
keymap("n", "<leader>bd", "<cmd>bdelete<CR>", with_desc("バッファを閉じる"))
keymap("n", "<leader>bD", "<cmd>bdelete!<CR>", with_desc("バッファを強制的に閉じる"))

-- ===========================================
-- テキスト編集
-- ===========================================

-- ビジュアルモードで行を上下に移動
keymap("v", "J", ":m '>+1<CR>gv=gv", with_desc("行を下に移動"))
keymap("v", "K", ":m '<-2<CR>gv=gv", with_desc("行を上に移動"))

-- スクロール時にカーソルを中央に維持
keymap("n", "<C-d>", "<C-d>zz", with_desc("下にスクロール"))
keymap("n", "<C-u>", "<C-u>zz", with_desc("上にスクロール"))

-- 検索結果を中央に維持
keymap("n", "n", "nzzzv", with_desc("次の検索結果"))
keymap("n", "N", "Nzzzv", with_desc("前の検索結果"))

-- インデント時に選択を維持
keymap("v", "<", "<gv", with_desc("左にインデント"))
keymap("v", ">", ">gv", with_desc("右にインデント"))

-- 選択範囲に貼り付けてもヤンクしない
keymap("x", "p", [["_dP]], with_desc("ヤンクせずに貼り付け"))

-- ブラックホールレジスタに削除
keymap({ "n", "v" }, "<leader>d", [["_d]], with_desc("ブラックホールに削除"))

-- ===========================================
-- 診断（LSP）
-- ===========================================

keymap("n", "[d", vim.diagnostic.goto_prev, with_desc("前の診断"))
keymap("n", "]d", vim.diagnostic.goto_next, with_desc("次の診断"))
keymap("n", "<leader>ld", vim.diagnostic.open_float, with_desc("診断を表示"))
keymap("n", "<leader>lq", vim.diagnostic.setloclist, with_desc("診断リスト"))

-- ===========================================
-- クイックアクション
-- ===========================================

-- 全選択
keymap("n", "<C-a>", "gg<S-v>G", with_desc("全選択"))

-- 新規ファイル
keymap("n", "<leader>fn", "<cmd>enew<CR>", with_desc("新規ファイル"))

-- Lazyプラグインマネージャー
keymap("n", "<leader>L", "<cmd>Lazy<CR>", with_desc("Lazyプラグインマネージャー"))

-- Mason LSPインストーラー
keymap("n", "<leader>M", "<cmd>Mason<CR>", with_desc("Mason LSPマネージャー"))
