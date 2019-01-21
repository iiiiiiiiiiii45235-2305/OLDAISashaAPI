notified = { }

-- recursive to simplify code
local function check_tag(msg, user_id, user)
    if msg.entities then
        for k, v in pairs(msg.entities) do
            -- check if there's a text_mention
            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                if tonumber(msg.entities[k].user.id) == tonumber(user_id) then
                    return true
                end
            end
        end
    end

    if user then
        if type(user) == 'table' then
            -- only sudoers
            -- check if first name is in message
            if msg.text then
                if string.match(msg.text, "^" .. user.first_name) or string.match(msg.text, "%W+" .. user.first_name .. "%W+") or string.match(msg.text, user.first_name .. "$") then
                    return true
                end
            end
            if user.username then
                -- check if username is in message
                if msg.text then
                    if string.match(msg.text:lower(), "^" .. user.username:lower()) or string.match(msg.text:lower(), "%W+" .. user.username:lower() .. "%W+") or string.match(msg.text:lower(), user.username:lower() .. "$") then
                        return true
                    end
                end
            end
            return false
        else
            if msg.text then
                if string.match(msg.text:lower(), "^" .. tostring(user):lower()) or string.match(msg.text:lower(), "%W+" .. tostring(user):lower() .. "%W+") or string.match(msg.text:lower(), tostring(user):lower() .. "$") then
                    return true
                end
            end
        end
    end
end

