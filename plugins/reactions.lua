local function run(msg, matches)
    if is_mod(msg) then
        return sendChatAction(msg.chat.id, matches[1]:lower())
    else
        return langs[msg.lang].require_mod
    end
end

return {
    description = "REACTIONS",
    patterns =
    {
        "^[#!/]([Tt][Yy][Pp][Ii][Nn][Gg])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Pp][Hh][Oo][Tt][Oo])$",
        "^[#!/]([Rr][Ee][Cc][Oo][Rr][Dd]_[Vv][Ii][Dd][Ee][Oo])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Vv][Ii][Dd][Ee][Oo])$",
        "^[#!/]([Rr][Ee][Cc][Oo][Rr][Dd]_[Aa][Uu][Dd][Ii][Oo])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Aa][Uu][Dd][Ii][Oo])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Dd][Oo][Cc][Uu][Mm][Ee][Nn][Tt])$",
        "^[#!/]([Ff][Ii][Nn][Dd]_[Ll][Oo][Cc][Aa][Tt][Ii][Oo][Nn])$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "MOD",
        "#typing on|off",
        "#upload_photo on|off",
        "#record_video on|off",
        "#upload_video on|off",
        "#record_audio on|off",
        "#upload_audio on|off",
        "#upload_document on|off",
        "#find_location on|off",
    },
}