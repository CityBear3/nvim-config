return {
  'b0o/incline.nvim',
  config = function()
    -- vim.opt.termguicolors = false
    local helpers = require('incline.helpers')
    local devicons = require('nvim-web-devicons')

    -- incline用のハイライトグループを作成
    -- vim.api.nvim_set_hl(0, 'InclineBg', { ctermbg = 238 })  -- Dracula current line風
    -- vim.api.nvim_set_hl(0, 'InclineGitAdd', { ctermfg = 10, ctermbg = 238 })     -- 緑
    -- vim.api.nvim_set_hl(0, 'InclineGitChange', { ctermfg = 11, ctermbg = 238 })  -- 黄
    -- vim.api.nvim_set_hl(0, 'InclineGitDelete', { ctermfg = 9, ctermbg = 238 })   -- 赤

    require('incline').setup {
      window = {
        padding = 0,
        margin = { horizontal = 0 },
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        if filename == '' then
          filename = '[No Name]'
        end
        local ft_icon, ft_color = devicons.get_icon_color(filename)
        local modified = vim.bo[props.buf].modified and ' ●' or ''


        -- Diagnostic label (公式の方法)
        local function get_diagnostic_label()
          local icons = { error = '✗ ', warn = '⚠ ', info = 'ℹ ', hint = '💡' }
          local label = {}
          for severity, icon in pairs(icons) do
            local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
            if n > 0 then
              table.insert(label, { icon .. n .. ' ', group = 'DiagnosticSign' .. severity })
            end
          end
          return label
        end
        local diag = get_diagnostic_label()

        -- Git diff (gitgutter)
        local function get_git_diff()
          local label = {}
          local ok, summary = pcall(function()
            return vim.api.nvim_buf_call(props.buf, function()
              return vim.fn.GitGutterGetHunkSummary()
            end)
          end)
          if not ok or not summary then
            return label
          end
          local added, changed, removed = summary[1], summary[2], summary[3]
          -- Diff Highlight
          local add_fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('DiffAdd')), 'fg#')
          local change_fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('DiffChange')), 'fg#')
          local delete_fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('DiffDelete')), 'fg#')

          if added and added > 0 then
            table.insert(label, { '+' .. added .. ' ', guifg = add_fg ~= '' and add_fg or '#50fa7b' })
          end
          if changed and changed > 0 then
            table.insert(label, { '~' .. changed .. ' ', guifg = change_fg ~= '' and change_fg or '#f1fa8c' })
          end
          if removed and removed > 0 then
            table.insert(label, { '-' .. removed .. ' ', guifg = delete_fg ~= '' and delete_fg or '#ff5555' })
          end
          return label
        end
        local git = get_git_diff()

        -- Statusline Bg Color
        local statusline_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('StatusLine')), 'bg#')
        if statusline_bg == '' then
          statusline_bg = '#44406e'  -- Fallback color
        end

        return {
          diag,
          #diag > 0 and #git > 0 and '| ' or '',
          git,
          (#diag > 0 or #git > 0) and '│ ' or '',
          ft_icon and { ' ', ft_icon, ' ', guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or '',
          { filename, gui = modified and 'bold,italic' or 'bold' },
          modified,
          ' ',
          guibg = statusline_bg,
        }
      end,
    }
  end,
}
