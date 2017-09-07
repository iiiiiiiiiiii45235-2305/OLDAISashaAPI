local restrictions_table = {
    -- user_id = { restrictions }
}
local kick_ban_errors = {
    -- chat_id = error
}
local default_restrictions = {
    can_send_messages = true,
    can_send_media_messages = true,
    can_send_other_messages = true,
    can_add_web_page_previews = true
}

local function user_msgs(user_id, chat_id)
    local user_info
    local uhash = 'user:' .. user_id
    local user = redis:hgetall(uhash)
    local um_hash = 'msgs:' .. user_id .. ':' .. chat_id
    user_info = tonumber(redis:get(um_hash) or 0)
    return user_info
end

local function kickinactive(executer, chat_id, num)
    local lang = get_lang(chat_id)
    local participants = getChatParticipants(chat_id)
    local kicked = 0
    for k, v in pairs(participants) do
        if v.user then
            v = v.user
            if tonumber(v.id) ~= tonumber(bot.id) and not is_mod2(v.id, chat_id, true) then
                local user_info = user_msgs(v.id, chat_id)
                if tonumber(user_info) < tonumber(num) then
                    kickUser(executer, v.id, chat_id, langs[lang].reasonInactive)
                    kicked = kicked + 1
                end
            end
        end
    end
    return langs[lang].massacre:gsub('X', kicked)
end

local function showRestrictions(chat_id, user_id, lang)
    local obj_user = getChatMember(chat_id, user_id)
    if type(obj_user) == 'table' then
        if obj_user.result then
            obj_user = obj_user.result
        else
            obj_user = nil
        end
    else
        obj_user = nil
    end
    if obj_user then
        if obj_user.status ~= 'creator' then
            if obj_user.status == 'restricted' then
                local text = langs[lang].restrictions ..
                langs[lang].restrictionSendMessages .. tostring(obj_user.can_send_messages) ..
                langs[lang].restrictionSendMediaMessages .. tostring(obj_user.can_send_media_messages) ..
                langs[lang].restrictionSendOtherMessages .. tostring(obj_user.can_send_other_messages) ..
                langs[lang].restrictionAddWebPagePreviews .. tostring(obj_user.can_add_web_page_previews)
                return text
            elseif obj_user.status == 'member' then
                local text = langs[lang].restrictions ..
                langs[lang].restrictionSendMessages .. tostring(true) ..
                langs[lang].restrictionSendMediaMessages .. tostring(true) ..
                langs[lang].restrictionSendOtherMessages .. tostring(true) ..
                langs[lang].restrictionAddWebPagePreviews .. tostring(true)
                return text
            else
                return langs[lang].errorTryAgain
            end
        else
            return langs[lang].errorTryAgain
        end
    else
        return langs[lang].errorTryAgain
    end
end

