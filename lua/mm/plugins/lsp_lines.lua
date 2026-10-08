return {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  config = function()
    require("lsp_lines").setup()
    -- Disable virtual_text since it is redundant with lsp_lines
    vim.diagnostic.config({ virtual_text = false })
  end,
}
