-- Neovim 基本設定

local opt = vim.opt

-- nvm経由のNode.jsツール（mmdc等）をPATHに追加
-- diagram.nvimがMermaidを描画するために必要
local function add_nvm_to_path()
  local home = os.getenv("HOME")
  local nvm_versions_dir = home .. "/.nvm/versions/node"
  local handle = io.popen("ls -1 " .. nvm_versions_dir .. " 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    for version in result:gmatch("[^\n]+") do
      local bin_path = nvm_versions_dir .. "/" .. version .. "/bin"
      local mmdc_path = bin_path .. "/mmdc"
      local f = io.open(mmdc_path, "r")
      if f then
        f:close()
        vim.env.PATH = bin_path .. ":" .. vim.env.PATH
        return
      end
    end
  end
end
add_nvm_to_path()

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
