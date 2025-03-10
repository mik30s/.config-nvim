-- ~/nvim/lua/slydragonn/maps.lua

vim.g.mapleader = " "

local function map(mode, lhs, rhs)
    vim.keymap.set(mode, lhs, rhs, { silent = true })
end


-- Save
map("n", "<leader>w", "<CMD>update<CR>")

-- Quit
map("n", "<leader>q", "<CMD>q<CR>")

-- Exit insert mode
map("i", "jk", "<ESC>")

-- NeoTree
map("n", "<leader>e", "<CMD>Neotree toggle<CR>")
map("n", "<leader>r", "<CMD>Neotree focus<CR>")

-- New Windows
map("n", "<leader>o", "<CMD>vsplit<CR>")
map("n", "<leader>p", "<CMD>split<CR>")

-- Window Navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-j>", "<C-w>j")

-- Resize Windows
map("n", "<C-Left>", "<C-w><")
map("n", "<C-Right>", "<C-w>>")
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")

map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', {})
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {})
map('n', '<leader>pp', '<cmd>Telescope buffers<cr>', {})

-- splitting windows
map('n', "<leader>hs", '<cmd>split<cr>', {})
map('n', "<leader>vs", '<cmd>vsplit<cr>', {})


-- Normal mode: move the current line down and up
map('n', '<A-j>', ':m .+1<CR>==', { noremap = true, silent = true })
map('n', '<A-k>', ':m .-2<CR>==', { noremap = true, silent = true })

-- Visual mode: move the selected block of lines down and up
map('v', '<A-j>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
map('v', '<A-k>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
 
