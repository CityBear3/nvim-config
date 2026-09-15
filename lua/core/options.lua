-- 基本設定
local opt = vim.opt

-- 文字コードをUTF-8に設定
opt.fileencoding = "utf-8"
-- バックアップファイルを作らない
opt.backup = false
-- スワップファイルを作らない
opt.swapfile = false
-- 編集中のファイルが変更されたら自動で読み直す
opt.autoread = true
-- バッファが編集中でもその他のファイルを開けるように
opt.hidden = true
-- 入力中のコマンドをステータスに表示する
opt.showcmd = true
-- Give more space for displaying messages
opt.cmdheight = 2
-- Having longer updatetime leads to noticeable delays
opt.updatetime = 300
-- Don't pass messages to |ins-completion-menu|
opt.shortmess:append("c")
-- クリップボード連携
opt.clipboard:append("unnamedplus")

-- 見た目系
-- 行番号を表示
opt.number = true
-- 現在の行を強調表示
opt.cursorline = true
-- 行末の1文字先までカーソルを移動できるように
opt.virtualedit = "onemore"
-- インデントはスマートインデント
opt.smartindent = true
-- ビープ音を可視化
opt.visualbell = true
-- 括弧入力時の対応する括弧を表示
opt.showmatch = true
-- ステータスラインを常に表示
opt.laststatus = 2
-- コマンドラインの補完
opt.wildmode = "list:longest"
-- シンタックスハイライトの有効化
vim.cmd("syntax enable")
-- コメントの色
vim.cmd("hi Comment ctermfg=lightgreen")
-- true color設定
opt.termguicolors = true

-- Tab系
-- 不可視文字を可視化(タブが「▸-」と表示される)
opt.list = true
opt.listchars = { tab = "▸-" }
-- Tab文字を半角スペースにする
opt.expandtab = true
-- 行頭以外のTab文字の表示幅（スペースいくつ分）
opt.tabstop = 2
-- 行頭でのTab文字の表示幅
opt.shiftwidth = 2

-- 検索系
-- 検索文字列が小文字の場合は大文字小文字を区別なく検索する
opt.ignorecase = true
-- 検索文字列に大文字が含まれている場合は区別して検索する
opt.smartcase = true
-- 検索文字列入力時に順次対象文字列にヒットさせる
opt.incsearch = true
-- 検索時に最後まで行ったら最初に戻る
opt.wrapscan = true
-- 検索語をハイライト表示
opt.hlsearch = true

-- その他
-- 言語ごとの保護対象を登録する。判定と編集制限は core.readonly が担当する
local readonly_rules = { directories = {}, path_fragments = {} }

local function protect_directory(path)
  if path and path ~= "" then
    readonly_rules.directories[#readonly_rules.directories + 1] = path
  end
end

local function protect_path_fragment(fragment)
  readonly_rules.path_fragments[#readonly_rules.path_fragments + 1] = fragment
end

-- Rust
protect_path_fragment("/rustlib/")
local cargo_home = vim.env.CARGO_HOME
if not cargo_home or cargo_home == "" then
  cargo_home = vim.fn.expand("~/.cargo")
end
protect_directory(cargo_home .. "/registry/src")
protect_directory(cargo_home .. "/git/checkouts")

-- Go
if vim.fn.executable("go") == 1 then
  local go_paths = {}
  local job = vim.fn.jobstart({ "go", "env", "GOROOT", "GOMODCACHE" }, {
    -- パスの確認でツールチェーンを自動ダウンロードしない
    env = { GOTOOLCHAIN = "local" },
    stdout_buffered = true,
    on_stdout = function(_, data)
      go_paths = data
    end,
  })
  if job > 0 then
    -- Go の取得に失敗しても起動や Rust の保護を妨げない
    local status = vim.fn.jobwait({ job }, 1000)[1]
    if status == -1 then
      vim.fn.jobstop(job)
    elseif status == 0 then
      if go_paths[1] and go_paths[1] ~= "" then
        protect_directory(go_paths[1] .. "/src")
      end
      protect_directory(go_paths[2])
    end
  end
end

require("core.readonly").setup(readonly_rules)
