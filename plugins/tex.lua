local function run(msg, matches)
    local eq = URL.escape(matches[1])
    local url = "http://latex.codecogs.com/png.download?" ..
    "\\dpi{300}%20\\LARGE%20" .. eq

    if downloadCache[url] then
        return sendPhoto(msg.chat.id, downloadCache[url])
    else
        return sendPhotoFromUrl(msg.chat.id, url)
    end
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