local function run(msg, matches)
    if msg.cb then
        if matches[2] == 'ALREADYREAD' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].markedAsRead, false)
            if not deleteMessage(msg.chat.id, msg.message_id, true) then
                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].markedAsRead)
            end
        elseif matches[2] == 'REGISTER' then
            if not redis_hget_something('tagalert:usernames', msg.from.id) then
                answerCallbackQuery(msg.cb_id, langs[msg.lang].tagalertRegistered, true)
                if msg.from.username then
                    redis_hset_something('tagalert:usernames', msg.from.id, msg.from.username:lower())
                else
                    redis_hset_something('tagalert:usernames', msg.from.id, true)
                end
                mystat(matches[1] .. matches[2] .. msg.from.id)
            else
                answerCallbackQuery(msg.cb_id, langs[msg.lang].pmnoticesAlreadyRegistered, true)
            end
            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].startMessage .. '\n' .. langs[msg.lang].nowSetNickname)
            -- editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].startMessage .. '\n' .. langs[msg.lang].nowSetNickname, { inline_keyboard = { { { text = langs[msg.lang].tutorialWord, url = 'http://telegra.ph/TUTORIAL-AISASHABOT-09-15' } } } })
        else
            if matches[2] == 'DELETEUP' then
                if tonumber(matches[3]) == tonumber(msg.from.id) then
                    if deleteMessage(msg.chat.id, msg.message_id) then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].upMessageDeleted, false)
                    else
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].cantDeleteMessage, false)
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                    end
                end
                mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
            elseif matches[2] == 'GOTO' then
                local link_in_keyboard = false
                if msg.from.username then
                    local res = sendKeyboard(matches[4], 'UP @' .. msg.from.username .. '\n#tag' .. msg.from.id, keyboard_tag(matches[4], matches[3], true, msg.from.id), false, matches[3], false, true)
                    if data[tostring(matches[4])] then
                        if is_mod2(msg.from.id, matches[4]) or(not data[tostring(matches[4])].settings.lock_grouplink) then
                            if data[tostring(matches[4])].link then
                                link_in_keyboard = true
                                if res then
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].repliedToMessage, { inline_keyboard = { { { text = langs[msg.lang].alreadyRead, callback_data = 'check_tagALREADYREAD' } }, { { text = langs[msg.lang].gotoGroup, url = data[tostring(matches[4])].link } } } }, false, false, true)
                                else
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].cantFindMessage, { inline_keyboard = { { { text = langs[msg.lang].alreadyRead, callback_data = 'check_tagALREADYREAD' } }, { { text = langs[msg.lang].gotoGroup, url = data[tostring(matches[4])].link } } } }, false, false, true)
                                end
                            end
                        end
                    end
                    if not link_in_keyboard then
                        if res then
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].repliedToMessage, true)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].cantFindMessage, true)
                        end
                        if not deleteMessage(msg.chat.id, msg.message_id, true) then
                            if sent then
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].repliedToMessage)
                            else
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].cantFindMessage)
                            end
                        end
                    end
                else
                    local sent = false
                    local res = sendKeyboard(matches[4], 'UP [' .. msg.from.first_name:mEscape_hard() .. '](tg://user?id=' .. msg.from.id .. ')\n#tag' .. msg.from.id, keyboard_tag(matches[4], matches[3], true, msg.from.id), 'markdown', matches[3], false, true)
                    if res then
                        sent = true
                    else
                        res = sendKeyboard(matches[4], 'UP <a href="tg://user?id=' .. msg.from.id .. '">' .. html_escape(msg.from.first_name) .. '</a>\n#tag' .. msg.from.id, keyboard_tag(matches[4], matches[3], true, msg.from.id), 'html', matches[3], false, true)
                        if res then
                            sent = true
                        else
                            res = sendKeyboard(matches[4], 'UP [' .. msg.from.first_name .. '](tg://user?id=' .. msg.from.id .. ')\n#tag' .. msg.from.id, keyboard_tag(matches[4], matches[3], true, msg.from.id), false, matches[3], false, true)
                            if res then
                                sent = true
                            end
                        end
                    end
                    if data[tostring(matches[4])] then
                        if is_mod2(msg.from.id, matches[4]) or(not data[tostring(matches[4])].settings.lock_grouplink) then
                            if data[tostring(matches[4])].link then
                                link_in_keyboard = true
                                if sent then
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].repliedToMessage, { inline_keyboard = { { { text = langs[msg.lang].alreadyRead, callback_data = 'check_tagALREADYREAD' } }, { { text = langs[msg.lang].gotoGroup, url = data[tostring(matches[4])].link } } } }, false, false, true)
                                else
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].cantFindMessage, { inline_keyboard = { { { text = langs[msg.lang].alreadyRead, callback_data = 'check_tagALREADYREAD' } }, { { text = langs[msg.lang].gotoGroup, url = data[tostring(matches[4])].link } } } }, false, false, true)
                                end
                            end
                        end
                    end
                    if sent then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].repliedToMessage, true)
                    else
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].cantFindMessage, true)
                    end
                    if not link_in_keyboard then
                        if not deleteMessage(msg.chat.id, msg.message_id, true) then
                            if sent then
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].repliedToMessage)
                            else
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].cantFindMessage)
                            end
                        end
                    end
                end
                mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
            end
        end
        return
    end

    if matches[1]:lower() == 'enablenotices' then
        if data[tostring(msg.chat.id)] and msg.from.is_owner then
            if not data[tostring(msg.chat.id)].settings.pmnotices then
                mystat('/enablenotices')
                data[tostring(msg.chat.id)].settings.pmnotices = true
                return langs[msg.lang].noticesEnabledGroup
            else
                return langs[msg.lang].noticesAlreadyEnabledGroup
            end
        else
            return langs[msg.lang].useYourGroups .. '\n' .. langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'disablenotices' then
        if data[tostring(msg.chat.id)] and msg.from.is_owner then
            if data[tostring(msg.chat.id)].settings.pmnotices then
                mystat('/disablenotices')
                data[tostring(msg.chat.id)].settings.pmnotices = false
                return langs[msg.lang].noticesDisabledGroup
            else
                return langs[msg.lang].noticesGroupAlreadyDisabled
            end
        else
            return langs[msg.lang].useYourGroups .. '\n' .. langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'registernotices' then
        if msg.chat.type == 'private' then
            if not redis_get_something('notice:' .. msg.from.id) then
                mystat('/registernotices')
                redis_set_something('notice:' .. msg.from.id, 1)
                return langs[msg.lang].pmnoticesRegistered
            else
                return langs[msg.lang].pmnoticesAlreadyRegistered
            end
        else
            return sendReply(msg, langs[msg.lang].require_private, 'html')
        end
    end

    if matches[1]:lower() == 'unregisternotices' then
        if msg.chat.type == 'private' then
            if redis_get_something('notice:' .. msg.from.id) then
                mystat('/unregisternotices')
                redis_del_something('notice:' .. msg.from.id)
                return langs[msg.lang].pmnoticesUnregistered
            else
                return langs[msg.lang].pmnoticesAlreadyUnregistered
            end
        else
            return sendReply(msg, langs[msg.lang].require_private, 'html')
        end
    end

    if matches[1]:lower() == 'enabletagalert' then
        if data[tostring(msg.chat.id)] and msg.from.is_owner then
            if not data[tostring(msg.chat.id)].settings.tagalert then
                mystat('/enabletagalert')
                data[tostring(msg.chat.id)].settings.tagalert = true
                return langs[msg.lang].tagalertGroupEnabled
            else
                return langs[msg.lang].tagalertGroupAlreadyEnabled
            end
        else
            return langs[msg.lang].useYourGroups .. '\n' .. langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'disabletagalert' then
        if data[tostring(msg.chat.id)] and msg.from.is_owner then
            if data[tostring(msg.chat.id)].settings.tagalert then
                mystat('/disabletagalert')
                data[tostring(msg.chat.id)].settings.tagalert = false
                return langs[msg.lang].tagalertGroupDisabled
            else
                return langs[msg.lang].tagalertGroupAlreadyDisabled
            end
        else
            return langs[msg.lang].useYourGroups .. '\n' .. langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'registertagalert' then
        if msg.chat.type == 'private' then
            if not redis_hget_something('tagalert:usernames', msg.from.id) then
                mystat('/registertagalert')
                if msg.from.username then
                    redis_hset_something('tagalert:usernames', msg.from.id, msg.from.username:lower())
                else
                    redis_hset_something('tagalert:usernames', msg.from.id, true)
                end
                return langs[msg.lang].tagalertRegistered
            else
                return langs[msg.lang].tagalertAlreadyRegistered
            end
        else
            return sendReply(msg, langs[msg.lang].require_private, 'html')
        end
    end

    if matches[1]:lower() == 'unregistertagalert' then
        if redis_hget_something('tagalert:usernames', msg.from.id) then
            mystat('/unregistertagalert')
            redis_hdelsrem_something('tagalert:usernames', msg.from.id)
            redis_hdelsrem_something('tagalert:nicknames', msg.from.id)
            return langs[msg.lang].tagalertUnregistered
        else
            return langs[msg.lang].tagalertAlreadyUnregistered
        end
    end

    if matches[1]:lower() == 'setnickname' and matches[2] then
        if redis_hget_something('tagalert:usernames', msg.from.id) then
            if string.len(matches[2]) >= 3 and matches[2]:match('%w+') then
                mystat('/setnickname')
                redis_hset_something('tagalert:nicknames', msg.from.id, matches[2]:lower())
                return langs[msg.lang].tagalertNicknameSet
            else
                return langs[msg.lang].tagalertNicknameTooShort
            end
        else
            return langs[msg.lang].tagalertRegistrationNeeded
        end
    end

    if matches[1]:lower() == 'unsetnickname' then
        if redis_hget_something('tagalert:usernames', msg.from.id) then
            mystat('/unsetnickname')
            redis_hdelsrem_something('tagalert:nicknames', msg.from.id)
            return langs[msg.lang].tagalertNicknameUnset
        else
            return langs[msg.lang].tagalertRegistrationNeeded
        end
    end

    --[[if matches[1]:lower() == 'tagall' then
        if msg.from.is_owner then
            return langs[msg.lang].useAISasha
            local text = ''
            if matches[2] then
                mystat('/tagall <text>')
                text = matches[2] .. "\n"
            elseif msg.reply then
                mystat('/tagall <reply_text>')
                text = msg.reply_to_message.text .. "\n"
            end
            local participants = getChatParticipants(msg.chat.id)
            for k, v in pairs(participants) do
                if v.user then
                    v = v.user
                    if v.username then
                        text = text .. "@" .. v.username .. " "
                    else
                        local print_name =(v.first_name or '') ..(v.last_name or '')
                        if print_name ~= '' then
                            text = text .. print_name .. " "
                        end
                    end
                end
            end
            return text
        else
            return langs[msg.lang].require_owner
        end
    end]]
