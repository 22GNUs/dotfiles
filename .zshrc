DEFAULT_USER=$USER

source ~/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle git-flow
antigen bundle heroku
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found
antigen bundle z
antigen bundle sudo
antigen bundle extract
antigen bundle soimort/translate-shell
antigen bundle docker
antigen bundle docker-compose

# See https://github.com/catppuccin/zsh-syntax-highlighting
source ~/.catppuccin_mocha-zsh-syntax-highlighting.zsh
# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# auto suggestion
antigen bundle zsh-users/zsh-autosuggestions

antigen apply

if [ "$(uname 2> /dev/null)" = "Linux" ]; then
    ## linux自定义
else
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# brew install starship first
eval "$(starship init zsh)"
