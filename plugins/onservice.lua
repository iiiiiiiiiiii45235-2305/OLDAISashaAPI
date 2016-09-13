-- Will leave the group if be added
local function run(msg, matches)
    if matches[1]:lower() == 'leave' or matches[1]:lower() == 'sasha abbandona' then
        if is_admin(msg) then
            if not matches[2] then
                sendMessage(msg.chat.id, langs[msg.lang].notMyGroup)
                return leaveChat(msg.chat.id)
            else
                sendMessage(matches[2], langs[msg.lang].notMyGroup)
                return leaveChat(matches[2])
            end
        else
            return langs[msg.lang].require_admin
        end
    end
end

local function pre_process(msg)
    if msg.service then
        if msg.service_type == 'chat_add_user' then
            if tostring(msg.added.id) == tostring(bot.id) then
                if not is_admin(msg) then
                    sendMessage(msg.chat.id, langs[msg.lang].notMyGroup)
                    leaveChat(msg.chat.id)
                end
            end
        end
    end
    return msg
end

return {
    description = "ONSERVICE",
    patterns =
    {
        "^[#!/]([Ll][Ee][Aa][Vv][Ee]) (%-?%d+)$",
        "^[#!/]([Ll][Ee][Aa][Vv][Ee])$",
        -- leave
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Bb][Bb][Aa][Nn][Dd][Oo][Nn][Aa]) (%-?%d+)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Bb][Bb][Aa][Nn][Dd][Oo][Nn][Aa])$",
    },
    pre_process = pre_process,
    run = run,
    min_rank = 3,
    syntax =
    {
        "ADMIN",
        "(#leave|sasha abbandona) [<group_id>]",
    },
}