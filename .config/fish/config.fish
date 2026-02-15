# Suppress greeting
set fish_greeting

# Add HomeBrew's bin directory to path
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin

# Enable Starship prompt
starship init fish | source

# Aliases
alias oc=opencode
# proxy
function set_proxy
    set -gx all_proxy http://my.proxy:7890
    set -gx NO_PROXY localhost,127.0.0.1
end

function unset_proxy
    set -e all_proxy
    set -e NO_PROXY
end
