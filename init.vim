" ===> 快捷键 {{{

" H L 跳至行首行尾
" J K 替代<c-d> <c-u> 上下翻页
" <leader>e 编辑vimrc
" <leader>s 保存vimrc
" <C-\><C-n> 终端模式切换
" <leader>" 双引号包裹当前单词
" <leader>' 单引号包裹当前单词
" jj 映射 <esc>
" <C-k> snippets 补全
" <esc><esc> 清除搜索高亮
" <leader>te 快速打开当前目录下的文件
" <leader>cd 快速切换到当前路径
" <leader>ss 打开/关闭 拼写检查
" <C-n> 打开/关闭 nerdtree
" shift+a 完全展开nerdtree
" <> tab 翻页
" paste模式切换 <F3>
"
" <c-p> 文件搜索
" 文件搜索状态<c-j><c-k>上下选择
" 文件搜索状态<c-t><c-v><c-x>打开tab或分屏打开

" }}}

" ===> 快捷键for Golang {{{

" 参考 https://github.com/fatih/vim-go-tutoria
"
" :GoDoc 显示go文档
" :GoDecls 显示所有定义
" :GoDeclsDir 显示目录下所有定义
" :GoFreevars 重构方法
" :GI <args> 快速导包
" ctrl-] or gd 跳转到定义
" ctrl-t 跳转回来
" ]] -> 跳转到下一个方法
" [[ -> 跳转到上一个方法
" :A, :AS, :AV, :AT 在新窗口打开golang alternate
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

" 显示分隔线
set listchars=tab:\|\ 
set list

" 编译时自动写入
set autowrite

" 设置剪贴板为系统剪贴板
set clipboard=unnamedplus

" 分割时将窗口分割到下方
set splitbelow

" w!! sudo 保存
cmap w!! w !sudo tee > /dev/null %

" }}}

" ===> 文本格式设置 {{{

" 用空格代替tab
set expandtab

" 2个空格=1个tab
set shiftwidth=4
set tabstop=4

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
" nnoremap <c-d> <nop>
" nnoremap <c-u> <nop>
" nnoremap J <c-d>
" nnoremap K <c-u>

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

" 关闭错误提示
nnoremap <leader>a :cclose<CR>

" }}}

" ===> Insert模式快捷键 {{{
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" }}}

" ===> Visual模式快捷键 {{{

" 黑洞删除
vnoremap <leader>d "_d
vnoremap <leader>p "_dP

" }}}

" ===> 命令绑定 {{{

" 打开终端
command! -nargs=* T split | resize 10 | terminal <args>
command! -nargs=* VT vsplit | terminal <args>

" 快速导入Go包
command! -nargs=* GI GoImport <args>

" 重构命名
command! -nargs=* GR GoRename <args>

" 绑定golang快速跳转
autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')

" 绑定gobuid和gorun
autocmd FileType go nmap <leader>b  <Plug>(go-build)
autocmd FileType go nmap <leader>r  <Plug>(go-run)

" 格式化golang代码
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 

"}}}

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

" lightline
Plug 'itchyny/lightline.vim'

" spacevim 样式状态栏
" Plug 'liuchengxu/eleline.vim'

" nerdtree 插件
Plug 'scrooloose/nerdtree'

" deoplete 自动补全
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" neosnippet 片段补全
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'

" deoplete Golang支持
Plug 'zchee/deoplete-go', { 'do': 'make'}

" Go语言支持
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" 模糊搜索
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" git插件
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

call plug#end()

" }}}

" ===> 插件设置 {{{

" =====================
" ==== vim-for-go 插件设置

" 高亮go类型
let g:go_highlight_types = 1

" 高亮go属性
let g:go_highlight_fields = 1

" 高亮go方法
let g:go_highlight_functions = 1

" 高亮go函数调用
let g:go_highlight_function_calls = 1

" 高亮符号
let g:go_highlight_operators = 1

" 高亮类型
let g:go_highlight_extra_types = 1

" 保存时自动go语法校验
let g:go_metalinter_autosave = 1

" 自动保存时校验项
let g:go_metalinter_autosave_enabled = ['vet', 'golint', 'errcheck']

" 自动补全imports
let g:go_fmt_command = "goimports"

" 自动弹出goInfo
" let g:go_auto_type_info = 1

" =====================

" ==== nerdtree 插件设置

" 设置宽度
let g:NERDTreeWinSize = 20

" <c-n> 开启/关闭nerdtree
map <C-n> :NERDTreeToggle<CR>

" 若打开的是目录则自动打开nerdtree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

" 窗口中只剩下nerdtree时自动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" =====================

" ==== FZF 模糊搜索插件配置

" <ctrl-p> 模糊搜索
nnoremap <silent> <C-p> :Files<CR>

" 默认的打开快捷键
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" 配置位置
let g:fzf_layout = { 'down': '~40%' }

" 适应配色方案
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" 保存记录
let g:fzf_history_dir = '~/.local/share/fzf-history'

nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" 插入模式快捷键
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})

" =====================

" ==== vim lightline 配置

let g:lightline = {
      \ 'colorscheme': 'one',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }

" =====================

" ==== deoplete 插件设置

" 开启补全支持
let g:deoplete#enable_at_startup = 1

" deoplete-go设置
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']

" 自动关闭补全窗口
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" neosnippet配置
" 设置快捷键
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

" ===================


" }}}

" ===> Color Schemes 设置 {{{

" 启用斜体
hi Comment cterm=italic

" spacevim 主题深度
" let g:space_vim_dark_background = 233

" 颜色主题
colorscheme space-vim-dark

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
  hi LineNr ctermbg=NONE guibg=NONE
endif

" }}}
