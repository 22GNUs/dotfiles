function commit
    git add . && pi -p "/skill:commit commit directly, no questions. split unrelated changes into separate commits." --model cf-compat/openrouter/deepseek/deepseek-v4-flash --no-session $argv
end
