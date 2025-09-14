return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
    "DiffviewFileHistory",
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diffview" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Project history" },
  },
  config = function()
    local actions = require("diffview.actions")
    require("diffview").setup({
      diff_binaries = false,
      enhanced_diff_hl = true,
      git_cmd = { "git" },
      use_icons = true,
      icons = {
        folder_closed = "",
        folder_open = "",
      },
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },
      view = {
        default = {
          layout = "diff2_horizontal",
          winbar_info = true,
        },
        merge_tool = {
          layout = "diff3_horizontal",
          disable_diagnostics = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          winbar_info = true,
        },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = "combined",
            },
            multi_file = {
              diff_merges = "first-parent",
            },
          },
        },
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
      commit_log_panel = {
        win_config = {},
      },
      default_args = {
        DiffviewOpen = { "--imply-local" },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          vim.opt_local.relativenumber = false
          vim.opt_local.number = true
        end,
      },
      keymaps = {
        disable_defaults = false,
        view = {
          ["<tab>"] = actions.select_next_entry,
          ["<s-tab>"] = actions.select_prev_entry,
          ["gf"] = actions.goto_file,
          ["<C-w><C-f>"] = actions.goto_file_split,
          ["<C-w>gf"] = actions.goto_file_tab,
          ["<leader>e"] = actions.focus_files,
          ["<leader>b"] = actions.toggle_files,
          ["g<C-x>"] = actions.cycle_layout,
          ["[x"] = actions.prev_conflict,
          ["]x"] = actions.next_conflict,
          ["<leader>co"] = actions.conflict_choose("ours"),
          ["<leader>ct"] = actions.conflict_choose("theirs"),
          ["<leader>cb"] = actions.conflict_choose("base"),
          ["<leader>ca"] = actions.conflict_choose("all"),
          ["dx"] = actions.conflict_choose("none"),
        },
        diff1 = {
          ["g?"] = actions.help({ "view", "diff1" }),
        },
        diff2 = {
          ["g?"] = actions.help({ "view", "diff2" }),
        },
        diff3 = {
          ["2do"] = actions.diffget("ours"),
          ["3do"] = actions.diffget("theirs"),
        },
        diff4 = {
          ["1do"] = actions.diffget("base"),
          ["2do"] = actions.diffget("ours"),
          ["3do"] = actions.diffget("theirs"),
        },
        file_panel = {
          ["j"] = actions.next_entry,
          ["<down>"] = actions.next_entry,
          ["k"] = actions.prev_entry,
          ["<up>"] = actions.prev_entry,
          ["<cr>"] = actions.select_entry,
          ["o"] = actions.select_entry,
          ["<2-LeftMouse>"] = actions.select_entry,
          ["-"] = actions.toggle_stage_entry,
          ["S"] = actions.stage_all,
          ["U"] = actions.unstage_all,
          ["X"] = actions.restore_entry,
          ["R"] = actions.refresh_files,
          ["L"] = actions.open_commit_log,
          ["<c-b>"] = actions.scroll_view(-0.25),
          ["<c-f>"] = actions.scroll_view(0.25),
          ["<tab>"] = actions.select_next_entry,
          ["<s-tab>"] = actions.select_prev_entry,
          ["gf"] = actions.goto_file,
          ["<C-w><C-f>"] = actions.goto_file_split,
          ["<C-w>gf"] = actions.goto_file_tab,
          ["i"] = actions.listing_style,
          ["f"] = actions.toggle_flatten_dirs,
          ["<leader>e"] = actions.focus_files,
          ["<leader>b"] = actions.toggle_files,
          ["g<C-x>"] = actions.cycle_layout,
          ["g?"] = actions.help("file_panel"),
        },
        file_history_panel = {
          ["g!"] = actions.options,
          ["<C-A-d>"] = actions.open_in_diffview,
          ["y"] = actions.copy_hash,
          ["L"] = actions.open_commit_log,
          ["zR"] = actions.open_all_folds,
          ["zM"] = actions.close_all_folds,
          ["j"] = actions.next_entry,
          ["<down>"] = actions.next_entry,
          ["k"] = actions.prev_entry,
          ["<up>"] = actions.prev_entry,
          ["<cr>"] = actions.select_entry,
          ["o"] = actions.select_entry,
          ["<2-LeftMouse>"] = actions.select_entry,
          ["<c-b>"] = actions.scroll_view(-0.25),
          ["<c-f>"] = actions.scroll_view(0.25),
          ["<tab>"] = actions.select_next_entry,
          ["<s-tab>"] = actions.select_prev_entry,
          ["gf"] = actions.goto_file,
          ["<C-w><C-f>"] = actions.goto_file_split,
          ["<C-w>gf"] = actions.goto_file_tab,
          ["<leader>e"] = actions.focus_files,
          ["<leader>b"] = actions.toggle_files,
          ["g<C-x>"] = actions.cycle_layout,
          ["g?"] = actions.help("file_history_panel"),
        },
        option_panel = {
          ["<tab>"] = actions.select_entry,
          ["q"] = actions.close,
          ["g?"] = actions.help("option_panel"),
        },
        help_panel = {
          ["q"] = actions.close,
        },
      },
    })
  end,
}

