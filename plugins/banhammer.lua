local kick_ban_errors = { }

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

local function run(msg, matches)
    if msg.service then
        return
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
        if matches[1]:lower() == 'gban' then
            if is_admin(msg) then
                mystat('/gban')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    gbanUser(msg.reply_to_message.forward_from.id)
                                    return langs[msg.lang].user .. msg.reply_to_message.forward_from.id .. langs[msg.lang].gbanned
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
                                gbanUser(msg.reply_to_message.adder.id)
                                local text = langs[msg.lang].user .. msg.reply_to_message.adder.id .. langs[msg.lang].gbanned '\n'
                                for k, v in pairs(msg.reply_to_message.added) do
                                    gbanUser(v.id)
                                    text = text .. langs[msg.lang].user .. v.id .. langs[msg.lang].gbanned .. '\n'
                                end
                                return text
                            elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                gbanUser(msg.reply_to_message.removed.id)
                                return langs[msg.lang].user .. msg.reply_to_message.removed.id .. langs[msg.lang].gbanned
                            else
                                gbanUser(msg.reply_to_message.from.id)
                                return langs[msg.lang].user .. msg.reply_to_message.from.id .. langs[msg.lang].gbanned
                            end
                        else
                            gbanUser(msg.reply_to_message.from.id)
                            return langs[msg.lang].user .. msg.reply_to_message.from.id .. langs[msg.lang].gbanned
                        end
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if string.match(matches[2], '^%d+$') then
                        gbanUser(matches[2])
                        return langs[msg.lang].user .. matches[2] .. langs[msg.lang].gbanned
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                gbanUser(obj_user.id)
                                return langs[msg.lang].user .. obj_user.id .. langs[msg.lang].gbanned
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
                                    ungbanUser(msg.reply_to_message.forward_from.id)
                                    return langs[msg.lang].user .. msg.reply_to_message.forward_from.id .. langs[msg.lang].ungbanned
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
                                ungbanUser(msg.reply_to_message.adder.id)
                                local text = langs[msg.lang].user .. msg.reply_to_message.adder.id .. langs[msg.lang].ungbanned '\n'
                                for k, v in pairs(msg.reply_to_message.added) do
                                    ungbanUser(v.id)
                                    text = text .. langs[msg.lang].user .. v.id .. langs[msg.lang].ungbanned .. '\n'
                                end
                                return text
                            elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                ungbanUser(msg.reply_to_message.removed.id)
                                return langs[msg.lang].user .. msg.reply_to_message.removed.id .. langs[msg.lang].ungbanned
                            else
                                ungbanUser(msg.reply_to_message.from.id)
                                return langs[msg.lang].user .. msg.reply_to_message.from.id .. langs[msg.lang].ungbanned
                            end
                        else
                            ungbanUser(msg.reply_to_message.from.id)
                            return langs[msg.lang].user .. msg.reply_to_message.from.id .. langs[msg.lang].ungbanned
                        end
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if string.match(matches[2], '^%d+$') then
                        ungbanUser(matches[2])
                        return langs[msg.lang].user .. matches[2] .. langs[msg.lang].ungbanned
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                ungbanUser(obj_user.id)
                                return langs[msg.lang].user .. obj_user.id .. langs[msg.lang].ungbanned
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
    else
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
end

local function clean_msg(msg)
    -- clean msg but returns it
    msg.cleaned = true
    if msg.text then
        msg.text = ''
    end
    if msg.media then
        if msg.caption then
            msg.caption = ''
        end
    end
    return msg
end

local function pre_process(msg)
    if msg then
        -- SERVICE MESSAGE
        if msg.service then
            if msg.service_type then
                -- Check if banned users joins chat
                if msg.service_type == 'chat_add_user' or msg.service_type == 'chat_add_users' then
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
                msg = clean_msg(msg)
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
        "#warn <id>|<username>|<reply>|from [<reason>]",
        "#unwarn <id>|<username>|<reply>|from [<reason>]",
        "#unwarnall <id>|<username>|<reply>|from [<reason>]",
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