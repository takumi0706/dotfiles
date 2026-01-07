-- Bufferline設定
-- 上部のタブバー（IntelliJ/VSCode風）

return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "ピン留め切り替え" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", desc = "ピン留め以外を閉じる" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "他のバッファを閉じる" },
      { "<leader>br", "<cmd>BufferLineCloseRight<CR>", desc = "右のバッファを閉じる" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", desc = "左のバッファを閉じる" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "前のバッファ" },
      { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "次のバッファ" },
      { "[b", "<cmd>BufferLineCyclePrev<CR>", desc = "前のバッファ" },
      { "]b", "<cmd>BufferLineCycleNext<CR>", desc = "次のバッファ" },
      { "[B", "<cmd>BufferLineMovePrev<CR>", desc = "バッファを左に移動" },
      { "]B", "<cmd>BufferLineMoveNext<CR>", desc = "バッファを右に移動" },
    },
    opts = {
      options = {
        mode = "buffers",
        themable = true,
        numbers = "none",
        close_command = "bdelete! %d",
        right_mouse_command = "bdelete! %d",
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = {
          icon = "▎",
          style = "icon",
        },
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 30,
        max_prefix_length = 30,
        truncate_names = true,
        tab_size = 21,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level, _, _)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "ファイルエクスプローラー",
            text_align = "center",
            separator = true,
          },
        },
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,
        separator_style = "thin",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
        sort_by = "insert_after_current",
      },
      highlights = {
        fill = {
          bg = { attribute = "bg", highlight = "Normal" },
        },
        background = {
          bg = { attribute = "bg", highlight = "Normal" },
        },
        buffer_selected = {
          bold = true,
          italic = false,
        },
        separator = {
          bg = { attribute = "bg", highlight = "Normal" },
        },
        separator_selected = {
          bg = { attribute = "bg", highlight = "Normal" },
        },
        separator_visible = {
          bg = { attribute = "bg", highlight = "Normal" },
        },
      },
    },
  },
}
