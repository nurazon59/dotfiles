local fyler_always_hidden = { "/%.git/", "/%.git$", "%.DS_Store$", "node_modules" }

local function toggle_fyler()
  local fyler = require("fyler")
  if fyler.getcwd() then
    fyler.close()
    return
  end

  local hidden = vim.deepcopy(fyler_always_hidden)
  local cwd = vim.fn.getcwd(-1, -1)
  local ok, result = pcall(function()
    return vim
      .system({ "git", "-C", cwd, "ls-files", "--others", "--ignored", "--exclude-standard", "--directory", "-z" })
      :wait()
  end)

  if ok and result.code == 0 then
    for path in result.stdout:gmatch("[^%z]+") do
      path = path:gsub("/$", "")
      local absolute = vim.fs.joinpath(cwd, path)
      hidden[#hidden + 1] = "^" .. absolute:gsub("([^%w])", "%%%1") .. "$"
    end
  end

  fyler.open({ ui = { hidden_items = { always_hidden = hidden } } })
end

return {
  { "nvim-tree/nvim-web-devicons", dir = "@nvim-web-devicons@", pin = true },
  { "MunifTanjim/nui.nvim", dir = "@nui-nvim@", pin = true },
  {
    "b0o/incline.nvim",
    dir = "@incline-nvim@",
    pin = true,
    event = "VeryLazy",
    opts = {
      render = function(props)
        local path = vim.api.nvim_buf_get_name(props.buf)
        local parent = path ~= "" and vim.fn.fnamemodify(path, ":h:t") or ""
        local line = vim.api.nvim_win_get_cursor(props.win)[1]
        local line_count = vim.api.nvim_buf_line_count(props.buf)
        return {
          parent ~= "" and { parent .. "/ ", group = "Comment" } or "",
          { line .. "/" .. line_count, group = "Comment" },
        }
      end,
    },
  },
  {
    "akinsho/bufferline.nvim",
    dir = "@bufferline-nvim@",
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
    dir = "@fyler-nvim@",
    pin = true,
    lazy = false,
    keys = {
      {
        "<leader>e",
        toggle_fyler,
        desc = "Explorer Fyler",
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      kind = "floating",
      win_opts = {
        cursorline = true,
      },
      extensions = {
        git = { enabled = true },
      },
      integrations = {
        icon = "nvim_web_devicons",
      },
      ui = {
        hidden_items = {
          switches = {},
          always_hidden = fyler_always_hidden,
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
    dir = "@no-neck-pain-nvim@",
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
    "petertriho/nvim-scrollbar",
    dir = "@nvim-scrollbar@",
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
    dir = "@snacks-nvim@",
    pin = true,
    opts = {
      dim = { enabled = false },
      scroll = { enabled = false },
      indent = { enabled = false },
      scope = { enabled = false },
      input = { enabled = true },
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
    dir = "@nvim-notify@",
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
    dir = "@indent-blankline-nvim@",
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
    "ojroques/nvim-hardline",
    dir = "@nvim-hardline@",
    pin = true,
    main = "hardline",
    opts = function()
      local line = require("hardline.parts.line").get_item
      return {
        sections = vim.tbl_filter(function(section)
          return type(section) ~= "table" or section.item ~= line
        end, require("hardline").options.sections),
      }
    end,
  },
  {
    "folke/noice.nvim",
    dir = "@noice-nvim@",
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
    dir = "@mini-icons@",
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
    dir = "@nvim-colorizer-lua@",
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
    dir = "@which-key-nvim@",
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
}
