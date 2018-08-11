-- tables that contains 'group_id' = message_id to delete old commands responses
local oldResponses = {
    lastWhitelist = { },
    lastWhitelistGban = { },
    lastWhitelistLink = { },
}

local function whitelist_link(chat_id, link)
    local lang = get_lang(chat_id)
    link = link:lower()
    -- make all the telegram's links t.me
    link = links_to_tdotme(link)
    -- remove http(s)
    link = link:gsub("[Hh][Tt][Tt][Pp][Ss]?://", '')
    if link:match("^[Tt]%.[Mm][Ee]/") or link:match("^@([%a][%w_]+)") then
        if not(link:match("[Tt]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or link:match("[Cc][Hh][Aa][Tt]%.[Ww][Hh][Aa][Tt][Ss][Aa][Pp][Pp]%.[Cc][Oo][Mm]/")) then
            if string.match(link, '^(%d+)$') then
                -- channel id
                local obj = getChat(link, true)
                if not obj then
                    return link .. langs[lang].notLink
                end
                if obj.type ~= 'channel' then
                    return link .. langs[lang].notLink
                end
            else
                -- public link/username
                -- remove ?start=blabla and things like that
                link = link:gsub('%?([^%s]+)', '')
                -- make links usernames
                link = link:gsub('[Tt]%.[Mm][Ee]/', '@')
                if not APIgetChat(link, true) then
                    return link .. langs[lang].notLink
                end
            end
        end
        -- else
        -- private link
        for k, v in pairs(data[tostring(chat_id)].whitelist.links) do
            if v == link then
                -- already whitelisted
                data[tostring(chat_id)].whitelist.links[k] = nil
                save_data(config.moderation.data, data)
                return link .. langs[lang].whitelistLinkRemoved
            end
        end
        table.insert(data[tostring(chat_id)].whitelist.links, link)
        save_data(config.moderation.data, data)
        return link .. langs[lang].whitelistLinkAdded
    else
        return link .. langs[lang].notLink
    end
end

local function run(msg, matches)
    if data[tostring(msg.chat.id)] then
        if matches[1]:lower() == "whitelist" then
            if msg.reply then
                if msg.from.is_owner then
                    mystat('/whitelist <user>')
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return whitelist_user(msg.chat.id, msg.reply_to_message.forward_from.id)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return whitelist_user(msg.chat.id, msg.reply_to_message.from.id)
                    end
                else
                    return langs[msg.lang].require_owner
                end
            elseif matches[2] and matches[2] ~= '' then
                if msg.from.is_owner then
                    mystat('/whitelist <user>')
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return whitelist_user(msg.chat.id, msg.entities[k].user.id)
                                end
                            end
                        end
                    end
                    matches[2] = tostring(matches[2]):gsub(' ', '')
                    if string.match(matches[2], '^%d+$') then
                        return whitelist_user(msg.chat.id, matches[2])
                    else
                        local obj_user = getChat(string.match(matches[2], '^[^%s]+') or '')
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return whitelist_user(msg.chat.id, obj_user.id)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                    return
                else
                    return langs[msg.lang].require_owner
                end
            else
                mystat('/whitelist')
                local text = langs[msg.lang].whitelistStart:gsub('X', msg.chat.title) .. '\n'
                for k, v in pairs(data[tostring(msg.chat.id)].whitelist.users) do
                    local user_info = redis:hgetall('user:' .. k)
                    if user_info and user_info.print_name then
                        local print_name = string.gsub(user_info.print_name, "_", " ")
                        text = text .. print_name .. " [" .. k .. "]\n"
                    else
                        text = text .. " [" .. k .. "]\n"
                    end
                end
                if msg.from.is_mod then
                    local tmp = oldResponses.lastWhitelist[tostring(msg.chat.id)]
                    oldResponses.lastWhitelist[tostring(msg.chat.id)] = getMessageId(sendReply(msg, text))
                    if tmp then
                        deleteMessage(msg.chat.id, tmp, true)
                    end
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                else
                    local tmp = ''
                    if not sendMessage(msg.from.id, text) then
                        tmp = getMessageId(sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id))
                    else
                        tmp = getMessageId(sendReply(msg, langs[msg.lang].generalSendPvt, 'html'))
                    end
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
                end
                return
            end
        end
        if matches[1]:lower() == "whitelistgban" then
            if msg.reply then
                if msg.from.is_owner then
                    mystat('/whitelistgban <user>')
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return whitegban_user(msg.chat.id, msg.reply_to_message.forward_from.id)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return whitegban_user(msg.chat.id, msg.reply_to_message.from.id)
                    end
                else
                    return langs[msg.lang].require_owner
                end
            elseif matches[2] and matches[2] ~= '' then
                if msg.from.is_owner then
                    mystat('/whitelistgban <user>')
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return whitegban_user(msg.chat.id, msg.entities[k].user.id)
                                end
                            end
                        end
                    end
                    matches[2] = tostring(matches[2]):gsub(' ', '')
                    if string.match(matches[2], '^%d+$') then
                        return whitegban_user(msg.chat.id, matches[2])
                    else
                        local obj_user = getChat(string.match(matches[2], '^[^%s]+') or '')
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return whitegban_user(msg.chat.id, obj_user.id)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                    return
                else
                    return langs[msg.lang].require_owner
                end
            else
                mystat('/whitelistgban')
                local text = langs[msg.lang].whitelistGbanStart:gsub('X', msg.chat.title) .. '\n'
                for k, v in pairs(data[tostring(msg.chat.id)].whitelist.gbanned) do
                    local user_info = redis:hgetall('user:' .. k)
                    if user_info and user_info.print_name then
                        local print_name = string.gsub(user_info.print_name, "_", " ")
                        text = text .. print_name .. " [" .. k .. "]\n"
                    else
                        text = text .. " [" .. k .. "]\n"
                    end
                end
                if msg.from.is_mod then
                    local tmp = oldResponses.lastWhitelistGban[tostring(msg.chat.id)]
                    oldResponses.lastWhitelistGban[tostring(msg.chat.id)] = getMessageId(sendReply(msg, text))
                    if tmp then
                        deleteMessage(msg.chat.id, tmp, true)
                    end
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                else
                    local tmp = ''
                    if not sendMessage(msg.from.id, text) then
                        tmp = getMessageId(sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id))
                    else
                        tmp = getMessageId(sendReply(msg, langs[msg.lang].generalSendPvt, 'html'))
                    end
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
                end
                return
            end
        end
        if matches[1]:lower() == "whitelistlink" then
            if matches[2] then
                if msg.from.is_owner then
                    mystat('/whitelistlink <link>')
                    return whitelist_link(msg.chat.id, matches[2])
                else
                    return langs[msg.lang].require_owner
                end
            else
                mystat('/whitelistlink')
                local text = langs[msg.lang].whitelistLinkStart:gsub('X', msg.chat.title) .. '\n'
                for k, v in pairs(data[tostring(msg.chat.id)].whitelist.links) do
                    text = text .. k .. ". " .. v .. "\n"
                end
                if msg.from.is_mod then
                    local tmp = oldResponses.lastWhitelistLink[tostring(msg.chat.id)]
                    oldResponses.lastWhitelistLink[tostring(msg.chat.id)] = getMessageId(sendReply(msg, text))
                    if tmp then
                        deleteMessage(msg.chat.id, tmp, true)
                    end
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                else
                    local tmp = ''
                    if not sendMessage(msg.from.id, text) then
                        tmp = getMessageId(sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id))
                    else
                        tmp = getMessageId(sendReply(msg, langs[msg.lang].generalSendPvt, 'html'))
                    end
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
                end
                return
            end
        end
    else
        return langs[msg.lang].useYourGroups
    end
end

return {
    description = "WHITELIST",
    patterns =
    {
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt][Gg][Bb][Aa][Nn])$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt][Ll][Ii][Nn][Kk])[Ss]?$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt]) ([^%s]+)$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt][Gg][Bb][Aa][Nn]) ([^%s]+)$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt][Ll][Ii][Nn][Kk]) ([^%s]+)$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/whitelist",
        "/whitelistgban",
        "/whitelistlink",
        "OWNER",
        "/whitelist {user}",
        "/whitelistgban {user}",
        "/whitelistlink {link}|{public_(channel|supergroup)_username}|{channel_id}",
    },
}