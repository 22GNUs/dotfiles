" ===> Requirements {{{
" 包管理器依赖:
" fzf 模糊搜索
" fd 忽略不需要的搜索结果
" the_silver_searcher(ag)
" ctags, ctags-exuberant
"
" pip依赖: neoplete
" npm依赖: vue-formater
"
" scala: ensime [http://ensime.github.io/]
" }}}

"===> 快捷键 {{{

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
" <C-w> R 切换左右分屏
" <C-w> T 切换上下分屏
" gd 跳转到定义处
" ctrl-o 从gd调回来
" ctrl-i 从ctrl-o再跳回去
" gr 在当前scope重构变量
" gR 全局重构变量
" <c-p> 文件搜索
" 文件搜索状态<c-j><c-k>上下选择
" 文件搜索状态<c-t><c-v><c-x>打开tab或分屏打开
" <C-k>, emmet补全
" F12 生成ctags

" }}}

" === 快捷操作 {{{

" :T 打开终端
" :Goyo 打开/关闭goyo模式
" :VT 垂直打开终端
" :Ack pattern dir 在目录下搜索关键字
"
" ------------ 以下操作依赖FZF插件
" :FZF (:Files) 查看项目下所有文件
" :Tags 查看项目下面所有Tag - 依赖 ctags -R . 生成tag
" :BTags 查看Buffer下面所有Tag - 依赖 ctags -R . 生成tag
" :Buffers 所有buffer
" :Commits 查看所有commit

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

" ===> 缩进配置 {{{
" 两个空格组
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype vue setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype scala setlocal ts=2 sw=2 expandtab
autocmd Filetype python setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab
autocmd Filetype coffeescript setlocal ts=2 sw=2 expandtab
"
" 四个空格组
autocmd Filetype jade setlocal ts=4 sw=4 sts=0 expandtab"
autocmd Filetype lua setlocal ts=4 sw=4 sts=0 expandtab"
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

" 在scope内重构变量
nnoremap gr gd[{V%::s/<C-R>///gc<left><left><left>

" 全局重构变量
nnoremap gR gD:%s/<C-R>///gc<left><left><left>

" vue格式化
autocmd FileType vue noremap <buffer> <leader>f :%!vue-formatter<CR>

" 格式化代码, 依赖autoformat插件
noremap <leader>f :Autoformat<CR>

noremap <F12> :!ctags -R -f ./.git/tags .<CR>

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

call plug#begin('~/.local/share/nvim/plugged')

" spacevim 颜色主题
Plug 'liuchengxu/space-vim-dark'

" lightline
Plug 'itchyny/lightline.vim'

" lightline-ale
Plug 'maximbaz/lightline-ale'

" spacevim 样式状态栏
" Plug 'liuchengxu/eleline.vim'

" nerdtree 插件
Plug 'scrooloose/nerdtree'

" deoplete 自动补全
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" deoplete for ruby
Plug 'fishbullet/deoplete-ruby'

" neosnippet 片段补全
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'

" js插件
Plug 'pangloss/vim-javascript'

" vue插件
Plug 'posva/vim-vue'

Plug 'derekwyatt/vim-scala'

" scala补全插件
Plug 'ensime/ensime-vim', { 'do': ':UpdateRemotePlugins' }

" lua 高亮插件
Plug 'tbastos/vim-lua'

" 模糊搜索
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" git插件
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" lint
Plug 'w0rp/ale'

" autopair
Plug 'jiangmiao/auto-pairs'

Plug 'junegunn/goyo.vim'

Plug 'hzchirs/vim-material'

" 搜索插件
Plug 'mileszs/ack.vim'

" 代码格式化
Plug 'Chiel92/vim-autoformat'

" emmet html插件
Plug 'mattn/emmet-vim'

call plug#end()

" }}}

" ===> 插件设置 {{{

" ====================
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
            \ 'ctrl-o': 'edit',
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
            \ 'colorscheme': 'material',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename', 'modified' ] ],
            \   'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok', 'gitbranch' ] ]
            \ },
            \ 'component_function': {
            \   'gitbranch': 'fugitive#head',
            \   'filename': 'LightLineFilename'
            \ },
            \ 'component_expand': {
            \  'linter_checking': 'lightline#ale#checking',
            \  'linter_warnings': 'lightline#ale#warnings',
            \  'linter_errors': 'lightline#ale#errors',
            \  'linter_ok': 'lightline#ale#ok',
            \ },
            \ 'component_type': {
            \     'linter_checking': 'left',
            \     'linter_warnings': 'warning',
            \     'linter_errors': 'error',
            \     'linter_ok': 'left',
            \ }
            \ }

" 文件名显示相对路径
function! LightLineFilename()
  return expand('%')
endfunction

" 字体配置
let g:lightline#ale#indicator_checking = "\uf110"
let g:lightline#ale#indicator_warnings = "\uf071"
let g:lightline#ale#indicator_errors = "\uf05e"
let g:lightline#ale#indicator_ok = "\uf00c"

" =====================

" ==== deoplete 插件设置

" 开启补全支持
let g:deoplete#enable_at_startup = 1

" 针对scala配置
" 参考: https://medium.com/@alandevlin7/neovim-scala-f392bcd8b7de<Paste>
" let g:deoplete#sources={} 
" let g:deoplete#sources._=['buffer', 'member', 'tag', 'file', 'omni', 'ultisnips'] 
" let g:deoplete#omni#input_patterns={} 
" let g:deoplete#omni#input_patterns.scala='[^. *\t]\.\w*'

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

" ==== js插件设置
" 打开jsdoc高亮
let g:javascript_plugin_jsdoc = 1
" 高亮js中的html和css
let javascript_enable_domhtmlcss = 1
" ===================

" ==== ack插件配置
" 配置ack插件使用ag
let g:ackprg = 'ag --nogroup --nocolor --column'
" ===================

" ==== AutoFormat 设置
" 去掉tab, 尾空格等等
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0
" ===================

" ==== emmet 设置
" 只在html, css, vue文件打开emmet
let g:user_emmet_install_global = 0
autocmd FileType html,css,vue EmmetInstall
" 设置补快捷键为c-k
let g:user_emmet_leader_key='<C-k>'
" ===================

" ==== ensime配置
let ensime_server_v2=1
" ===================
" }}}

" ===> Color Schemes 设置 {{{

" 启用斜体
hi Comment cterm=italic

" spacevim 主题深度
" let g:space_vim_dark_background = 233

" 颜色主题
" colorscheme space-vim-dark

" Oceanic
let g:material_style='oceanic'
set background=dark
colorscheme vim-material

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
