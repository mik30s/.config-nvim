-- ~/nvim/lua/slydragonn/plugins/colorscheme.lua

return {
--    "mofiqul/vscode.nvim",
--    "nyoom-engineering/oxocarbon.nvim",
    "rmehri01/onenord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd("colorscheme  onenord")
    end,
}
 
