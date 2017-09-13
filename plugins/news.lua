local function run(msg, matches)
    if matches[1]:lower() == 'news' then
        return news_table.news or langs.news
    end
    if matches[1]:lower() == 'spamnews' then
        if is_sudo(msg) then
            news_table.news = matches[2] or langs.news
            news_table.tot_chats = 0
            news_table.chats = { }
            for k, v in pairs(data.groups) do
                if data[tostring(v)] then
                    news_table.tot_chats = news_table.tot_chats + 1
                    news_table.chats[tostring(v)] = true
                end
            end
            for k, v in pairs(data.realms) do
                if data[tostring(v)] then
                    news_table.tot_chats = news_table.tot_chats + 1
                    news_table.chats[tostring(v)] = true
                end
            end
            news_table.spam = true
            news_table.counter = 0
            news_table.chat_msg_to_update = msg.chat.id
            news_table.msg_to_update = sendMessage(msg.chat.id, "SPAMMING NEWS " .. news_table.counter .. "/" .. tostring(news_table.tot_chats)).result.message_id or nil
        else
            return langs[msg.lang].require_sudo
        end
    end
    if matches[1]:lower() == 'stopnews' then
        if is_sudo(msg) then
            news_table.chats = nil
            news_table.spam = false
            news_table.tot_chats = 0
        else
            return langs[msg.lang].require_sudo
        end
    end
end

local function pre_process(msg)
    if msg then
        if news_table.spam and news_table.chats then
            if news_table.chats[tostring(msg.chat.id)] then
                sendMessage(msg.chat.id, news_table.news or langs.news)
                news_table.chats[tostring(msg.chat.id)] = false
                news_table.counter = news_table.counter + 1
                local text = "SPAMMING NEWS " .. news_table.counter .. "/" .. tostring(news_table.tot_chats) .. '\n'
                for k, v in pairs(news_table.chats) do
                    if not news_table.chats[k] then
                        text = text .. data[tostring(k)].set_name .. '\n'
                    end
                end
                editMessage(news_table.chat_msg_to_update, news_table.msg_to_update, text)
            end
        end
        return msg
    end
end

return {
    description = "NEWS",
    patterns =
    {
        "^[#!/]([Nn][Ee][Ww][Ss])$",
        "^[#!/]([Ss][Pp][Aa][Mm][Nn][Ee][Ww][Ss])$",
        "^[#!/]([Ss][Pp][Aa][Mm][Nn][Ee][Ww][Ss]) (.*)$",
        "^[#!/]([Ss][Tt][Oo][Pp][Nn][Ee][Ww][Ss])$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#news",
        "SUDO",
        "#spamnews [<news>]",
        "#stopnews",
    },
}