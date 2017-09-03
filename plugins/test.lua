local function run(msg, matches)
    if is_sudo(msg) then
        io.popen("lua timework.lua 30 40 \"porco dio\"")
    end
end

return {
    description = "TEST",
    patterns = { "^[#!/]([Tt][Ee][Ss][Tt])$", },
    run = run,
    min_rank = 4,
    syntax = { }
}