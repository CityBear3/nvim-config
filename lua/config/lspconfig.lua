-- local on_attach = function(client, bufnr)
-- 
--   -- LSPが持つフォーマット機能を無効化する
--   -- →例えばtsserverはデフォルトでフォーマット機能を提供しますが、利用したくない場合はコメントアウトを解除してください
--   --client.server_capabilities.documentFormattingProvider = false
--   
--   -- 下記ではデフォルトのキーバインドを設定しています
--   -- ほかのLSPプラグインを使う場合（例：Lspsaga）は必要ないこともあります
-- 
-- local set = vim.keymap.set
--   set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
--   set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
--   set("n", "<C-m>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
--   set("n", "gy", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
--   set("n", "rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
--   set("n", "ma", "<cmd>lua vim.lsp.buf.code_action()<CR>")
--   set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
--   set("n", "<C-e>", "<cmd>lua vim.diagnostic.open_float()<CR>", {
--     buffer = bufnr
--   })
--   set("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>")
--   set("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>")
-- 
-- end

local on_attach = function(client, bufnr)
  local set = vim.keymap.set
  local opts = { buffer = bufnr }

  -- set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  -- set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
  -- set("n", "<C-m>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  -- set("n", "gy", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  -- set("n", "rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  -- set("n", "ma", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  -- set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)

  -- Lspsaga Integration
  set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", opts)
  set("n", "gt", "<cmd>Lspsaga goto_type_definition<CR>", opts)
  set("n", "gr", "<cmd>Lspsaga finder<CR>", opts)
  set("n", "gi", "<cmd>Lspsaga goto_implementation<CR>", opts)

  -- Lspsaga UI features
  set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
  set("n", "<C-m>", "<cmd>Lspsaga signature_help<CR>", opts)
  set("n", "ma", "<cmd>Lspsaga code_action<CR>", opts)
  set("n", "rn", "<cmd>Lspsaga rename<CR>", opts)

  -- Lspsaga outline
  set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", opts)

  -- Lspsaga Call Hierarchy
  set("n", "gci", "<cmd>Lspsaga incoming_calls<CR>", opts)
  set("n", "gco", "<cmd>Lspsaga outgoing_calls<CR>", opts)

  -- Lspsaga Peek functions (definition and Type Definition preview)
  set("n", "gpd", "<cmd>Lspsaga peek_definition<CR>", opts)
  set("n", "gpt", "<cmd>Lspsaga peek_type_definition<CR>", opts)

  -- Lspsaga Diagnostic features
  set("n", "<C-e>", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
  set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
  set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
end


-- 補完プラグインであるcmp_nvim_lspをLSPと連携させています（後述）
local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- (2022/11/1追記):cmp-nvim-lspに破壊的変更が加えられ、
-- local capabilities = require('cmp_nvim_lsp').update_capabilities(
--  vim.lsp.protocol.make_client_capabilities()
-- )
-- ⇑上記のupdate_capabilities(...)の関数は非推奨となり、代わりにdefault_capabilities()関数が採用されました。日本語情報が少ないため、念の為併記してメモしておきます。

-- この一連の記述で、mason.nvimでインストールしたLanguage Serverが自動的に個別にセットアップされ、利用可能になります
require("mason").setup()
-- require("mason-lspconfig").setup()
-- require("mason-lspconfig").setup_handlers {
--   function (server_name) -- default handler (optional)
--     require("lspconfig")[server_name].setup {
--       on_attach = on_attach, --keyバインドなどの設定を登録
--       capabilities = capabilities, --cmpを連携
--     }
--   end,
-- }
vim.lsp.config("*", {
  on_attach = on_attach,
  capabilities = capabilities
})

vim.lsp.config("rust_analyzer", {
   on_attach = on_attach,
   capabilities = capabilities,
   settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
      },
    },
  },
})

-- 診断表示の設定
vim.diagnostic.config({
  virtual_text = {
    spacing = 2,
    source = "if_many",
    prefix = "●",
  },
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})


vim.lsp.set_log_level("OFF")

vim.lsp.enable(require("mason-lspconfig").get_installed_servers())

require("fidget").setup {
  -- options
}

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspFormatOnSave", {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf })
        end,
      })
    end
  end,
})

