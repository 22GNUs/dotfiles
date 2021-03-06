# PATH ========
export npm_config_prefix=~/.node_modules
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home
export ANDROID_HOME="/Users/wangxinhua/Library/Android/sdk"
export ANDROID_SDK_ROOT="/Users/wangxinhua/Library/Android/sdk"
export ANDROID_AVD_HOME=/Users/wangxinhua/.android/avd

export PATH=$ANDROID_HOME/tools:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/build-tools/23.0.1:$PATH

export PATH=$PATH:$JAVA_HOME/bin:$HOME/.node_modules/bin
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
alias transen='trans en:zh'
alias scalafmt='ng scalafmt'
# eval $(thefuck --alias)
# =============

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
