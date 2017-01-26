local function tagall_chat(extra, success, result)
    local chat_id = extra.chat_id
    local text = extra.msg_text .. "\n"
    for k, v in pairs(result.members) do
        if v.username then
            if v.username ~= 'AISasha' and string.sub(v.username:lower(), -3) ~= 'bot' then
                text = text .. "@" .. v.username .. " "
            end
        end
    end
    return send_large_msg('chat#id' .. chat_id, text, ok_cb, true)
end

local function tagall_channel(extra, success, result)
    local chat_id = extra.chat_id
    local text = extra.msg_text .. "\n"
    for k, v in pairs(result) do
        if v.username then
            if v.username ~= 'AISasha' and string.sub(v.username:lower(), -3) ~= 'bot' then
                text = text .. "@" .. v.username .. " "
            end
        end
    end
    return send_large_msg('channel#id' .. chat_id, text, ok_cb, true)
end

local function run(msg, matches)
    if is_owner(msg) then
        mystat('/tagall <text>')
        if matches[1] then
            local participants = getChatParticipants(msg.chat.id)
            local text = matches[1] .. "\n"
            for k, v in pairs(participants) do
                if v.user then
                    v = v.user
                    if v.username then
                        text = text .. "@" .. v.username .. " "
                    else
                        local print_name =(v.first_name or '') ..(v.last_name or '')
                        if print_name ~= '' then
                            text = text .. print_name .. " "
                        end
                    end
                end
            end
            return text
        end
    else
        return langs[msg.lang].require_owner
    end
end

return {
    description = "TAGALL",
    patterns =
    {
        "^[#!/][Tt][Aa][Gg][Aa][Ll][Ll] +(.+)$",
        "^[Ss][Aa][Ss][Hh][Aa] [Tt][Aa][Gg][Gg][Aa] [Tt][Uu][Tt][Tt][Ii] +(.+)$",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "OWNER",
        "(#tagall|sasha tagga tutti) <text>",
    },
}