local function run(msg, matches)
    if is_sudo(msg) then
        io.popen("lua timework.lua \"" .. vardumptext(bot):gsub("\"", "\\\"") .. "\" \"" .. vardumptext(sudoers):gsub("\"", "\\\"") .. "\" 30 40")
    end
end

return {
    description = "TEST",
    patterns = { "^[#!/]([Tt][Ee][Ss][Tt])$", },
    run = run,
    min_rank = 4,
    syntax = { }
}