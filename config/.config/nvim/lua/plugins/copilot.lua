return {
  -- copilot.lua - GitHub Copilot用のLuaベース実装
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = false,  -- blink-cmp-copilotと競合するため無効化
        },
        suggestion = {
          enabled = false,  -- blink-cmp-copilotと競合するため無効化
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = 'node', -- Node.jsのパス（v20以上必須）
        server_opts_overrides = {},
      })
    end,
  },

  -- blink-cmp-copilot - blink.cmp用のCopilotソース
  {
    "giuxtaposition/blink-cmp-copilot",
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
  },

  -- blink.cmpにcopilotソースを追加
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      "giuxtaposition/blink-cmp-copilot",
    },
    opts = function(_, opts)
      -- blink.cmp設定を拡張
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      opts.sources.providers = opts.sources.providers or {}
      
      -- copilotをdefaultソースに追加（lspの後に）
      table.insert(opts.sources.default, 2, "copilot")
      
      -- copilotプロバイダーを設定
      opts.sources.providers.copilot = {
        name = "copilot",
        module = "blink-cmp-copilot",
        score_offset = 100,
        async = true,
        transform_items = function(_, items)
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1
          CompletionItemKind[kind_idx] = "Copilot"
          for _, item in ipairs(items) do
            item.kind = kind_idx
          end
          return items
        end,
      }
      
      return opts
    end,
  },

  -- CopilotChat - AI支援チャット機能（オプション）
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    cmd = { "CopilotChat" },
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    opts = {
      debug = false,
      window = {
        layout = 'vertical',
        width = 0.35,
        height = 0.5,
      },
    },
    keys = {
      {
        "<leader>cc",
        "<cmd>CopilotChat<cr>",
        desc = "CopilotChat - Open chat window",
      },
      {
        "<leader>cq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
      {
        "<leader>ch",
        "<cmd>CopilotChatHelp<cr>",
        desc = "CopilotChat - Help actions",
      },
      {
        "<leader>ce",
        "<cmd>CopilotChatExplain<cr>",
        mode = { "n", "v" },
        desc = "CopilotChat - Explain code",
      },
      {
        "<leader>ct",
        "<cmd>CopilotChatTests<cr>",
        mode = { "n", "v" },
        desc = "CopilotChat - Generate tests",
      },
      {
        "<leader>cr",
        "<cmd>CopilotChatReview<cr>",
        mode = { "n", "v" },
        desc = "CopilotChat - Review code",
      },
      {
        "<leader>cR",
        "<cmd>CopilotChatRefactor<cr>",
        mode = { "n", "v" },
        desc = "CopilotChat - Refactor code",
      },
      {
        "<leader>cn",
        "<cmd>CopilotChatBetterNamings<cr>",
        mode = { "n", "v" },
        desc = "CopilotChat - Better Naming",
      },
    },
  },
}