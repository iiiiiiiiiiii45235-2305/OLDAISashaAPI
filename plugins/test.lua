local function run(msg, matches)
    if is_sudo(msg) then
        loadfile("timework.lua")(20, 30, 40, vardumptext)
    end
end

return {
    description = "TEST",
    patterns = { },
    run = run,
    min_rank = 4,
    syntax = { }
}