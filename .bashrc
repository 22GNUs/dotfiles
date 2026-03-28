# Bash configuration for SDKMAN.
# Keep this lightweight and shell-specific; it does not affect fish.

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH
export BASH_ENV="$HOME/.bashrc"

if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.sdkman/bin/sdkman-init.sh" >/dev/null 2>&1 || true
fi
