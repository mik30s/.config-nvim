-- Android dev tooling for Neovim. Only activated when cwd is an Android project.
local M = {}

local sdk = os.getenv("ANDROID_HOME") or os.getenv("ANDROID_SDK_ROOT") or (os.getenv("HOME") .. "/Android/Sdk")

-- Returns the Gradle root if cwd (or a parent) is an Android project, else nil.
function M.root()
  if M._root ~= nil then
    return M._root or nil
  end
  M._root = false
  local settings = vim.fs.find({ "settings.gradle.kts", "settings.gradle" }, {
    upward = true,
    path = vim.fn.getcwd(),
  })[1]
  if settings then
    local root = vim.fs.dirname(settings)
    local manifest = vim.fs.find("AndroidManifest.xml", { path = root, limit = 1, type = "file" })[1]
    if manifest then
      M._root = root
    end
  end
  return M._root or nil
end

function M.is_android()
  return M.root() ~= nil
end

-- Reads applicationId from app/build.gradle(.kts)
function M.app_id()
  for _, f in ipairs({ "/app/build.gradle.kts", "/app/build.gradle" }) do
    local path = M.root() .. f
    if vim.fn.filereadable(path) == 1 then
      for _, line in ipairs(vim.fn.readfile(path)) do
        local id = line:match('applicationId%s*=?%s*"([^"]+)"')
        if id then
          return id
        end
      end
    end
  end
end

local term_cache = {}
local function term(name, cmd, opts)
  opts = opts or {}
  local Terminal = require("toggleterm.terminal").Terminal
  if term_cache[name] then
    term_cache[name]:shutdown()
  end
  local t = Terminal:new({
    cmd = cmd,
    dir = M.root(),
    direction = opts.direction or "horizontal",
    close_on_exit = false,
    hidden = true,
    display_name = name,
  })
  term_cache[name] = t
  t:open(opts.size or 15)
  if not opts.focus then
    vim.cmd("wincmd p")
  end
end

local function adb()
  local serial = vim.g.android_device
  return serial and ("adb -s " .. serial) or "adb"
end

-- Run gradle in background, parse Kotlin/Java errors into quickfix.
function M.gradle(tasks, on_ok)
  local cmd = { M.root() .. "/gradlew", "--console=plain" }
  vim.list_extend(cmd, vim.split(tasks, " ", { trimempty = true }))
  vim.notify("gradle " .. tasks .. " ...", vim.log.levels.INFO, { title = "Android" })
  local started = vim.uv.hrtime()
  vim.system(cmd, { cwd = M.root(), text = true }, function(res)
    vim.schedule(function()
      local items = {}
      local out = (res.stdout or "") .. "\n" .. (res.stderr or "")
      for line in out:gmatch("[^\n]+") do
        -- Kotlin: e: file:///path/File.kt:12:5 message
        local sev, file, lnum, col, msg = line:match("^([ew]): file://(.-):(%d+):(%d+) (.*)$")
        if not sev then
          sev, file, lnum, col, msg = line:match("^([ew]): (/.-): %((%d+), (%d+)%): (.*)$")
        end
        if sev then
          table.insert(items, {
            filename = file, lnum = tonumber(lnum), col = tonumber(col),
            text = msg, type = sev == "e" and "E" or "W",
          })
        else
          -- Java / AAPT: /path/File.java:12: error: message
          local jf, jl, jt, jm = line:match("^(/.-):(%d+): (%a+): (.*)$")
          if jf then
            table.insert(items, { filename = jf, lnum = tonumber(jl), text = jm, type = jt:sub(1, 1):upper() })
          end
        end
      end
      vim.fn.setqflist({}, "r", { title = "gradle " .. tasks, items = items })
      local secs = string.format("%.1fs", (vim.uv.hrtime() - started) / 1e9)
      if res.code == 0 then
        vim.notify("✔ gradle " .. tasks .. " (" .. secs .. ")", vim.log.levels.INFO, { title = "Android" })
        if #items > 0 then vim.cmd("copen | wincmd p") end
        if on_ok then on_ok() end
      else
        vim.notify("✘ gradle " .. tasks .. " failed (" .. secs .. ")", vim.log.levels.ERROR, { title = "Android" })
        if #items > 0 then
          vim.cmd("copen")
        else
          -- No parseable errors: dump raw output
          local lines = vim.split(out, "\n")
          vim.fn.setqflist({}, "r", { title = "gradle " .. tasks, lines = lines })
          vim.cmd("copen | normal! G")
        end
      end
    end)
  end)
end

function M.launch()
  local id = M.app_id()
  vim.system({ "sh", "-c", adb() .. " shell monkey -p " .. id .. " -c android.intent.category.LAUNCHER 1" })
  vim.notify("Launched " .. id, vim.log.levels.INFO, { title = "Android" })
end

function M.run()
  M.gradle("installDebug", M.launch)
end

