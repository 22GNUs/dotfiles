function __fish_sdkman_lazy_init
    if not test -f "$__fish_sdkman_init"
        return 1
    end

    if begin
            not set -q SDKMAN_DIR
            or test (ls -ld "$SDKMAN_DIR" | awk '{print $3}') != (whoami)
        end
        set -e SDKMAN_DIR
        __fish_sdkman_run_in_bash "source $__fish_sdkman_init"
    end
end
