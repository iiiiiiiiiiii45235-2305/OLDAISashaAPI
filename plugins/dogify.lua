local function run(msg, matches)
    local base = "http://dogr.io/"
    local path = string.gsub(matches[1], " ", "%%20")
    local url = base .. URL.escape(matches[1]) .. '.png?split=false&.png'
    return pyrogramUpload(msg.chat.id, "photo", url, msg.message_id)
end

return {
    description = "DOGIFY",
    patterns =
    {
        "^[#!/][Dd][Oo][Gg][Ii][Ff][Yy] (.+)$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/dogify {your/words/with/slashes}",
    },
}