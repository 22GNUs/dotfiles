# common
# export TERM="xterm-256color"

DEFAULT_USER=$USER

source ~/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle heroku
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found
antigen bundle z
antigen bundle sudo
antigen bundle extract

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# auto suggestion
antigen bundle zsh-users/zsh-autosuggestions

# antigen theme halfo/lambda-mod-zsh-theme
# antigen theme https://github.com/denysdovhan/spaceship-prompt spaceship

POWERLEVEL9K_MODE='nerdfont-complete'
antigen theme bhilburn/powerlevel9k powerlevel9k
# Tell Antigen that you're done.
antigen apply

# custom
alias phttpserver='python3 -m http.server';

# PATH ========
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_201.jdk/Contents/Home

export npm_config_prefix=~/.node_modules

export GOPATH=$(go env GOPATH)

export PATH=$PATH:$(go env GOPATH)/bin:$JAVA_HOME/bin:$HOME/.node_modules/bin
# PATH ========

# translate english to chinese
# need tranlate-shell installed
# See https://github.com/soimort/translate-shell
alias transen='trans en:zh'

# load sdk man
export SDKMAN_DIR="/Users/wangxinhua/.sdkman"
[[ -s "/Users/wangxinhua/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/wangxinhua/.sdkman/bin/sdkman-init.sh"

# eval $(thefuck --alias)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# 先从aur安装powerline, powerline-fonts
# powerline-daemon -q
# . /usr/lib/python3.7/site-packages/powerline/bindings/zsh/powerline.zsh
