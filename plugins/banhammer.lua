local kick_ban_errors = { }
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

local restrictionsDictionary = {
    ["can_send_messages"] = "can_send_messages",
    ["send_messages"] = "can_send_messages",
    ["can_send_media_messages"] = "can_send_media_messages",
    ["send_media_messages"] = "can_send_media_messages",
    ["can_send_other_messages"] = "can_send_other_messages",
    ["send_other_messages"] = "can_send_other_messages",
    ["can_add_web_page_previews"] = "can_add_web_page_previews",
    ["add_web_page_previews"] = "can_add_web_page_previews",
}

local reverseRestrictionsDictionary = {
    ["can_send_messages"] = "send_messages",
    ["send_messages"] = "send_messages",
    ["can_send_media_messages"] = "send_media_messages",
    ["send_media_messages"] = "send_media_messages",
    ["can_send_other_messages"] = "send_other_messages",
    ["send_other_messages"] = "send_other_messages",
    ["can_add_web_page_previews"] = "add_web_page_previews",
    ["add_web_page_previews"] = "add_web_page_previews",
}

local function adjustRestrictions(param_restrictions)
    local restrictions = {
        can_send_messages = true,
        can_send_media_messages = true,
        can_send_other_messages = true,
        can_add_web_page_previews = true
    }
    if param_restrictions then
        if type(param_restrictions) == 'table' then
            for k, v in pairs(param_restrictions) do
                if restrictionsDictionary[k] then
                    restrictions[tostring(restrictionsDictionary[k])] = param_restrictions[tostring(restrictionsDictionary[k])]
                end
            end
        elseif type(param_restrictions) == 'string' then
            param_restrictions = param_restrictions:lower()
            for k, v in pairs(param_restrictions:split(' ')) do
                if restrictionsDictionary[v] then
                    if restrictionsDictionary[v] == 'can_send_messages' then
                        restrictions[restrictionsDictionary[v]] = false
                        restrictions['can_send_media_messages'] = false
                        restrictions['can_send_other_messages'] = false
                        restrictions['can_add_web_page_previews'] = false
                    end
                    if restrictionsDictionary[v] == 'can_send_media_messages' then
                        restrictions[restrictionsDictionary[v]] = false
                        restrictions['can_send_other_messages'] = false
                        restrictions['can_add_web_page_previews'] = false
                    end
                    if restrictionsDictionary[v] == 'can_send_other_messages' then
                        restrictions[restrictionsDictionary[v]] = false
                    end
                    if restrictionsDictionary[v] == 'can_add_web_page_previews' then
                        restrictions[restrictionsDictionary[v]] = false
                    end
                end
            end
        end
    end
    return restrictions
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
        if obj_user.status == 'member' then
            local text = langs[lang].restrictions ..
            langs[lang].restrictionSendMessages .. tostring(obj_user.can_send_messages or false) ..
            langs[lang].restrictionSendMediaMessages .. tostring(obj_user.can_send_media_messages or false) ..
            langs[lang].restrictionSendOtherMessages .. tostring(obj_user.can_send_other_messages or false) ..
            langs[lang].restrictionAddWebPagePreviews .. tostring(obj_user.can_add_web_page_previews or false)
            return text
        else
            return langs[lang].errorTryAgain
        end
    else
        return langs[lang].errorTryAgain
    end
end

