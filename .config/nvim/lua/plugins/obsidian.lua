return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    workspaces = {
      {
        name = "work",
        path = "~/vaults/work",
      },
    },
    daily_notes = {
      folder = "daily",
      date_format = "YYYY-MM-DD",
      default_tags = { "daily" },
    },
  },
}