function M.logcat(all)
  local id = M.app_id()
  local cmd
  if all then
    cmd = adb() .. " logcat -v color"
  else
    -- Follow the app across restarts by re-resolving pid
    cmd = string.format(
      "while true; do pid=$(%s shell pidof -s %s); if [ -n \"$pid\" ]; then %s logcat -v color --pid=$pid; fi; sleep 1; done",
      adb(), id, adb()
    )
  end
  term("logcat", cmd, { direction = "vertical", size = math.floor(vim.o.columns * 0.4) })
end

function M.select_device()
  local out = vim.fn.systemlist("adb devices | tail -n +2 | grep -w device | cut -f1")
  if #out == 0 then
    return vim.notify("No devices connected", vim.log.levels.WARN, { title = "Android" })
  end
  vim.ui.select(out, { prompt = "Device" }, function(choice)
    if choice then
      vim.g.android_device = choice
      vim.notify("Using " .. choice, vim.log.levels.INFO, { title = "Android" })
    end
  end)
end

function M.emulator()
  local bin = sdk .. "/emulator/emulator"
  local avds = vim.fn.systemlist(bin .. " -list-avds")
  if #avds == 0 then
    return vim.notify("No AVDs found (create one with avdmanager)", vim.log.levels.WARN, { title = "Android" })
  end
  vim.ui.select(avds, { prompt = "Emulator" }, function(avd)
    if avd then
      vim.system({ bin, "-avd", avd, "-netdelay", "none", "-netspeed", "full" }, { detach = true })
      vim.notify("Starting " .. avd, vim.log.levels.INFO, { title = "Android" })
    end
  end)
end

function M.setup()
  -- KLS bundles an older Kotlin compiler than the project; drop its spurious
  -- "compiled with an incompatible version of Kotlin" metadata errors.
  local orig = vim.lsp.handlers["textDocument/publishDiagnostics"]
  vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, ...)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if result and client and client.name == "kotlin_language_server" then
      result.diagnostics = vim.tbl_filter(function(d)
        return not d.message:find("incompatible version of Kotlin", 1, true)
      end, result.diagnostics)
    end
    return orig(err, result, ctx, ...)
  end
  local cmds = {
    AndroidBuild = function() M.gradle("assembleDebug") end,
    AndroidInstall = function() M.gradle("installDebug") end,
    AndroidRun = M.run,
    AndroidLaunch = M.launch,
    AndroidClean = function() M.gradle("clean") end,
    AndroidTest = function() M.gradle("testDebugUnitTest") end,
    AndroidLint = function() M.gradle("lintDebug") end,
    AndroidLogcat = function() M.logcat(false) end,
    AndroidLogcatAll = function() M.logcat(true) end,
    AndroidDevice = M.select_device,
    AndroidEmulator = M.emulator,
    AndroidStop = function() vim.system({ "sh", "-c", adb() .. " shell am force-stop " .. M.app_id() }) end,
    AndroidUninstall = function() vim.system({ "sh", "-c", adb() .. " uninstall " .. M.app_id() }) end,
    AndroidScreenshot = function()
      local f = string.format("%s/screenshot_%s.png", M.root(), os.date("%Y%m%d_%H%M%S"))
      vim.system({ "sh", "-c", adb() .. " exec-out screencap -p > " .. f })
      vim.notify("Saved " .. f, vim.log.levels.INFO, { title = "Android" })
    end,
    AndroidMirror = function()
      if vim.fn.executable("scrcpy") == 0 then
        return vim.notify("Install scrcpy for device mirroring", vim.log.levels.WARN)
      end
      vim.system({ "scrcpy", "--stay-awake" }, { detach = true })
    end,
  }
  for name, fn in pairs(cmds) do
    vim.api.nvim_create_user_command(name, fn, {})
  end
  vim.api.nvim_create_user_command("Gradle", function(o) M.gradle(o.args) end, { nargs = "+" })

  local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = "Android: " .. desc }) end
  map("<leader>ab", "<cmd>AndroidBuild<cr>", "build debug")
  map("<leader>ar", "<cmd>AndroidRun<cr>", "install + launch")
  map("<leader>ai", "<cmd>AndroidInstall<cr>", "install")
  map("<leader>as", "<cmd>AndroidStop<cr>", "force stop")
  map("<leader>at", "<cmd>AndroidTest<cr>", "unit tests")
  map("<leader>aL", "<cmd>AndroidLint<cr>", "lint")
  map("<leader>al", "<cmd>AndroidLogcat<cr>", "logcat (app)")
  map("<leader>ac", "<cmd>AndroidClean<cr>", "clean")
  map("<leader>ad", "<cmd>AndroidDevice<cr>", "select device")
  map("<leader>ae", "<cmd>AndroidEmulator<cr>", "start emulator")
  map("<leader>am", "<cmd>AndroidMirror<cr>", "mirror (scrcpy)")
end

return M
