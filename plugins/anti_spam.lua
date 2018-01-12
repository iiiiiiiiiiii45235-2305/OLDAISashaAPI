-- Empty tables for solving multiple kicking problem(thanks to @topkecleon)
local kicktable = {
    -- chat_id = { user_id }
}
local cbwarntable = {
    -- user_id
}
local floodkicktable = {
    -- chat_id = counter
}
local modsContacted = {
    -- chat_id = false/true
}
local hashes = {
    -- chat_id = { msgHash = counter }
}

local TIME_CHECK = 2
-- seconds
-- Save stats, ban user
local function pre_process(msg)
    if msg then
        if not kicktable[msg.chat.id] then
            kicktable[msg.chat.id] = { }
        end
        if not hashes[msg.chat.id] then
            hashes[msg.chat.id] = { }
        end

        -- Ignore service msg
        if msg.service then
            if msg.added then
                for k, v in pairs(msg.added) do
                    kicktable[msg.chat.id][v.id] = false
                end
            end
            return msg
        end

        -- Save chat's total messages
        local totalhash = 'chatmsgs:' .. msg.chat.id
        if not redis:get(totalhash) then
            redis:set(totalhash, 0)
        end
        redis:incr(totalhash)

        -- Save user on Redis
        if msg.from.type == 'user' then
            local savehash = 'user:' .. msg.from.id
            print('Saving user', savehash)
            if msg.from.print_name then
                redis:hset(savehash, 'print_name', msg.from.print_name)
            end
            if msg.from.first_name then
                redis:hset(savehash, 'first_name', msg.from.first_name)
            end
            if msg.from.last_name then
                redis:hset(savehash, 'last_name', msg.from.last_name)
            end
        end

        -- Save stats on Redis
        local statshash = 'chat:' .. msg.chat.id .. ':users'
        if msg.chat.type == 'private' then
            statshash = 'chat:' .. msg.from.id
        end
        redis:sadd(statshash, msg.from.id)

        -- Total user msgs in TIME_CHECK seconds
        local userhash = 'api:user:' .. msg.from.id .. ':msgs'
        local usermsgs = tonumber(redis:get(userhash) or 0)
        redis:setex(userhash, TIME_CHECK, usermsgs + 1)
        print('messages: ' .. usermsgs)

        if msg.cb then
            if not cbwarntable[msg.from.id] then
                if usermsgs >= 4 then
                    cbwarntable[msg.from.id] = true
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].dontFloodKeyboard, true)
                end
            else
                cbwarntable[msg.from.id] = false
            end
        else
            -- Total user msgs in that chat excluding keyboard interactions
            local msgshash = 'msgs:' .. msg.from.id .. ':' .. msg.chat.id
            redis:incr(msgshash)
        end

        if not msg.edited then
            -- Ignore mods,owner and admins
            if msg.from.is_mod then
                return msg
            end

            -- Check for a distributed flood in one minute
            local hash
            if msg.media then
                local file_id = ''
                if msg.media_type == 'photo' then
                    local bigger_pic_id = ''
                    local size = 0
                    for k, v in pairsByKeys(msg.photo) do
                        if v.file_size > size then
                            size = v.file_size
                            bigger_pic_id = v.file_id
                        end
                    end
                    file_id = bigger_pic_id
                elseif msg.media_type == 'video' then
                    file_id = msg.video.file_id
                elseif msg.media_type == 'video_note' then
                    file_id = msg.video_note.file_id
                elseif msg.media_type == 'audio' then
                    file_id = msg.audio.file_id
                elseif msg.media_type == 'voice_note' then
                    file_id = msg.voice.file_id
                elseif msg.media_type == 'gif' then
                    file_id = msg.document.file_id
                elseif msg.media_type == 'document' then
                    file_id = msg.document.file_id
                elseif msg.media_type == 'sticker' then
                    file_id = msg.sticker.file_id
                end
                hash = file_id
            else
                hash = sha2.hash256(msg.text)
            end
            hashes[msg.chat.id][hash] =(hashes[msg.chat.id][hash] or 0) + 1

            -- Check flood
            if msg.chat.type == 'private' then
                if hashes[msg.chat.id][hash] > 10 then
                    -- don't write two times the same thing
                    usermsgs = 10
                end
                if usermsgs >= 7 then
                    print("Pass2")
                    -- Block user if spammed in private
                    blockUser(msg.from.id, msg.lang)
                    sendMessage(msg.from.id, langs[msg.lang].user .. "[" .. msg.from.id .. "]" .. langs[msg.lang].blockedForSpam)
                    sendLog(langs[msg.lang].user .. "[" .. msg.from.id .. "]" .. langs[msg.lang].blockedForSpam, false, true)
                    savelog(msg.from.id .. " PM", "User [" .. msg.from.id .. "] blocked for spam.")
                    return nil
                end
            elseif data[tostring(msg.chat.id)] then
                -- Check if flood is on or off
                if not data[tostring(msg.chat.id)].settings.flood then
                    return msg
                end
                local NUM_MSG_MAX = 5
                local strict = false
                if data[tostring(msg.chat.id)] then
                    if data[tostring(msg.chat.id)].settings then
                        if data[tostring(msg.chat.id)].settings.flood_max then
                            NUM_MSG_MAX = tonumber(data[tostring(msg.chat.id)].settings.flood_max)
                            -- Obtain group flood sensitivity
                        end
                        if data[tostring(msg.chat.id)].settings.strict then
                            strict = data[tostring(msg.chat.id)].settings.strict
                        end
                    end
                end
                -- if more than 10 messages all equals
                local shitstormAlarm = false
                if hashes[msg.chat.id][hash] > 10 then
                    shitstormAlarm = true
                    local text = ''
                    if string.match(getWarn(msg.chat.id), "%d+") then
                        text = tostring(warnUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonFlood))
                        text = text .. '\n' .. tostring(kickUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonFlood))
                    elseif not strict then
                        text = kickUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonFlood)
                    else
                        text = banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonFlood)
                    end
                    sendMessage(msg.chat.id, text)
                end
                if usermsgs >= NUM_MSG_MAX then
                    floodkicktable[msg.chat.id] =(floodkicktable[msg.chat.id] or 0)
                    local user = msg.from.id
                    -- Ignore whitelisted
                    if isWhitelisted(msg.chat.tg_cli_id, msg.from.id) then
                        return msg
                    end
                    if kicktable[msg.chat.id][msg.from.id] == true then
                        local member = getChatMember(msg.chat.id, msg.from.id)
                        if type(member) == 'table' then
                            if member.ok and member.result then
                                if member.result.status == 'left' or member.result.status == 'kicked' then
                                    return
                                else
                                    kicktable[msg.chat.id][msg.from.id] = false
                                end
                            end
                        end
                    end
                    local text = ''
                    if string.match(getWarn(msg.chat.id), "%d+") then
                        text = tostring(warnUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonFlood))
                        text = text .. '\n' .. tostring(kickUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonFlood))
                    elseif not strict then
                        text = kickUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonFlood)
                    else
                        text = banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonFlood)
                    end
                    local username = msg.from.username or 'USERNAME'
                    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
                        if msg.from.username then
                            savelog(msg.chat.id, msg.from.print_name .. " @" .. username .. " [" .. msg.from.id .. "] kicked for #spam")
                            sendMessage(msg.chat.id, text)
                        else
                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] kicked for #spam")
                            sendMessage(msg.chat.id, text)
                        end
                    end
                    -- incr it on redis
                    local gbanspam = 'gban:spam' .. msg.from.id
                    redis:incr(gbanspam)
                    local gbanspam = 'gban:spam' .. msg.from.id
                    local gbanspamonredis = redis:get(gbanspam)
                    -- Check if user has spammed is group more than 4 times
                    if gbanspamonredis then
                        if tonumber(gbanspamonredis) == 4 and not msg.from.is_owner then
                            -- Global ban that user
                            gbanUser(msg.from.id, msg.lang)
                            local gbanspam = 'gban:spam' .. msg.from.id
                            -- reset the counter
                            redis:set(gbanspam, 0)
                            -- Send this to that chat
                            sendMessage(msg.chat.id, langs[msg.lang].user .. " [ " .. profileLink(msg.from.id, msg.from.print_name) .. " ] " .. msg.from.id .. langs[msg.lang].gbanned .. " (SPAM)", 'html')
                            gban_text = langs[msg.lang].user .. " [ " .. profileLink(msg.from.id, msg.from.print_name) .. " ] ( @" .. username .. " ) " .. msg.from.id .. langs[msg.lang].gbannedFrom .. " ( " .. msg.chat.print_name .. " ) [ " .. msg.chat.id .. " ] (SPAM)"
                            -- send it to log group/channel
                            sendLog(gban_text, 'html', true)
                        end
                    end
                    kicktable[msg.chat.id][msg.from.id] = true
                    floodkicktable[msg.chat.id] = floodkicktable[msg.chat.id] + 1
                end
                -- check if there's a possible ongoing shitstorm (if flooders are more than 4 in 1 minute)
                if (floodkicktable[msg.chat.id] >= 4 or shitstormAlarm) and not modsContacted[msg.chat.id] then
                    modsContacted[msg.chat.id] = true
                    local hashtag = '#alarm' .. tostring(msg.message_id)
                    local chat_name = msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']'
                    local group_link = data[tostring(msg.chat.id)]['settings']['set_link']
                    if group_link then
                        chat_name = "<a href=\"" .. group_link .. "\">" .. html_escape(chat_name) .. "</a>"
                    end
                    local attentionText = langs[msg.lang].possibleShitstorm .. chat_name .. '\n' ..
                    'HASHTAG: ' .. hashtag
                    local already_contacted = { }
                    already_contacted[tonumber(bot.id)] = bot.id
                    already_contacted[tonumber(bot.userVersion.id)] = bot.userVersion.id
                    local cant_contact = ''
                    local list = getChatAdministrators(msg.chat.id)
                    if list then
                        for i, admin in pairs(list.result) do
                            if not already_contacted[tonumber(admin.user.id)] then
                                already_contacted[tonumber(admin.user.id)] = admin.user.id
                                if sendChatAction(admin.user.id, 'typing', true) then
                                    sendMessage(admin.user.id, attentionText, 'html')
                                else
                                    cant_contact = cant_contact .. admin.user.id .. ' ' ..(admin.user.username or('NOUSER ' .. admin.user.first_name .. ' ' ..(admin.user.last_name or ''))) .. '\n'
                                end
                            end
                        end
                    end

                    -- owner
                    local owner = data[tostring(msg.chat.id)]['set_owner']
                    if owner then
                        if not already_contacted[tonumber(owner)] then
                            already_contacted[tonumber(owner)] = owner
                            if sendChatAction(owner, 'typing', true) then
                                sendMessage(owner, attentionText, 'html')
                            else
                                cant_contact = cant_contact .. owner .. '\n'
                            end
                        end
                    end

                    -- determine if table is empty
                    if next(data[tostring(msg.chat.id)]['moderators']) ~= nil then
                        for k, v in pairs(data[tostring(msg.chat.id)]['moderators']) do
                            if not already_contacted[tonumber(k)] then
                                already_contacted[tonumber(k)] = k
                                if sendChatAction(k, 'typing', true) then
                                    sendMessage(k, attentionText, 'html')
                                else
                                    cant_contact = cant_contact .. k .. ' ' ..(v or '') .. '\n'
                                end
                            end
                        end
                    end
                    if cant_contact ~= '' then
                        sendMessage(msg.chat.id, langs[msg.lang].cantContact .. cant_contact)
                    end
                    data[tostring(msg.chat.id)]['settings']['lock_spam'] = true
                    sendMessage(msg.chat.id, hashtag)
                end
                if usermsgs >= NUM_MSG_MAX then
                    return nil
                end
            end
        end
        return msg
    end
end

local function cron()
    -- clear those tables on the top of the plugin
    kicktable = { }
    cbwarntable = { }
    floodkicktable = { }
    modsContacted = { }
    hashes = { }
end

return {
    description = "ANTI_SPAM",
    cron = cron,
    patterns = { },
    pre_process = pre_process,
    min_rank = 5,
}