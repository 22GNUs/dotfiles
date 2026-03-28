# SDKMAN! paths used by lazy-loaded helper functions.
set -g __fish_sdkman_init "$HOME/.sdkman/bin/sdkman-init.sh"
set -g __fish_sdkman_noexport_init "$HOME/.config/fisher/github.com/reitzig/sdkman-for-fish/sdkman-noexport-init.sh"
set -g __fish_sdkman_candidates_file "$HOME/.sdkman/var/candidates"

if status is-interactive
    __fish_sdkman_register_shims
end
