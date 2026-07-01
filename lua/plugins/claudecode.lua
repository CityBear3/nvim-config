-- Custom claudecode.nvim terminal provider that runs Claude in a herdr pane.
--
-- Why a custom provider instead of the built-in "external" one:
--   `herdr pane run` returns immediately, so the "external" provider (which
--   tracks the launched process to decide whether a terminal already exists)
--   loses track of the pane and spawns a duplicate on every launch trigger.
--   Here we remember the pane id ourselves and skip re-spawning while it is
--   still alive.
--
-- Why `--env`:
--   The pane's process is spawned by the herdr daemon, so env passed through
--   Neovim's jobstart would NOT reach it. We inject the IDE-integration env
--   (ENABLE_IDE_INTEGRATION / CLAUDE_CODE_SSE_PORT) via `herdr pane split
--   --env`, which is what makes the external Claude auto-connect to this
--   Neovim's WebSocket server.
local herdr = {}
local pane_id = nil

---Is the tracked Claude pane still alive? (`herdr pane get` exits non-zero when absent.)
local function pane_alive()
  if not pane_id then
    return false
  end
  vim.fn.system({ "herdr", "pane", "get", pane_id })
  return vim.v.shell_error == 0
end

---Move focus to the Claude pane. We always split it to the right of Neovim,
---so focusing the right neighbour of the current (Neovim) pane lands on it.
local function focus_pane()
  vim.fn.system({ "herdr", "pane", "focus", "--direction", "right", "--current" })
end

function herdr.setup(_) end

---Open Claude in a new herdr pane, reusing the existing one if still alive.
---@param cmd_string string The claude command (e.g. "claude", "claude --resume")
---@param env_table table Environment variables the plugin wants Claude to inherit
function herdr.open(cmd_string, env_table, _, _focus)
  if pane_alive() then
    -- Claude pane already exists; just focus it (do NOT respawn / kill session).
    focus_pane()
    return
  end

  -- Step 1: split the current (Neovim) pane to the RIGHT, carrying the IDE env.
  local split = {
    "herdr", "pane", "split", "--current",
    "--direction", "right", "--focus",
    "--cwd", vim.fn.getcwd(),
  }
  for k, v in pairs(env_table) do
    table.insert(split, "--env")
    table.insert(split, k .. "=" .. tostring(v))
  end

  local out = vim.fn.system(split)
  if vim.v.shell_error ~= 0 then
    vim.notify("herdr pane split failed: " .. out, vim.log.levels.ERROR)
    return
  end

  local ok, decoded = pcall(vim.json.decode, out)
  local id = ok and decoded and decoded.result and decoded.result.pane and decoded.result.pane.pane_id
  if not id then
    vim.notify("herdr pane split: could not parse pane_id from: " .. out, vim.log.levels.ERROR)
    return
  end
  pane_id = id

  -- Step 2: run claude in the freshly created pane. It inherits the --env vars
  -- set above and connects back to Neovim automatically.
  vim.fn.system({ "herdr", "pane", "run", pane_id, cmd_string })
end

function herdr.close()
  if pane_alive() then
    vim.fn.system({ "herdr", "pane", "close", pane_id })
  end
  pane_id = nil
end

---Toggle: open if no pane, otherwise focus the existing one (keeps the session).
function herdr.simple_toggle(cmd_string, env_table, effective_config)
  if pane_alive() then
    focus_pane()
  else
    herdr.open(cmd_string, env_table, effective_config, true)
  end
end

function herdr.focus_toggle(cmd_string, env_table, effective_config)
  herdr.simple_toggle(cmd_string, env_table, effective_config)
end

function herdr.ensure_visible() end

function herdr.get_active_bufnr()
  return nil
end

---Only usable inside a herdr session; otherwise claudecode falls back to native.
function herdr.is_available()
  return vim.env.HERDR_ENV ~= nil
end

return {
  "coder/claudecode.nvim",
  lazy = false,
  dependencies = { "folke/snacks.nvim" },
  opts = {
    terminal = {
      provider = herdr,
    },
  },
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
    },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
