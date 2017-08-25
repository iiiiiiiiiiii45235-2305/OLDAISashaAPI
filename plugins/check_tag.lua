notified = { }

local function keyboard_tag(chat_id, message_id, callback, other_message_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }

    if not callback then
        keyboard.inline_keyboard[1] = { }
        keyboard.inline_keyboard[1][1] = { text = langs[get_lang(chat_id)].gotoMessage, callback_data = 'check_tagGOTO' .. message_id .. chat_id }

        keyboard.inline_keyboard[2] = { }
        keyboard.inline_keyboard[2][1] = { text = langs[get_lang(chat_id)].alreadyRead, callback_data = 'check_tagALREADYREAD' }
    else
        keyboard.inline_keyboard[1] = { }
        keyboard.inline_keyboard[1][1] = { text = langs[get_lang(chat_id)].deleteUp, callback_data = 'check_tagDELETEUP' .. chat_id }
    end

    return keyboard
end

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
            -- check if first name is in message
            if msg.text then
                if string.find(msg.text, user.first_name) then
                    return true
                end
            end
            if msg.media then
                if msg.caption then
                    if string.find(msg.caption, user.first_name) then
                        return true
                    end
                end
            end
            if user.username then
                -- check if username is in message
                if msg.text then
                    if string.find(msg.text:lower(), user.username:lower()) then
                        return true
                    end
                end
                if msg.media then
                    if msg.caption then
                        if string.find(msg.caption:lower(), user.username:lower()) then
                            return true
                        end
                    end
                end
            end
            return false
        else
            if msg.text then
                if string.find(msg.text:lower(), user:lower()) then
                    return true
                end
            end
            if msg.media then
                if msg.caption then
                    if string.find(msg.caption:lower(), user:lower()) then
                        return true
                    end
                end
            end
        end
    end
end

local function run(msg, matches)
    if msg.cb then
        if matches[1] then
            if matches[1] == '###cbcheck_tag' then
                if matches[2] then
                    if matches[2] == 'ALREADYREAD' then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].markedAsRead, false)
                        deleteMessage(msg.chat.id, msg.message_id)
                    elseif matches[3] and not matches[4] then
                        if matches[2] == 'DELETEUP' then
                            if deleteMessage(matches[3], msg.message_id) then
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].upMessageDeleted, false)
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].upMessageAlreadyDeleted, false)
                            end
                        end
                    elseif matches[3] and matches[4] then
                        if matches[2] == 'GOTO' then
                            if msg.from.username then
                                local res = sendKeyboard(matches[4], 'UP @' .. msg.from.username, false, keyboard_tag(matches[4], matches[3], true), matches[3])
                                if res then
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].repliedToMessage)
                                else
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].cantFindMessage)
                                end
                            else
                                local sent = false
                                local res = sendKeyboard(matches[4], 'UP [' .. msg.from.first_name .. '](tg://user?id=' .. msg.from.id .. ')', 'markdown', keyboard_tag(matches[4], matches[3], true), matches[3])
                                if res then
                                    sent = true
                                else
                                    res = sendKeyboard(matches[4], 'UP <a href="tg://user?id=' .. msg.from.id .. '">' .. msg.from.first_name .. '</a>', 'html', keyboard_tag(matches[4], matches[3], true), matches[3])
                                    if res then
                                        sent = true
                                    else
                                        res = sendKeyboard(matches[4], 'UP [' .. msg.from.first_name .. '](tg://user?id=' .. msg.from.id .. ')', false, keyboard_tag(matches[4], matches[3], true), matches[3])
                                        if res then
                                            sent = true
                                        end
                                    end
                                end
                                if sent then
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].repliedToMessage)
                                else
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].cantFindMessage)
                                end
                            end
                        end
                    end
                    return
                end
            end
        end
    end
    if matches[1]:lower() == 'enabletagalert' then
        if msg.from.is_owner then
            mystat('/enabletagalert')
            redis:set('tagalert:' .. tostring(msg.chat.id), true)
            return langs[msg.lang].tagalertGroupEnabled
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'disabletagalert' then
        if msg.from.is_owner then
            mystat('/disabletagalert')
            redis:del('tagalert:' .. tostring(msg.chat.id))
            return langs[msg.lang].tagalertGroupDisabled
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'registertagalert' then
        if msg.chat.type == 'private' then
            if not redis:hget('tagalert:usernames', msg.from.id) then
                mystat('/registertagalert')
                if msg.from.username then
                    redis:hset('tagalert:usernames', msg.from.id, msg.from.username:lower())
                else
                    redis:hset('tagalert:usernames', msg.from.id, true)
                end
                return langs[msg.lang].tagalertUserRegistered
            else
                return langs[msg.lang].tagalertAlreadyRegistered
            end
        else
            return langs[msg.lang].require_private
        end
    end

    if matches[1]:lower() == 'unregistertagalert' then
        if redis:hget('tagalert:usernames', msg.from.id) then
            mystat('/unregistertagalert')
            redis:hdel('tagalert:usernames', msg.from.id)
            redis:hdel('tagalert:nicknames', msg.from.id)
            return langs[msg.lang].tagalertUserUnregistered
        else
            return langs[msg.lang].tagalertRegistrationNeeded
        end
    end

    if matches[1]:lower() == 'setnickname' and matches[2] then
        if redis:hget('tagalert:usernames', msg.from.id) then
            if string.len(matches[2]) >= 3 then
                mystat('/setnickname')
                redis:hset('tagalert:nicknames', msg.from.id, matches[2]:lower())
                return langs[msg.lang].tagalertNicknameSet
            else
                return langs[msg.lang].tagalertNicknameTooShort
            end
        else
            return langs[msg.lang].tagalertRegistrationNeeded
        end
    end

    if matches[1]:lower() == 'unsetnickname' then
        if redis:hget('tagalert:usernames', msg.from.id) then
            mystat('/unsetnickname')
            redis:hdel('tagalert:nicknames', msg.from.id)
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

