# PATH ========
export npm_config_prefix=~/.node_modules
export ANDROID_HOME="/Users/wangxinhua/Library/Android/sdk"
export ANDROID_SDK_ROOT="/Users/wangxinhua/Library/Android/sdk"
export ANDROID_AVD_HOME=/Users/wangxinhua/.android/avd

export PATH=$ANDROID_HOME/tools:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/build-tools/23.0.1:$PATH

export PATH=$PATH:$JAVA_HOME/bin:$HOME/.node_modules/bin
export PATH=$PATH:/Users/wangxinhua/Library/Python/3.8/bin
export HOMEBREW_NO_AUTO_UPDATE=1

# load sdk man
export SDKMAN_DIR="/Users/wangxinhua/.sdkman"
[[ -s "/Users/wangxinhua/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/wangxinhua/.sdkman/bin/sdkman-init.sh"

# 设置fzf使用fd过滤文件
# 需要安装fd
# 可以在项目中指定.fdignore文件来忽略, 格式类似.gitignore
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
# PATH ========

# alias =======
alias phttpserver='python3 -m http.server';
# translate english to chinese
# need tranlate-shell installed
# See https://github.com/soimort/translate-shell
alias scalafmt='ng scalafmt'
alias lg='lazygit'
alias gvim='neovide --multigrid --frame buttonless'
alias wba='wordbook add'
alias wbl='wordbook lst'

if [ -x "$(command -v thefuck)" ]; then
  eval $(thefuck --alias)
fi

# =============

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# if which go >/dev/null; then
#   # Check if go installed in path, then set goproxy
#   go env -w GO111MODULE=on
#   go env -w GOPROXY=https://goproxy.io,direct
# else
#     echo go does not exist
# fi
. "$HOME/.cargo/env"
