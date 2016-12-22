local function is_here(chat_id, user_id)
    local lang = get_lang(chat_id)
    local chat_member = getChatMember(chat_id, user_id)
    if type(chat_member) == 'table' then
        if chat_member.result then
            chat_member = chat_member.result
            if chat_member.status == 'creator' or chat_member.status == 'administrator' or chat_member.status == 'member' then
                return langs[lang].ishereYes
            else
                return langs[lang].ishereNo
            end
        end
    end
end

local function get_reverse_rank(chat_id, user_id)
    local lang = get_lang(chat_id)
    local rank = get_rank(user_id, chat_id)
    return langs[lang].rank .. reverse_rank_table[rank + 1]
end

local function get_object_info(obj, chat_id)
    local lang = get_lang(chat_id)
    if obj then
        local text = langs[lang].infoWord
        if obj.type == 'private' then
            text = text .. langs[lang].chatType .. langs[lang].userWord
            if obj.first_name then
                text = text .. langs[lang].name .. obj.first_name
            end
            if obj.last_name then
                text = text .. langs[lang].surname .. obj.last_name
            end
            if obj.username then
                text = text .. langs[lang].username .. '@' .. obj.username
            end
            local msgs = tonumber(redis:get('msgs:' .. obj.id .. ':' .. chat_id) or 0)
            text = text .. langs[lang].rank .. reverse_rank_table[get_rank(obj.id, chat_id) + 1] ..
            langs[lang].date .. os.date('%c') ..
            langs[lang].totalMessages .. msgs
            local otherinfo = langs[lang].otherInfo
            if obj.id ~= bot.id then
                local chat_member = getChatMember(chat_id, obj.id)
                if type(chat_member) == 'table' then
                    if chat_member.result then
                        chat_member = chat_member.result
                        if chat_member.status then
                            otherinfo = otherinfo .. chat_member.status:upper() .. ' '
                        end
                    end
                end
            end
            if redis:sismember('whitelist', obj.id) then
                otherinfo = otherinfo .. 'WHITELISTED '
            end
            if isGbanned(obj.id) then
                otherinfo = otherinfo .. 'GBANNED '
            end
            if isBanned(obj.id, chat_id) then
                otherinfo = otherinfo .. 'BANNED '
            end
            if isBlocked(obj.id) then
                otherinfo = otherinfo .. 'PM BLOCKED '
            end
            if otherinfo == langs[lang].otherInfo then
                otherinfo = otherinfo .. langs[lang].noOtherInfo
            end
            text = text .. otherinfo ..
            langs[lang].long_id .. obj.id
        elseif obj.type == 'group' then
            text = text .. langs[lang].chatType .. langs[lang].groupWord
            if obj.title then
                text = text .. langs[lang].groupName .. obj.title
            end
            text = text .. langs[lang].date .. os.date('%c') ..
            langs[lang].long_id .. obj.id
        elseif obj.type == 'supergroup' then
            text = text .. langs[lang].chatType .. langs[lang].supergroupWord
            if obj.title then
                text = text .. langs[lang].supergroupName .. obj.title
            end
            if obj.username then
                text = text .. langs[lang].username .. '@' .. obj.username
            end
            text = text .. langs[lang].date .. os.date('%c') ..
            langs[lang].long_id .. obj.id
        elseif obj.type == 'channel' then
            text = text .. langs[lang].chatType .. langs[lang].channelWord
            if obj.title then
                text = text .. langs[lang].channelName .. obj.title
            end
            if obj.username then
                text = text .. langs[lang].username .. '@' .. obj.username
            end
            text = text .. langs[lang].date .. os.date('%c') ..
            langs[lang].long_id .. obj.id
        else
            return langs[lang].peerTypeUnknown
        end
        return text
    else
        return langs[lang].noObject
    end
end

