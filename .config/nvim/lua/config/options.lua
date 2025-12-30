-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.transparency = true
vim.g.tokyonight_dark_float = false
vim.g.lazyvim_blink_main = false
vim.o.shell = "fish"

-- 在VSCode环境中禁用Neovim的拼写检查，使用VSCode的拼写检查
-- 使用多种方法检测VSCode环境，确保配置生效
local is_vscode = vim.g.vscode or vim.env.VSCODE_PID or vim.fn.exists("g:vscode")

if is_vscode then
  vim.opt.spell = false
  vim.opt.spelllang = "" -- 清空拼写语言设置
  -- 确保相关的拼写检查选项都被禁用
  vim.opt.spellfile = ""
  vim.opt.spellcapcheck = ""
end

require("config.neovide")
