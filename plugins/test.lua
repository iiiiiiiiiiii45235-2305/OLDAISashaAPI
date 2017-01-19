local function run(msg, matches)
    printvardump(resolveChannelSupergroupsUsernames(matches[1]))
end

return {
    description = "TEST",
    patterns =
    {
        "^[#!/][Gg][Ee][Tt][Cc][Hh][Aa][Tt] (.*)",
    },
    run = run,
    min_rank = 4,
    syntax =
    {
    }
}