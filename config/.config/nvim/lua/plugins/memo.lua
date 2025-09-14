-- タイムスタンプ付きメモ機能（自動commit/push付き）
-- 記事参考: https://zenn.dev/vim_jp/articles/d4f89682bebd9f
return {
  {
    "nvim-lua/plenary.nvim", -- ファイル操作用ユーティリティ
    lazy = false,
    config = function()
      -- メモリポジトリのパス
      local memo_repo_path = vim.fn.expand("~/src/github.com/nurazon59/memo")
      local current_memo_path = nil

      -- メモディレクトリの存在確認
      if vim.fn.isdirectory(memo_repo_path) == 0 then
        vim.notify("メモリポジトリが存在しません: " .. memo_repo_path, vim.log.levels.ERROR)
        return
      end

      -- 自動commit/push関数
      local function auto_commit_and_push(file_path)
        local filename = vim.fn.fnamemodify(file_path, ":t")
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")

        -- メモリポジトリに移動してGit操作を実行
        local commands = {
          string.format("cd %s", vim.fn.shellescape(memo_repo_path)),
          string.format("git add %s", vim.fn.shellescape(filename)),
          string.format(
            "git commit -m 'feat(memo): %s を更新\n\nprompt: Neovimから自動保存' 2>/dev/null || true",
            filename
          ),
          "git push origin main 2>/dev/null || true",
        }

        local cmd = table.concat(commands, " && ")
        vim.fn.jobstart(cmd, {
          on_exit = function(_, exit_code)
            if exit_code == 0 then
              vim.notify("メモを自動保存・プッシュしました", vim.log.levels.INFO)
            end
          end,
        })
      end

      -- 新規メモファイル作成関数
      local function create_new_memo()
        local timestamp = os.date("%Y%m%d_%H%M%S")
        local filename = string.format("memo_%s.md", timestamp)
        local file_path = string.format("%s/%s", memo_repo_path, filename)

        -- ヘッダーを含むテンプレート
        local template = string.format(
          [[# メモ - %s

## 📝 内容

]],
          os.date("%Y年%m月%d日 %H:%M:%S")
        )

        -- ファイルを作成してテンプレートを書き込む
        local file = io.open(file_path, "w")
        if file then
          file:write(template)
          file:close()
        end

        return file_path
      end

      -- メモトグル関数
      local function memo_toggle()
        -- すでにメモが開いていたら保存して閉じる
        if current_memo_path and vim.fn.expand("%:p") == current_memo_path then
          vim.cmd("write")
          auto_commit_and_push(current_memo_path)
          vim.cmd("bdelete")
          current_memo_path = nil
          return
        end

        -- 新しいメモファイルを作成
        current_memo_path = create_new_memo()

        -- メモファイルを開く
        vim.cmd("edit " .. current_memo_path)

        -- バッファ設定
        vim.opt_local.bufhidden = "wipe"
        vim.opt_local.swapfile = false

        -- 自動保存設定
        local autocmd_group = vim.api.nvim_create_augroup("MemoAutoSave", { clear = true })

        vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
          group = autocmd_group,
          buffer = 0,
          callback = function()
            if vim.api.nvim_buf_get_name(0) == current_memo_path then
              vim.cmd("silent update")
            end
          end,
        })

        -- バッファを離れる時にcommit/push
        vim.api.nvim_create_autocmd({ "BufLeave", "BufUnload", "VimLeave" }, {
          group = autocmd_group,
          buffer = 0,
          once = true,
          callback = function()
            if vim.fn.filereadable(current_memo_path) == 1 then
              vim.cmd("silent update")
              auto_commit_and_push(current_memo_path)
            end
          end,
        })
      end

      -- 既存のメモファイルを開く関数
      local function open_recent_memo()
        -- メモディレクトリから最新のファイルを取得
        local cmd = string.format("ls -t %s/memo_*.md 2>/dev/null | head -1", vim.fn.shellescape(memo_repo_path))
        local handle = io.popen(cmd)
        if handle then
          local recent_file = handle:read("*a"):gsub("\n", "")
          handle:close()

          if recent_file ~= "" then
            current_memo_path = recent_file
            vim.cmd("edit " .. current_memo_path)

            -- バッファ設定
            vim.opt_local.bufhidden = "wipe"
            vim.opt_local.swapfile = false

            -- 自動保存設定
            local autocmd_group = vim.api.nvim_create_augroup("MemoAutoSave", { clear = true })

            vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
              group = autocmd_group,
              buffer = 0,
              callback = function()
                if vim.api.nvim_buf_get_name(0) == current_memo_path then
                  vim.cmd("silent update")
                end
              end,
            })

            vim.api.nvim_create_autocmd({ "BufLeave", "BufUnload", "VimLeave" }, {
              group = autocmd_group,
              buffer = 0,
              once = true,
              callback = function()
                if vim.fn.filereadable(current_memo_path) == 1 then
                  vim.cmd("silent update")
                  auto_commit_and_push(current_memo_path)
                end
              end,
            })
          else
            vim.notify("既存のメモファイルが見つかりません", vim.log.levels.WARN)
            memo_toggle() -- 新規作成
          end
        end
      end

      -- Telescopeでメモファイルを検索する関数
      local function search_memos()
        local ok, telescope = pcall(require, "telescope.builtin")
        if ok then
          telescope.find_files({
            prompt_title = "メモを検索",
            cwd = memo_repo_path,
            find_command = { "find", ".", "-name", "memo_*.md", "-type", "f" },
            attach_mappings = function(_, map)
              map("i", "<CR>", function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                if selection then
                  current_memo_path = selection.path
                  vim.cmd("edit " .. current_memo_path)

                  -- バッファ設定と自動保存設定
                  vim.opt_local.bufhidden = "wipe"
                  vim.opt_local.swapfile = false

                  local autocmd_group = vim.api.nvim_create_augroup("MemoAutoSave", { clear = true })

                  vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
                    group = autocmd_group,
                    buffer = 0,
                    callback = function()
                      if vim.api.nvim_buf_get_name(0) == current_memo_path then
                        vim.cmd("silent update")
                      end
                    end,
                  })

                  vim.api.nvim_create_autocmd({ "BufLeave", "BufUnload", "VimLeave" }, {
                    group = autocmd_group,
                    buffer = 0,
                    once = true,
                    callback = function()
                      if vim.fn.filereadable(current_memo_path) == 1 then
                        vim.cmd("silent update")
                        auto_commit_and_push(current_memo_path)
                      end
                    end,
                  })
                end
              end)
              return true
            end,
          })
        else
          vim.notify("Telescopeが利用できません", vim.log.levels.ERROR)
        end
      end

      -- コマンドを作成
      vim.api.nvim_create_user_command("Memo", memo_toggle, {})
      vim.api.nvim_create_user_command("MemoRecent", open_recent_memo, {})
      vim.api.nvim_create_user_command("MemoSearch", search_memos, {})

      -- キーマッピング
      vim.keymap.set("n", "mo", "<Cmd>Memo<CR>", { desc = "新規メモを作成" })
      vim.keymap.set("n", "<leader>mm", "<Cmd>Memo<CR>", { desc = "新規メモを作成" })
      vim.keymap.set("n", "<leader>mr", "<Cmd>MemoRecent<CR>", { desc = "最近のメモを開く" })
      vim.keymap.set("n", "<leader>ms", "<Cmd>MemoSearch<CR>", { desc = "メモを検索" })
    end,
  },
}

