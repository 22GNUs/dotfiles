# Suppress greeting
set fish_greeting

# Add HomeBrew's bin directory to path
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin

# Enable Starship prompt
starship init fish | source

# Aliases
alias gvim="neovide --frame transparent"
alias oc=opencode

# pnpm
set -gx PNPM_HOME /Users/xinhua/Library/pnpm
fish_add_path $PNPM_HOME

# SDKMAN initialization
if test -d ~/.sdkman/candidates/java/current
    set -gx SDKMAN_DIR ~/.sdkman
    set -gx JAVA_HOME ~/.sdkman/candidates/java/current
    fish_add_path $JAVA_HOME/bin
end