end

local function send_tag_alert(msg, user_id)
    local lang = get_lang(user_id)
    if msg.reply then
        if not msg.reply_to_message.service then
            forwardMessage(user_id, msg.chat.id, msg.reply_to_message.message_id)
        end
    end
    local text = langs[lang].receiver .. msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']\n' .. langs[lang].sender
    if msg.from.username then
        text = text .. '@' .. msg.from.username .. ' [' .. msg.from.id .. ']\n'
    else
        text = text .. msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']\n'
    end
    text = text .. langs[lang].msgText

    if msg.media then
        local tot_len = string.len(text .. '\n#tag' .. user_id)
        local caption_len = string.len(msg.text)
        local allowed_len = 200 - tot_len
        if caption_len > allowed_len then
            text = text .. msg.text:sub(1, allowed_len - 3) .. '...'
        else
            text = text .. msg.text
        end
        text = text .. '\n#tag' .. user_id
        if msg.media_type == 'photo' then
            local bigger_pic_id = ''
            local size = 0
            for k, v in pairsByKeys(msg.photo) do
                if v.file_size then
                    if v.file_size > size then
                        size = v.file_size
                        bigger_pic_id = v.file_id
                    end
                end
            end
            sendPhotoId(user_id, bigger_pic_id, text)
        elseif msg.media_type == 'video' then
            sendVideoId(user_id, msg.video.file_id, text)
        elseif msg.media_type == 'audio' then
            sendAudioId(user_id, msg.audio.file_id, text)
        elseif msg.media_type == 'voice_note' then
            sendVoiceId(user_id, msg.voice.file_id, text)
        elseif msg.media_type == 'gif' then
            sendAnimationId(user_id, msg.animation.file_id, text)
        elseif msg.media_type == 'document' then
            sendDocumentId(user_id, msg.document.file_id, text)
        end
    else
        text = text .. msg.text .. '\n#tag' .. user_id
        sendMessage(user_id, text)
    end
    sendKeyboard(user_id, langs[lang].whatDoYouWantToDo, keyboard_tag(msg.chat.id, msg.message_id, false, user_id))
