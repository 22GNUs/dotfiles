" ===> Requirements {{{
" coc插件:
" :CocInstall coc-snippets
" :CocInstall coc-json // json语法
" :CocInstall coc-tsserver // js, ts
" :CocInstall coc-java // for java
"
" 包管理器依赖:
" fzf 模糊搜索
" gem install rouge (rougify)
" fd 忽略不需要的搜索结果
" 在.zshrc加入: 
" export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
"
" the_silver_searcher(ag)
" ctags, ctags-exuberant
"
" }}}

"===> 快捷键 {{{

" H L 跳至行首行尾
" J K 替代<c-d> <c-u> 上下翻页
" <leader>B 编译metals
" <leader>e 编辑vimrc
" <leader>s 保存vimrc
" <leader>f 格式化选中单位 - (依赖lsp server)
" <C-\><C-n> 终端模式切换
" <leader>" 双引号包裹当前单词
" <leader>' 单引号包裹当前单词
" jj 映射 <esc>
" <esc><esc> 清除搜索高亮
" <leader>te 快速打开当前目录下的文件
" <leader>cd 快速切换到当前路径
" <leader>ss 打开/关闭 拼写检查
" <C-n> 打开/关闭 nerdtree
" <C-t> 打开/关闭 Vista
" shift+a 完全展开nerdtree
" <> tab 翻页
" paste模式切换 <F3>
" <C-w> R 切换左右分屏
" <C-w> T 切换上下分屏
" gd 跳转到定义处
" ctrl-o 从gd调回来
" ctrl-i 从ctrl-o再跳回去
" gn 在当前scope重构变量
" gN 全局重构变量
" <c-p> 文件搜索
" 文件搜索状态<c-j><c-k>上下选择
" 文件搜索状态<c-t><c-v><c-x>打开tab或分屏打开

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
" :Format 全局格式化
" :Vista 打开侧边标签栏

" }}}

" ===> 基础设置 {{{

" 设置leader键映射
let mapleader=','

" 显示状态栏
set laststatus=2

" 高亮选中行
se cursorline

" 启用高亮
syntax on

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

" 设置tags目录
set tags=./.tags;,~/.vimtags

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

" ===> 语言配置 {{{
" 两个空格组
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype vue setlocal ts=2 sw=2 expandtab
autocmd Filetype ruby setlocal ts=2 sw=2 expandtab
autocmd Filetype scala setlocal ts=2 sw=2 expandtab
autocmd Filetype python setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab
autocmd Filetype java setlocal ts=2 sw=2 expandtab
autocmd Filetype coffeescript setlocal ts=2 sw=2 expandtab
"
" 四个空格组
autocmd Filetype jade setlocal ts=4 sw=4 sts=0 expandtab"
autocmd Filetype lua setlocal ts=4 sw=4 sts=0 expandtab"