local function keyboard_restrictions_list(chat_id, user_id, param_restrictions)
    if not param_restrictions then
        local obj_user = getChatMember(chat_id, user_id)
        if type(obj_user) == 'table' then
            if obj_user.result then
                -- assign user to restrictions
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
        param_restrictions = obj_user
    end
    if param_restrictions then
        local restrictions = adjustRestrictions(param_restrictions)
        local keyboard = { }
        keyboard.inline_keyboard = { }
        local row = 1
        local column = 1
        keyboard.inline_keyboard[row] = { }
        for var, value in pairs(restrictions) do
            if type(value) == 'boolean' then
                if value then
                    keyboard.inline_keyboard[row][column] = { text = '✅' .. reverseRestrictionsDictionary[var], callback_data = 'banhammerRESTRICT' .. user_id .. reverseRestrictionsDictionary[var] .. chat_id }
                else
                    keyboard.inline_keyboard[row][column] = { text = '🚫' .. reverseRestrictionsDictionary[var], callback_data = 'banhammerUNRESTRICT' .. user_id .. reverseRestrictionsDictionary[var] .. chat_id }
                end
                row = row + 1
                keyboard.inline_keyboard[row] = { }
            end
        end
        keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].updateKeyboard, callback_data = 'banhammerBACK' .. user_id .. chat_id }
        column = column + 1
        keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].deleteKeyboard, callback_data = 'banhammerDELETE' }
        return keyboard
    else
        local keyboard = { }
        keyboard.inline_keyboard = { }
        local row = 1
        local column = 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].deleteKeyboard, callback_data = 'banhammerDELETE' }
        return keyboard
    end
end

local function run(msg, matches)
    if msg.service then
        return
    end
    if msg.cb then
        if matches[1] then
            if matches[1] == '###cbbanhammer' then
                if matches[2] then
                    if matches[2] == 'DELETE' then
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                    elseif matches[2] == 'BACK' then
                        if matches[3] and matches[4] then
                            editMessageText(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', matches[4]), 'X', tostring(matches[3])) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(matches[4], matches[3]))
                        end
                    elseif matches[3] and matches[4] then
                        if matches[5] then
                            if matches[2] == 'RESTRICT' then
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
                                        editMessageText(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', matches[5]), 'X', tostring(matches[3])) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(matches[5], matches[3], restrictions))
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
                                        editMessageText(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', matches[5]), 'X', tostring(matches[3])) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(matches[5], matches[3], restrictions))
                                    end
                                else
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                                end
                            end
                        end
                    end
                    return
                end
            end
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
        if matches[1]:lower() == 'restrict' then
            if msg.from.is_mod then
                mystat('/restrict')
                local restrictions = clone_table(default_restrictions)
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    if matches[3] then
                                        restrictions = adjustRestrictions(matches[3]:lower())
                                    end
                                    return restrictChatMember(msg.chat.id, msg.reply_to_message.forward_from.id, restrictions)
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
                            return restrictChatMember(msg.chat.id, msg.reply_to_message.from.id, restrictions)
                        end
                    else
                        if matches[2] then
                            restrictions = adjustRestrictions(matches[2]:lower())
                        end
                        return restrictChatMember(msg.chat.id, msg.reply_to_message.from.id, restrictions)
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    if matches[3] then
                                        restrictions = adjustRestrictions(matches[3]:lower())
                                    end
                                    return restrictChatMember(msg.chat.id, obj_user.id, restrictions)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                if matches[3] then
                                    restrictions = adjustRestrictions(matches[3]:lower())
                                end
                                return restrictChatMember(msg.chat.id, obj_user.id, restrictions)
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
        if matches[1]:lower() == 'unrestrict' then
            if msg.from.is_owner then
                mystat('/unrestrict')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return unrestrictChatMember(msg.chat.id, msg.reply_to_message.forward_from.id)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return unrestrictChatMember(msg.chat.id, msg.reply_to_message.from.id)
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return unrestrictChatMember(msg.chat.id, obj_user.id)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return unrestrictChatMember(msg.chat.id, obj_user.id)
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
            if msg.reply then
                if msg.from.is_mod then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    if msg.chat.type ~= 'private' then
                                        sendReply(msg, langs[msg.lang].sendRestrictionsPvt)
                                    end
                                    sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', msg.chat.id), 'X', tostring(msg.reply_to_message.forward_from.id)) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(msg.chat.id, msg.reply_to_message.forward_from.id))
                                    return
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        if msg.chat.type ~= 'private' then
                            sendReply(msg, langs[msg.lang].sendRestrictionsPvt)
                        end
                        sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', msg.chat.id), 'X', tostring(msg.reply_to_message.from.id)) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(msg.chat.id, msg.reply_to_message.from.id))
                        return
                    end
                else
                    return langs[msg.lang].require_mod
                end
            elseif matches[2] and matches[2] ~= '' then
                if msg.from.is_mod then
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    if msg.chat.type ~= 'private' then
                                        sendReply(msg, langs[msg.lang].sendRestrictionsPvt)
                                    end
                                    sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', msg.chat.id), 'X', tostring(obj_user.id)) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(msg.chat.id, obj_user.id))
                                    return
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                if msg.chat.type ~= 'private' then
                                    sendReply(msg, langs[msg.lang].sendRestrictionsPvt)
                                end
                                sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].restrictionsOf, 'Y', msg.chat.id), 'X', tostring(obj_user.id)) .. '\n' .. langs[msg.lang].restrictionsIntro, keyboard_restrictions_list(msg.chat.id, obj_user.id))
                                return
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                else
                    return langs[msg.lang].require_mod
                end
            end
            return
        end
        if matches[1]:lower() == 'textualrestrictions' then
            mystat('/restrictions')
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
                if string.match(matches[2], '^%d+$') then
                    return showRestrictions(msg.chat.id, matches[2], msg.lang)
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
end

