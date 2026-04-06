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
        sign = false,
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      },
      code = {
        enabled = true,
        sign = true,
        style = "full",
        width = "full",
        left_pad = 2,
        right_pad = 2,
        border = "thin",
        language_pad = 0,
        -- diagram.nvimが処理するコードブロックを除外
        disable_background = { "mermaid", "plantuml", "d2" },
      },
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "⬜ " },
        checked = { icon = "✅ " },
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
          "┌",
          "┬",
          "┐",
          "├",
          "┼",
          "┤",
          "└",
          "┴",
          "┘",
          "│",
          "─",
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
      vim.g.mkdp_auto_start = 0
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
  -- Wezterm Sixel バックエンド対応
  {
    "3rd/image.nvim",
    ft = { "markdown" },
    build = false, -- luarocks ビルドをスキップ
    opts = {
      processor = "magick_cli", -- CLI モードを使用（luarocks 不要）
      backend = "sixel", -- Wezterm では Sixel を使用（Kitty は非互換）
      scale_factor = 1.5, -- インライン表示を1.5倍に拡大
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = true,
          download_remote_images = true,
          only_render_image_at_cursor = true, -- パフォーマンス最適化
          filetypes = { "markdown" },
        },
      },
      max_width = nil, -- 制限なし
      max_height = nil, -- 制限なし
      max_height_window_percentage = 100,
      max_width_window_percentage = 100,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },

  -- diagram.nvim: Neovim内図表描画
  -- Mermaid/PlantUML/D2 対応（image.nvim連携）
  {
    "3rd/diagram.nvim",
    ft = { "markdown" },
    dependencies = {
      "3rd/image.nvim",
    },
    config = function()
      require("diagram").setup({
        integrations = {
          require("diagram.integrations.markdown"),
        },
        renderer_options = {
          mermaid = {
            background = "#1e1e2e", -- Catppuccin Mocha の背景色
            theme = "dark",
            scale = 2, -- 軽量化
            width = 800, -- 軽量化
            height = 600,
          },
        },
      })
      vim.defer_fn(function()
        vim.cmd("doautocmd BufWinEnter")
      end, 100)
    end,
    keys = {
      {
        "<leader>mdm",
        function()
          -- カーソル位置のMermaidコードブロックを取得してシステムビューアで開く
          local markdown_integration = require("diagram.integrations.markdown")

          -- コードブロック全体の範囲を取得するヘルパー関数
          local function get_extended_range(bufnr, diagram)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local start_row = diagram.range.start_row
            local end_row = diagram.range.end_row

            for i = start_row, 0, -1 do
              local line = lines[i + 1]
              if line and line:match("^%s*```") then
                start_row = i
                break
              end
            end

            for i = end_row, #lines - 1 do
              local line = lines[i + 1]
              if line and line:match("^%s*```%s*$") then
                end_row = i
                break
              end
            end

            return { start_row = start_row, end_row = end_row }
          end

          -- カーソル位置のダイアグラムを検出
          local bufnr = vim.api.nvim_get_current_buf()
          local diagrams = markdown_integration.query_buffer_diagrams(bufnr)
          local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1

          local target_diagram = nil
          for _, diagram in ipairs(diagrams) do
            local extended = get_extended_range(bufnr, diagram)
            if cursor_line >= extended.start_row and cursor_line <= extended.end_row then
              target_diagram = diagram
              break
            end
          end

          if not target_diagram then
            vim.notify("カーソル位置にダイアグラムがありません", vim.log.levels.WARN)
            return
          end

          if target_diagram.renderer_id ~= "mermaid" then
            vim.notify(
              "Mermaidダイアグラムではありません: " .. target_diagram.renderer_id,
              vim.log.levels.WARN
            )
            return
          end

          vim.notify("Mermaid描画中（高解像度）...", vim.log.levels.INFO)

          -- 直接 mmdc を実行（キャッシュをバイパス）
          local tmp_input = vim.fn.tempname() .. ".mmd"
          local tmp_output = vim.fn.tempname() .. ".png"

          -- ソースを一時ファイルに書き込み
          local f = io.open(tmp_input, "w")
          if not f then
            vim.notify("一時ファイルの作成に失敗しました", vim.log.levels.ERROR)
            return
          end
          f:write(target_diagram.source)
          f:close()

          -- mmdc を最高解像度で実行（vim.fn.jobstart で PATH を正しく継承）
          local cmd = string.format(
            "mmdc -i %s -o %s -b '#1e1e2e' -t dark -s 10 --width 2560 --height 1440",
            vim.fn.shellescape(tmp_input),
            vim.fn.shellescape(tmp_output)
          )

          vim.fn.jobstart(cmd, {
            on_exit = function(_, exit_code)
              -- 一時入力ファイルを削除
              os.remove(tmp_input)

              -- システムビューアで開く
              if exit_code == 0 and vim.fn.filereadable(tmp_output) == 1 then
                vim.ui.open(tmp_output)
                vim.notify("システムビューアで開きました", vim.log.levels.INFO)
              else
                vim.notify("レンダリングに失敗しました", vim.log.levels.ERROR)
              end
            end,
          })
        end,
        desc = "Mermaid描画（システムビューア）",
        ft = "markdown",
      },
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
      { "<leader>mdx", "<cmd>MDTaskToggle<CR>", desc = "チェックボックストグル", ft = "markdown" },
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
