local function run(msg, matches)
    if is_sudo(msg) then
        io.popen('lua timework.lua "' .. matches[2] .. '" "' .. matches[3] .. '" "' .. matches[4] .. '"')
    end
end

return {
    description = "TEST",
    patterns = { "^[#!/]([Tt][Ee][Ss][Tt]) (%d+) (^%s) (%-?%d+)$", },
    run = run,
    min_rank = 4,
    syntax = { }
}