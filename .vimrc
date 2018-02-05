" Source Base Vim Config
source ~/.ideavimrc

" ===> 插件 {{{

call plug#begin('~/.vim/plugged')

" spacevim 颜色主题
Plug 'liuchengxu/space-vim-dark'

" spacevim 样式状态栏
Plug 'liuchengxu/eleline.vim'

" json显示插件
Plug 'elzr/vim-json'

" markdown 插件
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

call plug#end()

" }}}

" ===> 插件设置 {{{

" ==== markdown 插件设置

" 折叠方式 (一级标题以外自动折叠)
let g:vim_markdown_folding_style_pythonic = 1

" TOC窗口自适应
let g:vim_markdown_toc_autofit = 1

" 高亮YAML Front Matter
let g:vim_markdown_frontmatter = 1

" 隐藏部分标签
" set conceallevel=2

" =====================


" }}}

" ===> Color Schemes 设置 {{{

" 启用true color
" set termguicolors

" 启用斜体
hi Comment cterm=italic

" spacevim 主题深度
let g:space_vim_dark_background = 235

" 颜色主题
colorscheme space-vim-dark

" }}}
