-- Set space as the leader key
vim.g.mapleader = " "
-- Open Netrw file explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move selected lines down (J) or up (K) in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Join lines without moving cursor
vim.keymap.set("n", "J", "mzJ`z")
-- Half-page down/up while keeping cursor in the middle
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-y>", "<C-u>zz")
-- Keep search matches in the middle when navigating
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Start "Vim with me" session
vim.keymap.set("n", "<leader>vwm", function()
    require("vim-with-me").StartVimWithMe()
end)
-- Stop "Vim with me" session
vim.keymap.set("n", "<leader>svwm", function()
    require("vim-with-me").StopVimWithMe()
end)

-- Paste over selection without copying the replaced text
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Copy to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete without copying to clipboard
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Map Ctrl+C to Escape in insert mode
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Disable Ex mode
vim.keymap.set("n", "Q", "<nop>")
-- Open tmux session switcher
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux new tmux-sessionizer<CR>")
-- Format buffer using LSP
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Navigate through quickfix list
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- Navigate through location list
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Search and replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- Make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Open packer config file
vim.keymap.set("n", "VITE_<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>");
-- Run "make it rain" cellular automaton
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

-- Source (reload) current file
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)
