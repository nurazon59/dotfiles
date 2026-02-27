return {
  {
    "akinsho/bufferline.nvim",
    lazy = true,
    event = "BufAdd",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        always_show_bufferline = false,
        custom_filter = function(buf)
          return vim.fn.bufname(buf) ~= ""
        end,
      },
    },
    config = function(_, opts)
      -- why: VeryLazyでsetup()が走るとshowtabline=2になりフラッシュするため、
      -- リストバッファが2つ以上になるまでsetupを遅延させる
      vim.api.nvim_create_autocmd("BufAdd", {
        callback = function()
          if #vim.fn.getbufinfo({ buflisted = 1 }) < 2 then
            return
          end
          require("bufferline").setup(opts)
          return true
        end,
      })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree", remap = true },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git Explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer Explorer",
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
        desc = "Start Neo-tree with directory",
        once = true,
        callback = function()
          if package.loaded["neo-tree"] then
            return
          end
          local stats = vim.uv.fs_stat(vim.fn.argv(0))
          if stats and stats.type == "directory" then
            require("neo-tree")
          end
        end,
      })
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      window = {
        width = 30,
        mappings = {
          ["l"] = "open",
          ["h"] = "close_node",
          ["<space>"] = "none",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
            desc = "Copy Path to Clipboard",
          },
          ["O"] = {
            function(state)
              require("lazy.util").open(state.tree:get_node().path, { system = true })
            end,
            desc = "Open with System Application",
          },
          ["P"] = { "toggle_preview", config = { use_float = false } },
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = {
            ".git",
            ".DS_Store",
            ".history",
          },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        git_status = {
          symbols = {
            unstaged = "󰄱",
            staged = "󰱒",
          },
        },
      },
    },
    config = function(_, opts)
      if Snacks then
        local function on_move(data)
          Snacks.rename.on_rename_file(data.source, data.destination)
        end
        local events = require("neo-tree.events")
        opts.event_handlers = opts.event_handlers or {}
        vim.list_extend(opts.event_handlers, {
          { event = events.FILE_MOVED, handler = on_move },
          { event = events.FILE_RENAMED, handler = on_move },
        })
      end
      require("neo-tree").setup(opts)
    end,
  },
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    opts = {
      width = 120,
      enableOnVimEnter = true,
      integrations = {
        NeoTree = {
          position = "left",
          reopen = true,
        },
      },
    },
    keys = {
      { "<leader>np", "<cmd>NoNeckPain<cr>", desc = "Toggle No Neck Pain" },
    },
  },
  {
    "tadaa/vimade",
    opts = {
      recipe = { "default", { animate = false } },
      fadelevel = 0.6,
      saturation = { value = 0.4 },
    },
  },
  {
    "petertriho/nvim-scrollbar",
    dependencies = { "lewis6991/gitsigns.nvim" },
    config = function()
      local p = require("rose-pine.palette")
      require("scrollbar").setup({
        handle = {
          color = p.highlight_med,
        },
        marks = {
          Search = { color = p.gold },
          Error = { color = p.love },
          Warn = { color = p.gold },
          Info = { color = p.foam },
          Hint = { color = p.iris },
          Misc = { color = p.iris },
        },
      })
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      dim = { enabled = false },
      scroll = { enabled = false },
      indent = { enabled = false },
      scope = { enabled = false },
      notifier = { enabled = false },
      words = { enabled = true },
    },
    keys = {
      { "<leader>n", "<cmd>Noice history<cr>", desc = "Notification History" },
      { "<leader>un", "<cmd>Noice dismiss<cr>", desc = "Dismiss All Notifications" },
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      stages = "static",
      render = "wrapped-compact",
      timeout = 3000,
      top_down = true,
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      scope = {
        show_start = false,
        show_end = false,
      },
      exclude = {
        filetypes = { "help", "dashboard", "neo-tree", "Trouble", "lazy", "mason", "toggleterm" },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        disabled_filetypes = {
          statusline = { "neo-tree" },
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {
          {
            function()
              local name = vim.fn.bufname()
              if name == "" then
                return ""
              end
              return vim.fn.fnamemodify(name, ":.")
            end,
          },
        },
        lualine_x = { "lsp_status" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            function()
              local name = vim.fn.bufname()
              if name == "" then
                return ""
              end
              return vim.fn.fnamemodify(name, ":.")
            end,
          },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
      },
      messages = {
        enabled = true,
      },
      popupmenu = {
        enabled = true,
        backend = "cmp",
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },
  {
    "nvim-mini/mini.icons",
    opts = function(_, opts)
      opts = opts or {}
      opts.extension = opts.extension or {}
      opts.file = opts.file or {}
      opts.filetype = opts.filetype or {}

      opts.extension.go = { glyph = "" }
      opts.extension.ts = { glyph = "" }
      opts.extension.tsx = { glyph = "" }
      opts.extension.test = { glyph = "" }
      opts.extension.spec = { glyph = "" }
      opts.extension["test.js"] = { glyph = "" }
      opts.extension["test.jsx"] = { glyph = "" }
      opts.extension["test.ts"] = { glyph = "" }
      opts.extension["test.tsx"] = { glyph = "" }
      opts.extension["spec.js"] = { glyph = "" }
      opts.extension["spec.jsx"] = { glyph = "" }
      opts.extension["spec.ts"] = { glyph = "" }
      opts.extension["spec.tsx"] = { glyph = "" }
      opts.filetype.go = { glyph = "" }
      opts.filetype.typescript = { glyph = "" }
      opts.filetype.typescriptreact = { glyph = "" }
      opts.file["go.mod"] = { glyph = "" }
      opts.file["go.sum"] = { glyph = "" }
      opts.file["go.work"] = { glyph = "" }
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufRead",
    config = function()
      require("colorizer").setup({
        "*",
        css = { hsl_fn = true },
        html = { mode = "background" },
      }, {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        AARRGGBB = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        tailwind = true,
        sass = { enable = true, parsers = { "css" } },
        virtualtext = "■",
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      win = {
        width = 40,
        col = math.huge,
        row = math.huge,
        border = "rounded",
        padding = { 1, 2 },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}
