function __git_branch_locate_repo --argument-names start_dir
    set -l dir $start_dir

    while true
        if test -d "$dir/.git"
            set -g __git_branch_repo_root "$dir"
            set -g __git_branch_gitdir "$dir/.git"
            return 0
        end

        if test -f "$dir/.git"
            read -l line < "$dir/.git"
            set -l gitdir (string replace -r '^gitdir: ' '' -- "$line")
            if not string match -q -- '/*' "$gitdir"
                set gitdir "$dir/$gitdir"
            end
            set -g __git_branch_repo_root "$dir"
            set -g __git_branch_gitdir "$gitdir"
            return 0
        end

        if test "$dir" = "/"
            break
        end

        set dir (path dirname "$dir")
    end

    return 1
end

function __git_branch_apply_head --argument-names head_contents
    set -l head (string trim -- "$head_contents")
    if string match -q -- 'ref: *' "$head"
        set -l ref (string replace -r '^ref: ' '' -- "$head")
        set -l branch (string replace -r '^refs/heads/' '' -- "$ref")
        set branch (string replace -r '^refs/remotes/' '' -- "$branch")
        set -gx GIT_BRANCH_PROMPT " $branch"
    else if test -n "$head"
        set -gx GIT_BRANCH_PROMPT " "(string sub -s 1 -l 7 -- "$head")
    else
        set -gx GIT_BRANCH_PROMPT
    end
end

function __git_branch_update_prompt --on-event fish_prompt --on-variable PWD
    set -l current_pwd $PWD

    if set -q __git_branch_repo_root; and set -q __git_branch_gitdir; and test -n "$__git_branch_repo_root"; and test -n "$__git_branch_gitdir"
        if test "$current_pwd" = "$__git_branch_repo_root"; or string match -q -- "$__git_branch_repo_root/*" "$current_pwd"
            set -l head_file "$__git_branch_gitdir/HEAD"
            if test -f "$head_file"
                __git_branch_apply_head (string collect < "$head_file")
                return 0
            end
        end
    end

    __git_branch_locate_repo "$current_pwd"
    or begin
        set -e __git_branch_repo_root __git_branch_gitdir
        set -gx GIT_BRANCH_PROMPT
        return 0
    end

    set -l head_file "$__git_branch_gitdir/HEAD"
    if not test -f "$head_file"
        set -gx GIT_BRANCH_PROMPT
        return 0
    end

    __git_branch_apply_head (string collect < "$head_file")
end
