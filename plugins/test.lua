local function run(msg, matches)
    if is_sudo(msg) then
    end
end

return {
    description = "TEST",
    patterns = { },
    run = run,
    min_rank = 4,
    syntax = { }
}