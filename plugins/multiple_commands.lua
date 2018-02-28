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
    return reverse_rank_table[rank]
end

local function get_object_info(obj, chat_id)
    local lang = get_lang(chat_id)
    printvardump(obj)
    if obj then
        local text = langs[lang].infoWord
        if obj.type == 'bot' then
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
            if tonumber(chat_id) < 0 then
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
                if isWhitelisted(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'WHITELISTED '
                end
                if isWhitelistedGban(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'WHITELISTEDGBAN '
                end
                if isBanned(obj.id, chat_id) then
                    otherinfo = otherinfo .. 'BANNED '
                end
                if isMutedUser(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'MUTED '
                end
                if string.match(getUserWarns(obj.id, chat_id), '%d+') then
                    otherinfo = otherinfo .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. '/' ..(data[tostring(chat_id)].settings.max_warns or 0) .. ' WARN '
                end
            end
            if isGbanned(obj.id) then
                otherinfo = otherinfo .. 'GBANNED '
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
            text = text .. langs[lang].rank .. reverse_rank_table[get_rank(obj.id, chat_id, true)] ..
            langs[lang].date .. os.date('%c') ..
            langs[lang].totalMessages .. msgs
            local otherinfo = langs[lang].otherInfo
            if tonumber(chat_id) < 0 then
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
                if isWhitelisted(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'WHITELISTED '
                end
                if isWhitelistedGban(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'WHITELISTEDGBAN '
                end
                if isBanned(obj.id, chat_id) then
                    otherinfo = otherinfo .. 'BANNED '
                end
                if isMutedUser(chat_id, obj.id) then
                    otherinfo = otherinfo .. 'MUTED '
                end
                if string.match(getUserWarns(obj.id, chat_id), '%d+') then
                    otherinfo = otherinfo .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. '/' ..(data[tostring(chat_id)].settings.max_warns or 0) .. ' WARN '
                end
            end
            if isGbanned(obj.id) then
                otherinfo = otherinfo .. 'GBANNED '
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
    if matches[2] then
        local tab = matches[2]:split(' ')
        local txt = ''
        if matches[1]:lower() == 'multipleid' then
            if msg.from.is_mod then
                mystat('/multipleid')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. msg.entities[k].user.id
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. user
                        else
                            local obj = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj then
                                txt = txt .. obj.id
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'multipleusername' then
            if msg.from.is_mod then
                mystat('/multipleusername')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' ..(msg.entities[k].user.username or('NOUSER ' .. msg.entities[k].user.first_name .. ' ' ..(msg.entities[k].user.last_name or '')))
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            local obj = getChat(user)
                            if obj then
                                txt = txt .. obj.username or('NOUSER ' ..(obj.first_name or obj.title) .. ' ' ..(obj.last_name or ''))
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        else
                            txt = txt .. user
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'multipleishere' then
            if msg.from.is_mod then
                mystat('/multipleishere')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. is_here(msg.chat.id, msg.entities[k].user.id)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. is_here(msg.chat.id, tonumber(user))
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. is_here(msg.chat.id, obj_user.id)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'multiplegetrank' then
            if msg.from.is_mod then
                mystat('/multiplegetrank')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. get_reverse_rank(msg.chat.id, msg.entities[k].user.id, true)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. get_reverse_rank(msg.chat.id, user, true)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. get_reverse_rank(msg.chat.id, obj_user.id, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'multipleinfo' then
            if msg.from.is_mod then
                mystat('/multipleinfo')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. get_object_info(msg.entities[k].user, msg.chat.id) .. '\n'
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%-?%d+$') then
                            txt = txt .. get_object_info(getChat(user), msg.chat.id) .. '\n'
                        else
                            txt = txt .. get_object_info(getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or '')), msg.chat.id) .. '\n'
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'multiplegetuserwarns' then
            if msg.from.is_mod then
                mystat('/multiplegetuserwarns')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. getUserWarns(msg.entities[k].user.id, msg.chat.id)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. getUserWarns(user, msg.chat.id)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. getUserWarns(obj_user.id, msg.chat.id)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'multiplemuteuser' then
            if msg.from.is_mod then
                mystat('/multiplemuteuser')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    if compare_ranks(msg.from.id, msg.entities[k].user.id, msg.chat.id) then
                                        if isMutedUser(msg.chat.id, user) then
                                            txt = txt .. user .. ' ' .. unmuteUser(msg.chat.id, msg.entities[k].user.id, msg.lang, true)
                                        else
                                            txt = txt .. user .. ' ' .. muteUser(msg.chat.id, msg.entities[k].user.id, msg.lang, true)
                                        end
                                    else
                                        txt = txt .. user .. ' ' .. langs[msg.lang].require_rank
                                    end
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            -- ignore higher or same rank
                            if compare_ranks(msg.from.id, user, msg.chat.id) then
                                if isMutedUser(msg.chat.id, user) then
                                    txt = txt .. unmuteUser(msg.chat.id, user, msg.lang, true)
                                else
                                    txt = txt .. muteUser(msg.chat.id, user, msg.lang, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].require_rank
                            end
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    -- ignore higher or same rank
                                    if compare_ranks(msg.from.id, obj_user.id, msg.chat.id) then
                                        if isMutedUser(msg.chat.id, obj_user.id) then
                                            txt = txt .. unmuteUser(msg.chat.id, obj_user.id, msg.lang, true)
                                        else
                                            txt = txt .. muteUser(msg.chat.id, obj_user.id, msg.lang, true)
                                        end
                                    else
                                        txt = txt .. langs[msg.lang].require_rank
                                    end
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'multiplewarn' then
            if msg.from.is_owner then
                mystat('/multiplewarn')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. warnUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, nil, true)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. warnUser(msg.from.id, user, msg.chat.id, nil, true)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. warnUser(msg.from.id, obj_user.id, msg.chat.id, nil, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'multipleunwarn' then
            if msg.from.is_owner then
                mystat('/multipleunwarn')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. unwarnUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, nil, true)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. unwarnUser(msg.from.id, user, msg.chat.id, nil, true)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. unwarnUser(msg.from.id, obj_user.id, msg.chat.id, nil, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'multipleunwarnall' then
            if msg.from.is_owner then
                mystat('/multipleunwarnall')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. unwarnallUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, nil, true)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. unwarnallUser(msg.from.id, user, msg.chat.id, nil, true)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. unwarnallUser(msg.from.id, obj_user.id, msg.chat.id, nil, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'multiplekick' then
            if msg.from.is_owner then
                mystat('/multiplekick')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. kickUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, nil, true)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. kickUser(msg.from.id, user, msg.chat.id, nil, true)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. kickUser(msg.from.id, obj_user.id, msg.chat.id, nil, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'multipleban' then
            if msg.from.is_owner then
                mystat('/multipleban')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. banUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, nil, nil, true)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. banUser(msg.from.id, user, msg.chat.id, nil, nil, true)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. banUser(msg.from.id, obj_user.id, msg.chat.id, nil, nil, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'multipleunban' then
            if msg.from.is_owner then
                mystat('/multipleunban')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. unbanUser(msg.from.id, msg.entities[k].user.id, msg.chat.id, nil, true)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. unbanUser(msg.from.id, user, msg.chat.id, nil, true)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. unbanUser(msg.from.id, obj_user.id, msg.chat.id, nil, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'multipledbsearch' then
            if is_sudo(msg) then
                mystat('/multipledbsearch')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    if database[tostring(msg.entities[k].user.id)] then
                                        txt = txt .. ' ' .. serpent.block(database[tostring(msg.entities[k].user.id)], { sortkeys = false, comment = false })
                                    else
                                        txt = txt .. ' ' .. langs[msg.lang].notFound
                                    end
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            if database[tostring(user)] then
                                txt = txt .. serpent.block(database[tostring(user)], { sortkeys = false, comment = false })
                            else
                                txt = txt .. langs[msg.lang].notFound
                            end
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    if database[tostring(obj_user.id)] then
                                        txt = txt .. serpent.block(database[tostring(obj_user.id)], { sortkeys = false, comment = false })
                                    else
                                        txt = txt .. langs[msg.lang].notFound
                                    end
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_sudo
            end
        end
        if matches[1]:lower() == 'multipledbdelete' then
            if is_sudo(msg) then
                mystat('/multipledbdelete')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    if database[tostring(msg.entities[k].user.id)] then
                                        database[tostring(msg.entities[k].user.id)] = nil
                                        txt = txt .. user .. ' ' .. langs[msg.lang].recordDeleted
                                    else
                                        txt = txt .. user .. ' ' .. langs[msg.lang].notFound
                                    end
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            if database[tostring(user)] then
                                database[tostring(user)] = nil
                                txt = txt .. langs[msg.lang].recordDeleted
                            else
                                txt = txt .. langs[msg.lang].notFound
                            end
                        else
                            local obj = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj then
                                if database[tostring(obj.id)] then
                                    database[tostring(obj.id)] = nil
                                    txt = txt .. langs[msg.lang].recordDeleted
                                else
                                    txt = txt .. langs[msg.lang].notFound
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                save_data(config.database.db, database, true)
                return txt
            else
                return langs[msg.lang].require_sudo
            end
        end
        if matches[1]:lower() == 'multiplegrouplink' then
            if is_sudo(msg) then
                mystat('/multiplegrouplink')
                for k, id in pairs(tab) do
                    txt = txt .. id .. ' '
                    local chat_title = ''
                    local group_link = langs[msg.lang].noLinkAvailable
                    if data[tostring(id)] then
                        chat_title = data[tostring(id)].name
                        if data[tostring(id)].settings then
                            if data[tostring(id)].link then
                                group_link = data[tostring(id)].link
                            end
                        end
                    end
                    txt = txt .. chat_title .. group_link .. '\n'
                end
                return txt
            else
                return langs[msg.lang].require_sudo
            end
        end
        if matches[1]:lower() == 'multiplepmblock' then
            if is_sudo(msg) then
                mystat('/multiplepmblock')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. blockUser(msg.entities[k].user.id, true)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. blockUser(user, true)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. blockUser(obj_user.id, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_sudo
            end
        end
        if matches[1]:lower() == 'multiplepmunblock' then
            if is_sudo(msg) then
                mystat('/multiplepmunblock')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. unblockUser(msg.entities[k].user.id, true)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. unblockUser(user, true)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. unblockUser(obj_user.id, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_sudo
            end
        end
        if matches[1]:lower() == 'multiplegban' then
            if is_sudo(msg) then
                mystat('/multiplegban')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. gbanUser(msg.entities[k].user.id, true, true)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. gbanUser(user, true, true)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. gbanUser(obj_user.id, true, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_sudo
            end
        end
        if matches[1]:lower() == 'multipleungban' then
            if is_sudo(msg) then
                mystat('/multipleungban')
                local found = false
                for k, user in pairs(tab) do
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, user) or 0) -1) == msg.entities[k].offset then
                                    found = true
                                    txt = txt .. user .. ' ' .. ungbanUser(msg.entities[k].user.id, true)
                                end
                            end
                        end
                    end
                    if not found then
                        txt = txt .. user .. ' '
                        if string.match(user, '^%d+$') then
                            txt = txt .. ungbanUser(user, true)
                        else
                            local obj_user = getChat('@' ..(string.match(user, '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    txt = txt .. ungbanUser(obj_user.id, true)
                                end
                            else
                                txt = txt .. langs[msg.lang].noObject
                            end
                        end
                    end
                    txt = txt .. '\n'
                    found = false
                end
                return txt
            else
                return langs[msg.lang].require_sudo
            end
        end
    end
end

return {
    description = "MULTIPLE_COMMANDS",
    patterns =
    {
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Ii][Dd]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Uu][Ss][Ee][Rr][Nn][Aa][Mm][Ee]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Ii][Ss][Hh][Ee][Rr][Ee]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Gg][Ee][Tt][Rr][Aa][Nn][Kk]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Ii][Nn][Ff][Oo]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Gg][Ee][Tt][Uu][Ss][Ee][Rr][Ww][Aa][Rr][Nn][Ss]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Mm][Uu][Tt][Ee][Uu][Ss][Ee][Rr]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Uu][Nn][Ww][Aa][Rr][Nn][Aa][Ll][Ll]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Uu][Nn][Ww][Aa][Rr][Nn]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Ww][Aa][Rr][Nn]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Kk][Ii][Cc][Kk]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Uu][Nn][Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Dd][Bb][Ss][Ee][Aa][Rr][Cc][Hh]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Dd][Bb][Dd][Ee][Ll][Ee][Tt][Ee]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Gg][Rr][Oo][Uu][Pp][Ll][Ii][Nn][Kk]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Pp][Mm][Uu][Nn][Bb][Ll][Oo][Cc][Kk]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Pp][Mm][Bb][Ll][Oo][Cc][Kk]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Gg][Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Uu][Nn][Gg][Bb][Aa][Nn]) (.*)$",
    },
    run = run,
    min_rank = 3,
    syntax =
    {
        "MOD",
        "/multipleid {username1} {username2} ...",
        "/multipleusername {id1} {id2} ...",
        "/multipleishere {user1} {user2} ...",
        "/multiplegetrank {user1} {user2} ...",
        "/multipleinfo {obj1} {obj2} ...",
        "/multiplegetuserwarns {user1} {user2} ...",
        "/multiplemuteuser {user1} {user2} ...",
        "OWNER",
        "/multiplewarn {user1} {user2} ...",
        "/multipleunwarn {user1} {user2} ...",
        "/multipleunwarnall {user1} {user2} ...",
        "/multiplekick {user1} {user2} ...",
        "/multipleban {user1} {user2} ...",
        "/multipleunban {user1} {user2} ...",
        "SUDO",
        "/multipledbsearch {obj1} {obj2} ...",
        "/multipledbdelete {obj1} {obj2} ...",
        "/multiplegrouplink {group1} {group2} ...",
        "/multiplepmblock {user1} {user2} ...",
        "/multiplepmunblock {user1} {user2} ...",
        "/multiplegban {user1} {user2} ...",
        "/multipleungban {user1} {user2} ...",
    },
}