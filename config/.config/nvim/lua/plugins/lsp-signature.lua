return {
  "ray-x/lsp_signature.nvim",
  event = "VeryLazy",
  opts = {
    bind = true,
    handler_opts = {
      border = "rounded",
    },
    hint_enable = true,
    hint_prefix = "🐼 ",
    floating_window = true,
    floating_window_above_cur_line = true,
    fix_pos = false,
    transparency = 10,
    toggle_key = "<C-k>",
    select_signature_key = "<C-n>",
    move_cursor_key = nil,
    max_height = 12,
    max_width = 80,
    padding = " ",
    close_timeout = 4000,
    extra_trigger_chars = {},
    zindex = 200,
    timer_interval = 200,
    toggle_key_flip_floatwin_setting = false,
  },
  config = function(_, opts)
    require("lsp_signature").setup(opts)
  end,
}
