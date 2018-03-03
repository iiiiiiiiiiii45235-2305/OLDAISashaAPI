-- tables that contains 'group_id' = message_id to delete old commands responses
local oldResponses = {
    lastNews = { },
}

local function run(msg, matches)
    if matches[1]:lower() == 'news' then
        if msg.from.is_mod then
            local tmp = oldResponses.lastNews[tostring(msg.chat.id)]
            oldResponses.lastNews[tostring(msg.chat.id)] = sendReply(msg, news_table.news or langs[msg.lang].newsText)
            if oldResponses.lastNews[tostring(msg.chat.id)] then
                if oldResponses.lastNews[tostring(msg.chat.id)].result then
                    if oldResponses.lastNews[tostring(msg.chat.id)].result.message_id then
                        oldResponses.lastNews[tostring(msg.chat.id)] = oldResponses.lastNews[tostring(msg.chat.id)].result.message_id
                    else
                        oldResponses.lastNews[tostring(msg.chat.id)] = nil
                    end
                else
                    oldResponses.lastNews[tostring(msg.chat.id)] = nil
                end
            end
            if tmp then
                deleteMessage(msg.chat.id, tmp, true)
            end
            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
        else
            local tmp = ''
            if not sendMessage(msg.from.id, news_table.news or langs[msg.lang].newsText) then
                tmp = sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id).result.message_id
            else
                tmp = sendReply(msg, langs[msg.lang].generalSendPvt, 'html').result.message_id
            end
            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
        end
        return
    end
    if matches[1]:lower() == 'spamnews' then
        if is_sudo(msg) then
            news_table.news = matches[2] or langs[msg.lang].newsText
            news_table.tot_chats = 0
            news_table.chats = { }
            for k, v in pairsByGroupName(data) do
                if data[tostring(k)] then
                    news_table.tot_chats = news_table.tot_chats + 1
                    news_table.chats[tostring(k)] = true
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
                sendMessage(msg.chat.id, news_table.news or langs[msg.lang].newsText)
                news_table.chats[tostring(msg.chat.id)] = false
                news_table.counter = news_table.counter + 1
                local text = "SPAMMING NEWS " .. news_table.counter .. "/" .. tostring(news_table.tot_chats) .. '\n'
                for k, v in pairsByGroupName(data) do
                    if not news_table.chats[k] then
                        text = text .. v.name .. '\n'
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
    min_rank = 1,
    syntax =
    {
        "USER",
        "/news",
        "SUDO",
        "/spamnews [{news}]",
        "/stopnews",
    },
}