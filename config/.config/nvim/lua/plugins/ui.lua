return {
  { "nvim-tree/nvim-web-devicons", pin = true },
  { "MunifTanjim/nui.nvim", pin = true },
  {
    "akinsho/bufferline.nvim",
    pin = true,
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
  },
  {
    "FylerOrg/fyler.nvim",
    pin = true,
    lazy = false,
    keys = {
      {
        "<leader>e",
        function()
          require("fyler").toggle()
        end,
        desc = "Explorer Fyler",
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      kind = "floating",
      extensions = {
        git = { enabled = true },
      },
      integrations = {
        icon = "nvim_web_devicons",
      },
      ui = {
        hidden_items = {
          switches = {},
          always_hidden = { "/%.git/", "/%.git$", "%.DS_Store$", "node_modules" },
        },
      },
      mappings = {
        n = {
          ["<Space>"] = {
            action = "select",
            args = { close = false, pick = false },
          },
          ["gx"] = {
            action = function(finder)
              vim.ui.open(finder:cursor_node_entry().path)
            end,
          },
          ["yp"] = {
            action = function(finder)
              vim.fn.setreg(vim.v.register, finder:cursor_node_entry().path)
            end,
          },
          ["yr"] = {
            action = function(finder)
              vim.fn.setreg(vim.v.register, vim.fn.fnamemodify(finder:cursor_node_entry().path, ":."))
            end,
          },
        },
      },
    },
  },
  {
    "shortcuts/no-neck-pain.nvim",
    pin = true,
    version = "*",
    opts = {
      width = 180,
    },
    keys = {
      { "<leader>np", "<cmd>NoNeckPain<cr>", desc = "Toggle No Neck Pain" },
    },
  },
  {
    "tadaa/vimade",
    pin = true,
    opts = {
      recipe = { "default", { animate = false } },
      ncmode = "windows",
      fadelevel = 0.6,
      saturation = { value = 0.4 },
    },
  },
  {
    "petertriho/nvim-scrollbar",
    pin = true,
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
    pin = true,
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
    pin = true,
    opts = {
      stages = "static",
      render = "wrapped-compact",
      timeout = 3000,
      top_down = true,
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    pin = true,
    main = "ibl",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      scope = {
        show_start = false,
        show_end = false,
      },
      exclude = {
        filetypes = { "help", "dashboard", "fyler_finder", "Trouble", "lazy", "mason", "toggleterm" },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    pin = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        disabled_filetypes = {
          statusline = { "fyler_finder" },
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
    pin = true,
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
    pin = true,
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
    "catgoose/nvim-colorizer.lua",
    pin = true,
    event = "BufRead",
    opts = {
      filetypes = { "*" },
      user_default_options = {
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
      },
    },
  },
  {
    "folke/which-key.nvim",
    pin = true,
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
  {
    "echasnovski/mini.starter",
    pin = true,
    lazy = false,
    config = function()
      local starter = require("mini.starter")

      local dir_items = {}
      local dashboard_dirs = vim.env.DASHBOARD_DIRS
      if dashboard_dirs then
        for raw_dir in dashboard_dirs:gmatch("[^,]+") do
          local dir = vim.fn.expand(raw_dir)
          local name = dir:match("([^/]+)$")
          table.insert(dir_items, {
            name = name,
            action = function()
              vim.cmd.cd(dir)
              require("fyler").open()
            end,
            section = "Projects",
          })
        end
      end

      local items = {
        {
          name = "Restore Session",
          action = function()
            require("resession").load(vim.fn.getcwd(), { dir = "dirsession" })
            vim.cmd("doautoall BufAdd")
          end,
          section = "Session",
        },
        { name = "Recent Files", action = "FzfLua oldfiles", section = "Files" },
        {
          name = "New File",
          action = function()
            vim.ui.input({ prompt = "File name: " }, function(name)
              if name and name ~= "" then
                vim.cmd.edit(name)
              end
            end)
          end,
          section = "Files",
        },
        {
          name = "Open Tree",
          action = function()
            require("fyler").open()
          end,
          section = "Files",
        },
        { name = "Quit", action = "qa", section = "" },
      }
      vim.list_extend(items, dir_items)

      starter.setup({
        header = table.concat({
          "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
          "████╗  ██║██║   ██║██║████╗ ████║",
          "██╔██╗ ██║██║   ██║██║██╔████╔██║",
          "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
          "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
          "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        }, "\n"),
        items = items,
        query_updaters = "abcdefghimnopqrstuvwxyz0123456789_-.",
        footer = "",
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniStarterOpened",
        callback = function()
          vim.keymap.set("n", "j", "<Cmd>lua MiniStarter.update_current_item('next')<CR>", { buffer = true })
          vim.keymap.set("n", "k", "<Cmd>lua MiniStarter.update_current_item('prev')<CR>", { buffer = true })
        end,
      })
    end,
  },
}
