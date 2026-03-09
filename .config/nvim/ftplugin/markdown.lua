-- Markdown固有の設定

-- はみ出した行を折り返して表示する
vim.opt_local.wrap = true

-- 単語の途中で折り返さない
vim.opt_local.linebreak = true

-- 折り返し行のインデントを維持する
vim.opt_local.breakindent = true

-- 表示行単位で移動する（折り返し行でも自然に上下移動できる）
vim.keymap.set("n", "j", "gj", { buffer = true })
vim.keymap.set("n", "k", "gk", { buffer = true })
