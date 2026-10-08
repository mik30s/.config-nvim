return {
  "Isrothy/neominimap.nvim",
  enabled = false,
  lazy = false,
  keys = {
    { "<leader>nm", "<cmd>Neominimap toggle<cr>", desc = "Toggle Neominimap" },
  },
  init = function()
    vim.g.neominimap = {
      auto_enable = true,
    }
  	end,
}
