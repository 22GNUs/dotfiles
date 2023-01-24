local load_override = require("core.utils").load_override
local present, luasnip = pcall(require, "luasnip")
if not present then
  return
end

local options = {
  history = true,
  updateevents = "TextChanged,TextChangedI",
}

options = load_override(options, "L3MON4D3/LuaSnip")
luasnip.config.set_config(options)
-- See https://github.com/L3MON4D3/LuaSnip/issues/525
luasnip.setup {
  region_check_events = "CursorHold,InsertLeave,InsertEnter",
  -- those are for removing deleted snippets, also a common problem
  delete_check_events = "TextChanged,InsertEnter",
}
require("luasnip.loaders.from_vscode").lazy_load { paths = vim.g.luasnippets_path or "" }
require("luasnip.loaders.from_vscode").lazy_load()

-- Default "InsertLeave" is not working, delete it and rebinding "ModeChanged"
-- See: https://www.reddit.com/r/neovim/comments/um7p7u/nvim_nvimcmp_luasnip_jumps_to_previous_snippets/
-- See: https://github.com/L3MON4D3/LuaSnip/issues/258
-- vim.api.nvim_del_autocmd "InsertLeave"
vim.api.nvim_create_autocmd("ModeChanged", {
  callback = function()
    if
      ((vim.v.event.old_mode == "s" and vim.v.event.new_mode == "n") or vim.v.event.old_mode == "i")
      and require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
      and not require("luasnip").session.jump_active
    then
      require("luasnip").unlink_current()
    end
  end,
})
