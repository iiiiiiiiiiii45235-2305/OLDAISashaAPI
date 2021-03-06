﻿local function is_here(chat_id, user_id)
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
    return langs[lang].rank .. reverse_rank_table[rank]
end

local function fixObjType(obj_type)
    if obj_type == 'private' or obj_type == 'user' or obj_type == 'bot' then
        -- private chat
        return "user"
    elseif obj_type == 'group' then
        -- group
        return "chat"
    elseif obj_type == 'supergroup' then
        -- supergroup
        return "chat"
    elseif obj_type == 'channel' then
        -- channel
        return "channel"
    end
    return "unknown"
end

local function get_object_info(obj, chat_id)
    local lang = get_lang(chat_id)
    if obj then
        local chat_name = ''
        if data[tostring(chat_id)] then
            chat_name = data[tostring(chat_id)].name or ''
        end
        local text = string.gsub(string.gsub(langs[lang].infoOf, 'Y', '(#chat' .. tostring(chat_id):gsub("-", "") .. ') ' .. chat_name), 'X', tostring('(#' .. fixObjType(obj.type) .. tostring(obj.id):gsub("-", "") .. ') ' ..(obj.first_name or obj.title) .. ' ' ..(obj.last_name or '')))
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
                if isWhitelisted(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'WHITELISTED '
                end
                if isWhitelistedGban(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'WHITELISTEDGBAN '
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
                    otherinfo = otherinfo .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. '/' ..(data[tostring(chat_id)].settings.max_warns or 0) .. ' WARN '
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
            local nickname = redis_hget_something('tagalert:nicknames', obj.id)
            if nickname then
                text = text .. langs[lang].nickname .. nickname
            end
            local msgs = tonumber(redis_get_something('msgs:' .. obj.id .. ':' .. chat_id) or 0)
            text = text .. langs[lang].rank .. reverse_rank_table[get_rank(obj.id, chat_id, true)] ..
            langs[lang].date .. os.date('%c') ..
            langs[lang].totalMessages .. msgs
            local pmnotices = redis_get_something('notice:' .. obj.id)
            if pmnotices then
                text = text .. langs[lang].pmnoticesRegistration .. 'true'
            else
                text = text .. langs[lang].pmnoticesRegistration .. 'false'
            end
            local tagalert = redis_hget_something('tagalert:usernames', obj.id)
            if tagalert then
                text = text .. langs[lang].tagalertRegistration .. 'true'
            else
                text = text .. langs[lang].tagalertRegistration .. 'false'
            end
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
                if isWhitelisted(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'WHITELISTED '
                end
                if isWhitelistedGban(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'WHITELISTEDGBAN '
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
                    otherinfo = otherinfo .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. '/' ..(data[tostring(chat_id)].settings.max_warns or 0) .. ' WARN '
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
            local groupnotices = data[tostring(obj.id)].settings.groupnotices
            if groupnotices then
                text = text .. langs[lang].groupnoticesRegistration .. 'true'
            else
                text = text .. langs[lang].groupnoticesRegistration .. 'false'
            end
            local pmnotices = data[tostring(obj.id)].settings.pmnotices
            if pmnotices then
                text = text .. langs[lang].pmnoticesRegistration .. 'true'
            else
                text = text .. langs[lang].pmnoticesRegistration .. 'false'
            end
            local tagalert = data[tostring(obj.id)].settings.tagalert
            if tagalert then
                text = text .. langs[lang].tagalertRegistration .. 'true'
            else
                text = text .. langs[lang].tagalertRegistration .. 'false'
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
            local groupnotices = data[tostring(obj.id)].settings.groupnotices
            if groupnotices then
                text = text .. langs[lang].groupnoticesRegistration .. 'true'
            else
                text = text .. langs[lang].groupnoticesRegistration .. 'false'
            end
            local pmnotices = data[tostring(obj.id)].settings.pmnotices
            if pmnotices then
                text = text .. langs[lang].pmnoticesRegistration .. 'true'
            else
                text = text .. langs[lang].pmnoticesRegistration .. 'false'
            end
            local tagalert = data[tostring(obj.id)].settings.tagalert
            if tagalert then
                text = text .. langs[lang].tagalertRegistration .. 'true'
            else
                text = text .. langs[lang].tagalertRegistration .. 'false'
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

local function promoteMod(chat_id, user)
    local lang = get_lang(chat_id)
    if data[tostring(chat_id)].moderators[tostring(user.id)] then
        return(user.username or user.print_name or user.first_name) .. langs[lang].alreadyMod
    end
    data[tostring(chat_id)].moderators[tostring(user.id)] =(user.username or user.print_name or user.first_name)
    save_data(config.moderation.data, data)
    if arePMNoticesEnabled(user.id, chat_id) then
        sendMessage(user.id, langs[get_lang(user.id)].youHaveBeenPromotedMod .. database[tostring(chat_id)].print_name)
    end
    return(user.username or user.print_name or user.first_name) .. langs[lang].promoteMod
end

local function demoteMod(chat_id, user)
    local lang = get_lang(chat_id)
    if not data[tostring(chat_id)].moderators[tostring(user.id)] then
        return(user.username or user.print_name or user.first_name) .. langs[lang].notMod
    end
    data[tostring(chat_id)].moderators[tostring(user.id)] = nil
    save_data(config.moderation.data, data)
    if arePMNoticesEnabled(user.id, chat_id) then
        sendMessage(user.id, langs[get_lang(user.id)].youHaveBeenDemotedMod .. database[tostring(chat_id)].print_name)
    end
    return(user.username or user.print_name or user.first_name) .. langs[lang].demoteMod
end

local function run(msg, matches)
    if msg.cb then
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
            local deeper = nil
            if matches[2] == 'BACK' then
                answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                local obj = getChat(matches[3])
                editMessageText(msg.chat.id, msg.message_id, get_object_info(obj, matches[4] or matches[3]), get_object_info_keyboard(msg.from.id, obj, matches[4] or matches[3]))
                updated = true
            elseif matches[2] == 'ADMINCOMMANDS' then
                if is_admin(msg) then
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                    local obj = getChat(matches[3])
                    editMessageText(msg.chat.id, msg.message_id, get_object_info(obj, matches[4] or matches[3]), get_object_info_keyboard(msg.from.id, obj, matches[4] or matches[3], matches[2]))
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                    updated = true
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_admin, true)
                end
            elseif matches[2] == 'PROMOTIONS' then
                if is_mod2(msg.from.id, matches[4]) then
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                    local obj = getChat(matches[3])
                    editMessageText(msg.chat.id, msg.message_id, get_object_info(obj, matches[4] or matches[3]), get_object_info_keyboard(msg.from.id, obj, matches[4] or matches[3], matches[2]))
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                    updated = true
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                end
            elseif matches[2] == 'PUNISHMENTS' then
                if is_mod2(msg.from.id, matches[4]) then
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                    local obj = getChat(matches[3])
                    editMessageText(msg.chat.id, msg.message_id, get_object_info(obj, matches[4] or matches[3]), get_object_info_keyboard(msg.from.id, obj, matches[4] or matches[3], matches[2]))
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                    updated = true
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                end
            elseif matches[2] == 'LINK' then
                if is_mod2(msg.from.id, matches[3]) then
                    local chat_name = ''
                    if data[tostring(matches[3])] then
                        chat_name = data[tostring(matches[3])].name or ''
                    end
                    local group_link = data[tostring(matches[3])].link
                    if group_link then
                        savelog(matches[3], msg.from.print_name .. " [" .. msg.from.id .. "] requested group link [" .. data[tostring(matches[3])].link .. "]")
                        editMessageText(msg.chat.id, msg.message_id, "<a href=\"" .. group_link .. "\">" .. html_escape(chat_name) .. "</a>", { inline_keyboard = { { { text = langs[msg.lang].previousPage .. langs[msg.lang].infoPage, callback_data = 'infoBACK' .. matches[3] } } } }, 'html')
                        updated = true
                    else
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].noLinkAvailable, true)
                    end
                    mystat(matches[1] .. matches[2] .. matches[3])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                end
            elseif matches[2] == 'NEWLINK' then
                if is_mod2(msg.from.id, matches[3]) then
                    local chat_name = ''
                    if data[tostring(matches[3])] then
                        chat_name = data[tostring(matches[3])].name or ''
                    end
                    local link = exportChatInviteLink(matches[3], true)
                    if link then
                        data[tostring(matches[3])].link = link
                        save_data(config.moderation.data, data)
                        savelog(matches[3], msg.from.print_name .. " [" .. msg.from.id .. "] created group link [" .. data[tostring(matches[3])].link .. "]")
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].linkCreated .. "\n<a href=\"" .. link .. "\">" .. html_escape(chat_name) .. "</a>", { inline_keyboard = { { { text = langs[msg.lang].previousPage .. langs[msg.lang].infoPage, callback_data = 'infoBACK' .. matches[3] } } } }, 'html')
                        updated = true
                    else
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].sendMeLink, true)
                    end
                    mystat(matches[1] .. matches[2] .. matches[3])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                end
                --[[elseif matches[2] == 'FREE' then
                --'infoFREE' .. executer .. obj.id .. '$' .. chat_id
                if is_admin2(msg.from.id) then
                    local chat_name = ''
                    if data[tostring(matches[3])] then
                        chat_name = data[tostring(matches[3])].name or ''
                    end
                    local link = exportChatInviteLink(matches[3], true)
                    if link then
                        data[tostring(matches[3])].link = link
                        save_data(config.moderation.data, data)
                        savelog(matches[3], msg.from.print_name .. " [" .. msg.from.id .. "] created group link [" .. data[tostring(matches[3])].link .. "]")
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].linkCreated .. "\n<a href=\"" .. link .. "\">" .. html_escape(chat_name) .. "</a>", { inline_keyboard = { { { text = langs[msg.lang].previousPage .. langs[msg.lang].infoPage, callback_data = 'infoBACK' .. matches[3] } } } }, 'html')
                        updated = true
                    else
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].sendMeLink, true)
                    end
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] .. matches[5])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_admin, true)
                end]]
            elseif matches[2] == 'INVITE' then
                if is_mod2(msg.from.id, matches[4]) then
                    local inviter = nil
                    if msg.from.username then
                        inviter = '@' .. msg.from.username .. ' [' .. msg.from.id .. ']'
                    else
                        inviter = msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']'
                    end
                    local link = nil
                    local group_link = data[tostring(matches[4])].link
                    if group_link then
                        link = inviter .. langs[msg.lang].invitedYouTo .. " <a href=\"" .. group_link .. "\">" .. html_escape((data[tostring(matches[4])].name or '')) .. "</a>"
                    end
                    local text = ''
                    if link then
                        if not globalCronTable.invitedTable[tostring(msg.chat.id)][tostring(matches[3])] then
                            if not userInChat(matches[4], matches[3], true) then
                                if sendMessage(matches[3], link, 'html') then
                                    globalCronTable.invitedTable[tostring(msg.chat.id)][tostring(matches[3])] = true
                                    text = langs[msg.lang].ok
                                else
                                    text = langs[msg.lang].noObjectInvite
                                end
                            else
                                text = langs[msg.lang].userAlreadyInChat
                            end
                        else
                            text = langs[msg.lang].userAlreadyInvited
                        end
                    else
                        text = langs[msg.lang].noLinkAvailable
                    end
                    answerCallbackQuery(msg.cb_id, text, true)
                    deeper = 'PROMOTIONS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                end
            elseif matches[2] == 'WHITELIST' then
                if is_owner2(msg.from.id, matches[4]) then
                    local text = whitelist_user(matches[4], matches[3])
                    answerCallbackQuery(msg.cb_id, text, true)
                    sendMessage(matches[4], text)
                    deeper = 'PROMOTIONS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                end
            elseif matches[2] == 'WHITELISTGBAN' then
                if is_owner2(msg.from.id, matches[4]) then
                    local text = whitegban_user(matches[4], matches[3])
                    answerCallbackQuery(msg.cb_id, text, true)
                    sendMessage(matches[4], text)
                    deeper = 'PROMOTIONS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                end
            elseif matches[2] == 'PROMOTE' then
                if is_owner2(msg.from.id, matches[4]) then
                    answerCallbackQuery(msg.cb_id, promoteMod(matches[4], getChat(matches[3])), true)
                    deeper = 'PROMOTIONS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                end
            elseif matches[2] == 'DEMOTE' then
                if is_owner2(msg.from.id, matches[4]) then
                    answerCallbackQuery(msg.cb_id, demoteMod(matches[4], getChat(matches[3])), true)
                    deeper = 'PROMOTIONS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                end
            elseif matches[2] == 'MUTEUSER' then
                if is_mod2(msg.from.id, matches[4]) then
                    if compare_ranks(msg.from.id, matches[3], matches[4]) then
                        if isMutedUser(matches[4], matches[3]) then
                            local text = unmuteUser(matches[4], matches[3], msg.lang)
                            answerCallbackQuery(msg.cb_id, text, true)
                            sendMessage(matches[4], text .. '\n#executer' .. msg.from.id)
                        else
                            local text = muteUser(matches[4], matches[3], msg.lang)
                            answerCallbackQuery(msg.cb_id, text, true)
                            sendMessage(matches[4], text .. '\n#executer' .. msg.from.id)
                        end
                    else
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].require_rank, true)
                    end
                    deeper = 'PUNISHMENTS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                end
            elseif matches[2] == 'WARNS--' or matches[2] == 'WARNS++' then
                if is_mod2(msg.from.id, matches[4]) then
                    if matches[2] == 'WARNS--' then
                        local text = unwarnUser(msg.from.id, matches[3], matches[4], '#executer' .. msg.from.id)
                        answerCallbackQuery(msg.cb_id, text, true)
                        sendMessage(matches[4], text)
                    elseif matches[2] == 'WARNS++' then
                        local text = warnUser(msg.from.id, matches[3], matches[4], '#executer' .. msg.from.id)
                        answerCallbackQuery(msg.cb_id, text, true)
                        sendMessage(matches[4], text)
                    end
                    deeper = 'PUNISHMENTS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                end
            elseif matches[2] == 'BAN' then
                if is_mod2(msg.from.id, matches[4]) then
                    local text = banUser(msg.from.id, matches[3], matches[4], '#executer' .. msg.from.id)
                    answerCallbackQuery(msg.cb_id, text, true)
                    sendMessage(matches[4], text)
                    deeper = 'PUNISHMENTS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                end
            elseif matches[2] == 'UNBAN' then
                if is_mod2(msg.from.id, matches[4]) then
                    local text = unbanUser(msg.from.id, matches[3], matches[4], '#executer' .. msg.from.id)
                    answerCallbackQuery(msg.cb_id, text, true)
                    sendMessage(matches[4], text)
                    deeper = 'PUNISHMENTS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_mod, true)
                end
            elseif matches[2] == 'GBAN' then
                if is_admin2(msg.from.id) then
                    answerCallbackQuery(msg.cb_id, gbanUser(matches[3]), true)
                    deeper = 'ADMINCOMMANDS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_admin, true)
                end
            elseif matches[2] == 'UNGBAN' then
                if is_admin2(msg.from.id) then
                    answerCallbackQuery(msg.cb_id, ungbanUser(matches[3]), true)
                    deeper = 'ADMINCOMMANDS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_admin, true)
                end
            elseif matches[2] == 'PMBLOCK' then
                if is_admin2(msg.from.id) then
                    answerCallbackQuery(msg.cb_id, blockUser(matches[3]), true)
                    deeper = 'ADMINCOMMANDS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_admin, true)
                end
            elseif matches[2] == 'PMUNBLOCK' then
                if is_admin2(msg.from.id) then
                    answerCallbackQuery(msg.cb_id, unblockUser(matches[3]), true)
                    deeper = 'ADMINCOMMANDS'
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_admin, true)
                end
            end
            if not updated then
                updated = true
                local obj = getChat(matches[3])
                if deeper then
                    editMessageText(msg.chat.id, msg.message_id, get_object_info(obj, matches[4] or matches[3]), get_object_info_keyboard(msg.from.id, obj, matches[4] or matches[3], deeper))
                else
                    editMessageText(msg.chat.id, msg.message_id, get_object_info(obj, matches[4] or matches[3]), get_object_info_keyboard(msg.from.id, obj, matches[4] or matches[3]))
                end
            end
        end
        return
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
            matches[2] = tostring(matches[2]):gsub(' ', '')
            if string.match(matches[2], '^%d+$') then
                return matches[2]
            else
                local obj = getChat(string.match(matches[2], '^[^%s]+') or '')
                if obj then
                    return obj.id
                else
                    return langs[msg.lang].noObject
                end
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
            matches[2] = tostring(matches[2]):gsub(' ', '')
            if string.match(matches[2], '^%d+$') then
                local obj = getChat(matches[2])
                if obj then
                    return obj.username or('NOUSER ' ..(obj.first_name or obj.title) .. ' ' ..(obj.last_name or ''))
                else
                    return langs[msg.lang].noObject
                end
            else
                return matches[2]
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
            matches[2] = tostring(matches[2]):gsub(' ', '')
            if string.match(matches[2], '^%d+$') then
                return get_reverse_rank(msg.chat.id, matches[2], true)
            else
                local obj_user = getChat(string.match(matches[2], '^[^%s]+') or '')
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
            matches[2] = tostring(matches[2]):gsub(' ', '')
            if string.match(matches[2], '^%d+$') then
                return is_here(msg.chat.id, tonumber(matches[2]))
            else
                local obj_user = getChat(string.match(matches[2], '^[^%s]+') or '')
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
    if matches[1]:lower() == 'trackuser' then
        if msg.from.is_mod then
            mystat('/trackuser')
            if msg.reply then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                local res = sendReply(msg, profileLink(msg.reply_to_message.forward_from.id, matches[2] or msg.reply_to_message.forward_from.first_name), 'html')
                                if not res then
                                    return langs[msg.lang].cantTrackUser
                                end
                            else
                                return langs[msg.lang].cantDoThisToChat
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    else
                        local res = sendReply(msg, profileLink(msg.reply_to_message.from.id, matches[2] or msg.reply_to_message.from.first_name), 'html')
                        if not res then
                            return langs[msg.lang].cantTrackUser
                        end
                    end
                else
                    local res = sendReply(msg, profileLink(msg.reply_to_message.from.id, matches[2] or msg.reply_to_message.from.first_name) .. "</a>", 'html')
                    if not res then
                        return langs[msg.lang].cantTrackUser
                    end
                end
            elseif matches[2] and matches[2] ~= '' then
                if msg.entities then
                    for k, v in pairs(msg.entities) do
                        -- check if there's a text_mention
                        if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                            if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                local res = sendReply(msg, profileLink(msg.entities[k].user.id, matches[3] or msg.entities[k].user.first_name), 'html')
                                if not res then
                                    return langs[msg.lang].cantTrackUser
                                end
                            end
                        end
                    end
                end
                matches[2] = tostring(matches[2]):gsub(' ', '')
                if string.match(matches[2], '^%d+$') then
                    local res = sendReply(msg, profileLink(matches[2], matches[3] or matches[2]), 'html')
                    if not res then
                        return langs[msg.lang].cantTrackUser
                    end
                else
                    local obj_user = getChat(string.match(matches[2], '^[^%s]+') or '')
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            local res = sendReply(msg, profileLink(obj_user.id, matches[3] or matches[2] or obj_user.id), 'html')
                            if not res then
                                return langs[msg.lang].cantTrackUser
                            end
                        end
                    else
                        return langs[msg.lang].noObject
                    end
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'info' then
        mystat('/info')
        if msg.chat.type == 'private' and matches[3] then
            if msg.reply then
                if is_mod2(msg.from.id, matches[3]) then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    local txt = get_object_info(msg.reply_to_message.forward_from, matches[3])
                                    if txt ~= langs[msg.lang].noObject then
                                        if not sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.reply_to_message.forward_from, matches[3])) then
                                            return langs[msg.lang].errorTryAgain
                                        end
                                    else
                                        return txt
                                    end
                                elseif msg.reply_to_message.forward_from_chat then
                                    local txt = get_object_info(msg.reply_to_message.forward_from_chat, matches[3])
                                    if txt ~= langs[msg.lang].noObject then
                                        if not sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.reply_to_message.forward_from_chat, matches[3])) then
                                            return langs[msg.lang].errorTryAgain
                                        end
                                    else
                                        return txt
                                    end
                                else
                                    return langs[msg.lang].errorNoForward
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    end
                else
                    return langs[msg.lang].require_mod
                end
            elseif matches[2] and matches[2] ~= '' then
                if is_mod2(msg.from.id, matches[3]) then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    local txt = get_object_info(msg.entities[k].user, matches[3])
                                    if txt ~= langs[msg.lang].noObject then
                                        if not sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.entities[k].user, matches[3])) then
                                            return langs[msg.lang].errorTryAgain
                                        end
                                    else
                                        return txt
                                    end
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%-?%d+$') then
                        local obj = getChat(matches[2])
                        local txt = get_object_info(obj, matches[3])
                        if txt ~= langs[msg.lang].noObject then
                            if not sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, obj, matches[3])) then
                                return langs[msg.lang].errorTryAgain
                            end
                        else
                            return txt
                        end
                    else
                        local obj = getChat(string.match(matches[2], '^[^%s]+') or '')
                        local txt = get_object_info(obj, matches[3])
                        if txt ~= langs[msg.lang].noObject then
                            if not sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, obj, matches[3])) then
                                return langs[msg.lang].errorTryAgain
                            end
                        else
                            return txt
                        end
                    end
                else
                    return langs[msg.lang].require_mod
                end
            end
        elseif msg.reply then
            if msg.from.is_mod then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                local txt = get_object_info(msg.reply_to_message.forward_from, msg.chat.id)
                                if txt ~= langs[msg.lang].noObject then
                                    if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.reply_to_message.forward_from, msg.chat.id)) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                    end
                                else
                                    local message_id = getMessageId(sendReply(msg, txt))
                                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                    return
                                end
                            elseif msg.reply_to_message.forward_from_chat then
                                local txt = get_object_info(msg.reply_to_message.forward_from_chat, msg.chat.id)
                                if txt ~= langs[msg.lang].noObject then
                                    if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.reply_to_message.forward_from_chat, msg.chat.id)) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                    end
                                else
                                    local message_id = getMessageId(sendReply(msg, txt))
                                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                    return
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    end
                else
                    if msg.reply_to_message.service then
                        if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                            local text = ''
                            local txt = get_object_info(msg.reply_to_message.adder, msg.chat.id)
                            if txt ~= langs[msg.lang].noObject then
                                if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.reply_to_message.adder, msg.chat.id)) then
                                    if msg.chat.type ~= 'private' then
                                        text = text .. langs[msg.lang].sendInfoPvt .. '\n'
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                end
                            else
                                text = text .. txt .. '\n'
                            end
                            for k, v in pairs(msg.reply_to_message.added) do
                                local txt = get_object_info(v, msg.chat.id)
                                if txt ~= langs[msg.lang].noObject then
                                    if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, v, msg.chat.id)) then
                                        if msg.chat.type ~= 'private' then
                                            text = text .. langs[msg.lang].sendInfoPvt .. '\n'
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                    end
                                else
                                    text = text .. txt .. '\n'
                                end
                            end
                            local message_id = getMessageId(sendReply(msg, text, 'html'))
                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                            return
                        elseif msg.reply_to_message.service_type == 'chat_add_user_link' then
                            local txt = get_object_info(msg.reply_to_message.from, msg.chat.id)
                            if txt ~= langs[msg.lang].noObject then
                                if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.reply_to_message.from, msg.chat.id)) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                end
                            else
                                local message_id = getMessageId(sendReply(msg, txt))
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                return
                            end
                        elseif msg.reply_to_message.service_type == 'chat_del_user' then
                            local txt = get_object_info(msg.reply_to_message.remover, msg.chat.id)
                            if txt ~= langs[msg.lang].noObject then
                                if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.reply_to_message.remover, msg.chat.id)) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                end
                            else
                                local message_id = getMessageId(sendReply(msg, txt))
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                return
                            end
                            local txt = get_object_info(msg.reply_to_message.removed, msg.chat.id)
                            if txt ~= langs[msg.lang].noObject then
                                if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.reply_to_message.removed, msg.chat.id)) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                end
                            else
                                local message_id = getMessageId(sendReply(msg, txt))
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                return
                            end
                        elseif msg.reply_to_message.service_type == 'chat_del_user_leave' then
                            local txt = get_object_info(msg.reply_to_message.removed, msg.chat.id)
                            if txt ~= langs[msg.lang].noObject then
                                if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.reply_to_message.removed, msg.chat.id)) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                end
                            else
                                local message_id = getMessageId(sendReply(msg, txt))
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                return
                            end
                        else
                            local txt = get_object_info(msg.reply_to_message.from, msg.chat.id)
                            if txt ~= langs[msg.lang].noObject then
                                if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.reply_to_message.from, msg.chat.id)) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                end
                            else
                                local message_id = getMessageId(sendReply(msg, txt))
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                return
                            end
                        end
                    else
                        local txt = get_object_info(msg.reply_to_message.from, msg.chat.id)
                        if txt ~= langs[msg.lang].noObject then
                            if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.reply_to_message.from, msg.chat.id)) then
                                if msg.chat.type ~= 'private' then
                                    local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                    return
                                end
                            else
                                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                            end
                        else
                            local message_id = getMessageId(sendReply(msg, txt))
                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                            return
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
                                local txt = get_object_info(msg.entities[k].user, msg.chat.id)
                                if txt ~= langs[msg.lang].noObject then
                                    if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, msg.entities[k].user, msg.chat.id)) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                    end
                                else
                                    local message_id = getMessageId(sendReply(msg, txt))
                                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                    return
                                end
                            end
                        end
                    end
                end
                if string.match(matches[2], '^%-?%d+$') then
                    local obj = getChat(matches[2])
                    local txt = get_object_info(obj, msg.chat.id)
                    if txt ~= langs[msg.lang].noObject then
                        if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, obj, msg.chat.id)) then
                            if msg.chat.type ~= 'private' then
                                local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                return
                            end
                        else
                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                        end
                    else
                        local message_id = getMessageId(sendReply(msg, txt))
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                        return
                    end
                else
                    local obj = getChat(string.match(matches[2], '^[^%s]+') or '')
                    local txt = get_object_info(obj, msg.chat.id)
                    if txt ~= langs[msg.lang].noObject then
                        if sendKeyboard(msg.from.id, txt, get_object_info_keyboard(msg.from.id, obj, msg.chat.id)) then
                            if msg.chat.type ~= 'private' then
                                local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                                return
                            end
                        else
                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                        end
                    else
                        local message_id = getMessageId(sendReply(msg, txt))
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                        return
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
        if msg.chat.type == 'private' and matches[3] then
            if msg.reply then
                if is_mod2(msg.from.id, matches[3]) then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return get_object_info(msg.reply_to_message.forward_from, matches[3])
                                elseif msg.reply_to_message.forward_from_chat then
                                    return get_object_info(msg.reply_to_message.forward_from_chat, matches[3])
                                else
                                    return langs[msg.lang].errorNoForward
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    end
                else
                    return langs[msg.lang].require_mod
                end
            elseif matches[2] and matches[2] ~= '' then
                if is_mod2(msg.from.id, matches[3]) then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return get_object_info(msg.entities[k].user, matches[3])
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%-?%d+$') then
                        local obj = getChat(matches[2])
                        return get_object_info(obj, matches[3])
                    else
                        local obj = getChat(string.match(matches[2], '^[^%s]+') or '')
                        return get_object_info(obj, matches[3])
                    end
                else
                    return langs[msg.lang].require_mod
                end
            end
        elseif msg.reply then
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
                    return get_object_info(getChat(string.match(matches[2], '^[^%s]+') or ''), msg.chat.id)
                end
            else
                return langs[msg.lang].require_mod
            end
        else
            return get_object_info(msg.from, msg.chat.id) .. '\n\n' .. get_object_info(msg.bot or msg.chat, msg.chat.id)
        end
        return
    end
    if matches[1]:lower() == 'groupinfo' then
        mystat('/groupinfo')
        if msg.from.is_mod then
            local txt = get_object_info(msg.chat, msg.chat.id)
            if txt ~= langs[msg.lang].noObject then
                if sendKeyboard(msg.from.id, get_object_info(msg.chat, msg.chat.id), get_object_info_keyboard(msg.from.id, msg.chat, msg.chat.id)) then
                    if msg.chat.type ~= 'private' then
                        local message_id = getMessageId(sendReply(msg, langs[msg.lang].sendInfoPvt, 'html'))
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
            else
                local message_id = getMessageId(sendReply(msg, txt))
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' ..(message_id or '') .. '"')
                return
            end
        else
            return get_object_info(msg.bot or msg.chat, msg.chat.id)
        end
    end
    if matches[1]:lower() == 'textualgroupinfo' then
        mystat('/groupinfo')
        return get_object_info(msg.bot or msg.chat, msg.chat.id)
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
            local group_link = data[tostring(matches[2])].link
            if not group_link then
                local link = exportChatInviteLink(matches[2], true)
                if link then
                    data[tostring(matches[2])].link = link
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
        "^(###cbinfo)(DELETE)(%-?%d+)%$(%-?%d+)$",
        "^(###cbinfo)(LINK)(%-%d+)$",
        "^(###cbinfo)(NEWLINK)(%-%d+)$",
        "^(###cbinfo)(DELETE)(%d+)(%-%d+)$",
        "^(###cbinfo)(BACK)(%-?%d+)%$(%-?%d+)$",
        "^(###cbinfo)(INVITE)(%d+)(%-%d+)$",
        "^(###cbinfo)(WHITELIST)(%d+)(%-%d+)$",
        "^(###cbinfo)(WHITELISTGBAN)(%d+)(%-%d+)$",
        "^(###cbinfo)(MUTEUSER)(%d+)(%-%d+)$",
        "^(###cbinfo)(WARNS)(%d+)(%-%d+)$",
        "^(###cbinfo)(WARNS%-%-)(%d+)(%-%d+)$",
        "^(###cbinfo)(WARNS%+%+)(%d+)(%-%d+)$",
        "^(###cbinfo)(UNBAN)(%d+)(%-%d+)$",
        "^(###cbinfo)(BAN)(%d+)(%-%d+)$",
        "^(###cbinfo)(UNGBAN)(%d+)%$(%-?%d+)$",
        "^(###cbinfo)(GBAN)(%d+)%$(%-?%d+)$",
        "^(###cbinfo)(PMUNBLOCK)(%d+)%$(%-?%d+)$",
        "^(###cbinfo)(PMBLOCK)(%d+)%$(%-?%d+)$",
        "^(###cbinfo)(DEMOTE)(%d+)(%-%d+)$",
        "^(###cbinfo)(PROMOTE)(%d+)(%-%d+)$",
        "^(###cbinfo)(ADMINCOMMANDS)(%d+)%$(%-?%d+)$",
        "^(###cbinfo)(PUNISHMENTS)(%d+)(%-%d+)$",
        "^(###cbinfo)(PROMOTIONS)(%d+)(%-%d+)$",

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
        "^[#!/]([Ii][Nn][Ff][Oo]) ([^%s]+) (%-%d+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ii][Nn][Ff][Oo])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ii][Nn][Ff][Oo]) ([^%s]+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ii][Nn][Ff][Oo]) ([^%s]+) (%-%d+)$",
        "^[#!/]([Tt][Rr][Aa][Cc][Kk][Uu][Ss][Ee][Rr])$",
        "^[#!/]([Tt][Rr][Aa][Cc][Kk][Uu][Ss][Ee][Rr]) ([^%s]+)$",
        "^[#!/]([Tt][Rr][Aa][Cc][Kk][Uu][Ss][Ee][Rr]) ([^%s]+) ([^%s]+)$",
        "^[#!/]([Gg][Rr][Oo][Uu][Pp][Ii][Nn][Ff][Oo])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Gg][Rr][Oo][Uu][Pp][Ii][Nn][Ff][Oo])$",
        -- "^[#!/]([Ww][Hh][Oo])$",
        -- who
        -- "^[#!/]([Mm][Ee][Mm][Bb][Ee][Rr][Ss])$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/id [{user}]",
        "/username [{user}]",
        "/getrank [{user}]",
        "/whoami",
        "/[textual]info",
        "/[textual]groupinfo",
        "/ishere {user}",
        "MOD",
        "/[textual]info {id}|{username}|{reply}|from",
        "/trackuser {id}|{username}|{reply}|from [{name}]",
        "PM",
        "/[textual]info {id}|{username}|from {group_id}",
        -- "(/who|/members)",
        "ADMIN",
        "/grouplink {group_id}",
    },
}