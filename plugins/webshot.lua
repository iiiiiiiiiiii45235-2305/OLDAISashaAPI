local function run(msg, matches)
    if msg.from.is_mod then
        local url = "http://webshot.okfnlabs.org/api/generate?url=" .. html_escape("http%3A%2F%2F" .. matches[1])
        if matches[2] and not matches[3] then
            url = url .. "&full=true"
        elseif matches[2] and matches[3] then
            url = url .. "&width=" .. matches[2] .. "&height=" .. matches[3]
        end
        return pyrogramUpload(msg.chat.id, "photo", url, msg.message_id)
    else
        return langs[msg.lang].require_mod
    end
end

return {
    description = "WEBSHOT",
    patterns =
    {
        "^[#!/][Ww][Ee][Bb][Ss][Hh][Oo][Tt] [Hh][Tt][Tt][Pp][Ss]?://([%w-_%.%?%.:/%+=&]+) ([Ff][Uu][Ll][Ll])$",
        "^[#!/][Ww][Ee][Bb][Ss][Hh][Oo][Tt] [Hh][Tt][Tt][Pp][Ss]?://([%w-_%.%?%.:/%+=&]+) (%d+)[Xx](%d+)$",
        "^[#!/][Ww][Ee][Bb][Ss][Hh][Oo][Tt] [Hh][Tt][Tt][Pp][Ss]?://([%w-_%.%?%.:/%+=&]+)$",
        "^[#!/][Ww][Ee][Bb][Ss][Hh][Oo][Tt] ([%w-_%.%?%.:/%+=&]+) ([Ff][Uu][Ll][Ll])$",
        "^[#!/][Ww][Ee][Bb][Ss][Hh][Oo][Tt] ([%w-_%.%?%.:/%+=&]+) (%d+)[Xx](%d+)$",
        "^[#!/][Ww][Ee][Bb][Ss][Hh][Oo][Tt] ([%w-_%.%?%.:/%+=&]+)$",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "MOD",
        "/webshot <url> [{width}x{height}|full]",
    },
}