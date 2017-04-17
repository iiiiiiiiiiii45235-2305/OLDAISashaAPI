local function whitelist_user(group_id, user_id, lang)
    if isWhitelisted(group_id, user_id) then
        redis:srem('whitelist:' .. group_id, user_id)
        return langs[lang].userBot .. user_id .. langs[lang].whitelistRemoved
    else
        redis:sadd('whitelist:' .. group_id, user_id)
        return langs[lang].userBot .. user_id .. langs[lang].whitelistAdded
    end
end

local function whitegban_user(group_id, user_id, lang)
    if isWhitelistedGban(group_id, user_id) then
        redis:srem('whitelist:gban:' .. group_id, user_id)
        return langs[lang].userBot .. user_id .. langs[lang].whitelistGbanRemoved
    else
        redis:sadd('whitelist:gban:' .. group_id, user_id)
        return langs[lang].userBot .. user_id .. langs[lang].whitelistGbanAdded
    end
end

local function run(msg, matches)
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
        elseif matches[2] then
            if is_owner(msg) then
                mystat('/whitelist <user>')
                if string.match(matches[2], '^%d+$') then
                    return whitelist_user(msg.chat.tg_cli_id, matches[2], msg.lang)
                else
                    local obj_user = getChat('@' .. string.match(matches[2], '^[^%s]+'):gsub('@', '') or '')
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            return whitelist_user(msg.chat.tg_cli_id, obj_user.id, msg.lang)
                        end
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
    if matches[1]:lower() == "clean whitelist" then
        if is_owner(msg) then
            mystat('/clean whitelist')
            redis:del('whitelist:' .. msg.chat.tg_cli_id)
            return langs[msg.lang].whitelistCleaned
        else
            return langs[msg.lang].require_owner
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
        elseif matches[2] then
            if is_owner(msg) then
                mystat('/whitelistgban <user>')
                if string.match(matches[2], '^%d+$') then
                    return whitegban_user(msg.chat.tg_cli_id, matches[2], msg.lang)
                else
                    local obj_user = getChat('@' .. string.match(matches[2], '^[^%s]+'):gsub('@', '') or '')
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            return whitegban_user(msg.chat.tg_cli_id, obj_user.id, msg.lang)
                        end
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
    if matches[1]:lower() == "clean whitelistgban" then
        if is_owner(msg) then
            mystat('/clean whitelistgban')
            redis:del('whitelist:gban:' .. msg.chat.tg_cli_id)
            return langs[msg.lang].whitelistGbanCleaned
        else
            return langs[msg.lang].require_owner
        end
    end
end

return {
    description = "WHITELIST",
    patterns =
    {
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt][Gg][Bb][Aa][Nn])$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt]) (.*)$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt][Gg][Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Cc][Ll][Ee][Aa][Nn] [Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Cc][Ll][Ee][Aa][Nn] [Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt][Gg][Bb][Aa][Nn])$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#whitelist",
        "#whitelistgban",
        "OWNER",
        "#whitelist <id>|<username>|<reply>",
        "#whitelistgban <id>|<username>|<reply>",
        "#clean whitelist",
        "#clean whitelistgban",
    },
}