vim.filetype.add({
  extension = {
    ["md.html"] = "markdown"
  }
})

if vim.lsp.get_clients == nil then
  vim.lsp.get_clients = vim.lsp.get_active_clients
end


vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    if vim.fn.expand("%:e") == "md.html" then
      vim.b.autoformat = false -- for plugins like conform.nvim
      vim.bo.formatexpr = ""   -- disables Vim's formatexpr
      vim.bo.formatprg = ""    -- disables external formatting tools
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
    local base = vim.fn.expand("%:r")  -- remove extension
    local dest = base .. ".md.html"
    local cmd = string.format("cp %s %s", vim.fn.shellescape(src), vim.fn.shellescape(dest))
    os.execute(cmd)
    --print("🔁 Saved as: " .. dest)
  end,
})


require("mm.settings")
require("mm.lazy")
require("mm.maps")
require("mm.rendermarkdown")
