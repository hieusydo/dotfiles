vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

vim.keymap.set({ "n", "v" }, ";", ":")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
local plugins_enabled = vim.env.HDO_ENABLE_NVIM_PLUGINS == "1"

local function warn(message)
  vim.schedule(function()
    vim.notify(message, vim.log.levels.WARN)
  end)
end

local function load_lockfile()
  local path = vim.fn.stdpath("config") .. "/lazy-lock.json"
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end

  local decoded_ok, lock = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not decoded_ok then
    return nil
  end
  return lock
end

local function installed_plugins_match(lock)
  local plugin_root = vim.fn.stdpath("data") .. "/lazy"
  for name, metadata in pairs(lock) do
    local path = plugin_root .. "/" .. name
    if uv.fs_stat(path) then
      local actual = vim.trim(vim.fn.system({ "git", "-C", path, "rev-parse", "HEAD" }))
      if vim.v.shell_error ~= 0 or actual ~= metadata.commit then
        return false, name
      end
    end
  end
  return true
end

if not plugins_enabled then
  warn("Neovim plugins are disabled. Review THIRD_PARTY.md, then set HDO_ENABLE_NVIM_PLUGINS=1.")
elseif not uv.fs_stat(lazypath) then
  warn("lazy.nvim is missing. Install its approved pinned commit before enabling plugins.")
else
  local lock = load_lockfile()
  if not lock then
    warn("Could not read lazy-lock.json; refusing to load plugins.")
  else
    local matches, plugin = installed_plugins_match(lock)
    if not matches then
      warn("Plugin commit mismatch for " .. plugin .. "; refusing to load plugins.")
    else
      vim.opt.rtp:prepend(lazypath)
      require("lazy").setup("plugins", {
        checker = { enabled = false },
        change_detection = { notify = false },
        install = { missing = false },
      })
    end
  end
end
