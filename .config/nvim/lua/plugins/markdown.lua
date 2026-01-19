-- Markdown 関連プラグイン設定
-- インライン装飾、ブラウザプレビュー、画像表示、TOC、テーブル編集等

return {
  -- render-markdown.nvim: インライン装飾
  -- Normal モードで装飾表示、Insert モードで raw テキスト
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      file_types = { "markdown" },
      render_modes = { "n", "c" },
      heading = {
        enabled = true,
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        enabled = true,
        sign = true,
        style = "full",
        width = "full",
        left_pad = 2,
        right_pad = 2,
        border = "thin",
      },
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
      },
      quote = {
        enabled = true,
        icon = "▋",
      },
      pipe_table = {
        enabled = true,
        style = "full",
        cell = "padded",
        border = {
          "┌", "┬", "┐",
          "├", "┼", "┤",
          "└", "┴", "┘",
          "│", "─",
        },
      },
      link = {
        enabled = true,
        image = "󰥶 ",
        hyperlink = "󰌹 ",
      },
    },
    keys = {
      { "<leader>mdt", "<cmd>RenderMarkdown toggle<CR>", desc = "装飾トグル", ft = "markdown" },
    },
  },

  -- markdown-preview.nvim: ブラウザプレビュー
  -- Mermaid/PlantUML 対応、同期スクロール
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_auto_start = 1
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_browser = ""
      vim.g.mkdp_preview_options = {
        maid = {},
        uml = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
      }
      vim.g.mkdp_theme = "dark"
    end,
    keys = {
      { "<leader>mdp", "<cmd>MarkdownPreviewToggle<CR>", desc = "ブラウザプレビュー", ft = "markdown" },
      { "<leader>mds", "<cmd>MarkdownPreviewStop<CR>", desc = "プレビュー停止", ft = "markdown" },
    },
  },

  -- image.nvim: 画像プレビュー
  -- Wezterm (Kitty Graphics Protocol) 対応
  {
    "3rd/image.nvim",
    ft = { "markdown" },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = true,
          download_remote_images = true,
          only_render_image_at_cursor = true,
          filetypes = { "markdown" },
        },
      },
      max_width = 100,
      max_height = 20,
      max_height_window_percentage = 50,
      max_width_window_percentage = nil,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },

  -- markdown-toc.nvim: TOC 生成
  -- 目次の自動生成・更新
  {
    "hedyhli/markdown-toc.nvim",
    ft = { "markdown" },
    cmd = { "Mtoc" },
    opts = {
      auto_update = true,
      toc_list = {
        markers = "-",
        cycle_markers = false,
        indent_size = 2,
      },
    },
    keys = {
      { "<leader>mdT", "<cmd>Mtoc<CR>", desc = "TOC 挿入", ft = "markdown" },
    },
  },

  -- markdown.nvim: ナビゲーション + チェックボックス
  -- 見出しジャンプ、TOC リスト、チェックボックストグル
  {
    "tadmccorkle/markdown.nvim",
    ft = { "markdown" },
    opts = {
      mappings = {
        go_curr_heading = "]c",
        go_parent_heading = "[c",
        go_next_heading = "]h",
        go_prev_heading = "[h",
      },
    },
    keys = {
      { "<leader>mdl", "<cmd>MDToc<CR>", desc = "TOC リスト表示", ft = "markdown" },
      {
        "<leader>mdx",
        function()
          require("markdown").toggle_checkbox()
        end,
        desc = "チェックボックストグル",
        ft = "markdown",
      },
      {
        "<leader>mda",
        function()
          require("markdown").add_link()
        end,
        desc = "リンク追加",
        mode = "v",
        ft = "markdown",
      },
    },
  },

  -- markdown-table-mode.nvim: テーブル編集
  -- 入力時に自動整形
  {
    "Kicamon/markdown-table-mode.nvim",
    ft = { "markdown" },
    opts = {
      filetype = { "markdown" },
      options = {
        insert = true,
        insert_leave = true,
      },
    },
    keys = {
      { "<leader>mdF", "<cmd>TableModeRealign<CR>", desc = "テーブル整形", ft = "markdown" },
    },
  },
}
