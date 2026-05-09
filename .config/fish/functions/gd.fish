function gd --description "Show changed module directories"
    git status --short | awk '{print $2}' | cut -d/ -f1-2 | sort -u
end