end

local function pre_process(msg)
    if msg then
        notified = { }
        -- update usernames
        if redis_hget_something('tagalert:usernames', msg.from.id) then
            if msg.from.username then
                if redis_hget_something('tagalert:usernames', msg.from.id) ~= msg.from.username:lower() then
                    redis_hset_something('tagalert:usernames', msg.from.id, msg.from.username:lower())
                end
            else
                redis_hset_something('tagalert:usernames', msg.from.id, true)
            end
        end
        if data[tostring(msg.chat.id)] then
            -- exclude private chats with bot
            for k, v in pairs(config.sudo_users) do
                if not notified[tostring(k)] then
                    -- exclude already notified
                    if tonumber(msg.from.id) ~= tonumber(k) and tonumber(msg.from.id) ~= tonumber(bot.userVersion.id) and tonumber(k) ~= tonumber(bot.userVersion.id) then
                        -- exclude autotags and tags from tg-cli version and tags of tg-cli version
                        if check_tag(msg, k, v) then
                            print('sudo', k)
                            -- set user as notified to not send multiple notifications
                            notified[tostring(k)] = true
                            if sendChatAction(k, 'typing') then
                                send_tag_alert(msg, k)
                            end
                        end
                    end
                end
            end
            if data[tostring(msg.chat.id)].settings.tagalert then
                -- if group is enabled to tagalert notifications then
                local usernames = redis_get_something('tagalert:usernames')
                for k, v in pairs(usernames) do
                    if not notified[tostring(k)] then
                        -- exclude already notified
                        if tonumber(msg.from.id) ~= tonumber(k) and tonumber(msg.from.id) ~= tonumber(bot.userVersion.id) and tonumber(k) ~= tonumber(bot.userVersion.id) then
                            -- exclude autotags and tags from tg-cli version and tags of tg-cli version
                            local usr = redis_hget_something('tagalert:usernames', k)
                            if usr == 'true' then
                                usr = nil
                            end
                            if check_tag(msg, k, usr) then
                                print('username', k)
                                if not msg.command then
                                    -- set user as notified to not send multiple notifications
                                    notified[tostring(k)] = true
                                    if sendChatAction(k, 'typing') then
                                        send_tag_alert(msg, k)
                                    end
                                else
                                    print("TAG FOUND BUT COMMAND")
                                end
                            end
                        end
                    end
                end
                local nicknames = redis_get_something('tagalert:nicknames')
                for k, v in pairs(nicknames) do
                    if not notified[tostring(k)] then
                        -- exclude already notified
                        if tonumber(msg.from.id) ~= tonumber(k) and tonumber(msg.from.id) ~= tonumber(bot.userVersion.id) and tonumber(k) ~= tonumber(bot.userVersion.id) then
                            -- exclude autotags and tags from tg-cli version and tags of tg-cli version
                            local nck = redis_hget_something('tagalert:usernames', k)
                            if nck == 'true' then
                                nck = nil
                            end
                            if check_tag(msg, k, nck) then
                                print('nickname', k)
                                if not msg.command then
                                    -- set user as notified to not send multiple notifications
                                    notified[tostring(k)] = true
                                    if sendChatAction(k, 'typing') then
                                        local obj = getChatMember(msg.chat.id, k)
                                        if type(obj) == 'table' then
                                            if obj.ok and obj.result then
                                                obj = obj.result
                                                if obj.status == 'creator' or obj.status == 'administrator' or obj.status == 'member' or obj.status == 'restricted' then
                                                    send_tag_alert(msg, k)
                                                end
                                            end
                                        end
                                    end
                                else
                                    print("TAG FOUND BUT COMMAND")
                                end
                            end
                        end
                    end
                end
            end
        end
        return msg
    end
