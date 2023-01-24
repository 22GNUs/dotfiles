local transparency = require("custom.settings").transparency
local M = {}

M.treesitter = {
  ensure_installed = {
    "json",
    "toml",
    "markdown",
    "bash",
    "lua",
    "go",
  },
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",

    "stylua",

    -- typescript
    "typescript-language-server",

    -- python
    "python-lsp-server",

    -- go
    "gopls",

    -- shell
    "shellcheck",

    -- json
    "json-lsp",
  },
}

M.nvterm = {
  terminals = {
    type_opts = {
      float = {
        relative = "editor",
        -- 上边距
        row = 0.18,
        -- 左边距
        col = 0.12,
        width = 0.75,
        height = 0.6,
        border = "single",
      },
      horizontal = { location = "rightbelow", split_ratio = 0.3 },
      vertical = { location = "rightbelow", split_ratio = 0.5 },
    },
  },
}

M.blankline = function()
  -- get colors from global theme table
  local colors = require("base46").get_theme_tb "base_30"
  vim.cmd(string.format([[highlight IndentBlanklineIndent1 guifg=%s gui=nocombine]], colors.red))
  vim.cmd(string.format([[highlight IndentBlanklineIndent2 guifg=%s gui=nocombine]], colors.purple))
  vim.cmd(string.format([[highlight IndentBlanklineIndent3 guifg=%s gui=nocombine]], colors.cyan))
  vim.cmd(string.format([[highlight IndentBlanklineIndent4 guifg=%s gui=nocombine]], colors.green))
  vim.cmd(string.format([[highlight IndentBlanklineIndent5 guifg=%s gui=nocombine]], colors.blue))
  vim.cmd(string.format([[highlight IndentBlanklineIndent6 guifg=%s gui=nocombine]], colors.yellow))
  return {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
    char_highlight_list = {
      "IndentBlanklineIndent1",
      "IndentBlanklineIndent2",
      "IndentBlanklineIndent3",
      "IndentBlanklineIndent4",
      "IndentBlanklineIndent5",
      "IndentBlanklineIndent6",
    },
  }
end

M.telescope = function()
  return {
    defaults = {
      prompt_prefix = "   ",
      winblend = transparency.winblend(),
    },
  }
end

M.cmp = function()
  local present, cmp = pcall(require, "cmp")
  if not present then
    return
  end
  return {
    mapping = {
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        -- See: https://github.com/L3MON4D3/LuaSnip/issues/532
        elseif require("luasnip").expand_or_locally_jumpable() then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),
    },
  }
end

M.whichkey = function()
  return {
    window = {
      winblend = transparency.winblend(),
    },
  }
end

return M
