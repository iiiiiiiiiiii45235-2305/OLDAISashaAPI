local function flame_user(executer, target, chat_id)
    local lang = get_lang(chat_id)
    local hash = 'flame:' .. chat_id
    local tokick = 'tokick:' .. chat_id
    -- ignore higher or same rank
    if compare_ranks(executer, target, chat_id) then
        redis:set(hash, 0);
        redis:set(tokick, target);
        return langs[lang].hereIAm
    else
        return langs[lang].require_rank
    end
end

local function run(msg, matches)
    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
        if msg.from.is_mod then
            if matches[1]:lower() == 'startflame' then
                mystat('/startflame')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return flame_user(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return flame_user(msg.from.id, msg.reply_to_message.from.id, msg.chat.id)
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if string.match(matches[2], '^%d+$') then
                        return flame_user(msg.from.id, matches[2], msg.chat.id)
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return flame_user(msg.from.id, obj_user.id, msg.chat.id)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            elseif matches[1]:lower() == 'stopflame' then
                mystat('/stopflame')
                local hash = 'flame:' .. msg.chat.id
                local tokick = 'tokick:' .. msg.chat.id
                -- ignore higher or same rank
                if redis:get(tokick) then
                    if compare_ranks(msg.from.id, redis:get(tokick), msg.chat.id) then
                        redis:del(hash)
                        redis:del(tokick)
                        return langs[msg.lang].stopFlame
                    else
                        return langs[msg.lang].require_rank
                    end
                end
            elseif matches[1]:lower() == 'flameinfo' then
                mystat('/flameinfo')
                local hash = 'flame:' .. msg.chat.id
                local tokick = 'tokick:' .. msg.chat.id
                local hashonredis = redis:get(hash)
                local user = redis:get(tokick)
                if hashonredis and user then
                    local obj_user = getChat(user)
                    if type(obj_user) == 'table' then
                        local text = langs[msg.lang].flaming
                        if obj_user.first_name then
                            text = text .. '\n' .. obj_user.first_name
                        end
                        if obj_user.last_name then
                            text = text .. '\n' .. obj_user.last_name
                        end
                        if obj_user.username then
                            text = text .. '\n@' .. obj_user.username
                        end
                        text = text .. '\n' .. obj_user.id
                        return text
                    end
                else
                    return langs[msg.lang].errorParameter
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    else
        return langs[msg.lang].useYourGroups
    end
end

local function pre_process(msg)
    if msg then
        if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
            local hash = 'flame:' .. msg.chat.id
            local tokick = 'tokick:' .. msg.chat.id
            if tostring(msg.from.id) == tostring(redis:get(tokick)) then
                redis:incr(hash)
                local hashonredis = redis:get(hash)
                if hashonredis then
                    sendReply(msg, langs.phrases.flame[tonumber(hashonredis)])
                    if tonumber(hashonredis) == #langs.phrases.flame then
                        local user_id = redis:get(tokick)
                        sendMessage(msg.chat.id, kickUser(bot.id, user_id, msg.chat.id, langs[msg.lang].reasonFlame))
                        redis:del(hash)
                        redis:del(tokick)
                    end
                end
            end
        end
        return msg
    end
end

return {
    description = "FLAME",
    patterns =
    {
        "^[#!/]([Ss][Tt][Aa][Rr][Tt][Ff][Ll][Aa][Mm][Ee]) ([^%s]+)$",
        "^[#!/]([Ss][Tt][Aa][Rr][Tt][Ff][Ll][Aa][Mm][Ee])$",
        "^[#!/]([Ss][Tt][Oo][Pp][Ff][Ll][Aa][Mm][Ee])$",
        "^[#!/]([Ff][Ll][Aa][Mm][Ee][Ii][Nn][Ff][Oo])$",
    },
    pre_process = pre_process,
    run = run,
    min_rank = 1,
    syntax =
    {
        "MOD",
        "/startflame <id>|<username>|<reply>|from",
        "/stopflame",
        "/flameinfo",
    },
}