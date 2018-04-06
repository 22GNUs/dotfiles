# common
# export TERM="xterm-256color"

# ------------------------------------------------
# POWERLEVEL9K_MODE='awesome-fontconfig'
# POWERLEVEL9K_MODE='awesome-patched'
# POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
# POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
# POWERLEVEL9K_STATUS_VERBOSE=false
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status os_icon load context dir vcs)
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time)
# POWERLEVEL9K_SHOW_CHANGESET=true
# POWERLEVEL9K_CHANGESET_HASH_LENGTH=6
# ------------------------------------------------


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

# material theme
# antigen theme halfo/lambda-mod-zsh-theme
antigen theme https://github.com/denysdovhan/spaceship-prompt spaceship

# Tell Antigen that you're done.
antigen apply

# custom
alias phttpserver='python3 -m http.server';
alias sha='nohup Files/gitrepo/shadowsocksr/shadowsocks/local.py -c ~/Files/.config/.ss/config_sy.json >> /dev/null &'

# ssh
alias xquark='ssh root@101.37.30.205'
alias xquark_hgw='ssh root@121.42.184.125'
alias xquark_mpmk='ssh root@118.31.16.164'
alias xquark_woxifan='ssh root@47.100.169.209'
alias xquark_qinyuan='ssh root@47.100.25.173'
alias xquark_germenwo='ssh root@47.97.18.139'
# translate english to chinese
# need tranlate-shell installed
# See https://github.com/soimort/translate-shell
alias transen='trans en:zh'

# load sdk man
export SDKMAN_DIR="/home/wangxinhua/.sdkman"
[[ -s "/home/wangxinhua/.sdkman/bin/sdkman-init.sh" ]] && source "/home/wangxinhua/.sdkman/bin/sdkman-init.sh"