local function pre_process(msg)
    if msg then
        -- SERVICE MESSAGE
        if msg.service then
            if msg.service_type then
                -- Check if banned users joins chat
                if msg.service_type == 'chat_add_user' or msg.service_type == 'chat_add_users' then
                    if #msg.added >= 5 then
                        if not is_owner(msg) then
                            sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonInviteFlood))
                        end
                    end
                    for k, v in pairs(msg.added) do
                        print('Checking invited user ' .. v.id)
                        if isBanned(v.id, msg.chat.id) and not msg.from.is_mod or(isGbanned(v.id) and not(is_admin2(msg.from.id) or isWhitelistedGban(msg.chat.tg_cli_id, v.id))) then
                            -- Check it with redis
                            print('User is banned!')
                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added a banned user >" .. v.id)
                            -- Save to logs
                            sendMessage(msg.chat.id, banUser(bot.id, v.id, msg.chat.id, langs[msg.lang].reasonBannedUser))
                            local banhash = 'addedbanuser:' .. msg.chat.id .. ':' .. msg.from.id
                            redis:incr(banhash)
                            local banhash = 'addedbanuser:' .. msg.chat.id .. ':' .. msg.from.id
                            local banaddredis = redis:get(banhash)
                            if banaddredis then
                                if tonumber(banaddredis) >= 4 and not msg.from.is_owner then
                                    sendMessage(msg.chat.id, kickUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonInviteBanned))
                                    -- Kick user who adds ban ppl more than 3 times
                                end
                                if tonumber(banaddredis) >= 8 and not msg.from.is_owner then
                                    sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonInviteBanned))
                                    -- Ban user who adds ban ppl more than 7 times
                                    local banhash = 'addedbanuser:' .. msg.chat.id .. ':' .. msg.from.id
                                    redis:set(banhash, 0)
                                    -- Reset the Counter
                                end
                            end
                        end
                        local bots_protection = false
                        if data[tostring(msg.chat.id)] then
                            if data[tostring(msg.chat.id)].settings then
                                if data[tostring(msg.chat.id)].settings.lock_bots then
                                    bots_protection = data[tostring(msg.chat.id)].settings.lock_bots
                                end
                            end
                        end
                        if v.username then
                            if bots_protection then
                                if not msg.from.is_mod then
                                    if string.sub(v.username:lower(), -3) == 'bot' then
                                        --- Will kick bots added by normal users
                                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added a bot > @" .. v.username)
                                        -- Save to logs
                                        sendMessage(msg.chat.id, banUser(bot.id, v.id, msg.chat.id))
                                    end
                                end
                            end
                        end
                    end
                end
                -- Check if banned user joins chat by link
                if msg.service_type == 'chat_add_user_link' then
                    print('Checking invited user ' .. msg.from.id)
                    if isWhitelistedGban(msg.chat.tg_cli_id, msg.from.id) then
                        return msg
                    end
                    if isBanned(msg.from.id, msg.chat.id) or(isGbanned(msg.from.id) and not isWhitelistedGban(msg.chat.tg_cli_id, msg.from.id)) then
                        -- Check it with redis
                        print('User is banned!')
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] is banned and kicked ! ")
                        -- Save to logs
                        sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id))
                    end
                end
                -- No further checks
                return msg
            end
        end
        -- banned user is talking !
        if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
            if isBanned(msg.from.id, msg.chat.id) or(isGbanned(msg.from.id) and not isWhitelistedGban(msg.chat.tg_cli_id, msg.from.id)) then
                -- Check it with redis
                print('Banned user talking!')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] banned user is talking !")
                -- Save to logs
                local txt = banUser(bot.id, msg.from.id, msg.chat.id)
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
        "^[#!/]([Uu][Nn][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) ([^%s]+)$",
        "^[#!/]([Uu][Nn][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt])$",
        "^[#!/]([Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt][Ii][Oo][Nn][Ss]) ([^%s]+)$",
        "^[#!/]([Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt][Ii][Oo][Nn][Ss])$",
        "^[#!/]([Kk][Ii][Cc][Kk][Mm][Ee])",
        "^[#!/]([Kk][Ii][Cc][Kk][Rr][Aa][Nn][Dd][Oo][Mm])$",
        "^[#!/]([Kk][Ii][Cc][Kk][Nn][Oo][Uu][Ss][Ee][Rr])$",
        "^[#!/]([Kk][Ii][Cc][Kk][Ii][Nn][Aa][Cc][Tt][Ii][Vv][Ee])$",
        "^[#!/]([Kk][Ii][Cc][Kk][Ii][Nn][Aa][Cc][Tt][Ii][Vv][Ee]) (%d+)$",
        "^[#!/]([Kk][Ii][Cc][Kk][Dd][Ee][Ll][Ee][Tt][Ee][Dd])$",
        "^[#!/]([Kk][Ii][Cc][Kk]) ([^%s]+) ?(.*)$",
        "^[#!/]([Kk][Ii][Cc][Kk]) (.*)$",
        "^[#!/]([Kk][Ii][Cc][Kk])$",
        "^[#!/]([Bb][Aa][Nn][Ll][Ii][Ss][Tt]) ([^%s]+)$",
        "^[#!/]([Bb][Aa][Nn][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Bb][Aa][Nn]) ([^%s]+) ?(.*)$",
        "^[#!/]([Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Bb][Aa][Nn])$",
        "^[#!/]([Uu][Nn][Bb][Aa][Nn]) ([^%s]+) ?(.*)$",
        "^[#!/]([Uu][Nn][Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Uu][Nn][Bb][Aa][Nn])$",
        "^[#!/]([Gg][Bb][Aa][Nn]) ([^%s]+)$",
        "^[#!/]([Gg][Bb][Aa][Nn])$",
        "^[#!/]([Uu][Nn][Gg][Bb][Aa][Nn]) ([^%s]+)$",
        "^[#!/]([Uu][Nn][Gg][Bb][Aa][Nn])$",
        "^[#!/]([Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt])$",
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
        "#restrict <id>|<username>|<reply>|from [send_messages] [send_media_messages] [send_other_messages] [add_web_page_previews]",
        "#unrestrict <id>|<username>|<reply>|from",
        "#restrictions <id>|<username>|<reply>|from",
        "#kick <id>|<username>|<reply>|from [<reason>]",
        "#ban <id>|<username>|<reply>|from [<reason>]",
        "#unban <id>|<username>|<reply>|from [<reason>]",
        "#banlist",
        -- "#kickrandom",
        -- "#kickdeleted",
        "OWNER",
        -- "#kicknouser",
        -- "#kickinactive [<msgs>]",
        "ADMIN",
        "#banlist <group_id>",
        "#gban <id>|<username>|<reply>|from",
        "#ungban <id>|<username>|<reply>|from",
        "#gbanlist",
    },
}