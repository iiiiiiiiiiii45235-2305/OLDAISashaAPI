local function run(msg, matches)
    local base = "http://dogr.io/"
    local path = string.gsub(matches[1], " ", "%%20")
    local url = base .. path .. '.png?split=false&.png'
    local urlm = "https?://[%%%w-_%.%?%.:/%+=&]+"

    if string.match(url, urlm) == url then
        return sendPhotoFromUrl(msg.chat.id, url)
    else
        return langs[msg.lang].opsError
    end
end

return {
    description = "DOGIFY",
    patterns =
    {
        "^[#!/][Dd][Oo][Gg][Ii][Ff][Yy] (.+)$",
        -- dogify
        "^[Ss][Aa][Ss][Hh][Aa] [Dd][Oo][Gg][Ee] (.+)$",
        "^[Dd][Oo][Gg][Ee] (.+)$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "(#dogify|[sasha] doge) <your/words/with/slashes>",
    },
}