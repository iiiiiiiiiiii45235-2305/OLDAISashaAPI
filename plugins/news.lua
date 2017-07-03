local function run(msg, matches)
    return "Alternative plugin completed, it manages alternative commands that can be executed as normal commands in the help."
end

return {
    description = "NEWS",
    patterns =
    {
        "^[#!/][Nn][Ee][Ww][Ss]$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#news",
    },
}