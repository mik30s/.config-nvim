vim.filetype.add({
	extension = {
		["md.html"] = "markdown",
		["mdx"] = "markdown",
	},
})

-- Global indent settings
vim.opt.tabstop = 2 -- Number of spaces a <Tab> counts for
vim.opt.softtabstop = 2 -- Number of spaces a <Tab> counts for while editing
vim.opt.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Convert tabs to spaces

if vim.lsp.get_clients == nil then
	vim.lsp.get_clients = vim.lsp.get_active_clients
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "html",
	callback = function()
		if vim.fn.expand("%:e") == "md.html" then
			vim.b.autoformat = false -- for plugins like conform.nvim
			vim.bo.formatexpr = "" -- disables Vim's formatexpr
			vim.bo.formatprg = "" -- disables external formatting tools
			print("🔕 Disabled autoformatting for .md.html buffer")
		end
	end,
})

vim.api.nvim_create_user_command("DisableAutoformat", function()
	vim.b.autoformat = false
	vim.bo.formatexpr = ""
	vim.bo.formatprg = ""
	print("🔕 Autoformatting disabled")
end, {})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.md",
	callback = function()
		local src = vim.fn.expand("%:p")
		local base = vim.fn.expand("%:r") -- remove extension
		local dest = base .. ".md.html"
		local cmd = string.format("cp %s %s", vim.fn.shellescape(src), vim.fn.shellescape(dest))
		osxecute(cmd)
		--print("🔁 Saved as: " .. dest)
	end,
})

-- Force these settings for all filetypes
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab",
})

vim.opt.clipboard = "unnamedplus"

require("mm.settings")
require("mm.lazy")
require("mm.maps")
require("mm.rendermarkdown")
