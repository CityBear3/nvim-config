return {
  {
    "lambdalisue/fern.vim",
    enabled = false, -- 一時的に無効化
    lazy = false,
    branch = "main",
    init = function()
      vim.g["fern#renderer"] = "nerdfont"
      vim.g["fern#default_hidden"] = true
      vim.g["fern#hide_cursor"] = true
    end,
    config = function()
      local ns = vim.api.nvim_create_namespace("fern-colors")
      vim.api.nvim_create_augroup('FernMyConf', {})
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fern",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
          vim.opt_local.signcolumn = "no"
          vim.opt_local.foldcolumn = "0"
          vim.opt_local.cursorline = true
        end,
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fern",
        callback = function()
          vim.opt_local.winfixbuf = true
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = "FernMyConf",
        pattern = "FernHighlight",
        callback = function()
          vim.api.nvim_win_set_hl_ns(0, ns)
          vim.api.nvim_set_hl(ns, "FernBranchSymbol", { link = "Directory" })
          vim.api.nvim_set_hl(ns, "FernBranchText", { link = "Directory" })
          -- Fernでの現在行ハイライト（ctermbg: 8=darkgray, 4=blue, 6=cyan など）
          vim.api.nvim_set_hl(ns, "CursorLine", { ctermbg = 8 })
        end
      })
      vim.api.nvim_create_autocmd("VimEnter", {
        group = "FernMyConf",
        nested = true,
        callback = function()
          vim.defer_fn(function()
            local bufname = vim.api.nvim_buf_get_name(0)
            -- Claude Codeのバッファを除外
            if bufname:match("%[Claude Code%]") then return end
            if vim.fn.argc() > 0 then
              vim.cmd("Fern . -drawer -stay -toggle -reveal=%")
            else
              vim.cmd("Fern . -drawer -drawer -toggle")
            end
          end, 800)
        end,
      })
      vim.api.nvim_create_autocmd("BufRead", {
        group = "FernMyConf",
        nested = true,
        callback = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          -- Claude Codeのバッファを除外
          if vim.bo.filetype ~= "fern"
            and vim.bo.buftype == ""
            and not bufname:match("%[Claude Code%]") then
            vim.cmd("Fern . -reveal=% -drawer -stay")
          end
        end,
      })
    end,
  },
}