local function pre_process(msg)
    if msg then
        notified = { }
        -- update usernames
        if redis:hget('tagalert:usernames', msg.from.id) then
            if msg.from.username then
                if redis:hget('tagalert:usernames', msg.from.id) ~= msg.from.username:lower() then
                    redis:hset('tagalert:usernames', msg.from.id, msg.from.username:lower())
                end
            else
                redis:hset('tagalert:usernames', msg.from.id, true)
            end
        end
        if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
            -- exclude private chats with bot
            for v, user in pairs(sudoers) do
                if not notified[tostring(user.id)] then
                    -- exclude already notified
                    if tonumber(msg.from.id) ~= tonumber(user.id) and tonumber(msg.from.id) ~= tonumber(bot.userVersion.id) then
                        -- exclude autotags and tags of tg-cli version
                        if check_tag(msg, user.id, user) then
                            local lang = get_lang(user.id)
                            -- set user as notified to not send multiple notifications
                            notified[tostring(user.id)] = true
                            if msg.reply then
                                forwardMessage(user.id, msg.chat.id, msg.reply_to_message.message_id)
                            end
                            local text = langs[lang].receiver .. msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']\n' .. langs[lang].sender
                            if msg.from.username then
                                text = text .. '@' .. msg.from.username .. ' [' .. msg.from.id .. ']\n'
                            else
                                text = text .. msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']\n'
                            end
                            text = text .. langs[lang].msgText

                            if msg.text then
                                text = text .. msg.text
                            end
                            if msg.media then
                                if msg.caption then
                                    text = text .. msg.caption
                                end
                            end
                            sendMessage(user.id, text)
                            sendKeyboard(user.id, langs[lang].whatDoYouWantToDo, keyboard_tag(msg.chat.id, msg.message_id))
                        end
                    end
                end
            end
            if redis:get('tagalert:' .. msg.chat.id) then
                -- if group is enabled to tagalert notifications then
                local usernames = redis:hkeys('tagalert:usernames')
                for i = 1, #usernames do
                    if not notified[tostring(usernames[i])] then
                        -- exclude already notified
                        if tonumber(msg.from.id) ~= tonumber(usernames[i]) and tonumber(msg.from.id) ~= tonumber(bot.userVersion.id) then
                            -- exclude autotags and tags of tg-cli version
                            local usr = redis:hget('tagalert:usernames', usernames[i])
                            if usr == 'true' then
                                usr = nil
                            end
                            if check_tag(msg, usernames[i], usr) then
                                local lang = get_lang(usernames[i])
                                -- set user as notified to not send multiple notifications
                                notified[tostring(usernames[i])] = true
                                if msg.reply then
                                    forwardMessage(usernames[i], msg.chat.id, msg.reply_to_message.message_id)
                                end
                                local text = langs[lang].receiver .. msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']\n' .. langs[lang].sender
                                if msg.from.username then
                                    text = text .. '@' .. msg.from.username .. ' [' .. msg.from.id .. ']\n'
                                else
                                    text = text .. msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']\n'
                                end
                                text = text .. langs[lang].msgText

                                if msg.text then
                                    text = text .. msg.text
                                end
                                if msg.media then
                                    if msg.caption then
                                        text = text .. msg.caption
                                    end
                                end
                                sendMessage(usernames[i], text)
                                sendKeyboard(usernames[i], langs[lang].whatDoYouWantToDo, keyboard_tag(msg.chat.id, msg.message_id))
                            end
                        end
                    end
                end
                local nicknames = redis:hkeys('tagalert:nicknames')
                for i = 1, #nicknames do
                    if not notified[tostring(nicknames[i])] then
                        -- exclude already notified
                        if tonumber(msg.from.id) ~= tonumber(nicknames[i]) and tonumber(msg.from.id) ~= tonumber(bot.userVersion.id) then
                            -- exclude autotags and tags of tg-cli version
                            if check_tag(msg, nicknames[i], redis:hget('tagalert:nicknames', nicknames[i])) then
                                local obj = getChatMember(msg.chat.id, nicknames[i])
                                if type(obj) == 'table' then
                                    if obj.ok and obj.result then
                                        obj = obj.result
                                        if obj.status == 'creator' or obj.status == 'administrator' or obj.status == 'member' then
                                            local lang = get_lang(nicknames[i])
                                            -- set user as notified to not send multiple notifications
                                            notified[tostring(nicknames[i])] = true
                                            if msg.reply then
                                                forwardMessage(nicknames[i], msg.chat.id, msg.reply_to_message.message_id)
                                            end
                                            local text = langs[lang].receiver .. msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']\n' .. langs[lang].sender
                                            if msg.from.username then
                                                text = text .. '@' .. msg.from.username .. ' [' .. msg.from.id .. ']\n'
                                            else
                                                text = text .. msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']\n'
                                            end
                                            text = text .. langs[lang].msgText

                                            if msg.text then
                                                text = text .. msg.text
                                            end
                                            if msg.media then
                                                if msg.caption then
                                                    text = text .. msg.caption
                                                end
                                            end
                                            sendMessage(nicknames[i], text)
                                            sendKeyboard(nicknames[i], langs[lang].whatDoYouWantToDo, keyboard_tag(msg.chat.id, msg.message_id))
                                        end
                                    end
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
        "^(###cbcheck_tag)(DELETEUP)(%d+)(%-%d+)$",
        "^(###cbcheck_tag)(GOTO)(%d+)(%-%d+)$",

        "^[#!/]([Ee][Nn][Aa][Bb][Ll][Ee][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Dd][Ii][Ss][Aa][Bb][Ll][Ee][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Rr][Ee][Gg][Ii][Ss][Tt][Ee][Rr][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Uu][Nn][Rr][Ee][Gg][Ii][Ss][Tt][Ee][Rr][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Ss][Ee][Tt][Nn][Ii][Cc][Kk][Nn][Aa][Mm][Ee]) (.*)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Nn][Ii][Cc][Kk][Nn][Aa][Mm][Ee])$",
        "^[#!/]([Tt][Aa][Gg][Aa][Ll][Ll])$",
        "^[#!/]([Tt][Aa][Gg][Aa][Ll][Ll]) +(.+)$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#registertagalert",
        "#unregistertagalert",
        "#setnickname <nickname>",
        "#unsetnickname",
        "OWNER",
        "#enabletagalert",
        "#disabletagalert",
        -- "#tagall <text>|<reply_text>",
    },
}