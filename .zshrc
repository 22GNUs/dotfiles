# common
export TERM="xterm-256color"

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

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# auto suggestion
antigen bundle zsh-users/zsh-autosuggestions

# material theme
antigen theme halfo/lambda-mod-zsh-theme

# Tell Antigen that you're done.
antigen apply

# custom
alias tencent="ssh wangxinhua@118.89.182.235";
alias phttpserver='python3 -m http.server';
alias socks='sslocal -c ~/Files/.config/.ss/config.json';
alias wemovie='ssh -R 80:localhost:8080 root@115.159.212.157'
alias chinese='trans :zh'
alias sus='sudo systemctl suspend'
alias red='nohup redis-server > /dev/null &'
alias ss='nohup sslocal -c Files/.config/.ss/config.json > /dev/null &'
alias xquark_hgw='ssh root@121.42.184.125'
alias xquark='ssh root@101.37.30.205'
alias xquark_mpmk='ssh root@118.31.16.164'
alias xquark_woxifan='ssh root@47.100.169.209'
alias xquark_qinyuan='ssh root@47.100.25.173'
alias xquark_germenwo='ssh root@47.97.18.139'
alias pc='proxychains4 -q'

# load sdk man
export SDKMAN_DIR="/home/wangxinhua/.sdkman"
[[ -s "/home/wangxinhua/.sdkman/bin/sdkman-init.sh" ]] && source "/home/wangxinhua/.sdkman/bin/sdkman-init.sh"