" 设置sbt使用scala的高亮
autocmd BufRead,BufNewFile *.sbt set filetype=scala
" 高亮json的注释
autocmd FileType json syntax match Comment +\/\/.\+$+
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
nnoremap gn gd[{V%::s/<C-R>///gc<left><left><left>

" 全局重构变量
nnoremap gN gD:%s/<C-R>///gc<left><left><left>

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
command! -nargs=* Te tabedit | terminal <args>
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

" coc补全插件
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" vim-surround
Plug 'tpope/vim-surround'

" commentary
Plug 'tpope/vim-commentary'

" 代码片段
Plug 'honza/vim-snippets'

" 自动生成tag
Plug 'ludovicchabant/vim-gutentags'

" lightline
Plug 'itchyny/lightline.vim'

" 图标
Plug 'ryanoasis/vim-devicons'

" nerdtree 插件
Plug 'scrooloose/nerdtree'

" js
Plug 'pangloss/vim-javascript'

" scala
Plug 'derekwyatt/vim-scala'

" lua
Plug 'tbastos/vim-lua'

" vue
Plug 'posva/vim-vue'

" 模糊搜索
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" tagbar
Plug 'liuchengxu/vista.vim'

" git插件
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" autopair
Plug 'jiangmiao/auto-pairs'

Plug 'junegunn/goyo.vim'

Plug 'hzchirs/vim-material'

" 搜索插件
Plug 'mileszs/ack.vim'

call plug#end()

" }}}

" ===> 插件设置 {{{

" ====================
" ==== coc 插件设置
" 推荐配置: 
set hidden
set nobackup
set nowritebackup
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=yes

" 绑定metals快捷键
" build-import
nnoremap <leader>B :call CocRequestAsync('metals', 'workspace/executeCommand', { 'command': 'build-import' })<CR>

" tab切换补全
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" <c-\> 触发补全
inoremap <silent><expr> <c-\> coc#refresh()

" <cr> (在vim中就是Enter) 确认补全
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" 这个有点屌
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" K 显示文档
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" rn 重命名
nmap <leader>rn <Plug>(coc-rename)

" 代码格式化
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.

xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" C-d 快捷键重复, 暂时注释
" Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
" nmap <silent> <C-d> <Plug>(coc-range-select)
" xmap <silent> <C-d> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
" =================

" ==== nerdtree 插件设置

" 设置宽度
let g:NERDTreeWinSize = 20

" <c-n> 开启/关闭 nerdtree
map <C-n> :NERDTreeToggle<CR>

" <c-t> 开启/关闭 Vista
map <C-t> :Vista!!<CR>

" 若打开的是目录则自动打开nerdtree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

" 窗口中只剩下nerdtree时自动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" =====================

" ==== FZF 模糊搜索插件配置

" 默认的打开快捷键
let g:fzf_action = {
            \ 'ctrl-o': 'edit',
            \ 'ctrl-t': 'tab split',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit' }

function! Fzf_dev()
  let l:fzf_files_options = ' -m --bind ctrl-d:preview-page-down,ctrl-u:preview-page-up --preview "rougify {2..-1} | head -'.&lines.'"'

  function! s:files()
    let l:files = split(system($FZF_DEFAULT_COMMAND), '\n')
    return s:prepend_icon(l:files)
  endfunction

  function! s:prepend_icon(candidates)
    let result = []
    for candidate in a:candidates
      let filename = fnamemodify(candidate, ':p:t')
      let icon = WebDevIconsGetFileTypeSymbol(filename, isdirectory(filename))
      call add(result, printf("%s %s", icon, candidate))
    endfor

    return result
  endfunction

  function! s:edit_file(items)
    let items = a:items
    let i = 1
    let ln = len(items)
    while i < ln
      let item = items[i]
      let parts = split(item, ' ')
      let file_path = get(parts, 1, '')
      let items[i] = file_path
      let i += 1
    endwhile
    call s:Sink(items)
  endfunction

  let opts = fzf#wrap({})
  let opts.source = <sid>files()
  let s:Sink = opts['sink*']
  let opts['sink*'] = function('s:edit_file')
  let opts.options .= l:fzf_files_options
  call fzf#run(opts)

endfunction

" <ctrl-p> 模糊搜索
nnoremap <silent> <C-p> :call Fzf_dev()<CR>

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
            \   'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename', 'modified', 'method' ] ],
            \   'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok', 'gitbranch' ] ]
            \ },
            \ 'component_function': {
            \   'gitbranch': 'fugitive#head',
            \   'filename': 'LightLineFilename',
            \   'method': 'NearestMethodOrFunction'
            \ }
            \ }

" 文件名显示相对路径
function! LightLineFilename()
  return expand('%')
endfunction

" ==== js插件设置
" 打开jsdoc高亮
let g:javascript_plugin_jsdoc = 1
" 高亮js中的html和css
let javascript_enable_domhtmlcss = 1
" ==================

" ==== ack插件配置
" 配置ack插件使用ag
let g:ackprg = 'ag --nogroup --nocolor --column'
" ===================
"
" ==== gutentags 配置

" gutentags搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归 "
let g:gutentags_project_root = ['.root', '.svn', '.git', '.project']

" 所生成的数据文件的名称 "
let g:gutentags_ctags_tagfile = '.tags'

" 配置 ctags 的参数 "
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+pxI']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
" ===================
"
" ==== vista 配置
" ===================

let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]

let g:vista_default_executive = 'coc'
" fzf_preview
let g:vista_fzf_preview = ['right:50%']
" 启用icon
let g:vista#renderer#enable_icon = 1

" 默认icon
let g:vista#renderer#icons = {
\   "function": "\uf794",
\   "variable": "\uf71b",
\  }
" }}}

" ===> Color Schemes 设置 {{{

" 启用斜体
hi Comment cterm=italic

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
