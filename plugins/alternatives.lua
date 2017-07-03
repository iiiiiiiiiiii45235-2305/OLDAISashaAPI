local function run(msg, matches)

end

local function pre_process(msg)
    if msg then
        if alternatives[tostring(msg.chat.id)] then
            if alternatives[tostring(msg.chat.id)].altCmd then
                for k, v in pairs(alternatives[tostring(msg.chat.id)].altCmd) do
                    if string.match(msg.text:lower(), '^' .. k) then
                        -- one match is enough
                        msg.text = string.gsub(msg.text, '^' .. k, v)
                        return msg
                    end
                end
            end
        end
        return msg
    end
end

return {
    description = "ALTERNATIVES",
    patterns =
    {
        "^[#!/][Gg][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss] ([^%s]+)$",
        "^[#!/][Uu][Nn][Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee] (.*)$",
        "^[#!/][Uu][Nn][Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss] (.*)$",
        "^[#!/][Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee] ([^%s]+) (.*)$",
        "^[#!/][Gg][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss] ([^%s]+)$",
        "^[#!/][Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee] ([^%s]+) (.*)$",
        "^[#!/][Uu][Nn][Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee] (.*)$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#getalternatives <command>",
        "#getglobalalternatives <command>",
        "MOD",
        "#setalternative <command> <alternative>",
        "#unsetalternative <alternative>",
        "OWNER",
        "#unsetalternatives <command>",
        "ADMIN",
        "#setglobalalternative <command> <alternative>",
        "#unsetglobalalternative <alternative>",
    },
}