local function run(msg, matches)
    if is_sudo(msg) then
    end
end

return {
    description = "TEST",
    patterns = { "^[#!/][Tt][Ee][Ss][Tt]$", },
    run = run,
    min_rank = 5,
    syntax = { }
}