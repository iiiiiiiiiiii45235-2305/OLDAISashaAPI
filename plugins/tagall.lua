local function run(msg, matches)
    if msg.from.is_owner then
        return langs[msg.lang].useAISasha
        --[[local text = ''
        if matches[1] then
            mystat('/tagall <text>')
            text = matches[1] .. "\n"
        elseif msg.reply then
            mystat('/tagall <reply_text>')
            text = msg.reply_to_message.text .. "\n"
        end
        local participants = getChatParticipants(msg.chat.id)
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
        return text]]
    else
        return langs[msg.lang].require_owner
    end
end

return {
    description = "TAGALL",
    patterns =
    {
        "^[#!/][Tt][Aa][Gg][Aa][Ll][Ll]$",
        "^[#!/][Tt][Aa][Gg][Aa][Ll][Ll] +(.+)$",
        "^[Ss][Aa][Ss][Hh][Aa] [Tt][Aa][Gg][Gg][Aa] [Tt][Uu][Tt][Tt][Ii]$",
        "^[Ss][Aa][Ss][Hh][Aa] [Tt][Aa][Gg][Gg][Aa] [Tt][Uu][Tt][Tt][Ii] +(.+)$",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "OWNER",
        "(#tagall|sasha tagga tutti) <text>|<reply_text>",
    },
}