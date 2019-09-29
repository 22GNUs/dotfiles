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

# POWERLEVEL9K_MODE='nerdfont-complete'
# antigen theme bhilburn/powerlevel9k powerlevel9k
# Tell Antigen that you're done.
antigen apply

# ArchLinux 执行自己安装的插件
if [ "$(uname 2> /dev/null)" = "Linux" ]; then
    powerline-daemon -q
    . /usr/lib/python3.7/site-packages/powerline/bindings/zsh/powerline.zsh
else
    # antigen theme halfo/lambda-mod-zsh-theme
    # OSX 使用spaceship
    antigen theme https://github.com/denysdovhan/spaceship-prompt spaceship
fi
