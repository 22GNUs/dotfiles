# Suppress greeting
set fish_greeting
# Add HomeBrew's bin directory to path so you can use HomeBrew's binaries like `starship`
# Fish uses `fish_add_path` instead of `export PATH` modify $PATH.
fish_add_path "/opt/homebrew/bin/"

# Add SDKMAN to path
fish_add_path (find ~/.sdkman/candidates/*/current/bin -maxdepth 0)

# Add cargo to path
fish_add_path "$HOME/.cargo/bin"

# Enable Starship prompt
starship init fish | source

# Create alias for sdkman
function sdk
    bash -c "source '$HOME/.sdkman/bin/sdkman-init.sh'; sdk $argv[1..]"
end

alias gvim="neovide --multigrid --frame buttonless"

if status is-interactive
  # Commands to run in interactive sessions can go here
end
