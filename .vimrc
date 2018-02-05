" ===> 快捷键 {{{

" H L 跳至行首行尾
" J K 替代<c-d> <c-u> 上下翻页
" <leader>e 编辑vimrc
" <leader>s 保存vimrc
" <leader>" 双引号包裹当前单词
" <leader>' 单引号包裹当前单词
" jj 映射 <esc>
" <leader>, 清除搜索高亮
" <leader>te 快速打开当前目录下的文件
" <leader>cd 快速切换到当前路径
" <leader>ss 打开/关闭 拼写检查

" }}}

" ===> 基础设置 {{{

" 设置leader键映射
let mapleader=','

" 显示状态栏
set laststatus=2

" 高亮选中行
se cursorline

" 启用高亮
syntax enable

" 显示相对行号
" set relativenumber

" 显示行号
set number

" 启用插件
filetype plugin on

" 启用缩进规则
filetype indent on

" 外部改变文件时自动读取
set autoread

" 搜索时忽略大小写
set ignorecase

" 高亮搜索结果
set hlsearch

" 搜索时自动显示选中的关键字
set incsearch

" 增强性能
set lazyredraw 

" 正则匹配时转意设置
set magic

" 显示匹配的括号
set showmatch

" 匹配括号的时间
set mat=2

" utf8编码
set encoding=utf8

" 设置剪贴板为系统剪贴板
set clipboard=unnamedplus

" 大写W sudo 保存
command W w !sudo tee % > /dev/null

" }}}

" ===> 文本格式设置 {{{

" 用空格代替tab
set expandtab

" 2个空格=1个tab
set shiftwidth=2
set tabstop=2

" 500个单词换行(Linebreak)
set lbr
set tw=500

" 自动缩进
set autoindent 
set smartindent 

" 显示时将过长的行换行
set wrap "Wrap lines

" }}}

" ===> Normal模式快捷键 {{{

nnoremap H ^
nnoremap L $

" 使用JK翻页
nnoremap <c-d> <nop>
nnoremap <c-u> <nop>
nnoremap J <c-d>
nnoremap K <c-u>

" 编辑我的vimrc文件
nnoremap <leader>e :vsplit $MYVIMRC<cr><c-w>w

" 重置我的vimrc文件
nnoremap <leader>s :source $MYVIMRC<cr>

" 用双引号包围当前单词
nnoremap <leader>" viw<esc>a"<esc>hbi"<esc>lel
nnoremap <leader>' viw<esc>a'<esc>hbi'<esc>lel

" 使用Alt+, Alt+. 翻页
" 仅在ideavim和neovim中有效
nnoremap <A-.> gt
nnoremap <A-,> gT

" }}}

" ===> Insert模式快捷键 {{{

" jj映射esc
inoremap jj <esc>

" }}}

" ===> Visual模式快捷键 {{{

" }}}

" ===> 其他设置 {{{

" <leader>,清除搜索高亮
map <silent> <leader>, :noh<cr>

" 切换到当前目录
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" 快速打开当前路径下的文件
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" 打开文件时回到上次编辑的地方
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" }}}

" ===> 设置缩写 {{{

iabbrev @@ stormaroon@gmail.com

" }}}

" ===> VIMScript脚本设置 {{{

augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" }}}

" ===> 拼写检查 {{{

" 只校验英文拼写问题
set spelllang=en

" 打开/关闭 拼写检查
map <leader>ss :setlocal spell!<cr>

" }}}

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
set termguicolors

" 启用斜体
hi Comment cterm=italic

" spacevim 主题深度
let g:space_vim_dark_background = 235

" 颜色主题
colorscheme space-vim-dark

" }}}
