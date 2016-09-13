local function set_warn(user_id, chat_id, value)
    local data = load_data(config.moderation.data)
    local lang = get_lang(chat_id)
    if tonumber(value) < 0 or tonumber(value) > 10 then
        return langs[lang].errorWarnRange
    end
    local warn_max = value
    data[tostring(chat_id)]['settings']['warn_max'] = warn_max
    save_data(config.moderation.data, data)
    savelog(chat_id, " [" .. user_id .. "] set warn to [" .. value .. "]")
    return langs[lang].warnSet .. value
end

local function get_warn(chat_id)
    local data = load_data(config.moderation.data)
    local lang = get_lang(chat_id)
    local warn_max = data[tostring(chat_id)]['settings']['warn_max']
    if not warn_max then
        return langs[lang].noWarnSet
    end
    return langs[lang].warnSet .. warn_max
end

local function get_user_warns(user_id, chat_id)
    local lang = get_lang(chat_id)
    local hashonredis = redis:get(chat_id .. ':warn:' .. user_id)
    local warn_msg = langs[lang].yourWarnings
    local warn_chat = string.match(get_warn(chat_id), "%d+")

    if hashonredis then
        warn_msg = string.gsub(string.gsub(warn_msg, 'Y', warn_chat), 'X', tostring(hashonredis))
        send_large_msg('chat#id' .. chat_id, warn_msg)
        send_large_msg('channel#id' .. chat_id, warn_msg)
    else
        warn_msg = string.gsub(string.gsub(warn_msg, 'Y', warn_chat), 'X', '0')
        send_large_msg('chat#id' .. chat_id, warn_msg)
        send_large_msg('channel#id' .. chat_id, warn_msg)
    end
end

local function warn_user(executer, target, chat_id)
    if compare_ranks(executer, target, chat_id) then
        local lang = get_lang(chat_id)
        local warn_chat = string.match(get_warn(chat_id), "%d+")
        redis:incr(chat_id .. ':warn:' .. target)
        local hashonredis = redis:get(chat_id .. ':warn:' .. target)
        if not hashonredis then
            redis:set(chat_id .. ':warn:' .. target, 1)
            sendMessage(chat_id, string.gsub(langs[lang].warned, 'X', '1'))
            hashonredis = 1
        end
        if tonumber(warn_chat) ~= 0 then
            if tonumber(hashonredis) >= tonumber(warn_chat) then
                redis:getset(chat_id .. ':warn:' .. target, 0)
                kickUser(executer, target, chat_id)
            end
            sendMessage(chat_id, string.gsub(langs[lang].warned, 'X', tostring(hashonredis)))
        end
        savelog(chat_id, "[" .. executer .. "] warned user " .. result.peer_id .. " Y")
    else
        sendMessage(chat_id, langs[lang].require_rank)
        savelog(chat_id, "[" .. executer .. "] warned user " .. result.peer_id .. " N")
    end
end

local function unwarn_user(executer, target, chat_id)
    if compare_ranks(executer, target, chat_id) then
        local lang = get_lang(chat_id)
        local warns = redis:get(chat_id .. ':warn:' .. target)
        if tonumber(warns) <= 0 then
            redis:set(chat_id .. ':warn:' .. target, 0)
            sendMessage(chat_id, langs[lang].alreadyZeroWarnings)
        else
            redis:set(chat_id .. ':warn:' .. target, warns - 1)
            sendMessage(chat_id, langs[lang].unwarned)
        end
        savelog(chat_id, "[" .. executer .. "] unwarned user " .. result.peer_id .. " Y")
    else
        sendMessage(chat_id, langs[lang].require_rank)
        savelog(chat_id, "[" .. executer .. "] unwarned user " .. result.peer_id .. " N")
    end
end

local function unwarnall_user(executer, target, chat_id)
    if compare_ranks(executer, target, chat_id) then
        local lang = get_lang(chat_id)
        redis:set(chat_id .. ':warn:' .. target, 0)
        savelog(chat_id, "[" .. executer .. "] unwarnedall user " .. result.peer_id .. " Y")
        sendMessage(chat_id, langs[lang].zeroWarnings)
    else
        sendMessage(chat_id, langs[lang].require_rank)
        savelog(chat_id, "[" .. executer .. "] unwarnedall user " .. result.peer_id .. " N")
    end
end

