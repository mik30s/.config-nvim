return {
  "Isrothy/neominimap.nvim",
  enabled = true,
  lazy = false,
  keys = {
    { "<leader>nm", "<cmd>Neominimap toggle<cr>", desc = "Toggle Neominimap" },
  },
  init = function()
    vim.opt.wrap = false
    vim.g.neominimap = {
      auto_enable = true,
    }
  	end,
}
