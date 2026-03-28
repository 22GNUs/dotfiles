# SDKMAN! paths used by lazy-loaded helper functions.
set -g __fish_sdkman_init "$HOME/.sdkman/bin/sdkman-init.sh"
set -g __fish_sdkman_noexport_init "$HOME/.config/fisher/github.com/reitzig/sdkman-for-fish/sdkman-noexport-init.sh"
set -g __fish_sdkman_candidates_file "$HOME/.sdkman/var/candidates"

if status is-interactive
    set -l __sdkman_not_found_hook "$__fish_config_dir/functions/fish_command_not_found.fish"
    if test -f "$__sdkman_not_found_hook"
        source "$__sdkman_not_found_hook"
    end
end