local function run(msg, matches)
    if matches[1]:lower() == "getrank" or matches[1]:lower() == "rango" then
        mystat('/getrank')
        if msg.reply then
            if matches[2] then
                if matches[2]:lower() == 'from' then
                    if msg.reply_to_message.forward then
                        if msg.reply_to_message.forward_from then
                            return get_reverse_rank(msg.chat.id, msg.reply_to_message.forward_from.id)
                        else
                            return langs[msg.lang].cantDoThisToChat
                        end
                    else
                        return langs[msg.lang].errorNoForward
                    end
                else
                    return get_reverse_rank(msg.chat.id, msg.reply_to_message.from.id)
                end
            else
                return get_reverse_rank(msg.chat.id, msg.reply_to_message.from.id)
            end
        elseif matches[2] then
            if string.match(matches[2], '^%d+$') then
                return get_reverse_rank(msg.chat.id, matches[2])
            else
                local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                if obj_user then
                    if obj_user.type == 'private' then
                        return get_reverse_rank(msg.chat.id, obj_user.id)
                    end
                end
            end
        else
            return get_reverse_rank(msg.chat.id, msg.from.id)
        end
    end
    if matches[1]:lower() == 'ishere' then
        mystat('/ishere')
        if msg.reply then
            if matches[2] then
                if matches[2]:lower() == 'from' then
                    if msg.reply_to_message.forward then
                        if msg.reply_to_message.forward_from then
                            return is_here(msg.chat.id, msg.reply_to_message.forward_from.id)
                        else
                            return langs[msg.lang].cantDoThisToChat
                        end
                    else
                        return langs[msg.lang].errorNoForward
                    end
                else
                    return is_here(msg.chat.id, msg.reply_to_message.from.id)
                end
            else
                return is_here(msg.chat.id, msg.reply_to_message.from.id)
            end
        elseif matches[2] then
            if string.match(matches[2], '^%d+$') then
                return is_here(msg.chat.id, tonumber(matches[2]))
            else
                local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                if obj_user then
                    if obj_user.type == 'private' then
                        return is_here(msg.chat.id, obj_user.id)
                    end
                end
            end
        end
    end
    if matches[1]:lower() == 'info' or matches[1]:lower() == 'sasha info' then
        mystat('/info')
        if msg.reply then
            if msg.from.is_mod then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                return get_object_info(msg.reply_to_message.forward_from, msg.chat.id)
                            else
                                return get_object_info(msg.reply_to_message.forward_from_chat, msg.chat.id)
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    end
                else
                    if msg.reply_to_message.service then
                        if msg.reply_to_message.service_type == 'chat_add_user' then
                            return get_object_info(msg.reply_to_message.adder, msg.chat.id) .. '\n\n' .. get_object_info(msg.reply_to_message.added, msg.chat.id)
                        elseif msg.reply_to_message.service_type == 'chat_del_user' then
                            return get_object_info(msg.reply_to_message.remover, msg.chat.id) .. '\n\n' .. get_object_info(msg.reply_to_message.removed, msg.chat.id)
                        elseif msg.reply_to_message.service_type == 'chat_add_user_link' then
                            return get_object_info(msg.reply_to_message.added, msg.chat.id)
                        elseif msg.reply_to_message.service_type == 'chat_del_user_leave' then
                            return get_object_info(msg.reply_to_message.removed, msg.chat.id)
                        else
                            return get_object_info(msg.reply_to_message.from, msg.chat.id)
                        end
                    else
                        return get_object_info(msg.reply_to_message.from, msg.chat.id)
                    end
                end
            else
                return langs[msg.lang].require_mod
            end
        elseif matches[2] then
            if msg.from.is_mod then
                if string.match(matches[2], '^%-?%d+$') then
                    local obj = getChat(matches[2])
                    if type(obj) == 'table' then
                        if obj.result then
                            obj = obj.result
                            return get_object_info(obj, msg.chat.id)
                        end
                    end
                else
                    local obj = resolveUsername(matches[2]:gsub('@', ''))
                    return get_object_info(obj, msg.chat.id)
                end
            else
                return langs[msg.lang].require_mod
            end
        else
            return get_object_info(msg.from, msg.chat.id) .. '\n\n' .. get_object_info(msg.bot or msg.chat, msg.chat.id)
        end
        return
    end
    if matches[1]:lower() == 'whoami' then
        mystat('/whoami')
        return get_object_info(msg.from, msg.chat.id)
    end
    if matches[1]:lower() == 'grouplink' or matches[1]:lower() == 'sasha link gruppo' or matches[1]:lower() == 'link gruppo' and matches[2] then
        mystat('/grouplink')
        if is_admin(msg) then
            local group_link = data[tostring(matches[2])]['settings']['set_link']
            if not group_link then
                return langs[msg.lang].noLinkAvailable
            end
            local obj = getChat(matches[2])
            if type(obj) == 'table' then
                if obj.result then
                    obj = obj.result
                    return obj.title .. '\n' .. group_link
                end
            end
        else
            return langs[msg.lang].require_admin
        end
    end
end

local function pre_process(msg)
    if msg then
        if msg.chat.type == 'private' and msg.forward then
            if get_rank(msg.from.id, msg.chat.id, true) > 0 then
                -- if moderator in some group or higher
                if msg.forward_from then
                    sendMessage(msg.chat.id, get_object_info(msg.forward_from, msg.chat.id))
                end
                if msg.forward_from_chat then
                    sendMessage(msg.chat.id, get_object_info(msg.forward_from_chat, msg.chat.id))
                end
            end
        end
        return msg
    end
end

return {
    description = "INFO",
    patterns =
    {
        "^[#!/]([Gg][Rr][Oo][Uu][Pp][Ll][Ii][Nn][Kk]) (%-?%d+)$",
        "^[#!/]([Ii][Ss][Hh][Ee][Rr][Ee])$",
        "^[#!/]([Ii][Ss][Hh][Ee][Rr][Ee]) (.*)$",
        "^[#!/]([Gg][Ee][Tt][Rr][Aa][Nn][Kk])$",
        "^[#!/]([Gg][Ee][Tt][Rr][Aa][Nn][Kk]) (.*)$",
        "^[#!/]([Ww][Hh][Oo][Aa][Mm][Ii])$",
        "^[#!/]([Ii][Nn][Ff][Oo])$",
        "^[#!/]([Ii][Nn][Ff][Oo]) (.*)$",
        -- grouplink
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Nn][Kk] [Gg][Rr][Uu][Pp][Pp][Oo]) (%-?%d+)$",
        "^([Ll][Ii][Nn][Kk] [Gg][Rr][Uu][Pp][Pp][Oo]) (%-?%d+)$",
        -- getrank
        "^([Rr][Aa][Nn][Gg][Oo])$",
        "^([Rr][Aa][Nn][Gg][Oo]) (.*)$",
        -- info
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Nn][Ff][Oo])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Nn][Ff][Oo]) (.*)$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#getrank|rango [<id>|<username>|<reply>]",
        "#whoami",
        "(#info|[sasha] info)",
        "#ishere <id>|<username>|<reply>|from",
        "MOD",
        "(#info|[sasha] info) <id>|<username>|<reply>|from",
        "ADMIN",
        "(#grouplink|[sasha] link gruppo) <group_id>",
    },
}