local function run(msg, matches)
    local url = "http://latex.codecogs.com/png.view?" ..
    "\\dpi{300}%20\\LARGE%20" .. URL.escape(matches[1])
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