local function run(msg, matches)
    local eq = URL.escape(matches[1])
    local url = "http://latex.codecogs.com/png.download?" ..
    "\\dpi{300}%20\\LARGE%20" .. eq
    io.popen('lua timework.lua "fileconversion" "0" "' .. msg.chat.id .. '" "' .. url .. '" "data/tmp/' .. math.random() .. '" "photo"')
    return pyrogramUpload(msg.chat.id, "photo", url, msg.message_id)
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