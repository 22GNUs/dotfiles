function pi
    # pi update installs from npm; use the official registry so anpm lag
    # cannot hide newly published @earendil-works/pi-coding-agent versions.
    if test (count $argv) -ge 1; and test $argv[1] = update
        set -x npm_config_registry https://registry.npmjs.org/
    end

    command pi $argv
end
