vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

vim.keymap.set({ "n", "v" }, ";", ":")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazyrepo = "https://github.com/folke/lazy.nvim.git"
local uv = vim.uv or vim.loop

local function warn(message)
  vim.schedule(function()
    vim.notify(message, vim.log.levels.WARN)
  end)
end

local function locked_commit(name)
  local path = vim.fn.stdpath("config") .. "/lazy-lock.json"
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end

  local decoded_ok, lock = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not decoded_ok or type(lock) ~= "table" or type(lock[name]) ~= "table" then
    return nil
  end
  return lock[name].commit
end

-- On first start, clone lazy.nvim at its commit in lazy-lock.json. lazy.nvim
-- then installs the missing plugins at their commits in the same file.
local function install_lazy()
  if uv.fs_stat(lazypath) then
    return true
  end
  if vim.fn.executable("git") ~= 1 then
    warn("Could not install lazy.nvim: git is missing. Neovim starts without plugins.")
    return false
  end

  local output = vim.fn.system({ "git", "clone", "--quiet", "--filter=blob:none", lazyrepo, lazypath })
  local commit = locked_commit("lazy.nvim")
  if vim.v.shell_error == 0 and commit then
    output = vim.fn.system({ "git", "-C", lazypath, "checkout", "--quiet", commit })
  end
  if vim.v.shell_error ~= 0 then
    vim.fn.delete(lazypath, "rf")
    warn("Could not install lazy.nvim. Neovim starts without plugins.\n" .. output)
    return false
  end
  return true
end

if install_lazy() then
  vim.opt.rtp:prepend(lazypath)
  require("lazy").setup("plugins", {
    checker = { enabled = false },
    change_detection = { notify = false },
  })
end
