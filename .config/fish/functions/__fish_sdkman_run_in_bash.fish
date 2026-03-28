function __fish_sdkman_run_in_bash
    # We need to leave stdin and stdout of sdk free for user interaction.
    # So, pipe relevant environment variables (which might have changed)
    # through a file.
    # But since now getting the exit code of sdk itself is a hassle,
    # pipe it as well.
    #
    # TODO: Can somebody get this to work without the overhead of a file?
    set pipe (mktemp)
    bash -c "$argv[1];
             echo -e \"\$?\" > $pipe;
             env | grep -e '^SDKMAN_\|^PATH' >> $pipe;
             env | grep -i -E \"^(`echo \${SDKMAN_CANDIDATES_CSV} | sed 's/,/|/g'`)_HOME\" >> $pipe;
             echo \"SDKMAN_OFFLINE_MODE=\${SDKMAN_OFFLINE_MODE}\" >> $pipe" # it's not an environment variable!
    set bashDump (cat $pipe; rm $pipe)

    set sdkStatus $bashDump[1]
    set bashEnv $bashDump[2..-1]

    # If SDKMAN! succeeded, copy relevant environment variables
    # to the current shell (they might have changed)
    if [ $sdkStatus = 0 ]
        for line in $bashEnv
            set parts (string split "=" $line)
            set var $parts[1]
            set value (string join "=" $parts[2..-1])

            switch "$var"
            case "PATH"
                # Special treatment: need fish list instead
                # of colon-separated list.
                set value (string split : "$value")
            end

            if test -n "$value"
                set -gx $var $value
                # Note: This makes SDKMAN_OFFLINE_MODE an environment variable.
                #       That gives it the behaviour we _want_!
            end
        end
    end

    return $sdkStatus
end
