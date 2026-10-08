-- ~/nvim/lua/mm/settings.lua
--

local global = vim.g
local o = vim.opt

-- Set tab behavior globally for all file types
o.tabstop = 2 -- A hard tab is 4 spaces wide for display
o.softtabstop = 2 -- Backspace and Tab keys treat 4 spaces as a single tab
o.expandtab = true -- Use spaces instead of actual tab characters
-- Editor options
o.number = true -- Print the line number in front of each line
o.relativenumber = false -- Show the line number relative to the line
o.clipboard = "unnamedplus"
o.syntax = "on" -- When this option is set, the syntax with this name is loaded.
o.autoindent = true -- Copy indent from current line when starting a new line.
o.cursorline = true -- Highlight the screen line of the cursor with CursorLine.
o.cursorcolumn = true -- Highlight the screen column of the cursor with CursorColumn (Crosshair effect).

-- Neon Green Crosshair Highlights (CursorLine & CursorColumn)
local function apply_neon_crosshair()
	vim.api.nvim_set_hl(0, "CursorLine", { bg = "#0d4a1e" })
	vim.api.nvim_set_hl(0, "CursorColumn", { bg = "#0d4a1e" })
end

-- Crosshair (cursorline + cursorcolumn) active window focus management
local crosshair_group = vim.api.nvim_create_augroup("CrosshairFocus", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufEnter", "ColorScheme" }, {
	group = crosshair_group,
	callback = function()
		apply_neon_crosshair()
		if vim.g.crosshair_enabled ~= false then
			vim.wo.cursorline = true
			vim.wo.cursorcolumn = true
		end
	end,
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
	group = crosshair_group,
	callback = function()
		vim.wo.cursorcolumn = false
	end,
})

o.expandtab = true -- In Insert mode: Use the appropriate number of spaces to insert a <Tab>.
o.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent.
o.tabstop = 2 -- Number of spaces that a <Tab> in the file counts for.
o.encoding = "UTF-8" -- Sets the character encoding used inside Vim.
o.ruler = true -- Show the line and column number of the cursor position, separated by a comma.
o.mouse = "a" -- Enable the use of the mouse. "a" you can use on all modes
o.title = true -- When on, the title of the window will be set to the value of 'titlestring'
o.hidden = true -- When on a buffer becomes hidden when it is |abandon|ed
o.ttimeoutlen = 0 -- The time in milliseconds that is waited for a key code or mapped key sequence to complete.
o.wildmenu = true -- When 'wildmenu' is on, command-line completion operates in an enhanced mode.
o.showcmd = true -- Show (partial) command in the last line of the screen. Set this option off if your terminal is slow.
o.showmatch = true -- When a bracket is inserted, briefly jump to the matching one.
o.inccommand = "split" -- When nonempty, shows the effects of :substitute, :smagic, :snomagic and user commands with the :command-preview flag as you type.
o.splitright = true
o.splitbelow = true -- When on, splitting a window will put the new window below the current one
o.termguicolors = true
o.wrap = true -- Enable line wrapping
o.linebreak = true -- Wrap lines at convenient points (words)
o.breakindent = true -- Maintain indentation for wrapped lines
-- Replace tabs with spaces
vim.opt.expandtab = true
-- show white space
o.list = true
o.listchars = {
	space = ".",
	tab = "→ ",
}
