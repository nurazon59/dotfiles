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
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    keys = {
      { "<leader>e", "<Cmd>NvimTreeToggle<CR>", desc = "Explorer NvimTree" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        api.map.on_attach.default(bufnr)
        vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
      end,
      view = {
        float = {
          enable = true,
          open_win_config = function()
            local width = 80
            local height = 50
            local columns = vim.o.columns
            local lines = vim.o.lines - vim.o.cmdheight

            return {
              relative = "editor",
              border = "rounded",
              width = width,
              height = height,
              row = math.floor((lines - height) / 2),
              col = math.floor((columns - width) / 2),
            }
          end,
        },
      },
      renderer = {
        highlight_git = "name",
        highlight_opened_files = "name",
        indent_markers = {
          enable = true,
        },
      },
      update_focused_file = {
        enable = true,
        update_root = {
          enable = false,
        },
      },
      filters = {
        git_ignored = false,
        custom = {
          "^\\.git$",
          "^\\.DS_Store$",
        },
      },
      actions = {
        open_file = {
          window_picker = {
            exclude = {
              filetype = {
                "notify",
                "lazy",
                "qf",
                "diff",
                "fugitive",
                "fugitiveblame",
                "Trouble",
                "trouble",
                "Outline",
              },
              buftype = { "nofile", "terminal", "help" },
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
    end,
  },
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    opts = {
      width = 120,
      autocmds = {
        enableOnVimEnter = true,
      },
      integrations = {
        NvimTree = {
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
      ncmode = "windows",
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
        filetypes = { "help", "dashboard", "NvimTree", "Trouble", "lazy", "mason", "toggleterm" },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        disabled_filetypes = {
          statusline = { "NvimTree" },
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
    "catgoose/nvim-colorizer.lua",
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
              vim.cmd("NvimTreeOpen")
            end,
            section = "Projects",
          })
        end
      end

      local items = {
        { name = "Restore Session", action = function()
            require("resession").load(vim.fn.getcwd(), { dir = "dirsession" })
            vim.cmd("doautoall BufAdd")
          end, section = "Session" },
        { name = "Recent Files", action = "FzfLua oldfiles", section = "Files" },
        { name = "New File", action = function()
            vim.ui.input({ prompt = "File name: " }, function(name)
              if name and name ~= "" then
                vim.cmd.edit(name)
              end
            end)
          end, section = "Files" },
        { name = "Open Tree", action = "NvimTreeOpen", section = "Files" },
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
