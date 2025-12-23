local o = vim.o
local transparency = require("custom.settings").transparency
o.termguicolors = true
o.list = true
o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
o.linebreak = true
o.showbreak = "↳  "
o.winblend = transparency.winblend()
o.pumblend = transparency.pumblend()
-- close other buffers and keep current opened only
-- see: https://tech.serhatteker.com/post/2020-06/close-all-buffers-but-current-in-vim/
vim.cmd "silent! command! BufCurOnly execute '%bdelete|edit#|bdelete#'"

-- neovide
require "custom.gui.neovide"
