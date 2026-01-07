-- Which-key設定
-- キーバインドをポップアップで表示（初心者に最適）

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
        mappings = true,
        rules = {},
        colors = true,
      },
      spec = {
        { "<leader>b", group = "バッファ" },
        { "<leader>c", group = "コード" },
        { "<leader>f", group = "検索/ファイル" },
        { "<leader>g", group = "Git" },
        { "<leader>gt", group = "Git切り替え" },
        { "<leader>l", group = "LSP" },
        { "<leader>s", group = "分割" },
        { "<leader>t", group = "テーマ/切り替え" },
        { "<leader>w", group = "保存", icon = "" },
        { "<leader>q", group = "終了", icon = "" },
        { "<leader>x", group = "保存して終了", icon = "" },
        { "[", group = "前へ" },
        { "]", group = "次へ" },
        { "g", group = "移動" },
      },
      win = {
        border = "rounded",
        padding = { 1, 2 },
        title = true,
        title_pos = "center",
      },
      layout = {
        width = { min = 20 },
        spacing = 3,
      },
      keys = {
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
      },
      sort = { "local", "order", "group", "alphanum", "mod" },
      expand = 0,
      replace = {
        key = {
          { "<Space>", "SPC" },
          { "<cr>", "RET" },
          { "<tab>", "TAB" },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "バッファローカルキーマップ",
      },
    },
  },
}
