notified = { }
-- recursive to simplify code
local function check_tag(msg, user_id, user)
    if msg.entities then
        -- check if there's a text_mention
        if msg.entities.type == 'text_mention' and msg.entities.user then
            if tonumber(msg.entities.user.id) == tonumber(user_id) then
                return true
            end
        end
    end

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

local function run(msg, matches)
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
                            if check_tag(msg, usernames[i], redis:hget('tagalert:usernames', usernames[i])) then
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
        "^[#!/]([Ee][Nn][Aa][Bb][Ll][Ee][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Dd][Ii][Ss][Aa][Bb][Ll][Ee][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Rr][Ee][Gg][Ii][Ss][Tt][Ee][Rr][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Uu][Nn][Rr][Ee][Gg][Ii][Ss][Tt][Ee][Rr][Tt][Aa][Gg][Aa][Ll][Ee][Rr][Tt])$",
        "^[#!/]([Ss][Ee][Tt][Nn][Ii][Cc][Kk][Nn][Aa][Mm][Ee]) (.*)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Nn][Ii][Cc][Kk][Nn][Aa][Mm][Ee])$",
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
    },
}