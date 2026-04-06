-- Mini.starter設定
-- ファイルなしでNeovimを開いた時のスタート画面

return {
  {
    "echasnovski/mini.starter",
    version = false,
    event = "VimEnter",
    opts = function()
      local starter = require("mini.starter")
      local logo = table.concat({
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                     ",
      }, "\n")

      local config = {
        evaluate_single = true,
        header = logo,
        items = {
          starter.sections.builtin_actions(),
          starter.sections.recent_files(5, false),
          starter.sections.recent_files(5, true),
          {
            { name = "ファイル検索", action = "Telescope find_files", section = "Telescope" },
            { name = "テキスト検索", action = "Telescope live_grep", section = "Telescope" },
            { name = "最近のファイル", action = "Telescope oldfiles", section = "Telescope" },
          },
          {
            { name = "ファイルツリー", action = "Neotree toggle", section = "アクション" },
            { name = "プラグイン管理", action = "Lazy", section = "アクション" },
            { name = "LSP管理", action = "Mason", section = "アクション" },
            { name = "ヘルスチェック", action = "checkhealth", section = "アクション" },
          },
        },
        content_hooks = {
          starter.gen_hook.adding_bullet("░ ", false),
          starter.gen_hook.aligning("center", "center"),
        },
        footer = "",
      }
      return config
    end,
    config = function(_, config)
      -- ファイルを開いた時にスターターを閉じる
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniStarterOpened",
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
      require("mini.starter").setup(config)
    end,
  },
}
