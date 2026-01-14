-- Telescope設定
-- ファイル検索、grep、バッファ一覧など

return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Telescope",
    keys = {
      -- ファイル検索（IntelliJ風）
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "ファイル検索" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "テキスト検索" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "バッファ一覧" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "ヘルプ検索" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "最近のファイル" },
      { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "カーソル下の単語を検索" },
      -- Git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Gitコミット" },
      { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "Gitブランチ" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Gitステータス" },
      -- LSP
      { "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>", desc = "ドキュメントシンボル" },
      { "<leader>lS", "<cmd>Telescope lsp_workspace_symbols<CR>", desc = "ワークスペースシンボル" },
      -- その他
      { "<leader>tc", "<cmd>Telescope colorscheme enable_preview=true<CR>", desc = "テーマ切り替え" },
      { "<leader><leader>", "<cmd>Telescope buffers<CR>", desc = "バッファ切り替え" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          path_display = { "truncate" },
          winblend = 0,
          border = {},
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "%.lock",
            "dist/",
            "build/",
            "%.min.js",
          },
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
            },
            n = {
              ["<esc>"] = actions.close,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["q"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
          },
          live_grep = {
            additional_args = function()
              return { "--hidden" }
            end,
          },
          buffers = {
            show_all_buffers = true,
            sort_lastused = true,
            mappings = {
              i = {
                ["<C-d>"] = actions.delete_buffer,
              },
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      -- fzf拡張を読み込み（利用可能な場合）
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
