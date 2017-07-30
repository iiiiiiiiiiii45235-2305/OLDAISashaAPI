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

local function get_reverse_rank(chat_id, user_id, check_local)
    local lang = get_lang(chat_id)
    local rank = get_rank(user_id, chat_id, check_local)
    return langs[lang].rank .. reverse_rank_table[rank + 1]
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
            if isWhitelisted(id_to_cli(chat_id), obj.id) then
                otherinfo = otherinfo .. 'WHITELISTED '
            end
            if isWhitelistedGban(id_to_cli(chat_id), obj.id) then
                otherinfo = otherinfo .. 'GBANWHITELISTED '
            end
            if isGbanned(obj.id) then
                otherinfo = otherinfo .. 'GBANNED '
            end
            if isBanned(obj.id, chat_id) then
                otherinfo = otherinfo .. 'BANNED '
            end
            if isMutedUser(chat_id, obj.id) then
                otherinfo = otherinfo .. 'MUTED '
            end
            if string.match(getUserWarns(obj.id, chat_id), '%d+') then
                otherinfo = otherinfo .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. ' WARN '
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
            if isWhitelisted(id_to_cli(chat_id), obj.id) then
                otherinfo = otherinfo .. 'WHITELISTED '
            end
            if isWhitelistedGban(id_to_cli(chat_id), obj.id) then
                otherinfo = otherinfo .. 'GBANWHITELISTED '
            end
            if isGbanned(obj.id) then
                otherinfo = otherinfo .. 'GBANNED '
            end
            if isBanned(obj.id, chat_id) then
                otherinfo = otherinfo .. 'BANNED '
            end
            if isMutedUser(chat_id, obj.id) then
                otherinfo = otherinfo .. 'MUTED '
            end
            if isBlocked(obj.id) then
                otherinfo = otherinfo .. 'PM BLOCKED '
            end
            if string.match(getUserWarns(obj.id, chat_id), '%d+') then
                otherinfo = otherinfo .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. ' WARN '
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
    --[[if matches[1]:lower() == 'multipleid' and matches[2] then
        if msg.from.is_mod then
            mystat('/multipleid')
            local tab = matches[2]:split(' ')
            local i = 0
            local txt = ''
            for k, id in pairs(tab) do
                txt = txt .. id .. ' '
                local obj = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                if obj then
                    txt = txt .. obj.id
                else
                    txt = txt .. langs[msg.lang].noObject
                end
                i = i + 1
                txt = txt .. '\n'
            end
            return txt
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'multipleusername' and matches[2] then
        if msg.from.is_mod then
            mystat('/multipleusername')
            local tab = matches[2]:split(' ')
            local i = 0
            local txt = ''
            for k, id in pairs(tab) do
                txt = txt .. id .. ' '
                local obj = getChat(matches[2])
                if obj then
                    txt = txt .. obj.username or('NOUSER ' ..(obj.first_name or obj.title) .. ' ' ..(obj.last_name or ''))
                else
                    txt = txt .. langs[msg.lang].noObject
                end
                i = i + 1
                txt = txt .. '\n'
            end
            return txt
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'multipleishere' and matches[2] then
        if msg.from.is_mod then
            mystat('/multipleishere')
            local tab = matches[2]:split(' ')
            local i = 0
            local txt = ''
            for k, id in pairs(tab) do
                txt = txt .. id .. ' '
                if string.match(matches[2], '^%d+$') then
                    txt = txt .. is_here(msg.chat.id, tonumber(matches[2]))
                else
                    local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            txt = txt .. is_here(msg.chat.id, obj_user.id)
                        end
                    else
                        txt = txt .. langs[msg.lang].noObject
                    end
                end
                i = i + 1
                txt = txt .. '\n'
            end
            return txt
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'multiplegetrank' and matches[2] then
        if msg.from.is_mod then
            mystat('/multiplegetrank')
            local tab = matches[2]:split(' ')
            local i = 0
            local txt = ''
            for k, id in pairs(tab) do
                txt = txt .. id .. ' '
                if string.match(matches[2], '^%d+$') then
                    txt = txt .. get_reverse_rank(msg.chat.id, matches[2], check_local)
                else
                    local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            txt = txt .. get_reverse_rank(msg.chat.id, obj_user.id, check_local)
                        end
                    else
                        txt = txt .. langs[msg.lang].noObject
                    end
                end
                i = i + 1
                txt = txt .. '\n'
            end
            return txt
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'multipleinfo' and matches[2] then
        if msg.from.is_mod then
            mystat('/multipleinfo')
            local tab = matches[2]:split(' ')
            local i = 0
            local txt = ''
            for k, id in pairs(tab) do
                if string.match(id, '^%-?%d+$') then
                    txt = txt .. get_object_info(getChat(id), msg.chat.id)
                else
                    txt = txt .. get_object_info(getChat('@' ..(string.match(id, '^[^%s]+'):gsub('@', '') or '')), msg.chat.id)
                end
                i = i + 1
                txt = txt .. '\n'
            end
            return txt
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'multiplewarn' and matches[2] then
        if msg.from.is_owner then
            mystat('/multiplewarn')
            local tab = matches[2]:split(' ')
            local i = 0
            for k, id in pairs(tab) do
                warnUser(msg.from.id, id, msg.chat.id)
                i = i + 1
            end
            return langs[msg.lang].multipleWarn:gsub('X', i)
        else
            return langs[msg.lang].require_owner
        end
    end
    if matches[1]:lower() == 'multipleunwarn' and matches[2] then
        if msg.from.is_owner then
            mystat('/multipleunwarn')
            local tab = matches[2]:split(' ')
            local i = 0
            for k, id in pairs(tab) do
                unwarnUser(msg.from.id, id, msg.chat.id)
                i = i + 1
            end
            return langs[msg.lang].multipleUnwarn:gsub('X', i)
        else
            return langs[msg.lang].require_owner
        end
    end
    if matches[1]:lower() == 'multipleunwarnall' and matches[2] then
        if msg.from.is_owner then
            mystat('/multipleunwarnall')
            local tab = matches[2]:split(' ')
            local i = 0
            for k, id in pairs(tab) do
                unwarnallUser(msg.from.id, id, msg.chat.id)
                i = i + 1
            end
            return langs[msg.lang].multipleUnwarnall:gsub('X', i)
        else
            return langs[msg.lang].require_owner
        end
    end
    if matches[1]:lower() == 'multiplekick' and matches[2] then
        if msg.from.is_owner then
            mystat('/multiplekick')
            local tab = matches[2]:split(' ')
            local i = 0
            for k, id in pairs(tab) do
                kickUser(msg.from.id, id, msg.chat.id)
                i = i + 1
            end
            return langs[msg.lang].multipleKick:gsub('X', i)
        else
            return langs[msg.lang].require_owner
        end
    end
    if matches[1]:lower() == 'multipleban' and matches[2] then
        if msg.from.is_owner then
            mystat('/multipleban')
            local tab = matches[2]:split(' ')
            local i = 0
            for k, id in pairs(tab) do
                banUser(msg.from.id, id, msg.chat.id)
                i = i + 1
            end
            return langs[msg.lang].multipleBan:gsub('X', i)
        else
            return langs[msg.lang].require_owner
        end
    end]]
    if matches[1]:lower() == 'multipleunban' and matches[2] then
        if msg.from.is_owner then
            mystat('/multipleunban')
            local tab = matches[2]:split(' ')
            local i = 0
            for k, id in pairs(tab) do
                unbanUser(msg.from.id, id, msg.chat.id)
                i = i + 1
            end
            return langs[msg.lang].multipleUnban:gsub('X', i)
        else
            return langs[msg.lang].require_owner
        end
    end
    if matches[1]:lower() == 'multiplegban' and matches[2] then
        if is_sudo(msg) then
            mystat('/multiplegban')
            local tab = matches[2]:split(' ')
            local i = 0
            for k, id in pairs(tab) do
                gbanUser(id)
                i = i + 1
            end
            return langs[msg.lang].multipleGban:gsub('X', i)
        else
            return langs[msg.lang].require_sudo
        end
    end
    --[[if matches[1]:lower() == 'multipleungban' and matches[2] then
        if is_sudo(msg) then
            mystat('/multipleungban')
            local tab = matches[2]:split(' ')
            local i = 0
            for k, id in pairs(tab) do
                ungbanUser(id)
                i = i + 1
            end
            return langs[msg.lang].multipleUngban:gsub('X', i)
        else
            return langs[msg.lang].require_sudo
        end
    end
    if matches[1]:lower() == 'multiplegrouplink' and matches[2] then
        if is_sudo(msg) then
            mystat('/multiplegrouplink')
            local tab = matches[2]:split(' ')
            local i = 0
            for k, id in pairs(tab) do
                txt = txt .. id .. ' '
                local group_link = data[tostring(id)]['settings']['set_link']
                if not group_link then
                    txt = txt .. langs[msg.lang].noLinkAvailable
                end
                local obj = getChat(matches[2])
                if type(obj) == 'table' then
                    txt = txt .. obj.title .. '\n' .. group_link
                end
                i = i + 1
                txt = txt .. '\n'
            end
            return langs[msg.lang].multipleUngban:gsub('X', i)
        else
            return langs[msg.lang].require_sudo
        end
    end]]
end

return {
    description = "MULTIPLE_COMMANDS",
    patterns =
    {
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Uu][Nn][Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Mm][Uu][Ll][Tt][Ii][Pp][Ll][Ee][Gg][Bb][Aa][Nn]) (.*)$",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "OWNER",
        "#multipleunban <user_id1> <user_id2> ...",
        "SUDO",
        "#multiplegban <user_id1> <user_id2> ...",
    },
}