-- Android dev environment: only loads when nvim is opened inside an Android project.
return {
  dir = vim.fn.stdpath("config") .. "/lua/mm/android",
  name = "android-dev",
  cond = function()
    return require("mm.android").is_android()
  end,
  dependencies = { "akinsho/toggleterm.nvim" },
  config = function()
    require("mm.android").setup()
  end,
}
