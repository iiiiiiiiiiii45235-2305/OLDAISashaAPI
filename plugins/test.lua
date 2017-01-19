local function run(msg, matches)
    if is_sudo(msg) then
        return vardumptext(resolveChannelSupergroupsUsernames(matches[1]))
    end
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