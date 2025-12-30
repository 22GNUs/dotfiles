-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")
local function keymap(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- bind <C-c> to <ESC> in insert mode
keymap("i", "jk", "<ESC>", { silent = true })
keymap("i", "jj", "<ESC>", { silent = true })
keymap("t", "jk", "<C-\\><C-n>", { silent = true })
keymap("t", "jj", "<C-\\><C-n>", { silent = true })
keymap("i", "<C-c>", "<Nop>", { silent = true })

-- buffers
if Util.has("bufferline.nvim") then
  keymap("n", "<H>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
  keymap("n", "<L>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
else
  keymap("n", "<H>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
  keymap("n", "<L>", "<cmd>bnext<cr>", { desc = "Next buffer" })
end

if vim.g.vscode then
  -- This block contains keymappings that are specific to running Neovim within the
  -- VSCode Neovim extension (https://github.com/vscode-neovim/vscode-neovim).
  -- It uses a helper function `callAction` to trigger VS Code's built-in commands.

  local vscode = require("vscode")
  local function callAction(action)
    return function()
      vscode.action(action)
    end
  end

  keymap("n", "<H>", "<cmd>Tabprevious<cr>", { desc = "Prev VSCode Tab" })
  keymap("n", "<L>", "<cmd>Tabnext<cr>", { desc = "Next VSCode Tab" })
  keymap(
    { "n", "v" },
    "<C-/>",
    callAction("workbench.action.terminal.toggleTerminal"),
    { desc = "Toggle VSCode Terminal" }
  )

  keymap({ "n", "v" }, "<leader>e", callAction("workbench.view.explorer"), { desc = "Toggle VSCode Explorer" })
  keymap({ "n", "v" }, "<leader>ca", callAction("editor.action.quickFix"), { desc = "VSCode Quick Fix / Code Actions" })
  keymap({ "n", "x" }, "<leader>cr", callAction("editor.action.rename"), { desc = "VSCode Rename Symbol" })
  keymap({ "n", "v" }, "<leader>bp", callAction("workbench.action.pinEditor"), { desc = "Pin VSCode Editor Tab" })
  keymap({ "n", "v" }, "<leader>bP", callAction("workbench.action.unpinEditor"), { desc = "Unpin VSCode Editor Tab" })
  keymap({ "n", "v" }, "<leader>ff", callAction("workbench.action.quickOpen"), { desc = "VSCode Search Symbols" })
  keymap({ "n", "v" }, "<leader>ss", callAction("workbench.action.showAllSymbols"), { desc = "VSCode Search Symbols" })
  keymap({ "n", "v" }, "<leader>sw", callAction("workbench.action.quickTextSearch"), { desc = "VSCode Quick Search" })
  keymap({ "n", "v" }, "<leader>gg", callAction("workbench.view.scm"), { desc = "Show Changes" })
  keymap({ "n", "v" }, "]e", callAction("editor.action.marker.next"), { desc = "Go to next problem" })
  keymap({ "n", "v" }, "[e", callAction("editor.action.marker.prev"), { desc = "Go to previous problem" })
  keymap({ "n", "v" }, "gI", callAction("editor.action.goToImplementation"), { desc = "Go to Implementation (VSCode)" })
  keymap({ "n", "v" }, "gD", callAction("editor.action.revealDeclaration"), { desc = "Go to declaration (VSCode)" })
  -- Java only
  keymap({ "n", "v" }, "gS", callAction("jdk.java.goto.super.implementation"), { desc = "Go to super (VSCode)" })
end
