# Suppress greeting
set fish_greeting

# Add HomeBrew's bin directory to path
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin

# Enable Starship prompt
starship init fish | source

# Aliases
alias oc=opencode