local function run(msg, matches)
    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
        if is_mod(msg) then
            if matches[1]:lower() == 'setwarn' and matches[2] then
                local txt = set_warn(msg.from.id, msg.chat.id, matches[2])
                if matches[2] == '0' then
                    return langs[msg.lang].neverWarn
                else
                    return txt
                end
            end
            if matches[1]:lower() == 'getwarn' then
                return get_warn(msg.chat.id)
            end
            if get_warn(msg.chat.id) == langs[msg.lang].noWarnSet then
                return langs[msg.lang].noWarnSet
            else
                if matches[1]:lower() == 'getuserwarns' or matches[1]:lower() == 'sasha ottieni avvertimenti' or matches[1]:lower() == 'ottieni avvertimenti' then
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return get_user_warns(msg.reply_to_message.forward_from.id, msg.chat.id)
                                    else
                                        -- return error cant whitelist chat
                                    end
                                else
                                    -- return error no forward
                                end
                            end
                        else
                            return get_user_warns(msg.reply_to_message.from.id, msg.chat.id)
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        return get_user_warns(matches[2], msg.chat.id)
                    else
                        local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                        if obj_user then
                            if obj_user.type == 'private' then
                                return get_user_warns(obj_user.id, msg.chat.id)
                            end
                        end
                    end
                    return
                end
                if matches[1]:lower() == 'warn' or matches[1]:lower() == 'sasha avverti' or matches[1]:lower() == 'avverti' then
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return warn_user(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id)
                                    else
                                        -- return error cant whitelist chat
                                    end
                                else
                                    -- return error no forward
                                end
                            end
                        else
                            return warn_user(msg.from.id, msg.reply_to_message.from.id, msg.chat.id)
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        return warn_user(msg.from.id, matches[2], msg.chat.id)
                    else
                        local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                        if obj_user then
                            if obj_user.type == 'private' then
                                return warn_user(msg.from.id, obj_user.id, msg.chat.id)
                            end
                        end
                    end
                    return
                end
                if matches[1]:lower() == 'unwarn' then
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return unwarn_user(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id)
                                    else
                                        -- return error cant whitelist chat
                                    end
                                else
                                    -- return error no forward
                                end
                            end
                        else
                            return unwarn_user(msg.from.id, msg.reply_to_message.from.id, msg.chat.id)
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        return unwarn_user(msg.from.id, matches[2], msg.chat.id)
                    else
                        local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                        if obj_user then
                            if obj_user.type == 'private' then
                                return unwarn_user(msg.from.id, obj_user.id, msg.chat.id)
                            end
                        end
                    end
                    return
                end
                if matches[1]:lower() == 'unwarnall' or matches[1]:lower() == 'sasha azzera avvertimenti' or matches[1]:lower() == 'azzera avvertimenti' then
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return unwarnall_user(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id)
                                    else
                                        -- return error cant whitelist chat
                                    end
                                else
                                    -- return error no forward
                                end
                            end
                        else
                            return unwarnall_user(msg.from.id, msg.reply_to_message.from.id, msg.chat.id)
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        return unwarnall_user(msg.from.id, matches[2], msg.chat.id)
                    else
                        local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                        if obj_user then
                            if obj_user.type == 'private' then
                                return unwarnall_user(msg.from.id, obj_user.id, msg.chat.id)
                            end
                        end
                    end
                    return
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    else
        return langs[msg.lang].useYourGroups
    end
end

return {
    description = "WARN",
    patterns =
    {
        "^[#!/]([Ss][Ee][Tt][Ww][Aa][Rr][Nn]) (%d+)$",
        "^[#!/]([Gg][Ee][Tt][Ww][Aa][Rr][Nn])$",
        "^[#!/]([Gg][Ee][Tt][Uu][Ss][Ee][Rr][Ww][Aa][Rr][Nn][Ss]) (.*)$",
        "^[#!/]([Gg][Ee][Tt][Uu][Ss][Ee][Rr][Ww][Aa][Rr][Nn][Ss])$",
        "^[#!/]([Ww][Aa][Rr][Nn]) (.*)$",
        "^[#!/]([Ww][Aa][Rr][Nn])$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn]) (.*)$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn])$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn][Aa][Ll][Ll]) (.*)$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn][Aa][Ll][Ll])$",
        -- getuserwarns
        "^([Ss][Aa][Ss][Hh][Aa] [Oo][Tt][Tt][Ii][Ee][Nn][Ii] [Aa][Vv][Vv][Ee][Rr][Tt][Ii][Mm][Ee][Nn][Tt][Ii]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Oo][Tt][Tt][Ii][Ee][Nn][Ii] [Aa][Vv][Vv][Ee][Rr][Tt][Ii][Mm][Ee][Nn][Tt][Ii])$",
        "^([Oo][Tt][Tt][Ii][Ee][Nn][Ii] [Aa][Vv][Vv][Ee][Rr][Tt][Ii][Mm][Ee][Nn][Tt][Ii]) (.*)$",
        "^([Oo][Tt][Tt][Ii][Ee][Nn][Ii] [Aa][Vv][Vv][Ee][Rr][Tt][Ii][Mm][Ee][Nn][Tt][Ii])$",
        -- warn
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Vv][Vv][Ee][Rr][Tt][Ii]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Vv][Vv][Ee][Rr][Tt][Ii])$",
        "^([Aa][Vv][Vv][Ee][Rr][Tt][Ii]) (.*)$",
        "^([Aa][Vv][Vv][Ee][Rr][Tt][Ii])$",
        -- unwarnall
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Zz][Zz][Ee][Rr][Aa] [Aa][Vv][Vv][Ee][Rr][Tt][Ii][Mm][Ee][Nn][Tt][Ii]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Zz][Zz][Ee][Rr][Aa] [Aa][Vv][Vv][Ee][Rr][Tt][Ii][Mm][Ee][Nn][Tt][Ii])$",
        "^([Aa][Zz][Zz][Ee][Rr][Aa] [Aa][Vv][Vv][Ee][Rr][Tt][Ii][Mm][Ee][Nn][Tt][Ii]) (.*)$",
        "^([Aa][Zz][Zz][Ee][Rr][Aa] [Aa][Vv][Vv][Ee][Rr][Tt][Ii][Mm][Ee][Nn][Tt][Ii])$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "MOD",
        "#setwarn <value>",
        "#getwarn",
        "(#getuserwarns|[sasha] ottieni avvertimenti) <id>|<username>|<reply>|from",
        "(#warn|[sasha] avverti) <id>|<username>|<reply>|from",
        "#unwarn <id>|<username>|<reply>|from",
        "(#unwarnall|[sasha] azzera avvertimenti) <id>|<username>|<reply>|from",
    },
}