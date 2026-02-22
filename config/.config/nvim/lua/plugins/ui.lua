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
      local kanagawa = require("kanagawa.colors").setup()
      local theme = kanagawa.theme
      local palette = kanagawa.palette
      require("scrollbar").setup({
        handle = {
          color = theme.ui.bg_p1,
        },
        marks = {
          Search = { color = palette.surimiOrange },
          Error = { color = theme.diag.error },
          Warn = { color = theme.diag.warning },
          Info = { color = theme.diag.info },
          Hint = { color = theme.diag.hint },
          Misc = { color = palette.oniViolet },
        },
      })
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "lsp_status" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
}
