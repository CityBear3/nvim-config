local M = {}
local uv = vim.uv or vim.loop

local function absolute_path(path)
  return uv.fs_realpath(path) or vim.fn.fnamemodify(path, ":p")
end

-- ディレクトリ配下、またはパスに含まれる文字列を保護ルールとして登録する
---@param config { directories?: string[], path_fragments?: string[] }
function M.setup(config)
  local matchers = {}

  for _, path in ipairs(config.directories or {}) do
    if path ~= "" then
      local directory = absolute_path(path):gsub("/+$", "") .. "/"
      matchers[#matchers + 1] = function(_, resolved_path)
        return resolved_path:sub(1, #directory) == directory
      end
    end
  end

  for _, fragment in ipairs(config.path_fragments or {}) do
    if fragment ~= "" then
      matchers[#matchers + 1] = function(name, resolved_path)
        return name:find(fragment, 1, true) or resolved_path:find(fragment, 1, true)
      end
    end
  end

  vim.api.nvim_create_autocmd("BufRead", {
    group = vim.api.nvim_create_augroup("ReadonlyDependencies", { clear = true }),
    callback = function(args)
      local name = vim.api.nvim_buf_get_name(args.buf)
      local path = absolute_path(name)
      for _, matches in ipairs(matchers) do
        if matches(name, path) then
          vim.bo[args.buf].readonly = true
          vim.bo[args.buf].modifiable = false
          return
        end
      end
    end,
  })
end

return M
