function __fish_sdkman_command_exists --argument-names cmd
    if not test -f "$__fish_sdkman_candidates_file"
        return 1
    end

    set -l candidates (string split , -- (string trim -- (string collect < "$__fish_sdkman_candidates_file")))
    contains -- "$cmd" $candidates
end
