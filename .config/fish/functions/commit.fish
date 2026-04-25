function commit
    git add . && pi -p "/skill:commit commit directly, no questions. split unrelated changes into separate commits." --model custom-synthetic/hf:zai-org/GLM-4.7-Flash --no-session $argv
end
