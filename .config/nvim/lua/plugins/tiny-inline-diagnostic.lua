-- tiny-inline-diagnostic: LSP診断メッセージの表示改善
-- 長いメッセージを自動折り返しして見切れを防止

return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  config = function()
    require("tiny-inline-diagnostic").setup({
      preset = "modern",
      transparent_bg = false,
      options = {
        multilines = {
          enabled = true,
          always_show = true,
        },
        show_all_diags_on_cursorline = true,
        overflow = {
          mode = "wrap",
        },
        softwrap = 30,
        enable_on_insert = false,
      },
    })

    -- 組み込みのvirtual_textを無効化（プラグインと競合するため）
    vim.diagnostic.config({ virtual_text = false })
  end,
}
