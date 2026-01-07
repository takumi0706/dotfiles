-- Neovim 基本設定

local opt = vim.opt

-- リーダーキー (Space)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 行番号
opt.number = true
opt.relativenumber = true

-- タブ・インデント
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- 行の折り返し
opt.wrap = false

-- 検索設定
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- カーソル行のハイライト
opt.cursorline = true

-- 外観
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- バックスペース
opt.backspace = "indent,eol,start"

-- クリップボード（システムクリップボードを使用）
opt.clipboard = "unnamedplus"

-- ウィンドウ分割
opt.splitright = true
opt.splitbelow = true

-- 単語の区切り文字
opt.iskeyword:append("-")

-- マウス
opt.mouse = "a"

-- ファイルエンコーディング
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- スワップとバックアップ
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- パフォーマンス
opt.updatetime = 250
opt.timeoutlen = 300

-- 補完
opt.completeopt = "menu,menuone,noselect"

-- スクロールオフセット
opt.scrolloff = 8
opt.sidescrolloff = 8

-- 不可視文字の表示
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Markdown用の非表示レベル
opt.conceallevel = 0

-- netrwを無効化（neo-treeを使用）
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
