-- キーマッピング
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- leaderキー設定
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- バッファ移動
keymap("n", "[b", ":bprev<CR>", opts)
keymap("n", "]b", ":bnext<CR>", opts)

-- 折り返し時に表示行単位での移動できるようにする
keymap("n", "j", "gj", opts)
keymap("n", "k", "gk", opts)

-- ESC連打でハイライト解除
keymap("n", "<Esc><Esc>", ":nohlsearch<CR><Esc>", opts)

-- 補完時にEnterで決定
keymap("i", "<CR>", function()
  return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
end, { expr = true, noremap = true })

-- カッコ補完: { ( [
keymap("i", "{", "{}<Left>", opts)
keymap("i", "{<CR>", "{}<Left><CR><ESC><S-o>", opts)
keymap("i", "()", "()", opts)
keymap("i", "(", "()<ESC>i", opts)
keymap("i", "(<CR>", "()<Left><CR><ESC><S-o>", opts)
keymap("i", "[", "[]<ESC>i", opts)
keymap("i", "[<CR>", "[]<Left><CR><ESC><S-o>", opts)

-- 補完: ' "
keymap("i", "''", "''", opts)
keymap("i", "'", "''<ESC>i", opts)
keymap("i", '""', '""', opts)
keymap("i", '"', '""<ESC>i', opts)

-- インサートモードのままカーソル移動
keymap("i", "<C-f>", "<C-g>U<Right>", opts)
keymap("i", "<C-f><C-f>", "<C-g>U<ESC><S-a>", opts)

-- jjでESC
keymap("i", "jj", "<ESC>", opts)

-- Fern
keymap("n", ",t", ":<C-u>Fern . -drawer -stay -keep -toggle -reveal=%<CR>", opts)
