local function is_here(chat_id, user_id)
    local lang = get_lang(chat_id)
    local chat_member = getChatMember(chat_id, user_id)
    if type(chat_member) == 'table' then
        if chat_member.result then
            chat_member = chat_member.result
            if chat_member.status == 'creator' or chat_member.status == 'administrator' or chat_member.status == 'member' or chat_member.status == 'restricted' then
                return langs[lang].ishereYes
            else
                return langs[lang].ishereNo
            end
        end
    end
end

local function get_reverse_rank(chat_id, user_id, check_local)
    local lang = get_lang(chat_id)
    local rank = get_rank(user_id, chat_id, check_local)
    return langs[lang].rank .. reverse_rank_table[rank + 1]
end

local function get_object_info(obj, chat_id)
    local lang = get_lang(chat_id)
    if obj then
        local text = langs[lang].infoWord
        if obj.type == 'bot' or obj.is_bot then
            text = text .. langs[lang].chatType .. langs[lang].botWord
            if obj.first_name then
                if obj.first_name == '' then
                    if database[tostring(obj.id)] then
                        return serpent.block(database[tostring(obj.id)], { sortkeys = false, comment = false })
                    else
                        text = text .. '\n$Deleted Account$'
                    end
                else
                    text = text .. langs[lang].name .. obj.first_name
                end
            end
            if obj.last_name then
                text = text .. langs[lang].surname .. obj.last_name
            end
            if obj.username then
                text = text .. langs[lang].username .. '@' .. obj.username
            end
            text = text .. langs[lang].date .. os.date('%c')
            local otherinfo = langs[lang].otherInfo
            if isGbanned(obj.id) then
                otherinfo = otherinfo .. 'GBANNED '
            end
            if tonumber(chat_id) < 0 then
                local status = ''
                local chat_member = getChatMember(chat_id, obj.id)
                if type(chat_member) == 'table' then
                    if chat_member.result then
                        chat_member = chat_member.result
                        if chat_member.status then
                            status = chat_member.status
                            otherinfo = otherinfo .. chat_member.status:upper():gsub('KICKED', 'BANNED') .. ' '
                        end
                    end
                end
                if isWhitelisted(id_to_cli(chat_id), obj.id) then
                    otherinfo = otherinfo .. 'WHITELISTED '
                end
                if isWhitelistedGban(id_to_cli(chat_id), obj.id) then
                    otherinfo = otherinfo .. 'GBANWHITELISTED '
                end
                if isBanned(obj.id, chat_id) then
                    if status ~= 'kicked' then
                        otherinfo = otherinfo .. 'PREBANNED '
                    end
                end
                if isMutedUser(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'MUTED '
                end
                if string.match(getUserWarns(obj.id, chat_id), '%d+') then
                    otherinfo = otherinfo .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. '/' ..(data[tostring(chat_id)].settings.warn_max or 0) .. ' WARN '
                end
            end
            if otherinfo == langs[lang].otherInfo then
                otherinfo = otherinfo .. langs[lang].noOtherInfo
            end
            text = text .. otherinfo ..
            langs[lang].long_id .. obj.id
        elseif obj.type == 'private' or obj.type == 'user' then
            text = text .. langs[lang].chatType .. langs[lang].userWord
            if obj.first_name then
                if obj.first_name == '' then
                    if database[tostring(obj.id)] then
                        return serpent.block(database[tostring(obj.id)], { sortkeys = false, comment = false })
                    else
                        text = text .. '\n$Deleted Account$'
                    end
                else
                    text = text .. langs[lang].name .. obj.first_name
                end
            end
            if obj.last_name then
                text = text .. langs[lang].surname .. obj.last_name
            end
            if obj.username then
                text = text .. langs[lang].username .. '@' .. obj.username
            end
            local msgs = tonumber(redis:get('msgs:' .. obj.id .. ':' .. chat_id) or 0)
            text = text .. langs[lang].rank .. reverse_rank_table[get_rank(obj.id, chat_id, true) + 1] ..
            langs[lang].date .. os.date('%c') ..
            langs[lang].totalMessages .. msgs
            local otherinfo = langs[lang].otherInfo
            if isGbanned(obj.id) then
                otherinfo = otherinfo .. 'GBANNED '
            end
            if isBlocked(obj.id) then
                otherinfo = otherinfo .. 'PM BLOCKED '
            end
            if tonumber(chat_id) < 0 then
                local status = ''
                local chat_member = getChatMember(chat_id, obj.id)
                if type(chat_member) == 'table' then
                    if chat_member.result then
                        chat_member = chat_member.result
                        if chat_member.status then
                            status = chat_member.status
                            otherinfo = otherinfo .. chat_member.status:upper():gsub('KICKED', 'BANNED') .. ' '
                        end
                    end
                end
                if isWhitelisted(id_to_cli(chat_id), obj.id) then
                    otherinfo = otherinfo .. 'WHITELISTED '
                end
                if isWhitelistedGban(id_to_cli(chat_id), obj.id) then
                    otherinfo = otherinfo .. 'GBANWHITELISTED '
                end
                if isBanned(obj.id, chat_id) then
                    if status ~= 'kicked' then
                        otherinfo = otherinfo .. 'PREBANNED '
                    end
                end
                if isMutedUser(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'MUTED '
                end
                if string.match(getUserWarns(obj.id, chat_id), '%d+') then
                    otherinfo = otherinfo .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. '/' ..(data[tostring(chat_id)].settings.warn_max or 0) .. ' WARN '
                end
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
            text = langs[lang].peerTypeUnknown
        end
        return text
    else
        return langs[lang].noObject
    end
end

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
    if msg.cb then
        if matches[1] then
            if matches[1] == '###cbinfo' then
                if matches[2] == 'DELETE' then
                    if matches[3] and matches[4] then
                        editMessageText(msg.chat.id, msg.message_id, get_object_info(getChat(matches[3]), matches[4]))
                    else
                        if not deleteMessage(msg.chat.id, msg.message_id, true) then
                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                        end
                    end
                else
                    local updated = false
                    if matches[2] == 'BACK' then
                        updated = true
                        local tab = get_object_info_keyboard(msg.from.id, getChat(matches[3]), matches[4] or matches[3])
                        if tab then
                            editMessageText(msg.chat.id, msg.message_id, tab.text, tab.keyboard)
                        else
                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].noObject)
                        end
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                    elseif matches[2] == 'LINK' then
                        if is_mod2(msg.from.id, matches[3]) then
                            mystat('###cbinfo' .. matches[2] .. matches[3])
                            local chat_name = ''
                            if data[tostring(matches[3])] then
                                chat_name = data[tostring(matches[3])].set_name or ''
                            end
                            local group_link = data[tostring(matches[3])]['settings']['set_link']
                            if not group_link then
                                local link = exportChatInviteLink(matches[3])
                                if link then
                                    updated = true
                                    data[tostring(matches[3])]['settings']['set_link'] = link
                                    save_data(config.moderation.data, data)
                                    group_link = link
                                    savelog(matches[3], msg.from.print_name .. " [" .. msg.from.id .. "] created group link [" .. data[tostring(matches[3])].settings.set_link .. "]")
                                    editMessageText(msg.chat.id, msg.message_id, chat_name .. '\n' .. group_link, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'infoBACK' .. matches[3] } } } })
                                else
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].noLinkAvailable, true)
                                end
                            else
                                updated = true
                                savelog(matches[3], msg.from.print_name .. " [" .. msg.from.id .. "] requested group link [" .. data[tostring(matches[3])].settings.set_link .. "]")
                                editMessageText(msg.chat.id, msg.message_id, chat_name .. '\n' .. group_link, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'infoBACK' .. matches[3] } } } })
                            end
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                        end
                    elseif matches[2] == 'NEWLINK' then
                        if is_mod2(msg.from.id, matches[3]) then
                            mystat('###cbinfo' .. matches[2] .. matches[3])
                            local chat_name = ''
                            if data[tostring(matches[3])] then
                                chat_name = data[tostring(matches[3])].set_name or ''
                            end
                            local link = exportChatInviteLink(matches[3])
                            if link then
                                updated = true
                                data[tostring(matches[3])]['settings']['set_link'] = link
                                save_data(config.moderation.data, data)
                                savelog(matches[3], msg.from.print_name .. " [" .. msg.from.id .. "] created group link [" .. data[tostring(matches[3])].settings.set_link .. "]")
                                editMessageText(msg.chat.id, msg.message_id, chat_name .. '\n' .. link, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'infoBACK' .. matches[3] } } } })
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].sendMeLink, true)
                            end
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                        end
                    elseif matches[2] == 'WHITELIST' then
                        if is_owner2(msg.from.id, matches[4]) then
                            mystat('###cbinfo' .. matches[2] .. matches[3] .. matches[4])
                            local text = whitelist_user(id_to_cli(matches[4]), matches[3], msg.lang)
                            answerCallbackQuery(msg.cb_id, text, false)
                            sendMessage(matches[4], text)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                        end
                    elseif matches[2] == 'GBANWHITELIST' then
                        if is_owner2(msg.from.id, matches[4]) then
                            mystat('###cbinfo' .. matches[2] .. matches[3] .. matches[4])
                            local text = whitegban_user(id_to_cli(matches[4]), matches[3], msg.lang)
                            answerCallbackQuery(msg.cb_id, text, false)
                            sendMessage(matches[4], text)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                        end
                    elseif matches[2] == 'MUTEUSER' then
                        if is_mod2(msg.from.id, matches[4]) then
                            mystat('###cbinfo' .. matches[2] .. matches[3] .. matches[4])
                            if compare_ranks(msg.from.id, matches[3], matches[4]) then
                                if isMutedUser(matches[4], matches[3]) then
                                    local text = unmuteUser(matches[4], matches[3], msg.lang)
                                    answerCallbackQuery(msg.cb_id, text, false)
                                    sendMessage(matches[4], text .. '\n#executer' .. msg.from.id)
                                else
                                    local text = muteUser(matches[4], matches[3], msg.lang)
                                    answerCallbackQuery(msg.cb_id, text, false)
                                    sendMessage(matches[4], text .. '\n#executer' .. msg.from.id)
                                end
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].require_rank, false)
                            end
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                        end
                    elseif matches[2] == 'WARNSMINUS' or matches[2] == 'WARNSPLUS' then
                        if is_mod2(msg.from.id, matches[4]) then
                            mystat('###cbinfo' .. matches[2] .. matches[3] .. matches[4])
                            if matches[2] == 'WARNSMINUS' then
                                local text = unwarnUser(msg.from.id, matches[3], matches[4], '#executer' .. msg.from.id)
                                answerCallbackQuery(msg.cb_id, text, false)
                                sendMessage(matches[4], text)
                            elseif matches[2] == 'WARNSPLUS' then
                                local text = warnUser(msg.from.id, matches[3], matches[4], '#executer' .. msg.from.id)
                                answerCallbackQuery(msg.cb_id, text, false)
                                sendMessage(matches[4], text)
                            end
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                        end
                    elseif matches[2] == 'BAN' then
                        if is_mod2(msg.from.id, matches[4]) then
                            mystat('###cbinfo' .. matches[2] .. matches[3] .. matches[4])
                            local text = banUser(msg.from.id, matches[3], matches[4], '#executer' .. msg.from.id)
                            answerCallbackQuery(msg.cb_id, text, false)
                            sendMessage(matches[4], text)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                        end
                    elseif matches[2] == 'UNBAN' then
                        if is_mod2(msg.from.id, matches[4]) then
                            mystat('###cbinfo' .. matches[2] .. matches[3] .. matches[4])
                            local text = unbanUser(msg.from.id, matches[3], matches[4], '#executer' .. msg.from.id)
                            answerCallbackQuery(msg.cb_id, text, false)
                            sendMessage(matches[4], text)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                        end
                    elseif matches[2] == 'GBAN' then
                        if is_admin2(msg.from.id) then
                            mystat('###cbinfo' .. matches[2] .. matches[3] .. matches[4])
                            local text = gbanUser(matches[3], msg.lang)
                            answerCallbackQuery(msg.cb_id, text, false)
                            sendMessage(matches[4], text)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_admin, true)
                        end
                    elseif matches[2] == 'UNGBAN' then
                        if is_admin2(msg.from.id) then
                            mystat('###cbinfo' .. matches[2] .. matches[3] .. matches[4])
                            local text = ungbanUser(matches[3], msg.lang)
                            answerCallbackQuery(msg.cb_id, text, false)
                            sendMessage(matches[4], text)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_admin, true)
                        end
                    elseif matches[2] == 'PMBLOCK' then
                        if is_admin2(msg.from.id) then
                            mystat('###cbinfo' .. matches[2] .. matches[3] .. matches[4])
                            local text = blockUser(matches[3], msg.lang)
                            answerCallbackQuery(msg.cb_id, text, false)
                            sendMessage(matches[4], text)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_admin, true)
                        end
                    elseif matches[2] == 'PMUNBLOCK' then
                        if is_admin2(msg.from.id) then
                            mystat('###cbinfo' .. matches[2] .. matches[3] .. matches[4])
                            local text = unblockUser(matches[3], msg.lang)
                            answerCallbackQuery(msg.cb_id, text, false)
                            sendMessage(matches[4], text)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].require_admin, true)
                        end
                    end
                    if not updated then
                        updated = true
                        local tab = get_object_info_keyboard(msg.from.id, getChat(matches[3]), matches[4] or matches[3])
                        if tab then
                            editMessageText(msg.chat.id, msg.message_id, tab.text, tab.keyboard)
                        else
                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].noObject)
                        end
                    end
                end
                return
            end
        end
    end
    if matches[1]:lower() == 'id' then
        mystat('/id')
        if msg.reply then
            if matches[2] then
                if matches[2]:lower() == 'from' then
                    if msg.reply_to_message.forward then
                        if msg.reply_to_message.forward_from then
                            return msg.reply_to_message.forward_from.id
                        else
                            return msg.reply_to_message.forward_from_chat.id
                        end
                    else
                        return langs[msg.lang].errorNoForward
                    end
                else
                    return msg.reply_to_message.from.id
                end
            else
                if msg.reply_to_message.service then
                    if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                        local text = msg.reply_to_message.adder.id .. '\n'
                        for k, v in pairs(msg.reply_to_message.added) do
                            text = text .. v.id .. '\n'
                        end
                        return text
                    elseif msg.reply_to_message.service_type == 'chat_add_user_link' then
                        return msg.reply_to_message.from.id
                    elseif msg.reply_to_message.service_type == 'chat_del_user' then
                        return msg.reply_to_message.remover.id .. '\n' .. msg.reply_to_message.removed.id
                    elseif msg.reply_to_message.service_type == 'chat_del_user_leave' then
                        return msg.reply_to_message.removed.id
                    else
                        return msg.reply_to_message.from.id
                    end
                else
                    return msg.reply_to_message.from.id
                end
            end
        elseif matches[2] and matches[2] ~= '' then
            if msg.entities then
                for k, v in pairs(msg.entities) do
                    -- check if there's a text_mention
                    if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                        if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                            return msg.entities[k].user.id
                        end
                    end
                end
            end
            local obj = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
            if obj then
                return obj.id
            else
                return langs[msg.lang].noObject
            end
        else
            return msg.from.id .. '\n' .. msg.chat.id
        end
    end
    if matches[1]:lower() == 'username' then
        mystat('/username')
        if msg.reply then
            if matches[2] then
                if matches[2]:lower() == 'from' then
                    if msg.reply_to_message.forward then
                        if msg.reply_to_message.forward_from then
                            return msg.reply_to_message.forward_from.username or('NOUSER ' .. msg.reply_to_message.forward_from.first_name .. ' ' ..(msg.reply_to_message.forward_from.last_name or ''))
                        else
                            return msg.reply_to_message.forward_from_chat.username or 'NOUSER ' .. msg.reply_to_message.forward_from_chat.title
                        end
                    else
                        return langs[msg.lang].errorNoForward
                    end
                else
                    return msg.reply_to_message.from.username or('NOUSER ' .. msg.reply_to_message.from.first_name .. ' ' ..(msg.reply_to_message.from.last_name or ''))
                end
            else
                if msg.reply_to_message.service then
                    if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                        local text =(msg.reply_to_message.adder.username or('NOUSER ' .. msg.reply_to_message.adder.first_name .. ' ' ..(msg.reply_to_message.adder.last_name or ''))) .. '\n'
                        for k, v in pairs(msg.reply_to_message.added) do
                            text = text ..(v.username or('NOUSER ' .. v.first_name .. ' ' ..(v.last_name or ''))) .. '\n'
                        end
                        return text
                    elseif msg.reply_to_message.service_type == 'chat_add_user_link' then
                        return msg.reply_to_message.from.username or('NOUSER ' .. msg.reply_to_message.from.first_name .. ' ' ..(msg.reply_to_message.from.last_name or ''))
                    elseif msg.reply_to_message.service_type == 'chat_del_user' then
                        return(msg.reply_to_message.remover.username or('NOUSER ' .. msg.reply_to_message.remover.first_name .. ' ' ..(msg.reply_to_message.remover.last_name or ''))) .. '\n' ..(msg.reply_to_message.removed.username or('NOUSER ' .. msg.reply_to_message.removed.first_name .. ' ' ..(msg.reply_to_message.removed.last_name or '')))
                    elseif msg.reply_to_message.service_type == 'chat_del_user_leave' then
                        return msg.reply_to_message.removed.username or('NOUSER ' .. msg.reply_to_message.remover.first_name .. ' ' ..(msg.reply_to_message.remover.last_name or ''))
                    else
                        return msg.reply_to_message.from.username or('NOUSER ' .. msg.reply_to_message.from.first_name .. ' ' ..(msg.reply_to_message.from.last_name or ''))
                    end
                else
                    return msg.reply_to_message.from.username or('NOUSER ' .. msg.reply_to_message.from.first_name .. ' ' ..(msg.reply_to_message.from.last_name or ''))
                end
            end
        elseif matches[2] and matches[2] ~= '' then
            if msg.entities then
                for k, v in pairs(msg.entities) do
                    -- check if there's a text_mention
                    if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                        if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                            return msg.entities[k].user.username or('NOUSER ' .. msg.entities[k].user.first_name .. ' ' ..(msg.entities[k].user.last_name or ''))
                        end
                    end
                end
            end
            local obj = getChat(matches[2])
            if obj then
                return obj.username or('NOUSER ' ..(obj.first_name or obj.title) .. ' ' ..(obj.last_name or ''))
            else
                return langs[msg.lang].noObject
            end
        else
            return(msg.from.username or('NOUSER ' .. msg.from.first_name .. ' ' ..(msg.from.last_name or ''))) .. '\n' ..(msg.chat.username or('NOUSER ' .. msg.chat.title))
        end
    end
    if matches[1]:lower() == 'getrank' then
        mystat('/getrank')
        if msg.reply then
            if matches[2] then
                if matches[2]:lower() == 'from' then
                    if msg.reply_to_message.forward then
                        if msg.reply_to_message.forward_from then
                            return get_reverse_rank(msg.chat.id, msg.reply_to_message.forward_from.id, true)
                        else
                            return langs[msg.lang].cantDoThisToChat
                        end
                    else
                        return langs[msg.lang].errorNoForward
                    end
                else
                    return get_reverse_rank(msg.chat.id, msg.reply_to_message.from.id, true)
                end
            else
                return get_reverse_rank(msg.chat.id, msg.reply_to_message.from.id, true)
            end
        elseif matches[2] and matches[2] ~= '' then
            if msg.entities then
                for k, v in pairs(msg.entities) do
                    -- check if there's a text_mention
                    if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                        if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                            return get_reverse_rank(msg.chat.id, msg.entities[k].user.id, true)
                        end
                    end
                end
            end
            if string.match(matches[2], '^%d+$') then
                return get_reverse_rank(msg.chat.id, matches[2], true)
            else
                local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                if obj_user then
                    if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                        return get_reverse_rank(msg.chat.id, obj_user.id, true)
                    end
                else
                    return langs[msg.lang].noObject
                end
            end
        else
            return get_reverse_rank(msg.chat.id, msg.from.id, true)
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
        elseif matches[2] and matches[2] ~= '' then
            if msg.entities then
                for k, v in pairs(msg.entities) do
                    -- check if there's a text_mention
                    if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                        if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                            return is_here(msg.chat.id, msg.entities[k].user.id)
                        end
                    end
                end
            end
            if string.match(matches[2], '^%d+$') then
                return is_here(msg.chat.id, tonumber(matches[2]))
            else
                local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                if obj_user then
                    if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                        return is_here(msg.chat.id, obj_user.id)
                    end
                else
                    return langs[msg.lang].noObject
                end
            end
        end
    end
    if matches[1]:lower() == 'info' then
        mystat('/info')
        if msg.reply then
            if msg.from.is_mod then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                local tab = get_object_info_keyboard(msg.from.id, msg.reply_to_message.forward_from, msg.chat.id)
                                if tab then
                                    if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendInfoPvt).result.message_id
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                    end
                                else
                                    return langs[msg.lang].noObject
                                end
                            else
                                local tab = get_object_info_keyboard(msg.from.id, msg.reply_to_message.forward_from_chat, msg.chat.id)
                                if tab then
                                    if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendInfoPvt).result.message_id
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                    end
                                else
                                    return langs[msg.lang].noObject
                                end
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    end
                else
                    if msg.reply_to_message.service then
                        if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                            local text = ''
                            local tab = get_object_info_keyboard(msg.from.id, msg.reply_to_message.adder, msg.chat.id)
                            if tab then
                                if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                                    if msg.chat.type ~= 'private' then
                                        text = text .. langs[msg.lang].sendInfoPvt .. '\n'
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                end
                            else
                                text = text .. langs[msg.lang].noObject .. '\n'
                            end
                            local keyboard_sent = false
                            for k, v in pairs(msg.reply_to_message.added) do
                                local tab = get_object_info_keyboard(msg.from.id, v, msg.chat.id)
                                if tab then
                                    if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                                        if msg.chat.type ~= 'private' then
                                            text = text .. langs[msg.lang].sendInfoPvt .. '\n'
                                        end
                                    else
                                        keyboard_sent = true
                                        if not keyboard_sent then
                                            sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                        end
                                    end
                                else
                                    text = text .. langs[msg.lang].noObject .. '\n'
                                end
                            end
                            return text
                        elseif msg.reply_to_message.service_type == 'chat_add_user_link' then
                            local tab = get_object_info_keyboard(msg.from.id, msg.reply_to_message.from, msg.chat.id)
                            if tab then
                                if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = sendReply(msg, langs[msg.lang].sendInfoPvt).result.message_id
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        elseif msg.reply_to_message.service_type == 'chat_del_user' then
                            local tab = get_object_info_keyboard(msg.from.id, msg.reply_to_message.remover, msg.chat.id)
                            if tab then
                                if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = sendReply(msg, langs[msg.lang].sendInfoPvt).result.message_id
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                            local tab = get_object_info_keyboard(msg.from.id, msg.reply_to_message.removed, msg.chat.id)
                            if tab then
                                if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = sendReply(msg, langs[msg.lang].sendInfoPvt).result.message_id
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        elseif msg.reply_to_message.service_type == 'chat_del_user_leave' then
                            local tab = get_object_info_keyboard(msg.from.id, msg.reply_to_message.removed, msg.chat.id)
                            if tab then
                                if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = sendReply(msg, langs[msg.lang].sendInfoPvt).result.message_id
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        else
                            local tab = get_object_info_keyboard(msg.from.id, msg.reply_to_message.from, msg.chat.id)
                            if tab then
                                if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = sendReply(msg, langs[msg.lang].sendInfoPvt).result.message_id
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local tab = get_object_info_keyboard(msg.from.id, msg.reply_to_message.from, msg.chat.id)
                        if tab then
                            if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                                if msg.chat.type ~= 'private' then
                                    local message_id = sendReply(msg, langs[msg.lang].sendInfoPvt).result.message_id
                                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                    return
                                end
                            else
                                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
            else
                return langs[msg.lang].require_mod
            end
        elseif matches[2] and matches[2] ~= '' then
            if msg.from.is_mod then
                if msg.entities then
                    for k, v in pairs(msg.entities) do
                        -- check if there's a text_mention
                        if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                            if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                local tab = get_object_info_keyboard(msg.from.id, msg.entities[k].user, msg.chat.id)
                                if tab then
                                    if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendInfoPvt).result.message_id
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                    end
                                else
                                    return langs[msg.lang].noObject
                                end
                            end
                        end
                    end
                end
                if string.match(matches[2], '^%-?%d+$') then
                    local tab = get_object_info_keyboard(msg.from.id, getChat(matches[2]), msg.chat.id)
                    if tab then
                        if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                            if msg.chat.type ~= 'private' then
                                local message_id = sendReply(msg, langs[msg.lang].sendInfoPvt).result.message_id
                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                return
                            end
                        else
                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                        end
                    else
                        return langs[msg.lang].noObject
                    end
                else
                    local tab = get_object_info_keyboard(msg.from.id, getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or '')), msg.chat.id)
                    if tab then
                        if sendKeyboard(msg.from.id, tab.text, tab.keyboard) then
                            if msg.chat.type ~= 'private' then
                                local message_id = sendReply(msg, langs[msg.lang].sendInfoPvt).result.message_id
                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                return
                            end
                        else
                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                        end
                    else
                        return langs[msg.lang].noObject
                    end
                end
            else
                return langs[msg.lang].require_mod
            end
        else
            return get_object_info(msg.from, msg.chat.id) .. '\n\n' .. get_object_info(msg.bot or msg.chat, msg.chat.id)
        end
        return
    end
    if matches[1]:lower() == 'textualinfo' then
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
                        if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                            local text = get_object_info(msg.reply_to_message.adder, msg.chat.id) .. '\n'
                            for k, v in pairs(msg.reply_to_message.added) do
                                text = text .. get_object_info(v, msg.chat.id) .. '\n'
                            end
                            return text
                        elseif msg.reply_to_message.service_type == 'chat_add_user_link' then
                            return get_object_info(msg.reply_to_message.from, msg.chat.id)
                        elseif msg.reply_to_message.service_type == 'chat_del_user' then
                            return get_object_info(msg.reply_to_message.remover, msg.chat.id) .. '\n\n' .. get_object_info(msg.reply_to_message.removed, msg.chat.id)
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
        elseif matches[2] and matches[2] ~= '' then
            if msg.from.is_mod then
                if msg.entities then
                    for k, v in pairs(msg.entities) do
                        -- check if there's a text_mention
                        if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                            if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                return get_object_info(msg.entities[k].user, msg.chat.id)
                            end
                        end
                    end
                end
                if string.match(matches[2], '^%-?%d+$') then
                    return get_object_info(getChat(matches[2]), msg.chat.id)
                else
                    return get_object_info(getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or '')), msg.chat.id)
                end
            else
                return langs[msg.lang].require_mod
            end
        else
            return get_object_info(msg.from, msg.chat.id) .. '\n\n' .. get_object_info(msg.bot or msg.chat, msg.chat.id)
        end
        return
    end
    --[[if matches[1]:lower() == 'who' or matches[1]:lower() == 'members' then
        if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
            if msg.from.is_mod then
                return langs[msg.lang].useAISasha
                mystat('/members')
                local participants = getChatParticipants(msg.chat.id)
                local text = langs[msg.lang].membersOf .. msg.chat.title .. ' ' .. msg.chat.id .. '\n'
                for k, v in pairsByKeys(participants) do
                    if v.user then
                        v = v.user
                        text = text ..(v.first_name or 'NONAME') ..(v.last_name or '') .. ' | @' ..(v.username or 'username') .. ' | ' .. v.id .. '\n'
                    end
                end
                -- remove rtl
                text = text:gsub("‮", "")
                return text
            else
                return langs[msg.lang].require_mod
            end
        end
    end]]
    if matches[1]:lower() == 'whoami' then
        mystat('/whoami')
        return get_object_info(msg.from, msg.chat.id)
    end
    if matches[1]:lower() == 'grouplink' and matches[2] then
        mystat('/grouplink')
        if is_admin(msg) then
            local group_link = data[tostring(matches[2])]['settings']['set_link']
            if not group_link then
                local link = exportChatInviteLink(matches[2])
                if link then
                    data[tostring(matches[2])]['settings']['set_link'] = link
                    save_data(config.moderation.data, data)
                    group_link = link
                else
                    return langs[msg.lang].noLinkAvailable
                end
            end
            local obj = getChat(matches[2])
            if type(obj) == 'table' then
                return obj.title .. '\n' .. group_link
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
        "^(###cbinfo)(DELETE)$",
        "^(###cbinfo)(DELETE)(%-%d+)$",
        "^(###cbinfo)(BACK)(%-%d+)$",
        "^(###cbinfo)(LINK)(%-%d+)$",
        "^(###cbinfo)(NEWLINK)(%-%d+)$",
        "^(###cbinfo)(DELETE)(%d+)(%-%d+)$",
        "^(###cbinfo)(BACK)(%-?%d+)(%-%d+)$",
        "^(###cbinfo)(WHITELIST)(%d+)(%-%d+)$",
        "^(###cbinfo)(GBANWHITELIST)(%d+)(%-%d+)$",
        "^(###cbinfo)(MUTEUSER)(%d+)(%-%d+)$",
        "^(###cbinfo)(WARNS)(%d+)(%-%d+)$",
        "^(###cbinfo)(WARNSMINUS)(%d+)(%-%d+)$",
        "^(###cbinfo)(WARNSPLUS)(%d+)(%-%d+)$",
        "^(###cbinfo)(UNBAN)(%d+)(%-%d+)$",
        "^(###cbinfo)(BAN)(%d+)(%-%d+)$",
        "^(###cbinfo)(UNGBAN)(%d+)(%-%d+)$",
        "^(###cbinfo)(GBAN)(%d+)(%-%d+)$",
        "^(###cbinfo)(PMUNBLOCK)(%d+)(%-%d+)$",
        "^(###cbinfo)(PMBLOCK)(%d+)(%-%d+)$",

        "^[#!/]([Ii][Dd])$",
        "^[#!/]([Ii][Dd]) ([^%s]+)$",
        "^[#!/]([Uu][Ss][Ee][Rr][Nn][Aa][Mm][Ee])$",
        "^[#!/]([Uu][Ss][Ee][Rr][Nn][Aa][Mm][Ee]) ([^%s]+)$",
        "^[#!/]([Gg][Rr][Oo][Uu][Pp][Ll][Ii][Nn][Kk]) (%-%d+)$",
        "^[#!/]([Ii][Ss][Hh][Ee][Rr][Ee])$",
        "^[#!/]([Ii][Ss][Hh][Ee][Rr][Ee]) ([^%s]+)$",
        "^[#!/]([Gg][Ee][Tt][Rr][Aa][Nn][Kk])$",
        "^[#!/]([Gg][Ee][Tt][Rr][Aa][Nn][Kk]) ([^%s]+)$",
        "^[#!/]([Ww][Hh][Oo][Aa][Mm][Ii])$",
        "^[#!/]([Ii][Nn][Ff][Oo])$",
        "^[#!/]([Ii][Nn][Ff][Oo]) ([^%s]+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ii][Nn][Ff][Oo])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ii][Nn][Ff][Oo]) ([^%s]+)$",
        -- "^[#!/]([Ww][Hh][Oo])$",
        -- who
        -- "^[#!/]([Mm][Ee][Mm][Bb][Ee][Rr][Ss])$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#id [<username>|<reply>|from]",
        "#username [<id>|<reply>|from]",
        "#getrank [<id>|<username>|<reply>|from]",
        "#whoami",
        "#[textual]info",
        "#ishere <id>|<username>|<reply>|from",
        "MOD",
        "#[textual]info <id>|<username>|<reply>|from",
        -- "(#who|#members)",
        "ADMIN",
        "#grouplink <group_id>",
    },
}