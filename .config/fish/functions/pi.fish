function pi
    # Always launch pi in FFF override mode unless explicitly overridden by a CLI flag.
    set -x PI_FFF_MODE override
    command pi $argv
end