end

return {
    description = "CHECK_TAG",
    patterns =
    {
        "^(###cbcheck_tag)(ALREADYREAD)$",
        "^(###cbcheck_tag)(REGISTER)$",
        "^(###cbcheck_tag)(DELETEUP)(%d+)(%-%d+)$",
        "^(###cbcheck_tag)(GOTO)(%d+)(%-%d+)$",

        "^[#!/]([Ee][Nn][Aa][Bb][Ll][Ee][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Dd][Ii][Ss][Aa][Bb][Ll][Ee][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Rr][Ee][Gg][Ii][Ss][Tt][Ee][Rr][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Uu][Nn][Rr][Ee][Gg][Ii][Ss][Tt][Ee][Rr][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Ee][Nn][Aa][Bb][Ll][Ee][Nn][Oo][Tt][Ii][Cc][Ee][Ss])$",
        "^[#!/]([Dd][Ii][Ss][Aa][Bb][Ll][Ee][Nn][Oo][Tt][Ii][Cc][Ee][Ss])$",
        "^[#!/]([Rr][Ee][Gg][Ii][Ss][Tt][Ee][Rr][Nn][Oo][Tt][Ii][Cc][Ee][Ss])$",
        "^[#!/]([Uu][Nn][Rr][Ee][Gg][Ii][Ss][Tt][Ee][Rr][Nn][Oo][Tt][Ii][Cc][Ee][Ss])$",
        "^[#!/]([Ss][Ee][Tt][Nn][Ii][Cc][Kk][Nn][Aa][Mm][Ee]) (.*)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Nn][Ii][Cc][Kk][Nn][Aa][Mm][Ee])$",
        "^[#!/]([Tt][Aa][Gg][Aa][Ll][Ll])$",
        "^[#!/]([Tt][Aa][Gg][Aa][Ll][Ll]) +(.+)$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/registertagalert",
        "/unregistertagalert",
        "/registernotices",
        "/unregisternotices",
        "/setnickname {nickname}",
        "/unsetnickname",
        "OWNER",
        "/enabletagalert",
        "/disabletagalert",
        "/enablenotices",
        "/disablenotices",
        -- "/tagall {text}|{reply_text}",
    },
}