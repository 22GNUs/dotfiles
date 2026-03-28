function __fish_sdkman_register_shims
    for bin_dir in "$HOME"/.sdkman/candidates/*/current/bin
        if not test -d "$bin_dir"
            continue
        end

        for entry in $bin_dir/*
            if not test -f "$entry"
                continue
            end

            if not test -x "$entry"
                continue
            end

            set -l cmd (path basename "$entry")
            switch $cmd
            case '*.cmd' '*.conf' '*.bash' '*.sh'
                continue
            end

            if functions -q -- $cmd
                continue
            end

            printf '%s\n' "function $cmd --wraps $cmd --description 'Lazy SDKMAN shim for $cmd'" "    __fish_sdkman_lazy_init >/dev/null 2>/dev/null" "    command $cmd \$argv" "end" | source
        end
    end
end
