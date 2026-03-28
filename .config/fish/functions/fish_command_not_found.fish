function fish_command_not_found --on-event fish_command_not_found
    set -l cmd $argv[1]
    if test -n "$cmd"; and __fish_sdkman_command_exists "$cmd"
        __fish_sdkman_lazy_init
        if type -q -- "$cmd"
            command $argv
            return $status
        end
    end

    __fish_default_command_not_found_handler $argv
end
