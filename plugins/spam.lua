local function spamText(chat_id, text, messages, time_between_messages)
    local i = 0
    while i <(tonumber(messages or 5) /(0.5 / tonumber(time_between_messages or 2))) / 2 do
        i = i + tonumber(time_between_messages or 2)
        io.popen('lua timework.lua "spamtext" "' .. chat_id .. '" "' .. i .. '" "' .. text:gsub('"', '\\"') .. '"')
    end
end

local function spamForward(chat_id, message_to_forward, messages, time_between_messages)
    local i = 0
    while i <(tonumber(messages or 5) /(0.5 / tonumber(time_between_messages or 2))) / 2 do
        i = i + tonumber(time_between_messages or 2)
        io.popen('lua timework.lua "spamforward" "' .. chat_id .. '" "' .. i .. '" "' .. message_to_forward .. '"')
    end
end

local function run(msg, matches)
    if matches[1]:lower() == 'spam' then
        if is_admin(msg) then
            if msg.reply then
                if matches[2] and matches[3] then
                    spamForward(msg.chat.id, msg.reply_to_message.message_id, matches[2], matches[3])
                else
                    spamForward(msg.chat.id, msg.reply_to_message.message_id)
                end
            else
                if matches[3] and matches[4] then
                    spamText(msg.chat.id, matches[4], matches[2], matches[3])
                else
                    spamText(msg.chat.id, matches[2])
                end
            end
        else
            return langs[msg.lang].require_admin
        end
    end
end

return {
    description = "SPAM",
    patterns =
    {
        -- specified values
        "^[#!/]([Ss][Pp][Aa][Mm]) (%d+) (%d+) (.+)$",
        -- reply specified values
        "^[#!/]([Ss][Pp][Aa][Mm]) (%d+) (%d+)$",
        -- default values
        "^[#!/]([Ss][Pp][Aa][Mm]) (.+)$",
        -- reply default values
        "^[#!/]([Ss][Pp][Aa][Mm])$",
    },
    run = run,
    min_rank = 3,
    syntax =
    {
        "ADMIN",
        "#spam [<messages> <seconds>] <reply>|<text>",
    },
}