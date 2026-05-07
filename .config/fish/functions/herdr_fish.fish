function herdr_fish --description 'Start herdr with fish as pane shell'
    env SHELL=(command -s fish) herdr $argv
end
