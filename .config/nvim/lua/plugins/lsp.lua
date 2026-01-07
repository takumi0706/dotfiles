-- LSP設定
-- コード補完・定義ジャンプ・リファクタリングなど

return {
  -- Mason: LSPサーバーインストーラー
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
        border = "rounded",
      },
    },
  },

  -- Mason-lspconfig: Masonとlspconfigのブリッジ
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "ts_ls", -- TypeScript/JavaScript
        "lua_ls", -- Lua
        "jsonls", -- JSON
        "html", -- HTML
        "cssls", -- CSS
        "eslint", -- ESLint
      },
      automatic_installation = true,
    },
  },

  -- nvim-lspconfig: LSP設定
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- 補完用のcapabilities
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- 診断アイコン
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- 診断設定
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
        },
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })

      -- キーマップ設定用のon_attach関数
      local on_attach = function(_, bufnr)
        local keymap = vim.keymap.set
        local opts = { buffer = bufnr, silent = true }

        -- LSPキーマップ（IntelliJ風）
        keymap("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "定義へジャンプ" }))
        keymap("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "宣言へジャンプ" }))
        keymap("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "実装へジャンプ" }))
        keymap(
          "n",
          "gr",
          "<cmd>Telescope lsp_references<CR>",
          vim.tbl_extend("force", opts, { desc = "参照を検索" })
        )
        keymap("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "ホバー情報" }))
        keymap(
          "n",
          "<leader>ca",
          vim.lsp.buf.code_action,
          vim.tbl_extend("force", opts, { desc = "コードアクション" })
        )
        keymap(
          "n",
          "<leader>rn",
          vim.lsp.buf.rename,
          vim.tbl_extend("force", opts, { desc = "シンボルをリネーム" })
        )
        keymap("n", "<leader>lf", function()
          vim.lsp.buf.format({ async = true })
        end, vim.tbl_extend("force", opts, { desc = "フォーマット" }))
        keymap(
          "n",
          "<leader>ls",
          vim.lsp.buf.signature_help,
          vim.tbl_extend("force", opts, { desc = "シグネチャヘルプ" })
        )
        keymap(
          "n",
          "<leader>lt",
          vim.lsp.buf.type_definition,
          vim.tbl_extend("force", opts, { desc = "型定義へジャンプ" })
        )
      end

      -- TypeScript/JavaScript
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
        },
      })

      -- Lua（Neovim設定用）
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      -- JSON
      lspconfig.jsonls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- HTML
      lspconfig.html.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- CSS
      lspconfig.cssls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- ESLint
      lspconfig.eslint.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
          -- 保存時に自動修正
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      })
    end,
  },
}
