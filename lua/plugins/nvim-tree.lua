return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  init = function()
    -- termguicolorsを維持
    -- vim.opt.termguicolors = false
  end,
  config = function()
    local ns = vim.api.nvim_create_namespace("nvim-tree-colors")

    -- NvimTreeのCursorLineハイライト設定
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NvimTree",
      callback = function()
        vim.api.nvim_win_set_hl_ns(0, ns)
        vim.api.nvim_set_hl(ns, "CursorLine", { ctermbg = 8 })
      end,
    })

    require("nvim-tree").setup({
      hijack_cursor = true,
      view = {
        width = 50,
        side = "left",
      },
      renderer = {
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
      },
      filters = {
        dotfiles = false,
      },
      git = {
        enable = true,
        ignore = false,
      },
      update_focused_file = {
        enable = true,
        update_root = false,
      },
    })

    -- 起動時に自動で開く
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        local bufname = vim.api.nvim_buf_get_name(data.buf)
        -- Claude Codeのバッファを除外
        if bufname:match("%[Claude Code%]") then return end

        -- ディレクトリを開いた場合
        local directory = vim.fn.isdirectory(data.file) == 1
        if directory then
          vim.cmd.cd(data.file)
          require("nvim-tree.api").tree.open()
          return
        end

        -- ファイルを開いた場合
        if vim.fn.argc() > 0 then
          require("nvim-tree.api").tree.toggle({ focus = false })
        end
      end,
    })
  end,
}
