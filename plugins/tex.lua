local function run(msg, matches)
    local url = "http://latex.codecogs.com/png.download?\\dpi{300}%20\\LARGE%20" .. URL.escape(matches[1])
    print(url)
    io.popen('lua timework.lua "fileconversion" "0" "' .. msg.chat.id .. '" "' .. url .. '" "data/tmp/' .. math.random() .. '" "photo"')
end

return {
    description = "TEX",
    patterns =
    {
        "^[#!/][Tt][Ee][Xx] (.+)$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/tex {equation}",
    },
}