local function whitelist_user(tgcli_chat_id, user_id, lang)
    if isWhitelisted(tgcli_chat_id, user_id) then
        redis:srem('whitelist:' .. tgcli_chat_id, user_id)
        return langs[lang].userBot .. user_id .. langs[lang].whitelistRemoved
    else
        redis:sadd('whitelist:' .. tgcli_chat_id, user_id)
        return langs[lang].userBot .. user_id .. langs[lang].whitelistAdded
    end
end

local function whitegban_user(tgcli_chat_id, user_id, lang)
    if isWhitelistedGban(tgcli_chat_id, user_id) then
        redis:srem('whitelist:gban:' .. tgcli_chat_id, user_id)
        return langs[lang].userBot .. user_id .. langs[lang].whitelistGbanRemoved
    else
        redis:sadd('whitelist:gban:' .. tgcli_chat_id, user_id)
        return langs[lang].userBot .. user_id .. langs[lang].whitelistGbanAdded
    end
end

local function whitelist_link(chat_id, link)
    local lang = get_lang(chat_id)
    link = link:lower()
    -- make all the telegram's links t.me
    link = links_to_tdotme(link)
    -- remove http(s)
    link = link:gsub("[Hh][Tt][Tt][Pp][Ss]?://", '')
    if link:match("^[Tt]%.[Mm][Ee]/") or link:match("^@([%a][%w_]+)") then
        if not(link:match("[Tt]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or link:match("[Cc][Hh][Aa][Tt]%.[Ww][Hh][Aa][Tt][Ss][Aa][Pp][Pp]%.[Cc][Oo][Mm]/")) then
            -- public link/username
            -- remove ?start=blabla and things like that
            link = link:gsub('%?([^%s]+)', '')
            -- make links usernames
            link = link:gsub('[Tt]%.[Mm][Ee]/', '@')
        end
        -- else
        -- private link
        if data[tostring(chat_id)] then
            if data[tostring(chat_id)].settings then
                if data[tostring(chat_id)].settings.links_whitelist then
                    for k, v in pairs(data[tostring(chat_id)].settings.links_whitelist) do
                        if v == link then
                            -- already whitelisted
                            data[tostring(chat_id)].settings.links_whitelist[k] = nil
                            save_data(config.moderation.data, data)
                            return link .. langs[lang].whitelistLinkRemoved
                        end
                    end
                end
            end
        end
        table.insert(data[tostring(chat_id)].settings.links_whitelist, link)
        save_data(config.moderation.data, data)
        return link .. langs[lang].whitelistLinkAdded
    else
        return link .. langs[lang].notLink
    end
end

local function run(msg, matches)
    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
        if matches[1]:lower() == "whitelist" then
            if msg.reply then
                if is_owner(msg) then
                    mystat('/whitelist <user>')
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return whitelist_user(msg.chat.tg_cli_id, msg.reply_to_message.forward_from.id, msg.lang)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return whitelist_user(msg.chat.tg_cli_id, msg.reply_to_message.from.id, msg.lang)
                    end
                else
                    return langs[msg.lang].require_owner
                end
            elseif matches[2] and matches[2] ~= '' then
                if is_owner(msg) then
                    mystat('/whitelist <user>')
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return whitelist_user(msg.chat.tg_cli_id, msg.entities[k].user.id, msg.lang)
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        return whitelist_user(msg.chat.tg_cli_id, matches[2], msg.lang)
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return whitelist_user(msg.chat.tg_cli_id, obj_user.id, msg.lang)
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
                local list = redis:smembers('whitelist:' .. msg.chat.tg_cli_id)
                local text = langs[msg.lang].whitelistStart .. msg.chat.title .. '\n'
                for k, v in pairs(list) do
                    local user_info = redis:hgetall('user:' .. v)
                    if user_info and user_info.print_name then
                        local print_name = string.gsub(user_info.print_name, "_", " ")
                        text = text .. k .. " - " .. print_name .. " [" .. v .. "]\n"
                    else
                        text = text .. k .. " - " .. v .. "\n"
                    end
                end
                return text
            end
        end
        if matches[1]:lower() == "whitelistgban" then
            if msg.reply then
                if is_owner(msg) then
                    mystat('/whitelistgban <user>')
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return whitegban_user(msg.chat.tg_cli_id, msg.reply_to_message.forward_from.id, msg.lang)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return whitegban_user(msg.chat.tg_cli_id, msg.reply_to_message.from.id, msg.lang)
                    end
                else
                    return langs[msg.lang].require_owner
                end
            elseif matches[2] and matches[2] ~= '' then
                if is_owner(msg) then
                    mystat('/whitelistgban <user>')
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return whitegban_user(msg.chat.tg_cli_id, msg.entities[k].user.id, msg.lang)
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        return whitegban_user(msg.chat.tg_cli_id, matches[2], msg.lang)
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return whitegban_user(msg.chat.tg_cli_id, obj_user.id, msg.lang)
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
                local list = redis:smembers('whitelist:gban:' .. msg.chat.tg_cli_id)
                local text = langs[msg.lang].whitelistGbanStart .. msg.chat.title .. '\n'
                for k, v in pairs(list) do
                    local user_info = redis:hgetall('user:' .. v)
                    if user_info and user_info.print_name then
                        local print_name = string.gsub(user_info.print_name, "_", " ")
                        text = text .. k .. " - " .. print_name .. " [" .. v .. "]\n"
                    else
                        text = text .. k .. " - " .. v .. "\n"
                    end
                end
                return text
            end
        end
        if matches[1]:lower() == "whitelistlink" then
            if is_owner(msg) then
                mystat('/whitelistlink <link>')
                return whitelist_link(msg.chat.id, matches[2])
            else
                mystat('/whitelistlink')
                local text = langs[msg.lang].whitelistLinkStart .. msg.chat.title .. '\n'
                if data[tostring(chat_id)] then
                    if data[tostring(chat_id)].settings then
                        if data[tostring(chat_id)].settings.links_whitelist then
                            for k, v in pairs(data[tostring(chat_id)].settings.links_whitelist) do
                                -- already whitelisted
                                text = text .. k .. ". " .. v .. "\n"
                            end
                        end
                    end
                end
                return text
            end
        end
    end
end

return {
    description = "WHITELIST",
    patterns =
    {
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt][Gg][Bb][Aa][Nn])$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt][Ll][Ii][Nn][Kk])$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt]) ([^%s]+)$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt][Gg][Bb][Aa][Nn]) ([^%s]+)$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt][Ll][Ii][Nn][Kk]) ([^%s]+)$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#whitelist",
        "#whitelistgban",
        "#whitelistlink",
        "OWNER",
        "#whitelist <id>|<username>|<reply>",
        "#whitelistgban <id>|<username>|<reply>",
        "#whitelistlink <link>",
    },
}