local function run(msg, matches)
    if msg.service then
        return
    end
    if msg.cb then
        if matches[1] == '###cbbanhammer' then
            if matches[2] == 'DELETE' then
                if not deleteMessage(msg.chat.id, msg.message_id, true) then
                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                end
            elseif matches[2] == 'BACK' then
                local chat_name = ''
                if data[tostring(matches[4])] then
                    chat_name = data[tostring(matches[4])].set_name or ''
                end
                editMessageText(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', '(' .. matches[4] .. ') ' .. chat_name), 'X', tostring('(' .. matches[3] .. ') ' ..(database[tostring(matches[3])]['print_name'] or ''))) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(matches[4], matches[3]))
                answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
            elseif matches[2] == 'RESTRICT' then
                if is_mod2(msg.from.id, matches[5]) then
                    mystat('###cbbanhammer' .. matches[2] .. matches[3] .. matches[4] .. matches[5])
                    local obj_user = getChatMember(matches[5], matches[3])
                    if type(obj_user) == 'table' then
                        if obj_user.result then
                            obj_user = obj_user.result
                            if obj_user.status == 'creator' or obj_user.status == 'left' or obj_user.status == 'kicked' then
                                obj_user = nil
                            end
                        else
                            obj_user = nil
                        end
                    else
                        obj_user = nil
                    end
                    if obj_user then
                        local restrictions = adjustRestrictions(obj_user)
                        if restrictionsDictionary[matches[4]:lower()] == 'can_send_messages' then
                            restrictions[restrictionsDictionary[matches[4]:lower()]] = false
                            restrictions['can_send_media_messages'] = false
                            restrictions['can_send_other_messages'] = false
                            restrictions['can_add_web_page_previews'] = false
                        end
                        if restrictionsDictionary[matches[4]:lower()] == 'can_send_media_messages' then
                            restrictions[restrictionsDictionary[matches[4]:lower()]] = false
                            restrictions['can_send_other_messages'] = false
                            restrictions['can_add_web_page_previews'] = false
                        end
                        if restrictionsDictionary[matches[4]:lower()] == 'can_send_other_messages' then
                            restrictions[restrictionsDictionary[matches[4]:lower()]] = false
                        end
                        if restrictionsDictionary[matches[4]:lower()] == 'can_add_web_page_previews' then
                            restrictions[restrictionsDictionary[matches[4]:lower()]] = false
                        end
                        if restrictChatMember(matches[5], obj_user.user.id, restrictions) then
                            answerCallbackQuery(msg.cb_id, matches[4] .. langs[msg.lang].denied, false)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].checkMyPermissions, false)
                        end
                        local chat_name = ''
                        if data[tostring(matches[5])] then
                            chat_name = data[tostring(matches[5])].set_name or ''
                        end
                        editMessageText(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', '(' .. matches[5] .. ') ' .. chat_name), 'X', tostring('(' .. matches[3] .. ') ' ..(database[tostring(matches[3])]['print_name'] or ''))) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(matches[5], matches[3], restrictions))
                    end
                else
                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                end
            elseif matches[2] == 'UNRESTRICT' then
                if is_mod2(msg.from.id, matches[5]) then
                    mystat('###cbbanhammer' .. matches[2] .. matches[3] .. matches[4] .. matches[5])
                    local obj_user = getChatMember(matches[5], matches[3])
                    if type(obj_user) == 'table' then
                        if obj_user.result then
                            obj_user = obj_user.result
                            if obj_user.status == 'creator' or obj_user.status == 'left' or obj_user.status == 'kicked' then
                                obj_user = nil
                            end
                        else
                            obj_user = nil
                        end
                    else
                        obj_user = nil
                    end
                    if obj_user then
                        local restrictions = adjustRestrictions(obj_user)
                        if restrictionsDictionary[matches[4]:lower()] == 'can_send_messages' then
                            restrictions[restrictionsDictionary[matches[4]:lower()]] = true
                        end
                        if restrictionsDictionary[matches[4]:lower()] == 'can_send_media_messages' then
                            restrictions['can_send_messages'] = true
                            restrictions[restrictionsDictionary[matches[4]:lower()]] = true
                        end
                        if restrictionsDictionary[matches[4]:lower()] == 'can_send_other_messages' then
                            restrictions['can_send_messages'] = true
                            restrictions['can_send_media_messages'] = true
                            restrictions[restrictionsDictionary[matches[4]:lower()]] = true
                        end
                        if restrictionsDictionary[matches[4]:lower()] == 'can_add_web_page_previews' then
                            restrictions['can_send_messages'] = true
                            restrictions['can_send_media_messages'] = true
                            restrictions[restrictionsDictionary[matches[4]:lower()]] = true
                        end
                        if restrictChatMember(matches[5], obj_user.user.id, restrictions) then
                            answerCallbackQuery(msg.cb_id, matches[4] .. langs[msg.lang].granted, false)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].checkMyPermissions, false)
                        end
                        local chat_name = ''
                        if data[tostring(matches[5])] then
                            chat_name = data[tostring(matches[5])].set_name or ''
                        end
                        editMessageText(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', '(' .. matches[5] .. ') ' .. chat_name), 'X', tostring('(' .. matches[3] .. ') ' ..(database[tostring(matches[3])]['print_name'] or ''))) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(matches[5], matches[3], restrictions))
                    end
                else
                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                end
            elseif matches[2] == 'TEMPBAN' then
                local time = tonumber(matches[3])
                local chat_name = ''
                if data[tostring(matches[6])] then
                    chat_name = data[tostring(matches[6])].set_name or ''
                end
                if matches[4] == 'BACK' then
                    editMessageText(msg.chat.id, msg.message_id, '(' .. matches[5] .. ') ' ..(database[tostring(matches[5])]['print_name'] or '') .. ' in ' .. '(' .. matches[6] .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time(matches[2], matches[6], matches[5], time))
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                elseif matches[4] == 'SECONDS' or matches[4] == 'MINUTES' or matches[4] == 'HOURS' or matches[4] == 'DAYS' or matches[4] == 'WEEKS' then
                    local remainder, weeks, days, hours, minutes, seconds = 0
                    weeks = math.floor(time / 604800)
                    remainder = time % 604800
                    days = math.floor(remainder / 86400)
                    remainder = remainder % 86400
                    hours = math.floor(remainder / 3600)
                    remainder = remainder % 3600
                    minutes = math.floor(remainder / 60)
                    seconds = remainder % 60
                    mystat('###cbbanhammer' .. matches[2] .. matches[3] .. matches[4] .. matches[5] .. matches[6] .. matches[7])
                    if matches[4] == 'SECONDS' then
                        if tonumber(matches[5]) == 0 then
                            time = time - seconds
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].secondsReset, false)
                        else
                            if (time + tonumber(matches[5])) >= 0 then
                                time = time + tonumber(matches[5])
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].errorBanhammerTimeRange, true)
                            end
                        end
                    elseif matches[4] == 'MINUTES' then
                        if tonumber(matches[5]) == 0 then
                            time = time -(minutes * 60)
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].minutesReset, false)
                        else
                            if (time +(tonumber(matches[5]) * 60)) >= 0 then
                                time = time +(tonumber(matches[5]) * 60)
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].errorBanhammerTimeRange, true)
                            end
                        end
                    elseif matches[4] == 'HOURS' then
                        if tonumber(matches[5]) == 0 then
                            time = time -(hours * 60 * 60)
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].hoursReset, false)
                        else
                            if (time +(tonumber(matches[5]) * 60 * 60)) >= 0 then
                                time = time +(tonumber(matches[5]) * 60 * 60)
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].errorBanhammerTimeRange, true)
                            end
                        end
                    elseif matches[4] == 'DAYS' then
                        if tonumber(matches[5]) == 0 then
                            time = time -(days * 60 * 60 * 24)
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].daysReset, false)
                        else
                            if (time +(tonumber(matches[5]) * 60 * 60 * 24)) >= 0 then
                                time = time +(tonumber(matches[5]) * 60 * 60 * 24)
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].errorBanhammerTimeRange, true)
                            end
                        end
                    elseif matches[4] == 'WEEKS' then
                        if tonumber(matches[5]) == 0 then
                            time = time -(weeks * 60 * 60 * 24 * 7)
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].weeksReset, false)
                        else
                            if (time +(tonumber(matches[5]) * 60 * 60 * 24 * 7)) >= 0 then
                                time = time +(tonumber(matches[5]) * 60 * 60 * 24 * 7)
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].errorBanhammerTimeRange, true)
                            end
                        end
                    end
                    editMessageText(msg.chat.id, msg.message_id, '(' .. matches[7] .. ') ' ..(database[tostring(matches[7])]['print_name'] or '') .. ' in ' .. '(' .. matches[6] .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time(matches[2], matches[6], matches[7], time))
                elseif matches[4] == 'DONE' then
                    mystat('###cbbanhammer' .. matches[2] .. matches[3] .. matches[4] .. matches[5] .. matches[6])
                    local text = ''
                    if time < 30 or time > 31622400 then
                        text = banUser(msg.from.id, matches[5], matches[6], '', os.time() + time)
                    else
                        text = banUser(msg.from.id, matches[5], matches[6], '', os.time() + time)
                    end
                    answerCallbackQuery(msg.cb_id, text, false)
                    sendMessage(matches[6], text)
                    if not deleteMessage(msg.chat.id, msg.message_id, true) then
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                    end
                end
            elseif matches[2] == 'TEMPRESTRICT' then
                local time = tonumber(matches[3])
                local chat_name = ''
                if data[tostring(matches[6])] then
                    chat_name = data[tostring(matches[6])].set_name or ''
                end
                if matches[4] == 'BACK' then
                    if restrictions_table[tostring(matches[5])] then
                        editMessageText(msg.chat.id, msg.message_id, '(' .. matches[5] .. ') ' ..(database[tostring(matches[5])]['print_name'] or '') .. ' in ' .. '(' .. matches[6] .. ') ' .. chat_name .. langs[msg.lang].tempRestrictIntro, keyboard_time(matches[2], matches[6], matches[5], time))
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                    else
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].errorTryAgain)
                    end
                elseif matches[4] == 'SECONDS' or matches[4] == 'MINUTES' or matches[4] == 'HOURS' or matches[4] == 'DAYS' or matches[4] == 'WEEKS' then
                    if restrictions_table[tostring(matches[7])] then
                        local remainder, weeks, days, hours, minutes, seconds = 0
                        weeks = math.floor(time / 604800)
                        remainder = time % 604800
                        days = math.floor(remainder / 86400)
                        remainder = remainder % 86400
                        hours = math.floor(remainder / 3600)
                        remainder = remainder % 3600
                        minutes = math.floor(remainder / 60)
                        seconds = remainder % 60
                        mystat('###cbbanhammer' .. matches[2] .. matches[3] .. matches[4] .. matches[5] .. matches[6] .. matches[7])
                        if matches[4] == 'SECONDS' then
                            if tonumber(matches[5]) == 0 then
                                time = time - seconds
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].secondsReset, false)
                            else
                                if (time + tonumber(matches[5])) >= 0 then
                                    time = time + tonumber(matches[5])
                                else
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].errorBanhammerTimeRange, true)
                                end
                            end
                        elseif matches[4] == 'MINUTES' then
                            if tonumber(matches[5]) == 0 then
                                time = time -(minutes * 60)
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].minutesReset, false)
                            else
                                if (time +(tonumber(matches[5]) * 60)) >= 0 then
                                    time = time +(tonumber(matches[5]) * 60)
                                else
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].errorBanhammerTimeRange, true)
                                end
                            end
                        elseif matches[4] == 'HOURS' then
                            if tonumber(matches[5]) == 0 then
                                time = time -(hours * 60 * 60)
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].hoursReset, false)
                            else
                                if (time +(tonumber(matches[5]) * 60 * 60)) >= 0 then
                                    time = time +(tonumber(matches[5]) * 60 * 60)
                                else
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].errorBanhammerTimeRange, true)
                                end
                            end
                        elseif matches[4] == 'DAYS' then
                            if tonumber(matches[5]) == 0 then
                                time = time -(days * 60 * 60 * 24)
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].daysReset, false)
                            else
                                if (time +(tonumber(matches[5]) * 60 * 60 * 24)) >= 0 then
                                    time = time +(tonumber(matches[5]) * 60 * 60 * 24)
                                else
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].errorBanhammerTimeRange, true)
                                end
                            end
                        elseif matches[4] == 'WEEKS' then
                            if tonumber(matches[5]) == 0 then
                                time = time -(weeks * 60 * 60 * 24 * 7)
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].weeksReset, false)
                            else
                                if (time +(tonumber(matches[5]) * 60 * 60 * 24 * 7)) >= 0 then
                                    time = time +(tonumber(matches[5]) * 60 * 60 * 24 * 7)
                                else
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].errorBanhammerTimeRange, true)
                                end
                            end
                        end
                        editMessageText(msg.chat.id, msg.message_id, '(' .. matches[7] .. ') ' ..(database[tostring(matches[7])]['print_name'] or '') .. ' in ' .. '(' .. matches[6] .. ') ' .. chat_name .. langs[msg.lang].tempRestrictIntro, keyboard_time(matches[2], matches[6], matches[7], time))
                    else
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].errorTryAgain)
                    end
                elseif matches[4] == 'DONE' then
                    if restrictions_table[tostring(matches[5])] then
                        mystat('###cbbanhammer' .. matches[2] .. matches[3] .. matches[4] .. matches[5] .. matches[6])
                        local text = ''
                        local restrictions = restrictions_table[tostring(matches[5])]
                        if time < 30 or time > 31622400 then
                            if restrictChatMember(matches[6], matches[5], restrictions, os.time() + time) then
                                for k, v in pairs(restrictions) do
                                    if not restrictions[k] then
                                        text = text .. reverseRestrictionsDictionary[k] .. ' '
                                    end
                                end
                                text = text .. langs[msg.lang].denied .. '\n#user' .. matches[5] .. ' #executer' .. msg.from.id .. ' #restrict'
                            else
                                text = langs[msg.lang].errorTryAgain
                            end
                        else
                            if restrictChatMember(matches[6], matches[5], restrictions, os.time() + time) then
                                for k, v in pairs(restrictions) do
                                    if not restrictions[k] then
                                        text = text .. reverseRestrictionsDictionary[k] .. ' '
                                    end
                                end
                                text = text .. langs[msg.lang].denied .. '\n#user' .. matches[5] .. ' #executer' .. msg.from.id .. ' #temprestrict ' .. langs[msg.lang].untilWord .. ' ' .. os.date('%Y-%m-%d %H:%M:%S', os.time() + time)
                            else
                                text = langs[msg.lang].errorTryAgain
                            end
                        end
                        restrictions_table[tostring(matches[5])] = nil
                        answerCallbackQuery(msg.cb_id, text, false)
                        sendMessage(matches[6], text)
                        if not deleteMessage(msg.chat.id, msg.message_id, true) then
                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                        end
                    else
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].errorTryAgain)
                    end
                end
            end
            return
        end
    end
    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
        if matches[1]:lower() == 'kickme' then
            if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] left using kickme ")
                -- Save to logs
                mystat('/kickme')
                return kickUser(bot.id, msg.from.id, msg.chat.id)
            else
                return langs[msg.lang].useYourGroups
            end
        end
        if matches[1]:lower() == 'getuserwarns' then
            if msg.from.is_mod then
                if getWarn(msg.chat.id) == langs[msg.lang].noWarnSet then
                    return langs[msg.lang].noWarnSet
                else
                    mystat('/getuserwarns')
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return getUserWarns(msg.reply_to_message.forward_from.id, msg.chat.id)
                                    else
                                        return langs[msg.lang].cantDoThisToChat
                                    end
                                else
                                    return langs[msg.lang].errorNoForward
                                end
                            end
                        else
                            return getUserWarns(msg.reply_to_message.from.id, msg.chat.id)
                        end
                    elseif matches[2] and matches[2] ~= '' then
                        if msg.entities then
                            for k, v in pairs(msg.entities) do
                                -- check if there's a text_mention
                                if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                    if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                        return getUserWarns(msg.entities[k].user.id, msg.chat.id)
                                    end
                                end
                            end
                        end
                        if string.match(matches[2], '^%d+$') then
                            return getUserWarns(matches[2], msg.chat.id)
                        else
                            local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return getUserWarns(obj_user.id, msg.chat.id)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    end
                    return
                end
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'muteuser' then
            if msg.from.is_mod then
                mystat('/muteuser')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    -- ignore higher or same rank
                                    if compare_ranks(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id) then
                                        if isMutedUser(msg.chat.id, msg.reply_to_message.forward_from.id) then
                                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed [" .. msg.reply_to_message.forward_from.id .. "] from the muted users list")
                                            return unmuteUser(msg.chat.id, msg.reply_to_message.forward_from.id, msg.lang)
                                        else
                                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added [" .. msg.reply_to_message.forward_from.id .. "] to the muted users list")
                                            return muteUser(msg.chat.id, msg.reply_to_message.forward_from.id, msg.lang)
                                        end
                                    else
                                        return langs[msg.lang].require_rank
                                    end
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        -- ignore higher or same rank
                        if compare_ranks(msg.from.id, msg.reply_to_message.from.id, msg.chat.id) then
                            if isMutedUser(msg.chat.id, msg.reply_to_message.from.id) then
                                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed [" .. msg.reply_to_message.from.id .. "] from the muted users list")
                                return unmuteUser(msg.chat.id, msg.reply_to_message.from.id, msg.lang)
                            else
                                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added [" .. msg.reply_to_message.from.id .. "] to the muted users list")
                                return muteUser(msg.chat.id, msg.reply_to_message.from.id, msg.lang)
                            end
                        else
                            return langs[msg.lang].require_rank
                        end
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    if compare_ranks(msg.from.id, msg.entities[k].user.id, msg.chat.id) then
                                        if isMutedUser(msg.chat.id, msg.entities[k].user.id) then
                                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed [" .. msg.entities[k].user.id .. "] from the muted users list")
                                            return unmuteUser(msg.chat.id, msg.entities[k].user.id, msg.lang)
                                        else
                                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added [" .. msg.entities[k].user.id .. "] to the muted users list")
                                            return muteUser(msg.chat.id, msg.entities[k].user.id, msg.lang)
                                        end
                                    else
                                        return langs[msg.lang].require_rank
                                    end
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        -- ignore higher or same rank
                        if compare_ranks(msg.from.id, matches[2], msg.chat.id) then
                            if isMutedUser(msg.chat.id, matches[2]) then
                                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed [" .. matches[2] .. "] from the muted users list")
                                return unmuteUser(msg.chat.id, matches[2], msg.lang)
                            else
                                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added [" .. matches[2] .. "] to the muted users list")
                                return muteUser(msg.chat.id, matches[2], msg.lang)
                            end
                        else
                            return langs[msg.lang].require_rank
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                -- ignore higher or same rank
                                if compare_ranks(msg.from.id, obj_user.id, msg.chat.id) then
                                    if isMutedUser(msg.chat.id, obj_user.id) then
                                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed [" .. obj_user.id .. "] from the muted users list")
                                        return unmuteUser(msg.chat.id, obj_user.id, msg.lang)
                                    else
                                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added [" .. obj_user.id .. "] to the muted users list")
                                        return muteUser(msg.chat.id, obj_user.id, msg.lang)
                                    end
                                else
                                    return langs[msg.lang].require_rank
                                end
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'mutelist' then
            if msg.from.is_mod then
                mystat('/mutelist')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup mutelist")
                return mutedUserList(msg.chat.id)
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'warn' then
            if msg.from.is_mod then
                if getWarn(msg.chat.id) == langs[msg.lang].noWarnSet then
                    return langs[msg.lang].noWarnSet
                else
                    mystat('/warn')
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return warnUser(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id, matches[3] or '')
                                    else
                                        return langs[msg.lang].cantDoThisToChat
                                    end
                                else
                                    return langs[msg.lang].errorNoForward
                                end
                            else
                                return warnUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            end
                        else
                            if msg.reply_to_message.service then
                                if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                                    local text = warnUser(msg.from.id, msg.reply_to_message.adder.id, msg.chat.id) .. '\n'
                                    for k, v in pairs(msg.reply_to_message.added) do
                                        text = text .. warnUser(msg.from.id, v.id, msg.chat.id) .. '\n'
                                    end
                                    return text ..(matches[2] or '') .. ' ' ..(matches[3] or '')
                                elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                    return warnUser(msg.from.id, msg.reply_to_message.removed.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                                else
                                    return warnUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                                end
                            else
                                return warnUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            end
                        end
                    elseif matches[2] and matches[2] ~= '' then
                        if msg.entities then
                            for k, v in pairs(msg.entities) do
                                -- check if there's a text_mention
                                if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                    if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                        return warnUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, matches[3] or '')
                                    end
                                end
                            end
                        end
                        if string.match(matches[2], '^%d+$') then
                            return warnUser(msg.from.id, matches[2], msg.chat.id, matches[3] or '')
                        else
                            local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return warnUser(msg.from.id, obj_user.id, msg.chat.id, matches[3] or '')
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    end
                    return
                end
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'unwarn' then
            if msg.from.is_mod then
                if getWarn(msg.chat.id) == langs[msg.lang].noWarnSet then
                    return langs[msg.lang].noWarnSet
                else
                    mystat('/unwarn')
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return unwarnUser(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id, matches[3] or '')
                                    else
                                        return langs[msg.lang].cantDoThisToChat
                                    end
                                else
                                    return langs[msg.lang].errorNoForward
                                end
                            else
                                return unwarnUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            end
                        else
                            if msg.reply_to_message.service then
                                if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                                    local text = unwarnUser(msg.from.id, msg.reply_to_message.adder.id, msg.chat.id) .. '\n'
                                    for k, v in pairs(msg.reply_to_message.added) do
                                        text = text .. unwarnUser(msg.from.id, v.id, msg.chat.id) .. '\n'
                                    end
                                    return text ..(matches[2] or '') .. ' ' ..(matches[3] or '')
                                elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                    return unwarnUser(msg.from.id, msg.reply_to_message.removed.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                                else
                                    return unwarnUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                                end
                            else
                                return unwarnUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            end
                        end
                    elseif matches[2] and matches[2] ~= '' then
                        if msg.entities then
                            for k, v in pairs(msg.entities) do
                                -- check if there's a text_mention
                                if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                    if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                        return unwarnUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, matches[3] or '')
                                    end
                                end
                            end
                        end
                        if string.match(matches[2], '^%d+$') then
                            return unwarnUser(msg.from.id, matches[2], msg.chat.id, matches[3] or '')
                        else
                            local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return unwarnUser(msg.from.id, obj_user.id, msg.chat.id, matches[3] or '')
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    end
                    return
                end
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'unwarnall' then
            if msg.from.is_mod then
                if getWarn(msg.chat.id) == langs[msg.lang].noWarnSet then
                    return langs[msg.lang].noWarnSet
                else
                    mystat('/unwarnall')
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return unwarnallUser(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id, matches[3] or '')
                                    else
                                        return langs[msg.lang].cantDoThisToChat
                                    end
                                else
                                    return langs[msg.lang].errorNoForward
                                end
                            else
                                return unwarnallUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            end
                        else
                            if msg.reply_to_message.service then
                                if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                                    local text = unwarnallUser(msg.from.id, msg.reply_to_message.adder.id, msg.chat.id) .. '\n'
                                    for k, v in pairs(msg.reply_to_message.added) do
                                        text = text .. unwarnallUser(msg.from.id, v.id, msg.chat.id) .. '\n'
                                    end
                                    return text ..(matches[2] or '') .. ' ' ..(matches[3] or '')
                                elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                    return unwarnallUser(msg.from.id, msg.reply_to_message.removed.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                                else
                                    return unwarnallUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                                end
                            else
                                return unwarnallUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            end
                        end
                    elseif matches[2] and matches[2] ~= '' then
                        if msg.entities then
                            for k, v in pairs(msg.entities) do
                                -- check if there's a text_mention
                                if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                    if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                        return unwarnallUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, matches[3] or '')
                                    end
                                end
                            end
                        end
                        if string.match(matches[2], '^%d+$') then
                            return unwarnallUser(msg.from.id, matches[2], msg.chat.id, matches[3] or '')
                        else
                            local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return unwarnallUser(msg.from.id, obj_user.id, msg.chat.id, matches[3] or '')
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    end
                    return
                end
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'temprestrict' then
            if msg.from.is_mod then
                mystat('/restrict')
                local restrictions = clone_table(default_restrictions)
                for k, v in pairs(restrictions) do
                    restrictions[k] = false
                end
                local chat_name = ''
                if data[tostring(msg.chat.id)] then
                    chat_name = data[tostring(msg.chat.id)].set_name or ''
                end
                local text = ''
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    local time, weeks, days, hours, minutes, seconds = 0
                                    if matches[3] and matches[4] and matches[5] and matches[6] and matches[7] then
                                        weeks = tonumber(matches[3])
                                        days = tonumber(matches[4])
                                        hours = tonumber(matches[5])
                                        minutes = tonumber(matches[6])
                                        seconds = tonumber(matches[7])
                                        time =(weeks * 7 * 24 * 60 * 60) +(days * 24 * 60 * 60) +(hours * 60 * 60) +(minutes * 60) + seconds
                                        if matches[8] then
                                            restrictions = adjustRestrictions(matches[8]:lower())
                                        end
                                        for k, v in pairs(restrictions) do
                                            if not restrictions[k] then
                                                text = text .. reverseRestrictionsDictionary[k] .. ' '
                                            end
                                        end
                                        if time < 30 or time > 31622400 then
                                            if restrictChatMember(msg.chat.id, msg.reply_to_message.forward_from.id, restrictions, os.time() + time) then
                                                text = text .. langs[msg.lang].denied .. '\n#user' .. msg.reply_to_message.forward_from.id .. ' #executer' .. msg.from.id .. ' #restrict'
                                            else
                                                text = langs[msg.lang].errorTryAgain
                                            end
                                        else
                                            if restrictChatMember(msg.chat.id, msg.reply_to_message.forward_from.id, restrictions, os.time() + time) then
                                                text = text .. langs[msg.lang].denied .. '\n#user' .. msg.reply_to_message.forward_from.id .. ' #executer' .. msg.from.id .. ' #temprestrict ' .. langs[msg.lang].untilWord .. ' ' .. os.date('%Y-%m-%d %H:%M:%S', os.time() + time)
                                            else
                                                text = langs[msg.lang].errorTryAgain
                                            end
                                        end
                                    else
                                        if matches[3] then
                                            restrictions = adjustRestrictions(matches[3]:lower())
                                        end
                                        restrictions_table[tostring(msg.reply_to_message.forward_from.id)] = restrictions
                                        if sendKeyboard(msg.from.id, '(' .. msg.reply_to_message.forward_from.id .. ') ' ..(database[tostring(msg.reply_to_message.forward_from.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempRestrictIntro, keyboard_time('TEMPRESTRICT', msg.chat.id, msg.reply_to_message.forward_from.id)) then
                                            if msg.chat.type ~= 'private' then
                                                local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                                return
                                            end
                                        else
                                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                        end
                                    end
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        else
                            local time, weeks, days, hours, minutes, seconds = 0
                            if matches[2] and matches[3] and matches[4] and matches[5] and matches[6] then
                                weeks = tonumber(matches[2])
                                days = tonumber(matches[3])
                                hours = tonumber(matches[4])
                                minutes = tonumber(matches[5])
                                seconds = tonumber(matches[6])
                                time =(weeks * 7 * 24 * 60 * 60) +(days * 24 * 60 * 60) +(hours * 60 * 60) +(minutes * 60) + seconds
                                if matches[7] then
                                    restrictions = adjustRestrictions(matches[7]:lower())
                                end
                                for k, v in pairs(restrictions) do
                                    if not restrictions[k] then
                                        text = text .. reverseRestrictionsDictionary[k] .. ' '
                                    end
                                end
                                if time < 30 or time > 31622400 then
                                    if restrictChatMember(msg.chat.id, msg.reply_to_message.from.id, restrictions, os.time() + time) then
                                        text = text .. langs[msg.lang].denied .. '\n#user' .. msg.reply_to_message.from.id .. ' #executer' .. msg.from.id .. ' #restrict'
                                    else
                                        text = langs[msg.lang].errorTryAgain
                                    end
                                else
                                    if restrictChatMember(msg.chat.id, msg.reply_to_message.from.id, restrictions, os.time() + time) then
                                        text = text .. langs[msg.lang].denied .. '\n#user' .. msg.reply_to_message.from.id .. ' #executer' .. msg.from.id .. ' #temprestrict ' .. langs[msg.lang].untilWord .. ' ' .. os.date('%Y-%m-%d %H:%M:%S', os.time() + time)
                                    else
                                        text = langs[msg.lang].errorTryAgain
                                    end
                                end
                            else
                                if matches[2] then
                                    restrictions = adjustRestrictions(matches[2]:lower())
                                end
                                restrictions_table[tostring(msg.reply_to_message.from.id)] = restrictions
                                if sendKeyboard(msg.from.id, '(' .. msg.reply_to_message.from.id .. ') ' ..(database[tostring(msg.reply_to_message.from.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempRestrictIntro, keyboard_time('TEMPRESTRICT', msg.chat.id, msg.reply_to_message.from.id)) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                end
                            end
                        end
                    else
                        local time, weeks, days, hours, minutes, seconds = 0
                        if matches[2] and matches[3] and matches[4] and matches[5] and matches[6] then
                            weeks = tonumber(matches[2])
                            days = tonumber(matches[3])
                            hours = tonumber(matches[4])
                            minutes = tonumber(matches[5])
                            seconds = tonumber(matches[6])
                            time =(weeks * 7 * 24 * 60 * 60) +(days * 24 * 60 * 60) +(hours * 60 * 60) +(minutes * 60) + seconds
                            if matches[7] then
                                restrictions = adjustRestrictions(matches[7]:lower())
                            end
                            for k, v in pairs(restrictions) do
                                if not restrictions[k] then
                                    text = text .. reverseRestrictionsDictionary[k] .. ' '
                                end
                            end
                            if time < 30 or time > 31622400 then
                                if restrictChatMember(msg.chat.id, msg.reply_to_message.from.id, restrictions, os.time() + time) then
                                    text = text .. langs[msg.lang].denied .. '\n#user' .. msg.reply_to_message.from.id .. ' #executer' .. msg.from.id .. ' #restrict'
                                else
                                    text = langs[msg.lang].errorTryAgain
                                end
                            else
                                if restrictChatMember(msg.chat.id, msg.reply_to_message.from.id, restrictions, os.time() + time) then
                                    text = text .. langs[msg.lang].denied .. '\n#user' .. msg.reply_to_message.from.id .. ' #executer' .. msg.from.id .. ' #temprestrict ' .. langs[msg.lang].untilWord .. ' ' .. os.date('%Y-%m-%d %H:%M:%S', os.time() + time)
                                else
                                    text = langs[msg.lang].errorTryAgain
                                end
                            end
                        else
                            if matches[2] then
                                restrictions = adjustRestrictions(matches[2]:lower())
                            end
                            restrictions_table[tostring(msg.reply_to_message.from.id)] = restrictions
                            if sendKeyboard(msg.from.id, '(' .. msg.reply_to_message.from.id .. ') ' ..(database[tostring(msg.reply_to_message.from.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempRestrictIntro, keyboard_time('TEMPRESTRICT', msg.chat.id, msg.reply_to_message.from.id)) then
                                if msg.chat.type ~= 'private' then
                                    local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                    return
                                end
                            else
                                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                            end
                        end
                    end
                elseif matches[2] and matches[2] ~= '' then
                    local time, weeks, days, hours, minutes, seconds = 0
                    if matches[3] and matches[4] and matches[5] and matches[6] and matches[7] then
                        weeks = tonumber(matches[3])
                        days = tonumber(matches[4])
                        hours = tonumber(matches[5])
                        minutes = tonumber(matches[6])
                        seconds = tonumber(matches[7])
                        time =(weeks * 7 * 24 * 60 * 60) +(days * 24 * 60 * 60) +(hours * 60 * 60) +(minutes * 60) + seconds
                        if msg.entities then
                            for k, v in pairs(msg.entities) do
                                -- check if there's a text_mention
                                if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                    if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                        if matches[8] then
                                            restrictions = adjustRestrictions(matches[8]:lower())
                                        end
                                        for k, v in pairs(restrictions) do
                                            if not restrictions[k] then
                                                text = text .. reverseRestrictionsDictionary[k] .. ' '
                                            end
                                        end
                                        if time < 30 or time > 31622400 then
                                            if restrictChatMember(msg.chat.id, msg.entities[k].user.id, restrictions, os.time() + time) then
                                                text = text .. langs[msg.lang].denied .. '\n#user' .. msg.entities[k].user.id .. ' #executer' .. msg.from.id .. ' #restrict'
                                            else
                                                text = langs[msg.lang].errorTryAgain
                                            end
                                        else
                                            if restrictChatMember(msg.chat.id, msg.entities[k].user.id, restrictions, os.time() + time) then
                                                text = text .. langs[msg.lang].denied .. '\n#user' .. msg.entities[k].user.id .. ' #executer' .. msg.from.id .. ' #temprestrict ' .. langs[msg.lang].untilWord .. ' ' .. os.date('%Y-%m-%d %H:%M:%S', os.time() + time)
                                            else
                                                text = langs[msg.lang].errorTryAgain
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if string.match(matches[2], '^%d+$') then
                            if matches[8] then
                                restrictions = adjustRestrictions(matches[8]:lower())
                            end
                            for k, v in pairs(restrictions) do
                                if not restrictions[k] then
                                    text = text .. reverseRestrictionsDictionary[k] .. ' '
                                end
                            end
                            if time < 30 or time > 31622400 then
                                if restrictChatMember(msg.chat.id, matches[2], restrictions, os.time() + time) then
                                    text = text .. langs[msg.lang].denied .. '\n#user' .. matches[2] .. ' #executer' .. msg.from.id .. ' #restrict'
                                else
                                    text = langs[msg.lang].errorTryAgain
                                end
                            else
                                if restrictChatMember(msg.chat.id, matches[2], restrictions, os.time() + time) then
                                    text = text .. langs[msg.lang].denied .. '\n#user' .. matches[2] .. ' #executer' .. msg.from.id .. ' #temprestrict ' .. langs[msg.lang].untilWord .. ' ' .. os.date('%Y-%m-%d %H:%M:%S', os.time() + time)
                                else
                                    text = langs[msg.lang].errorTryAgain
                                end
                            end
                        else
                            local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    if matches[8] then
                                        restrictions = adjustRestrictions(matches[8]:lower())
                                    end
                                    for k, v in pairs(restrictions) do
                                        if not restrictions[k] then
                                            text = text .. reverseRestrictionsDictionary[k] .. ' '
                                        end
                                    end
                                    if time < 30 or time > 31622400 then
                                        if restrictChatMember(msg.chat.id, obj_user.id, restrictions, os.time() + time) then
                                            text = text .. langs[msg.lang].denied .. '\n#user' .. obj_user.id .. ' #executer' .. msg.from.id .. ' #restrict'
                                        else
                                            text = langs[msg.lang].errorTryAgain
                                        end
                                    else
                                        if restrictChatMember(msg.chat.id, obj_user.id, restrictions, os.time() + time) then
                                            text = text .. langs[msg.lang].denied .. '\n#user' .. obj_user.id .. ' #executer' .. msg.from.id .. ' #temprestrict ' .. langs[msg.lang].untilWord .. ' ' .. os.date('%Y-%m-%d %H:%M:%S', os.time() + time)
                                        else
                                            text = langs[msg.lang].errorTryAgain
                                        end
                                    end
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        if msg.entities then
                            for k, v in pairs(msg.entities) do
                                -- check if there's a text_mention
                                if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                    if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                        if matches[3] then
                                            restrictions = adjustRestrictions(matches[3]:lower())
                                        end
                                        restrictions_table[tostring(msg.entities[k].user.id)] = restrictions
                                        if sendKeyboard(msg.from.id, '(' .. msg.entities[k].user.id .. ') ' ..(database[tostring(msg.entities[k].user.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempRestrictIntro, keyboard_time('TEMPRESTRICT', msg.chat.id, msg.entities[k].user.id)) then
                                            if msg.chat.type ~= 'private' then
                                                local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                                return
                                            end
                                        else
                                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                        end
                                    end
                                end
                            end
                        end
                        if string.match(matches[2], '^%d+$') then
                            if matches[3] then
                                restrictions = adjustRestrictions(matches[3]:lower())
                            end
                            restrictions_table[tostring(matches[2])] = restrictions
                            if sendKeyboard(msg.from.id, '(' .. matches[2] .. ') ' ..(database[tostring(matches[2])]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempRestrictIntro, keyboard_time('TEMPRESTRICT', msg.chat.id, matches[2])) then
                                if msg.chat.type ~= 'private' then
                                    local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                    return
                                end
                            else
                                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                            end
                        else
                            local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    if matches[3] then
                                        restrictions = adjustRestrictions(matches[3]:lower())
                                    end
                                    restrictions_table[tostring(obj_user.id)] = restrictions
                                    if sendKeyboard(msg.from.id, '(' .. obj_user.id .. ') ' ..(database[tostring(obj_user.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempRestrictIntro, keyboard_time('TEMPRESTRICT', msg.chat.id, obj_user.id)) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                    end
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    end
                end
                return text
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'restrict' then
            if msg.from.is_mod then
                mystat('/restrict')
                local restrictions = clone_table(default_restrictions)
                for k, v in pairs(restrictions) do
                    restrictions[k] = false
                end
                local text = ''
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    if matches[3] then
                                        restrictions = adjustRestrictions(matches[3]:lower())
                                    end
                                    for k, v in pairs(restrictions) do
                                        if not restrictions[k] then
                                            text = text .. reverseRestrictionsDictionary[k] .. ' '
                                        end
                                    end
                                    if restrictChatMember(msg.chat.id, msg.reply_to_message.forward_from.id, restrictions) then
                                        return text .. langs[msg.lang].denied .. '\n#user' .. msg.reply_to_message.forward_from.id .. ' #executer' .. msg.from.id .. ' #restrict'
                                    else
                                        return langs[msg.lang].errorTryAgain
                                    end
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        else
                            if matches[2] then
                                restrictions = adjustRestrictions(matches[2]:lower())
                            end
                            for k, v in pairs(restrictions) do
                                if not restrictions[k] then
                                    text = text .. reverseRestrictionsDictionary[k] .. ' '
                                end
                            end
                            if restrictChatMember(msg.chat.id, msg.reply_to_message.from.id, restrictions) then
                                return text .. langs[msg.lang].denied .. '\n#user' .. msg.reply_to_message.from.id .. ' #executer' .. msg.from.id .. ' #restrict'
                            else
                                return langs[msg.lang].errorTryAgain
                            end
                        end
                    else
                        if matches[2] then
                            restrictions = adjustRestrictions(matches[2]:lower())
                        end
                        for k, v in pairs(restrictions) do
                            if not restrictions[k] then
                                text = text .. reverseRestrictionsDictionary[k] .. ' '
                            end
                        end
                        if restrictChatMember(msg.chat.id, msg.reply_to_message.from.id, restrictions) then
                            return text .. langs[msg.lang].denied .. '\n#user' .. msg.reply_to_message.from.id .. ' #executer' .. msg.from.id .. ' #restrict'
                        else
                            return langs[msg.lang].errorTryAgain
                        end
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    if matches[3] then
                                        restrictions = adjustRestrictions(matches[3]:lower())
                                    end
                                    for k, v in pairs(restrictions) do
                                        if not restrictions[k] then
                                            text = text .. reverseRestrictionsDictionary[k] .. ' '
                                        end
                                    end
                                    if restrictChatMember(msg.chat.id, msg.entities[k].user.id, restrictions) then
                                        return text .. langs[msg.lang].denied .. '\n#user' .. msg.entities[k].user.id .. ' #executer' .. msg.from.id .. ' #restrict'
                                    else
                                        return langs[msg.lang].errorTryAgain
                                    end
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        if matches[3] then
                            restrictions = adjustRestrictions(matches[3]:lower())
                        end
                        for k, v in pairs(restrictions) do
                            if not restrictions[k] then
                                text = text .. reverseRestrictionsDictionary[k] .. ' '
                            end
                        end
                        if restrictChatMember(msg.chat.id, obj_user.id, restrictions) then
                            return text .. langs[msg.lang].denied .. '\n#user' .. matches[2] .. ' #executer' .. msg.from.id .. ' #restrict'
                        else
                            return langs[msg.lang].errorTryAgain
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                if matches[3] then
                                    restrictions = adjustRestrictions(matches[3]:lower())
                                end
                                for k, v in pairs(restrictions) do
                                    if not restrictions[k] then
                                        text = text .. reverseRestrictionsDictionary[k] .. ' '
                                    end
                                end
                                if restrictChatMember(msg.chat.id, obj_user.id, restrictions) then
                                    return text .. langs[msg.lang].denied .. '\n#user' .. obj_user.id .. ' #executer' .. msg.from.id .. ' #restrict'
                                else
                                    return langs[msg.lang].errorTryAgain
                                end
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return text
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'unrestrict' then
            if msg.from.is_owner then
                mystat('/unrestrict')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    if unrestrictChatMember(msg.chat.id, msg.reply_to_message.forward_from.id) then
                                        return langs[msg.lang].userUnrestricted .. '\n#user' .. msg.reply_to_message.forward_from.id .. ' #executer' .. msg.from.id .. ' #unrestrict'
                                    else
                                        return langs[msg.lang].errorTryAgain
                                    end
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        else
                            if unrestrictChatMember(msg.chat.id, msg.reply_to_message.from.id) then
                                return langs[msg.lang].userUnrestricted .. '\n#user' .. msg.reply_to_message.from.id .. ' #executer' .. msg.from.id .. ' #unrestrict'
                            else
                                return langs[msg.lang].errorTryAgain
                            end
                        end
                    else
                        if unrestrictChatMember(msg.chat.id, msg.reply_to_message.from.id) then
                            return langs[msg.lang].userUnrestricted .. '\n#user' .. msg.reply_to_message.from.id .. ' #executer' .. msg.from.id .. ' #unrestrict'
                        else
                            return langs[msg.lang].errorTryAgain
                        end
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    if unrestrictChatMember(msg.chat.id, msg.entities[k].user.id) then
                                        return langs[msg.lang].userUnrestricted .. '\n#user' .. msg.entities[k].user.id .. ' #executer' .. msg.from.id .. ' #unrestrict'
                                    else
                                        return langs[msg.lang].errorTryAgain
                                    end
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        if unrestrictChatMember(msg.chat.id, matches[2]) then
                            return langs[msg.lang].userUnrestricted .. '\n#user' .. matches[2] .. ' #executer' .. msg.from.id .. ' #unrestrict'
                        else
                            return langs[msg.lang].errorTryAgain
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                if unrestrictChatMember(msg.chat.id, obj_user.id) then
                                    return langs[msg.lang].userUnrestricted .. '\n#user' .. obj_user.id .. ' #executer' .. msg.from.id .. ' #unrestrict'
                                else
                                    return langs[msg.lang].errorTryAgain
                                end
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'restrictions' then
            mystat('/restrictions')
            local chat_name = ''
            if data[tostring(msg.chat.id)] then
                chat_name = data[tostring(msg.chat.id)].set_name or ''
            end
            if msg.from.is_mod then
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. msg.reply_to_message.forward_from.id .. ') ' .. msg.reply_to_message.forward_from.first_name .. ' ' ..(msg.reply_to_message.forward_from.last_name or ''))) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(msg.chat.id, msg.reply_to_message.forward_from.id)) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendRestrictionsPvt).result.message_id
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                    end
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. msg.reply_to_message.from.id .. ') ' .. msg.reply_to_message.from.first_name .. ' ' ..(msg.reply_to_message.from.last_name or ''))) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(msg.chat.id, msg.reply_to_message.from.id)) then
                            if msg.chat.type ~= 'private' then
                                local message_id = sendReply(msg, langs[msg.lang].sendRestrictionsPvt).result.message_id
                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                return
                            end
                        else
                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                        end
                        return
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    local obj_user = getChat(msg.entities[k].user.id)
                                    if type(obj_user) == 'table' then
                                        if obj_user then
                                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                                if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. obj_user.id .. ') ' .. obj_user.first_name .. ' ' ..(obj_user.last_name or ''))) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(msg.chat.id, obj_user.id)) then
                                                    if msg.chat.type ~= 'private' then
                                                        local message_id = sendReply(msg, langs[msg.lang].sendRestrictionsPvt).result.message_id
                                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                                        return
                                                    end
                                                else
                                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                                end
                                            end
                                        else
                                            return langs[msg.lang].noObject
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. obj_user.id .. ') ' .. obj_user.first_name .. ' ' ..(obj_user.last_name or ''))) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(msg.chat.id, obj_user.id)) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendRestrictionsPvt).result.message_id
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                    end
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. obj_user.id .. ') ' .. obj_user.first_name .. ' ' ..(obj_user.last_name or ''))) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(msg.chat.id, obj_user.id)) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = sendReply(msg, langs[msg.lang].sendRestrictionsPvt).result.message_id
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                end
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'textualrestrictions' then
            mystat('/restrictions')
            if msg.from.is_mod then
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return showRestrictions(msg.chat.id, msg.reply_to_message.forward_from.id, msg.lang)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        else
                            return showRestrictions(msg.chat.id, msg.reply_to_message.from.id, msg.lang)
                        end
                    else
                        return showRestrictions(msg.chat.id, msg.reply_to_message.from.id, msg.lang)
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return showRestrictions(msg.chat.id, msg.entities[k].user.id, msg.lang)
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return showRestrictions(msg.chat.id, obj_user.id, msg.lang)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return showRestrictions(msg.chat.id, obj_user.id, msg.lang)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'kick' then
            if msg.from.is_mod then
                mystat('/kick')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return kickUser(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id, matches[3] or '')
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        else
                            return kickUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                        end
                    else
                        if msg.reply_to_message.service then
                            if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                                local text = kickUser(msg.from.id, msg.reply_to_message.adder.id, msg.chat.id) .. '\n'
                                for k, v in pairs(msg.reply_to_message.added) do
                                    text = text .. kickUser(msg.from.id, v.id, msg.chat.id) .. '\n'
                                end
                                return text ..(matches[2] or '') .. ' ' ..(matches[3] or '')
                            elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                return kickUser(msg.from.id, msg.reply_to_message.removed.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            else
                                return kickUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            end
                        else
                            return kickUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                        end
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return kickUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, matches[3] or '')
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        return kickUser(msg.from.id, matches[2], msg.chat.id, matches[3] or '')
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return kickUser(msg.from.id, obj_user.id, msg.chat.id, matches[3] or '')
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        --[[if matches[1]:lower() == 'kickrandom' then
            if msg.from.is_mod then
                return langs[msg.lang].useAISasha
                mystat('/kickrandom')
                local kickable = false
                local id
                local participants = getChatParticipants(msg.chat.id)
                local unlocker = 0
                while not kickable do
                    if unlocker == 100 then
                        return langs[msg.lang].badLuck
                    end
                    id = participants[math.random(#participants)].user.id
                    print(id)
                    if tonumber(id) ~= tonumber(bot.id) and not is_mod2(id, msg.chat.id, true) and not isWhitelisted(msg.chat.tg_cli_id, id) then
                        kickable = true
                        kickUser(msg.from.id, id, msg.chat.id)
                    else
                        print('403')
                        unlocker = unlocker + 1
                    end
                end
                return id .. langs[msg.lang].kicked
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'kickdeleted' then
            if msg.from.is_mod then
                return langs[msg.lang].useAISasha
                mystat('/kickdeleted')
                local kicked = 0
                local participants = getChatParticipants(msg.chat.id)
                for k, v in pairs(participants) do
                    if v.user then
                        v = v.user
                        if not v.first_name then
                            if v.id then
                                kickUser(msg.from.id, v.id, msg.chat.id)
                                kicked = kicked + 1
                            end
                        end
                    end
                end
                return langs[msg.lang].massacre:gsub('X', kicked)
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'kickinactive' then
            if msg.from.is_owner then
                return langs[msg.lang].kickinactiveWarning
                mystat('/kickinactive')
                local num = matches[2] or 0
                return kickinactive(msg.from.id, msg.chat.id, tonumber(num))
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'kicknouser' then
            if msg.from.is_owner then
                return langs[msg.lang].useAISasha
                mystat('/kicknouser')
                local kicked = 0
                local participants = getChatParticipants(msg.chat.id)
                for k, v in pairs(participants) do
                    if v.user then
                        v = v.user
                        if not v.username then
                            kickUser(msg.from.id, v.id, msg.chat.id)
                            kicked = kicked + 1
                        end
                    end
                end
                return langs[msg.lang].massacre:gsub('X', kicked)
            else
                return langs[msg.lang].require_owner
            end
        end]]
        if matches[1]:lower() == 'banlist' and not matches[2] then
            if msg.from.is_mod then
                mystat('/banlist')
                return banList(msg.chat.id)
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'countbanlist' and not matches[2] then
            if msg.from.is_mod then
                mystat('/countbanlist')
                local list = redis:smembers('banned:' .. msg.chat.id)
                return #list
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'tempban' then
            if msg.from.is_mod then
                mystat('/ban')
                local chat_name = ''
                if data[tostring(msg.chat.id)] then
                    chat_name = data[tostring(msg.chat.id)].set_name or ''
                end
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    local time, weeks, days, hours, minutes, seconds = 0
                                    if matches[3] and matches[4] and matches[5] and matches[6] and matches[7] then
                                        weeks = tonumber(matches[3])
                                        days = tonumber(matches[4])
                                        hours = tonumber(matches[5])
                                        minutes = tonumber(matches[6])
                                        seconds = tonumber(matches[7])
                                        time =(weeks * 7 * 24 * 60 * 60) +(days * 24 * 60 * 60) +(hours * 60 * 60) +(minutes * 60) + seconds
                                        return banUser(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id, matches[8] or '', os.time() + time)
                                    else
                                        if compare_ranks(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id) then
                                            if sendKeyboard(msg.from.id, '(' .. msg.reply_to_message.forward_from.id .. ') ' ..(database[tostring(msg.reply_to_message.forward_from.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time('TEMPBAN', msg.chat.id, msg.reply_to_message.forward_from.id)) then
                                                if msg.chat.type ~= 'private' then
                                                    local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                                    return
                                                end
                                            else
                                                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                            end
                                        else
                                            return langs[msg.lang].require_rank
                                        end
                                    end
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        else
                            local time, weeks, days, hours, minutes, seconds = 0
                            if matches[2] and matches[3] and matches[4] and matches[5] and matches[6] then
                                weeks = tonumber(matches[2])
                                days = tonumber(matches[3])
                                hours = tonumber(matches[4])
                                minutes = tonumber(matches[5])
                                seconds = tonumber(matches[6])
                                time =(weeks * 7 * 24 * 60 * 60) +(days * 24 * 60 * 60) +(hours * 60 * 60) +(minutes * 60) + seconds
                                return banUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[7] or '') .. ' ' ..(matches[8] or ''), os.time() + time)
                            else
                                if compare_ranks(msg.from.id, msg.reply_to_message.from.id, msg.chat.id) then
                                    if sendKeyboard(msg.from.id, '(' .. msg.reply_to_message.from.id .. ') ' ..(database[tostring(msg.reply_to_message.from.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time('TEMPBAN', msg.chat.id, msg.reply_to_message.from.id)) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                    end
                                else
                                    return langs[msg.lang].require_rank
                                end
                            end
                        end
                    else
                        if msg.reply_to_message.service then
                            local time, weeks, days, hours, minutes, seconds = 0
                            if matches[2] and matches[3] and matches[4] and matches[5] and matches[6] then
                                weeks = tonumber(matches[2])
                                days = tonumber(matches[3])
                                hours = tonumber(matches[4])
                                minutes = tonumber(matches[5])
                                seconds = tonumber(matches[6])
                                time =(weeks * 7 * 24 * 60 * 60) +(days * 24 * 60 * 60) +(hours * 60 * 60) +(minutes * 60) + seconds
                                if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                                    local text = banUser(msg.from.id, msg.reply_to_message.adder.id, msg.chat.id, '', os.time() + time) .. '\n'
                                    for k, v in pairs(msg.reply_to_message.added) do
                                        text = text .. banUser(msg.from.id, v.id, msg.chat.id, '', os.time() + time) .. '\n'
                                    end
                                    return text ..(matches[7] or '') .. ' ' ..(matches[8] or '')
                                elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                    return banUser(msg.from.id, msg.reply_to_message.removed.id, msg.chat.id,(matches[7] or '') .. ' ' ..(matches[8] or ''), os.time() + time)
                                else
                                    return banUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[7] or '') .. ' ' ..(matches[8] or ''), os.time() + time)
                                end
                            else
                                if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                                    local text = ''
                                    if compare_ranks(msg.from.id, msg.reply_to_message.adder.id, msg.chat.id) then
                                        if sendKeyboard(msg.from.id, '(' .. msg.reply_to_message.adder.id .. ') ' ..(database[tostring(msg.reply_to_message.adder.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time('TEMPBAN', msg.chat.id, msg.reply_to_message.adder.id)) then
                                            if msg.chat.type ~= 'private' then
                                                text = text .. langs[msg.lang].sendTimeKeyboardPvt .. '\n'
                                            end
                                        else
                                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                        end
                                    else
                                        text = text .. langs[msg.lang].require_rank .. '\n'
                                    end
                                    for k, v in pairs(msg.reply_to_message.added) do
                                        if compare_ranks(msg.from.id, v.id, msg.chat.id) then
                                            if sendKeyboard(msg.from.id, '(' .. v.id .. ') ' ..(database[tostring(v.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time('TEMPBAN', msg.chat.id, v.id)) then
                                                if msg.chat.type ~= 'private' then
                                                    text = text .. langs[msg.lang].sendTimeKeyboardPvt .. '\n'
                                                end
                                            else
                                                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                            end
                                        else
                                            text = text .. langs[msg.lang].require_rank .. '\n'
                                        end
                                    end
                                    if msg.chat.type ~= 'private' then
                                        local message_id = sendReply(msg, text).result.message_id
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                        return
                                    end
                                    return text
                                elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                    if compare_ranks(msg.from.id, msg.reply_to_message.removed.id, msg.chat.id) then
                                        if sendKeyboard(msg.from.id, '(' .. msg.reply_to_message.removed.id .. ') ' ..(database[tostring(msg.reply_to_message.removed.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time('TEMPBAN', msg.chat.id, msg.reply_to_message.removed.id)) then
                                            if msg.chat.type ~= 'private' then
                                                local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                                return
                                            end
                                        else
                                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                        end
                                    else
                                        return langs[msg.lang].require_rank
                                    end
                                else
                                    if compare_ranks(msg.from.id, msg.reply_to_message.from.id, msg.chat.id) then
                                        if sendKeyboard(msg.from.id, '(' .. msg.reply_to_message.from.id .. ') ' ..(database[tostring(msg.reply_to_message.from.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time('TEMPBAN', msg.chat.id, msg.reply_to_message.from.id)) then
                                            if msg.chat.type ~= 'private' then
                                                local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                                return
                                            end
                                        else
                                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                        end
                                    else
                                        return langs[msg.lang].require_rank
                                    end
                                end
                            end
                        else
                            local time, weeks, days, hours, minutes, seconds = 0
                            if matches[2] and matches[3] and matches[4] and matches[5] and matches[6] then
                                weeks = tonumber(matches[2])
                                days = tonumber(matches[3])
                                hours = tonumber(matches[4])
                                minutes = tonumber(matches[5])
                                seconds = tonumber(matches[6])
                                time =(weeks * 7 * 24 * 60 * 60) +(days * 24 * 60 * 60) +(hours * 60 * 60) +(minutes * 60) + seconds
                                return banUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[7] or '') .. ' ' ..(matches[8] or ''), os.time() + time)
                            else
                                if compare_ranks(msg.from.id, msg.reply_to_message.from.id, msg.chat.id) then
                                    if sendKeyboard(msg.from.id, '(' .. msg.reply_to_message.from.id .. ') ' ..(database[tostring(msg.reply_to_message.from.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time('TEMPBAN', msg.chat.id, msg.reply_to_message.from.id)) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                    end
                                else
                                    return langs[msg.lang].require_rank
                                end
                            end
                        end
                    end
                elseif matches[2] and matches[2] ~= '' then
                    local time, weeks, days, hours, minutes, seconds = 0
                    if matches[3] and matches[4] and matches[5] and matches[6] and matches[7] then
                        weeks = tonumber(matches[3])
                        days = tonumber(matches[4])
                        hours = tonumber(matches[5])
                        minutes = tonumber(matches[6])
                        seconds = tonumber(matches[7])
                        time =(weeks * 7 * 24 * 60 * 60) +(days * 24 * 60 * 60) +(hours * 60 * 60) +(minutes * 60) + seconds
                        if msg.entities then
                            for k, v in pairs(msg.entities) do
                                -- check if there's a text_mention
                                if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                    if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                        return banUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, matches[8] or '', os.time() + time)
                                    end
                                end
                            end
                        end
                        if string.match(matches[2], '^%d+$') then
                            return banUser(msg.from.id, matches[2], msg.chat.id, matches[8] or '', os.time() + time)
                        else
                            local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return banUser(msg.from.id, obj_user.id, msg.chat.id, matches[8] or '', os.time() + time)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        if msg.entities then
                            for k, v in pairs(msg.entities) do
                                -- check if there's a text_mention
                                if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                    if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                        if compare_ranks(msg.from.id, msg.entities[k].user.id, msg.chat.id) then
                                            if sendKeyboard(msg.from.id, '(' .. msg.entities[k].user.id .. ') ' ..(database[tostring(msg.entities[k].user.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time('TEMPBAN', msg.chat.id, msg.entities[k].user.id)) then
                                                if msg.chat.type ~= 'private' then
                                                    local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                                    return
                                                end
                                            else
                                                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                            end
                                        else
                                            return langs[msg.lang].require_rank
                                        end
                                    end
                                end
                            end
                        end
                        if string.match(matches[2], '^%d+$') then
                            if compare_ranks(msg.from.id, matches[2], msg.chat.id) then
                                if sendKeyboard(msg.from.id, '(' .. matches[2] .. ') ' ..(database[tostring(matches[2])]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time('TEMPBAN', msg.chat.id, matches[2])) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                end
                            else
                                return langs[msg.lang].require_rank
                            end
                        else
                            local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    if compare_ranks(msg.from.id, obj_user.id, msg.chat.id) then
                                        if sendKeyboard(msg.from.id, '(' .. obj_user.id .. ') ' ..(database[tostring(obj_user.id)]['print_name'] or '') .. ' in ' .. '(' .. msg.chat.id .. ') ' .. chat_name .. langs[msg.lang].tempBanIntro, keyboard_time('TEMPBAN', msg.chat.id, obj_user.id)) then
                                            if msg.chat.type ~= 'private' then
                                                local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt).result.message_id
                                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                                io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                                                return
                                            end
                                        else
                                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                                        end
                                    else
                                        return langs[msg.lang].require_rank
                                    end
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'ban' then
            if msg.from.is_mod then
                mystat('/ban')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return banUser(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id, matches[3] or '')
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        else
                            return banUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                        end
                    else
                        if msg.reply_to_message.service then
                            if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                                local text = banUser(msg.from.id, msg.reply_to_message.adder.id, msg.chat.id) .. '\n'
                                for k, v in pairs(msg.reply_to_message.added) do
                                    text = text .. banUser(msg.from.id, v.id, msg.chat.id) .. '\n'
                                end
                                return text ..(matches[2] or '') .. ' ' ..(matches[3] or '')
                            elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                return banUser(msg.from.id, msg.reply_to_message.removed.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            else
                                return banUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            end
                        else
                            return banUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                        end
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return banUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, matches[3] or '')
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        return banUser(msg.from.id, matches[2], msg.chat.id, matches[3] or '')
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return banUser(msg.from.id, obj_user.id, msg.chat.id, matches[3] or '')
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'unban' then
            if msg.from.is_mod then
                mystat('/unban')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return unbanUser(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id, matches[3] or '')
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        else
                            return unbanUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                        end
                    else
                        if msg.reply_to_message.service then
                            if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                                local text = unbanUser(msg.from.id, msg.reply_to_message.adder.id, msg.chat.id) .. '\n'
                                for k, v in pairs(msg.reply_to_message.added) do
                                    text = text .. unbanUser(msg.from.id, v.id, msg.chat.id) .. '\n'
                                end
                                return text ..(matches[2] or '') .. ' ' ..(matches[3] or '')
                            elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                return unbanUser(msg.from.id, msg.reply_to_message.removed.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            else
                                return unbanUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                            end
                        else
                            return unbanUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id,(matches[2] or '') .. ' ' ..(matches[3] or ''))
                        end
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return unbanUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, matches[3] or '')
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        return unbanUser(msg.from.id, matches[2], msg.chat.id, matches[3] or '')
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return unbanUser(msg.from.id, obj_user.id, msg.chat.id, matches[3] or '')
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
    end
    if matches[1]:lower() == 'gban' then
        if is_admin(msg) then
            mystat('/gban')
            if msg.reply then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                return gbanUser(msg.reply_to_message.forward_from.id, msg.lang)
                            else
                                return langs[msg.lang].cantDoThisToChat
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    end
                else
                    if msg.reply_to_message.service then
                        if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                            local text = gbanUser(msg.reply_to_message.adder.id, msg.lang) .. '\n'
                            for k, v in pairs(msg.reply_to_message.added) do
                                text = text .. gbanUser(v.id, msg.lang)
                            end
                            return text
                        elseif msg.reply_to_message.service_type == 'chat_del_user' then
                            return gbanUser(msg.reply_to_message.removed.id, msg.lang)
                        else
                            return gbanUser(msg.reply_to_message.from.id, msg.lang)
                        end
                    else
                        return gbanUser(msg.reply_to_message.from.id, msg.lang)
                    end
                end
            elseif matches[2] and matches[2] ~= '' then
                if msg.entities then
                    for k, v in pairs(msg.entities) do
                        -- check if there's a text_mention
                        if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                            if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                return gbanUser(msg.entities[k].user.id, msg.lang)
                            end
                        end
                    end
                end
                if string.match(matches[2], '^%d+$') then
                    return gbanUser(matches[2], msg.lang)
                else
                    local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            return gbanUser(obj_user.id, msg.lang)
                        end
                    else
                        return langs[msg.lang].noObject
                    end
                end
            end
            return
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1]:lower() == 'ungban' then
        if is_admin(msg) then
            mystat('/ungban')
            if msg.reply then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                return ungbanUser(msg.reply_to_message.forward_from.id, msg.lang)
                            else
                                return langs[msg.lang].cantDoThisToChat
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    end
                else
                    if msg.reply_to_message.service then
                        if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                            local text = ungbanUser(msg.reply_to_message.adder.id, msg.lang) .. '\n'
                            for k, v in pairs(msg.reply_to_message.added) do
                                text = text .. ungbanUser(v.id, msg.lang) .. '\n'
                            end
                            return text
                        elseif msg.reply_to_message.service_type == 'chat_del_user' then
                            return ungbanUser(msg.reply_to_message.removed.id, msg.lang)
                        else
                            return ungbanUser(msg.reply_to_message.from.id, msg.lang)
                        end
                    else
                        return ungbanUser(msg.reply_to_message.from.id, msg.lang)
                    end
                end
            elseif matches[2] and matches[2] ~= '' then
                if msg.entities then
                    for k, v in pairs(msg.entities) do
                        -- check if there's a text_mention
                        if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                            if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                return ungbanUser(msg.entities[k].user.id, msg.lang)
                            end
                        end
                    end
                end
                if string.match(matches[2], '^%d+$') then
                    return ungbanUser(matches[2], msg.lang)
                else
                    local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            return ungbanUser(obj_user.id, msg.lang)
                        end
                    else
                        return langs[msg.lang].noObject
                    end
                end
            end
            return
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1]:lower() == 'banlist' and matches[2] then
        if is_admin(msg) then
            mystat('/banlist <group_id>')
            return banList(matches[2])
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1]:lower() == 'countbanlist' and matches[2] then
        if is_admin(msg) then
            mystat('/countbanlist <group_id>')
            local list = redis:smembers('banned:' .. matches[2])
            return #list
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1]:lower() == 'gbanlist' then
        if is_admin(msg) then
            mystat('/gbanlist')
            local hash = 'gbanned'
            local list = redis:smembers(hash)
            local gbanlist = langs[get_lang(msg.chat.id)].gbanListStart
            for k, v in pairs(list) do
                local user_info = redis:hgetall('user:' .. v)
                if user_info and user_info.print_name then
                    local print_name = string.gsub(user_info.print_name, "_", " ")
                    local print_name = string.gsub(print_name, "?", "")
                    gbanlist = gbanlist .. k .. " - " .. print_name .. " [" .. v .. "]\n"
                else
                    gbanlist = gbanlist .. k .. " - " .. v .. "\n"
                end
            end
            local file = io.open("./groups/gbanlist.txt", "w")
            file:write(gbanlist)
            file:flush()
            file:close()
            return sendDocument(msg.chat.id, "./groups/gbanlist.txt")
            -- return sendMessage(msg.chat.id, gbanlist)
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1]:lower() == 'countgbanlist' then
        if is_admin(msg) then
            mystat('/countgbanlist')
            local list = redis:smembers('gbanned')
            return #list
        else
            return langs[msg.lang].require_admin
        end
    end
end

local function pre_process(msg)
    if msg then
        -- SERVICE MESSAGE
        if msg.service then
            if msg.service_type then
                -- Check if banned users joins chat
                if msg.service_type == 'chat_add_user' or msg.service_type == 'chat_add_users' then
                    local text = ''
                    local inviteFlood = false
                    if #msg.added >= 5 then
                        if not is_owner(msg) then
                            inviteFlood = true
                            text = text .. banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonInviteFlood)
                        end
                    end
                    local ban = false
                    local reason = ''
                    for k, v in pairs(msg.added) do
                        print('Checking invited user ' .. v.id)
                        if inviteFlood then
                            ban = true
                            reason = langs[msg.lang].reasonInviteFlood
                        end
                        if isBanned(v.id, msg.chat.id) and not msg.from.is_mod then
                            print('User is banned!')
                            ban = true
                            reason = langs[msg.lang].reasonBannedUser
                        end
                        if isGbanned(v.id) and not(is_admin2(msg.from.id) or isWhitelistedGban(msg.chat.tg_cli_id, v.id)) then
                            print('User is gbanned!')
                            ban = true
                            reason = langs[msg.lang].reasonGbannedUser
                        end
                        if ban then
                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added a banned user >" .. v.id)
                            -- Save to logs
                            text = text .. banUser(bot.id, v.id, msg.chat.id, reason)
                            local banhash = 'addedbanuser:' .. msg.chat.id .. ':' .. msg.from.id
                            redis:incr(banhash)
                            local banhash = 'addedbanuser:' .. msg.chat.id .. ':' .. msg.from.id
                            local banaddredis = redis:get(banhash)
                            if banaddredis then
                                if tonumber(banaddredis) >= 4 and not msg.from.is_owner then
                                    text = text .. kickUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonInviteBanned)
                                    -- Kick user who adds ban ppl more than 3 times
                                end
                                if tonumber(banaddredis) >= 8 and not msg.from.is_owner then
                                    text = text .. banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonInviteBanned)
                                    -- Ban user who adds ban ppl more than 7 times
                                    local banhash = 'addedbanuser:' .. msg.chat.id .. ':' .. msg.from.id
                                    redis:set(banhash, 0)
                                    -- Reset the Counter
                                end
                            end
                        end
                        ban = false
                        reason = ''
                    end
                    if text ~= '' then
                        sendMessage(msg.chat.id, text)
                    end
                end
                -- Check if banned user joins chat by link
                if msg.service_type == 'chat_add_user_link' then
                    local ban = false
                    local reason = ''
                    print('Checking invited user ' .. msg.from.id)
                    if isBanned(msg.from.id, msg.chat.id) and not msg.from.is_mod then
                        print('User is banned!')
                        ban = true
                        reason = langs[msg.lang].reasonBannedUser
                    end
                    if isGbanned(msg.from.id) and not(is_admin2(msg.from.id) or isWhitelistedGban(msg.chat.tg_cli_id, msg.from.id)) then
                        print('User is gbanned!')
                        ban = true
                        reason = langs[msg.lang].reasonGbannedUser
                    end
                    if ban then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] is banned and kicked ! ")
                        -- Save to logs
                        sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, reason))
                    end
                end
                -- No further checks
                return msg
            end
        end
        -- banned user is talking !
        if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
            local ban = false
            local reason = ''
            if isBanned(msg.from.id, msg.chat.id) then
                print('Banned user talking!')
                ban = true
                reason = langs[msg.lang].reasonBannedUser
            end
            if isGbanned(msg.from.id) and not isWhitelistedGban(msg.chat.tg_cli_id, msg.from.id) then
                print('Gbanned user talking!')
                ban = true
                reason = langs[msg.lang].reasonGbannedUser
            end
            if ban then
                -- Check it with redis
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] banned user is talking !")
                -- Save to logs
                local txt = banUser(bot.id, msg.from.id, msg.chat.id, reason)
                if txt == langs[msg.lang].errors[1] or txt == langs[msg.lang].errors[2] or txt == langs[msg.lang].errors[3] or txt == langs[msg.lang].errors[4] then
                    if kick_ban_errors[tostring(chat_id)] then
                        if txt ~= kick_ban_errors[tostring(chat_id)] then
                            kick_ban_errors[tostring(chat_id)] = txt
                            sendMessage(msg.chat.id, txt)
                        end
                    else
                        kick_ban_errors[tostring(chat_id)] = txt
                        sendMessage(msg.chat.id, txt)
                    end
                else
                    sendMessage(msg.chat.id, txt)
                end
                return nil
            end
        end
        return msg
    end
end

local function cron()
    -- clear table on the top of the plugin
    kick_ban_errors = { }
end

return {
    description = "BANHAMMER",
    cron = cron,
    patterns =
    {
        "^(###cbbanhammer)(DELETE)$",
        "^(###cbbanhammer)(BACK)(%d+)(%-%d+)$",
        "^(###cbbanhammer)(RESTRICT)(%d+)(.*)(%-%d+)$",
        "^(###cbbanhammer)(UNRESTRICT)(%d+)(.*)(%-%d+)$",
        "^(###cbbanhammer)(TEMPBAN)(%d+)(BACK)(%d+)(%-%d+)$",
        "^(###cbbanhammer)(TEMPBAN)(%d+)(SECONDS)([%+%-]?%d+)(%-%d+)%$(%d+)$",
        "^(###cbbanhammer)(TEMPBAN)(%d+)(MINUTES)([%+%-]?%d+)(%-%d+)%$(%d+)$",
        "^(###cbbanhammer)(TEMPBAN)(%d+)(HOURS)([%+%-]?%d+)(%-%d+)%$(%d+)$",
        "^(###cbbanhammer)(TEMPBAN)(%d+)(DAYS)([%+%-]?%d+)(%-%d+)%$(%d+)$",
        "^(###cbbanhammer)(TEMPBAN)(%d+)(WEEKS)([%+%-]?%d+)(%-%d+)%$(%d+)$",
        "^(###cbbanhammer)(TEMPBAN)(%d+)(DONE)(%d+)(%-%d+)$",
        "^(###cbbanhammer)(TEMPRESTRICT)(%d+)(BACK)(%d+)(%-%d+)$",
        "^(###cbbanhammer)(TEMPRESTRICT)(%d+)(SECONDS)([%+%-]?%d+)(%-%d+)%$(%d+)$",
        "^(###cbbanhammer)(TEMPRESTRICT)(%d+)(MINUTES)([%+%-]?%d+)(%-%d+)%$(%d+)$",
        "^(###cbbanhammer)(TEMPRESTRICT)(%d+)(HOURS)([%+%-]?%d+)(%-%d+)%$(%d+)$",
        "^(###cbbanhammer)(TEMPRESTRICT)(%d+)(DAYS)([%+%-]?%d+)(%-%d+)%$(%d+)$",
        "^(###cbbanhammer)(TEMPRESTRICT)(%d+)(WEEKS)([%+%-]?%d+)(%-%d+)%$(%d+)$",
        "^(###cbbanhammer)(TEMPRESTRICT)(%d+)(DONE)(%d+)(%-%d+)$",

        "^[#!/]([Gg][Ee][Tt][Uu][Ss][Ee][Rr][Ww][Aa][Rr][Nn][Ss]) ([^%s]+)$",
        "^[#!/]([Gg][Ee][Tt][Uu][Ss][Ee][Rr][Ww][Aa][Rr][Nn][Ss])$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn][Aa][Ll][Ll]) ([^%s]+) ?(.*)$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn][Aa][Ll][Ll]) (.*)$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn][Aa][Ll][Ll])$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn]) ([^%s]+) ?(.*)$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn]) (.*)$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn])$",
        "^[#!/]([Ww][Aa][Rr][Nn]) ([^%s]+) ?(.*)$",
        "^[#!/]([Ww][Aa][Rr][Nn]) (.*)$",
        "^[#!/]([Ww][Aa][Rr][Nn])$",
        "^[#!/]([Mm][Uu][Tt][Ee][Uu][Ss][Ee][Rr]) ([^%s]+)$",
        "^[#!/]([Mm][Uu][Tt][Ee][Uu][Ss][Ee][Rr])$",
        "^[#!/]([Mm][Uu][Tt][Ee][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) ([^%s]+) (.*)$",
        "^[#!/]([Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) (.*)$",
        "^[#!/]([Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt])$",
        "^[#!/]([Tt][Ee][Mm][Pp][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) ([^%s]+) (%d+) (%d+) (%d+) (%d+) (%d+) (.*)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) (%d+) (%d+) (%d+) (%d+) (%d+) (.*)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) (%d+) (%d+) (%d+) (%d+) (%d+)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) ([^%s]+) (.*)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) (.*)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt])$",
        "^[#!/]([Uu][Nn][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) ([^%s]+)$",
        "^[#!/]([Uu][Nn][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt])$",
        "^[#!/]([Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt][Ii][Oo][Nn][Ss]) ([^%s]+)$",
        "^[#!/]([Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt][Ii][Oo][Nn][Ss])$",
        "^[#!/]([Tt][Ee][Mm][Pp][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt][Ii][Oo][Nn][Ss]) ([^%s]+)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt][Ii][Oo][Nn][Ss])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt][Ii][Oo][Nn][Ss]) ([^%s]+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt][Ii][Oo][Nn][Ss])$",
        "^[#!/]([Kk][Ii][Cc][Kk][Mm][Ee])",
        "^[#!/]([Kk][Ii][Cc][Kk][Rr][Aa][Nn][Dd][Oo][Mm])$",
        "^[#!/]([Kk][Ii][Cc][Kk][Nn][Oo][Uu][Ss][Ee][Rr])$",
        "^[#!/]([Kk][Ii][Cc][Kk][Ii][Nn][Aa][Cc][Tt][Ii][Vv][Ee])$",
        "^[#!/]([Kk][Ii][Cc][Kk][Ii][Nn][Aa][Cc][Tt][Ii][Vv][Ee]) (%d+)$",
        "^[#!/]([Kk][Ii][Cc][Kk][Dd][Ee][Ll][Ee][Tt][Ee][Dd])$",
        "^[#!/]([Kk][Ii][Cc][Kk]) ([^%s]+) ?(.*)$",
        "^[#!/]([Kk][Ii][Cc][Kk]) (.*)$",
        "^[#!/]([Kk][Ii][Cc][Kk])$",
        "^[#!/]([Bb][Aa][Nn][Ll][Ii][Ss][Tt]) (%-%d+)$",
        "^[#!/]([Bb][Aa][Nn][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Cc][Oo][Uu][Nn][Tt][Bb][Aa][Nn][Ll][Ii][Ss][Tt]) (%-%d+)$",
        "^[#!/]([Cc][Oo][Uu][Nn][Tt][Bb][Aa][Nn][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Bb][Aa][Nn]) ([^%s]+) ?(.*)$",
        "^[#!/]([Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Bb][Aa][Nn])$",
        "^[#!/]([Tt][Ee][Mm][Pp][Bb][Aa][Nn]) ([^%s]+) (%d+) (%d+) (%d+) (%d+) (%d+) ?(.*)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Bb][Aa][Nn]) (%d+) (%d+) (%d+) (%d+) (%d+) (.*)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Bb][Aa][Nn]) (%d+) (%d+) (%d+) (%d+) (%d+)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Bb][Aa][Nn]) ([^%s]+) ?(.*)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Bb][Aa][Nn])$",
        "^[#!/]([Uu][Nn][Bb][Aa][Nn]) ([^%s]+) ?(.*)$",
        "^[#!/]([Uu][Nn][Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Uu][Nn][Bb][Aa][Nn])$",
        "^[#!/]([Gg][Bb][Aa][Nn]) ([^%s]+)$",
        "^[#!/]([Gg][Bb][Aa][Nn])$",
        "^[#!/]([Uu][Nn][Gg][Bb][Aa][Nn]) ([^%s]+)$",
        "^[#!/]([Uu][Nn][Gg][Bb][Aa][Nn])$",
        "^[#!/]([Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Cc][Oo][Uu][Nn][Tt][Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt])$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#kickme",
        "MOD",
        "#getuserwarns <id>|<username>|<reply>|from",
        "#muteuser <id>|<username>|<reply>|from",
        "#mutelist",
        "#warn <id>|<username>|<reply>|from [<reason>]",
        "#unwarn <id>|<username>|<reply>|from [<reason>]",
        "#unwarnall <id>|<username>|<reply>|from [<reason>]",
        "#temprestrict <id>|<username>|<reply>|from [<weeks> <days> <hours> <minutes> <seconds>] [send_messages] [send_media_messages] [send_other_messages] [add_web_page_previews]",
        "#restrict <id>|<username>|<reply>|from [send_messages] [send_media_messages] [send_other_messages] [add_web_page_previews]",
        "#unrestrict <id>|<username>|<reply>|from",
        "#[textual]restrictions <id>|<username>|<reply>|from",
        "#kick <id>|<username>|<reply>|from [<reason>]",
        "#tempban <id>|<username>|<reply>|from [<weeks> <days> <hours> <minutes> <seconds>] [<reason>]",
        "#ban <id>|<username>|<reply>|from [<reason>]",
        "#unban <id>|<username>|<reply>|from [<reason>]",
        "#[count]banlist",
        -- "#kickrandom",
        -- "#kickdeleted",
        "OWNER",
        -- "#kicknouser",
        -- "#kickinactive [<msgs>]",
        "ADMIN",
        "#[count]banlist <group_id>",
        "#gban <id>|<username>|<reply>|from",
        "#ungban <id>|<username>|<reply>|from",
        "#[count]gbanlist",
    },
}