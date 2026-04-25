return {
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
      stages = "static",
      render = "compact",
      fps = 5,
      level = 1,
      timeout = 2000,
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = {
          enabled = false,
        },
      },
    },
  },
  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        -- change help to vimdoc
        "vimdoc",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      log_level = "warn", -- suppress INFO-level messages like "Skipping wait for gitignored"
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            ".github",
            ".gitignore",
            "package-lock.json",
          },
          never_show = { ".git", "node_modules", ".next" },
        },
      },
      window = {
        mappings = {
          ["o"] = "open",
        },
      },
    },
    keys = {
      -- Add a <C-n> remap to open neotree
      { "<C-n>", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
    },
  },
  -- Disable markdown plugins inside Obsidian vaults
  {
    "MeanderingProgrammer/render-markdown.nvim",
    cond = function()
      return not require("config.vaults").in_any_vault()
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cond = function()
      return not require("config.vaults").in_any_vault()
    end,
  },
}
