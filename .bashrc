# Bash configuration for Homebrew tools.
# Keep this lightweight and shell-specific; it does not affect fish.

path_prepend() {
  local dir="$1"
  PATH=":$PATH:"
  PATH="${PATH//:$dir:/:}"
  PATH="${PATH#:}"
  PATH="${PATH%:}"
  PATH="$dir${PATH:+:$PATH}"
}

path_prepend /opt/homebrew/bin
path_prepend "$HOME/.local/bin"

export PATH
export BASH_ENV="$HOME/.bashrc"
