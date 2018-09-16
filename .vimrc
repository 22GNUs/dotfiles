" ===> 快捷键 {{{

" H L 跳至行首行尾
" J K 替代<c-d> <c-u> 上下翻页
" <leader>e 编辑vimrc
" <leader>s 保存vimrc
" <leader>" 双引号包裹当前单词
" <leader>' 单引号包裹当前单词
" jj 映射 <esc>
" <esc><esc> 清除搜索高亮
" <leader>te 快速打开当前目录下的文件
" <leader>cd 快速切换到当前路径
" <leader>ss 打开/关闭 拼写检查
" <c-n> 打开/关闭 nerdtree
" <> tab 翻页
" paste模式切换 <F3>
"
" <c-p> 文件搜索
" 文件搜索状态<c-j><c-k>上下选择
" 文件搜索状态<c-t><c-v><c-x>打开tab或分屏打开

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

" w!! sudo 保存
cmap w!! w !sudo tee > /dev/null %

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

" 使用 <> 翻页
nnoremap > gt
nnoremap < gT

" 黑洞删除
nnoremap <leader>d "_d

" }}}

" ===> Insert模式快捷键 {{{

" jj映射esc
" inoremap jj <esc>

" }}}

" ===> Visual模式快捷键 {{{

" 黑洞删除
vnoremap <leader>d "_d
vnoremap <leader>p "_dP

" }}}

" ===> 其他设置 {{{

" 设置复制模式
set pastetoggle=<F3>

" <leader>,清除搜索高亮
nnoremap <esc><esc> :noh<return>

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

" dracula 主题
Plug 'dracula/vim', { 'as': 'dracula' }

" onedark 主题
Plug 'joshdick/onedark.vim', {'as': 'onedark'}

" spacevim 样式状态栏
Plug 'liuchengxu/eleline.vim'

" json显示插件
Plug 'elzr/vim-json'

" markdown 插件
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" markdown预览
Plug 'iamcco/markdown-preview.vim'

" nerdtree 插件
Plug 'scrooloose/nerdtree'

" ctrlp 文件搜索插件
Plug 'ctrlpvim/ctrlp.vim'

" deoplete 自动补全
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

" supertab tab补全
Plug 'ervandew/supertab'

" 自动补全括号
Plug 'jiangmiao/auto-pairs'

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

" 关闭编辑时代码缩写
let g:vim_markdown_conceal = 0

" =====================

" ==== nerdtree 插件设置

" <c-n> 开启/关闭nerdtree
map <C-n> :NERDTreeToggle<CR>

" 若打开的是目录则自动打开nerdtree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

" 窗口中只剩下nerdtree时自动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" =====================

" ==== ctrlp 插件设置

" 设置查找目录
let g:ctrlp_working_path_mode = 'ra'

" 过滤文件
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows

let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" ====================

" ==== deoplete 插件设置

" 开启补全支持
let g:deoplete#enable_at_startup = 1

" 自动关闭补全窗口
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" ===================


" }}}

" ===> Color Schemes 设置 {{{

" 启用斜体
hi Comment cterm=italic

" spacevim 主题深度
" let g:space_vim_dark_background = 235

" 颜色主题
colorscheme onedark

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has("termguicolors"))
  set termguicolors
endif

" }}}
