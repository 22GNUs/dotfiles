# Suppress greeting
set fish_greeting

# Add HomeBrew's bin directory to path
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin

# Enable Starship prompt via a cached generated init script.
if status is-interactive
    set -l __starship_cache_dir "$HOME/.cache/fish"
    set -l __starship_init_cache "$__starship_cache_dir/starship-init.fish"
    set -l __starship_bin (command -s starship)
    set -l __starship_config "$HOME/.config/starship.toml"

    if test -n "$__starship_bin"
        if not test -f "$__starship_init_cache"; or test "$__starship_bin" -nt "$__starship_init_cache"; or test "$__starship_config" -nt "$__starship_init_cache"
            mkdir -p "$__starship_cache_dir"
            set -l __starship_tmp (mktemp "$__starship_init_cache.XXXXXX")
            "$__starship_bin" init fish --print-full-init > "$__starship_tmp"; and mv "$__starship_tmp" "$__starship_init_cache"; or rm -f "$__starship_tmp"
        end

        if test -f "$__starship_init_cache"
            source "$__starship_init_cache"
        end
    end

    __git_branch_update_prompt
end

# pnpm
set -gx PNPM_HOME "/Users/xinhua/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Pi aliases
if status is-interactive
    alias pa='pi --tools read,bash,edit,write,grep,find,ls'
    alias pr='pi --readonly'
end
