-- Custom mappings

local M = {}

M.general = {
  n = {
    [">"] = { "gt", "Go to next tab" },
    ["<"] = { "gt", "Go to previous tab" },
    ["<leader>ss"] = {
      ":source % <CR>",
      "source current",
      opts = { silent = true },
    },
    ["<leader>lg"] = {
      function()
        require("nvterm.terminal").send("lazygit", "float")
      end,
      "open lazygit",
    },
  },
}

M.focus = {
  n = {
    ["<leader>wh"] = {
      ":FocusSplitLeft<CR>",
      "focus left",
      opts = { silent = true },
    },
    ["<leader>wj"] = {
      ":FocusSplitDown<CR>",
      "focus left",
      opts = { silent = true },
    },
    ["<leader>wk"] = {
      ":FocusSplitUp<CR>",
      "focus left",
      opts = { silent = true },
    },
    ["<leader>wl"] = {
      ":FocusSplitRight<CR>",
      "focus left",
      opts = { silent = true },
    },
    ["<leader>wn"] = {
      ":FocusSplitNicely<CR>",
      "focus nicely",
      opts = { silent = true },
    },
  },
}

M.nvterm = {
  n = {
    -- toggle in terminal mode (float)
    ["<leader>ft"] = {
      function()
        require("nvterm.terminal").toggle "float"
      end,
      "new float term",
    },
  },
}

M.symbles_outline = {
  n = {
    ["<leader>so"] = {
      ":SymbolsOutline<CR>",
      "toggle symbols",
      opts = { silent = true },
    },
  },
}

return M
