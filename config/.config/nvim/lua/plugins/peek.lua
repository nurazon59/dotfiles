-- Markdown内のMermaidダイアグラムをプレビューするためのプラグイン
return {
  "toppair/peek.nvim",
  event = { "VeryLazy" },
  build = function()
    local deno_path = vim.fn.expand("~/.local/share/mise/installs/deno/2.4.5/bin/deno")
    if vim.fn.executable(deno_path) == 1 then
      vim.fn.system(deno_path .. " run -A scripts/build.js")
    else
      -- フォールバック：通常のdenoコマンドを試す
      vim.fn.system("deno run -A scripts/build.js")
    end
  end,
  config = function()
    require("peek").setup({
      theme = "dark",
      app = "browser", -- webviewまたはbrowser
      update_on_change = true,
      syntax = true,
      close_on_bdelete = true,
      filetype = { "markdown" },
    })

    -- プレビュー用のコマンドを定義
    vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
    vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    vim.api.nvim_create_user_command("PeekToggle", function()
      local peek = require("peek")
      if peek.is_open() then
        peek.close()
      else
        peek.open()
      end
    end, {})

    -- キーマッピング
    vim.keymap.set("n", "<leader>mo", ":PeekOpen<CR>", { desc = "Markdown Preview Open" })
    vim.keymap.set("n", "<leader>mc", ":PeekClose<CR>", { desc = "Markdown Preview Close" })
    vim.keymap.set("n", "<leader>mt", ":PeekToggle<CR>", { desc = "Markdown Preview Toggle" })
  end,
}