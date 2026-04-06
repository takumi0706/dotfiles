-- Git統合設定
-- gitsignsで行単位の変更表示、lazygitでフルGit UI

return {
  -- Gitsigns: ガター（行番号横）にGit変更を表示
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      signcolumn = true,
      numhl = false,
      linehl = false,
      word_diff = false,
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 1000,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil,
      max_file_length = 40000,
      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- ナビゲーション
        map("n", "]h", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, "次のhunk")

        map("n", "[h", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, "前のhunk")

        -- アクション
        map("n", "<leader>gp", gs.preview_hunk, "hunkをプレビュー")
        map("n", "<leader>gi", gs.preview_hunk_inline, "hunkをインラインプレビュー")
        map("n", "<leader>gS", gs.stage_buffer, "バッファをステージ")
        map("n", "<leader>gR", gs.reset_buffer, "バッファをリセット")
        map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "hunkをステージ")
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "hunkをリセット")
        map("n", "<leader>gu", gs.undo_stage_hunk, "ステージを取り消し")
        map("n", "<leader>gd", gs.diffthis, "差分を表示")
        map("n", "<leader>gD", function()
          gs.diffthis("~")
        end, "前回との差分")
        map("n", "<leader>gB", function()
          gs.blame_line({ full = true })
        end, "行のblame")
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "行blameを切り替え")
        map("n", "<leader>gtd", gs.toggle_deleted, "削除行を表示切り替え")

        -- テキストオブジェクト
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "hunkを選択")
      end,
    },
  },

  -- Lazygit: フルGit UI
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGitを開く" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<CR>", desc = "現在のファイルのLazyGit" },
    },
  },
}
