local preview_user = {
    id = '1234567890',
    first_name = 'FIRST_NAME',
    last_name = 'LAST_NAME',
    username = 'USERNAME',
    print_name = 'FIRST_NAME LAST_NAME'
}

-- tables that contains 'group_id' = message_id to delete old goodbye/welcome messages
local last_goodbye = { }
local last_welcome = { }

local function set_welcome(chat_id, welcome)
    local lang = get_lang(chat_id)
    data[tostring(chat_id)]['welcome'] = welcome
    save_data(config.moderation.data, data)
    return langs[lang].newWelcome .. welcome
end

local function get_welcome(chat_id)
    if data[tostring(chat_id)] then
        if data[tostring(chat_id)]['welcome'] then
            local welcome = data[tostring(chat_id)]['welcome']
            return welcome
        end
    end
end

local function unset_welcome(chat_id)
    local lang = get_lang(chat_id)
    data[tostring(chat_id)]['welcome'] = nil
    save_data(config.moderation.data, data)
    return langs[lang].welcomeRemoved
end

local function set_memberswelcome(chat_id, value)
    local lang = get_lang(chat_id)
    data[tostring(chat_id)]['welcomemembers'] = value
    save_data(config.moderation.data, data)
    return string.gsub(langs[lang].newWelcomeNumber, 'X', tostring(value))
end

local function get_memberswelcome(chat_id)
    local lang = get_lang(chat_id)
    if not data[tostring(chat_id)]['welcomemembers'] then
        return langs[lang].noSetValue
    end
    local value = data[tostring(chat_id)]['welcomemembers']
    return value
end

local function set_goodbye(chat_id, goodbye)
    local lang = get_lang(chat_id)
    data[tostring(chat_id)]['goodbye'] = goodbye
    save_data(config.moderation.data, data)
    return langs[lang].newGoodbye .. goodbye
end

local function get_goodbye(chat_id)
    if data[tostring(chat_id)] then
        if data[tostring(chat_id)]['goodbye'] then
            local goodbye = data[tostring(chat_id)]['goodbye']
            return goodbye
        end
    end
end

local function unset_goodbye(chat_id)
    local lang = get_lang(chat_id)
    data[tostring(chat_id)]['goodbye'] = nil
    save_data(config.moderation.data, data)
    return langs[lang].goodbyeRemoved
end

local function get_rules(chat_id)
    local lang = get_lang(chat_id)
    if not data[tostring(chat_id)]['rules'] then
        return langs[lang].noRules
    end
    local rules = data[tostring(chat_id)]['rules']
    return rules
end

local function adjust_goodbyewelcome(goodbyewelcome, chat, user)
    -- chat
    if string.find(goodbyewelcome, '$chatid') then
        goodbyewelcome = goodbyewelcome:gsub('$chatid', chat.id)
    end
    if string.find(goodbyewelcome, '$chatname') then
        goodbyewelcome = goodbyewelcome:gsub('$chatname', chat.title)
    end
    if string.find(goodbyewelcome, '$chatusername') then
        if chat.username then
            goodbyewelcome = goodbyewelcome:gsub('$chatusername', '@' .. chat.username)
        else
            goodbyewelcome = goodbyewelcome:gsub('$chatusername', 'NO CHAT USERNAME')
        end
    end
    if string.find(goodbyewelcome, '$rules') then
        goodbyewelcome = goodbyewelcome:gsub('$rules', get_rules(chat.id))
    end
    if string.find(goodbyewelcome, '$grouplink') then
        if data[tostring(chat.id)].settings.set_link then
            goodbyewelcome = goodbyewelcome:gsub('$grouplink', data[tostring(chat.id)].settings.set_link)
        else
            goodbyewelcome = goodbyewelcome:gsub('$grouplink', 'NO GROUP LINK SET')
        end
    end

    -- user
    if string.find(goodbyewelcome, '$userid') then
        goodbyewelcome = goodbyewelcome:gsub('$userid', user.id)
    end
    if string.find(goodbyewelcome, '$firstname') then
        goodbyewelcome = goodbyewelcome:gsub('$firstname', user.first_name)
    end
    if string.find(goodbyewelcome, '$lastname') then
        if user.last_name then
            goodbyewelcome = goodbyewelcome:gsub('$lastname', user.last_name)
        end
    end
    if string.find(goodbyewelcome, '$printname') then
        user.print_name = user.first_name
        if user.last_name then
            user.print_name = user.print_name .. ' ' .. user.last_name
        end
        goodbyewelcome = goodbyewelcome:gsub('$printname', user.print_name)
    end
    if string.find(goodbyewelcome, '$username') then
        if user.username then
            goodbyewelcome = goodbyewelcome:gsub('$username', '@' .. user.username)
        else
            goodbyewelcome = goodbyewelcome:gsub('$username', 'NO USERNAME')
        end
    end
    return goodbyewelcome
end

local function sendWelcome(chat, added, message_id)
    local welcome = get_welcome(chat.id)
    if welcome then
        if string.match(welcome, '^photo') then
            welcome = welcome:gsub('^photo', '')
            local media_id = welcome:match('^([^%s]+)')
            local caption = welcome:match('^[^%s]+ (.*)')
            return sendPhotoId(chat.id, media_id, caption, message_id)
        elseif string.match(welcome, '^video') then
            welcome = welcome:gsub('^video', '')
            local media_id = welcome:match('^([^%s]+)')
            local caption = welcome:match('^[^%s]+ (.*)')
            return sendVideoId(chat.id, media_id, caption, message_id)
        elseif string.match(welcome, '^video_note') then
            welcome = welcome:gsub('^video_note', '')
            local media_id = welcome:match('^([^%s]+)')
            return sendVideoNoteId(chat.id, media_id, message_id)
        elseif string.match(welcome, '^audio') then
            welcome = welcome:gsub('^audio', '')
            local media_id = welcome:match('^([^%s]+)')
            local caption = welcome:match('^[^%s]+ (.*)')
            return sendAudioId(chat.id, media_id, caption, message_id)
        elseif string.match(welcome, '^voice_note') or string.match(welcome, '^voice') then
            welcome = welcome:gsub('^voice_note', '')
            welcome = welcome:gsub('^voice', '')
            local media_id = welcome:match('^([^%s]+)')
            local caption = welcome:match('^[^%s]+ (.*)')
            return sendVoiceId(chat.id, media_id, caption, message_id)
        elseif string.match(welcome, '^gif') then
            welcome = welcome:gsub('^gif', '')
            local media_id = welcome:match('^([^%s]+)')
            local caption = welcome:match('^[^%s]+ (.*)')
            return sendDocumentId(chat.id, media_id, caption, message_id)
        elseif string.match(welcome, '^document') then
            welcome = welcome:gsub('^document', '')
            local media_id = welcome:match('^([^%s]+)')
            local caption = welcome:match('^[^%s]+ (.*)')
            return sendDocumentId(chat.id, media_id, caption, message_id)
        elseif string.match(welcome, '^sticker') then
            welcome = welcome:gsub('^sticker', '')
            local media_id = welcome:match('^([^%s]+)')
            return sendStickerId(chat.id, media_id, message_id)
        else
            local text = ''
            for k, v in pairs(added) do
                text = text .. adjust_goodbyewelcome(welcome, chat, v) .. '\n'
            end
            return sendMessage(chat.id, text, false, message_id)
        end
    end
end

local function sendGoodbye(chat, removed, message_id)
    local goodbye = get_goodbye(chat.id)
    if goodbye then
        if string.match(goodbye, '^photo') then
            goodbye = goodbye:gsub('^photo', '')
            local media_id = goodbye:match('^([^%s]+)')
            local caption = goodbye:match('^[^%s]+ (.*)')
            return sendPhotoId(chat.id, media_id, caption, message_id)
        elseif string.match(goodbye, '^video') then
            goodbye = goodbye:gsub('^video', '')
            local media_id = goodbye:match('^([^%s]+)')
            local caption = goodbye:match('^[^%s]+ (.*)')
            return sendVideoId(chat.id, media_id, caption, message_id)
        elseif string.match(goodbye, '^video_note') then
            goodbye = goodbye:gsub('^video_note', '')
            local media_id = goodbye:match('^([^%s]+)')
            return sendVideoNoteId(chat.id, media_id, message_id)
        elseif string.match(goodbye, '^audio') then
            goodbye = goodbye:gsub('^audio', '')
            local media_id = goodbye:match('^([^%s]+)')
            local caption = goodbye:match('^[^%s]+ (.*)')
            return sendAudioId(chat.id, media_id, caption, message_id)
        elseif string.match(goodbye, '^voice_note') or string.match(goodbye, '^voice') then
            goodbye = goodbye:gsub('^voice_note', '')
            goodbye = goodbye:gsub('^voice', '')
            local media_id = goodbye:match('^([^%s]+)')
            local caption = goodbye:match('^[^%s]+ (.*)')
            return sendVoiceId(chat.id, media_id, caption, message_id)
        elseif string.match(goodbye, '^gif') then
            goodbye = goodbye:gsub('^gif', '')
            local media_id = goodbye:match('^([^%s]+)')
            local caption = goodbye:match('^[^%s]+ (.*)')
            return sendDocumentId(chat.id, media_id, caption, message_id)
        elseif string.match(goodbye, '^document') then
            goodbye = goodbye:gsub('^document', '')
            local media_id = goodbye:match('^([^%s]+)')
            local caption = goodbye:match('^[^%s]+ (.*)')
            return sendDocumentId(chat.id, media_id, caption, message_id)
        elseif string.match(goodbye, '^sticker') then
            goodbye = goodbye:gsub('^sticker', '')
            local media_id = goodbye:match('^([^%s]+)')
            return sendStickerId(chat.id, media_id, message_id)
        else
            return sendMessage(chat.id, adjust_goodbyewelcome(goodbye, chat, removed), false, message_id)
        end
    end
end

local function run(msg, matches)
    if is_realm(msg) or is_group(msg) or is_super_group(msg) then
        if msg.from.is_mod then
            if matches[1]:lower() == 'getwelcome' then
                mystat('/getwelcome')
                return get_welcome(msg.chat.id)
            end
            if matches[1]:lower() == 'getgoodbye' then
                mystat('/getgoodbye')
                return get_goodbye(msg.chat.id)
            end
            if matches[1]:lower() == 'previewwelcome' then
                mystat('/previewwelcome')
                if last_welcome[tostring(msg.chat.id)] then
                    deleteMessage(msg.chat.id, last_welcome[tostring(msg.chat.id)])
                end
                last_welcome[tostring(msg.chat.id)] = sendWelcome(msg.chat, { preview_user }, msg.message_id).result.message_id or nil
            end
            if matches[1]:lower() == 'previewgoodbye' then
                mystat('/previewgoodbye')
                if last_goodbye[tostring(msg.chat.id)] then
                    deleteMessage(msg.chat.id, last_goodbye[tostring(msg.chat.id)])
                end
                last_goodbye[tostring(msg.chat.id)] = sendGoodbye(msg.chat, preview_user, msg.message_id).result.message_id or nil
                return
            end
            if matches[1]:lower() == 'setwelcome' then
                mystat('/setwelcome')
                if msg.reply then
                    if msg.reply_to_message.media then
                        local file_id = ''
                        local caption = matches[2] or ''
                        if msg.reply_to_message.media_type == 'photo' then
                            local bigger_pic_id = ''
                            local size = 0
                            for k, v in pairsByKeys(msg.reply_to_message.photo) do
                                if v.file_size > size then
                                    size = v.file_size
                                    bigger_pic_id = v.file_id
                                end
                            end
                            file_id = bigger_pic_id
                        elseif msg.reply_to_message.media_type == 'video' then
                            file_id = msg.reply_to_message.video.file_id
                        elseif msg.reply_to_message.media_type == 'video_note' then
                            file_id = msg.reply_to_message.video_note.file_id
                        elseif msg.reply_to_message.media_type == 'audio' then
                            file_id = msg.reply_to_message.audio.file_id
                        elseif msg.reply_to_message.media_type == 'voice_note' then
                            file_id = msg.reply_to_message.voice.file_id
                        elseif msg.reply_to_message.media_type == 'gif' then
                            file_id = msg.reply_to_message.document.file_id
                        elseif msg.reply_to_message.media_type == 'document' then
                            file_id = msg.reply_to_message.document.file_id
                        elseif msg.reply_to_message.media_type == 'sticker' then
                            file_id = msg.reply_to_message.sticker.file_id
                        else
                            sendMessage(msg.chat.id, langs[msg.lang].useQuoteOnFile)
                        end
                        if caption ~= '' then
                            caption = ' ' .. caption
                        end
                        return set_welcome(msg.chat.id, msg.reply_to_message.media_type .. file_id .. caption)
                    else
                        return set_welcome(msg.chat.id, msg.reply_to_message.text)
                    end
                elseif matches[2] then
                    if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                        return langs[msg.lang].crossexecDenial
                    end
                    return set_welcome(msg.chat.id, matches[2])
                end
            end
            if matches[1]:lower() == 'setgoodbye' then
                mystat('/setgoodbye')
                if msg.reply then
                    if msg.reply_to_message.media then
                        local file_id = ''
                        local caption = matches[2] or ''
                        if msg.reply_to_message.media_type == 'photo' then
                            local bigger_pic_id = ''
                            local size = 0
                            for k, v in pairsByKeys(msg.reply_to_message.photo) do
                                if v.file_size > size then
                                    size = v.file_size
                                    bigger_pic_id = v.file_id
                                end
                            end
                            file_id = bigger_pic_id
                        elseif msg.reply_to_message.media_type == 'video' then
                            file_id = msg.reply_to_message.video.file_id
                        elseif msg.reply_to_message.media_type == 'video_note' then
                            file_id = msg.reply_to_message.video_note.file_id
                        elseif msg.reply_to_message.media_type == 'audio' then
                            file_id = msg.reply_to_message.audio.file_id
                        elseif msg.reply_to_message.media_type == 'voice_note' then
                            file_id = msg.reply_to_message.voice.file_id
                        elseif msg.reply_to_message.media_type == 'gif' then
                            file_id = msg.reply_to_message.document.file_id
                        elseif msg.reply_to_message.media_type == 'document' then
                            file_id = msg.reply_to_message.document.file_id
                        elseif msg.reply_to_message.media_type == 'sticker' then
                            file_id = msg.reply_to_message.sticker.file_id
                        else
                            sendMessage(msg.chat.id, langs[msg.lang].useQuoteOnFile)
                        end
                        if caption ~= '' then
                            caption = ' ' .. caption
                        end
                        return set_goodbye(msg.chat.id, msg.reply_to_message.media_type .. file_id .. caption)
                    else
                        return set_goodbye(msg.chat.id, msg.reply_to_message.text)
                    end
                elseif matches[2] then
                    if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                        return langs[msg.lang].crossexecDenial
                    end
                    return set_goodbye(msg.chat.id, matches[2])
                end
            end
            if matches[1]:lower() == 'unsetwelcome' then
                mystat('/unsetwelcome')
                return unset_welcome(msg.chat.id)
            end
            if matches[1]:lower() == 'unsetgoodbye' then
                mystat('/unsetgoodbye')
                return unset_goodbye(msg.chat.id)
            end
            if matches[1]:lower() == 'setmemberswelcome' then
                mystat('/setmemberswelcome')
                local text = set_memberswelcome(msg.chat.id, matches[2])
                if matches[2] == '0' then
                    return langs[msg.lang].neverWelcome
                else
                    return text
                end
            end
            if matches[1]:lower() == 'getmemberswelcome' then
                mystat('/getmemberswelcome')
                return get_memberswelcome(msg.chat.id)
            end
        else
            return langs[msg.lang].require_mod
        end
    end
end

local function pre_process(msg)
    if msg then
        if msg.service then
            if is_realm(msg) or is_group(msg) or is_super_group(msg) then
                if (msg.service_type == "chat_add_user" or msg.service_type == "chat_add_users" or msg.service_type == "chat_add_user_link") and get_memberswelcome(msg.chat.id) ~= langs[msg.lang].noSetValue and get_welcome(msg.chat.id) then
                    local hash
                    if msg.chat.type == 'group' then
                        hash = 'chat:welcome' .. msg.chat.id
                    end
                    if msg.chat.type == 'supergroup' then
                        hash = 'channel:welcome' .. msg.chat.id
                    end
                    redis:incr(hash)
                    local hashonredis = redis:get(hash)
                    if hashonredis then
                        if tonumber(hashonredis) >= tonumber(get_memberswelcome(msg.chat.id)) and tonumber(get_memberswelcome(msg.chat.id)) ~= 0 then
                            local tmp = last_welcome[tostring(msg.chat.id)]
                            last_welcome[tostring(msg.chat.id)] = sendWelcome(msg.chat, msg.added, msg.message_id).result.message_id or nil
                            redis:getset(hash, 0)
                            if tmp then
                                deleteMessage(msg.chat.id, tmp)
                            end
                        end
                    else
                        redis:set(hash, 0)
                    end
                end
                if (msg.service_type == "chat_del_user" or msg.service_type == "chat_add_user_leave") and get_goodbye(msg.chat.id) then
                    local tmp = last_goodbye[tostring(msg.chat.id)]
                    last_goodbye[tostring(msg.chat.id)] = sendGoodbye(msg.chat, msg.removed, msg.message_id).result.message_id or nil
                    if tmp then
                        deleteMessage(msg.chat.id, tmp)
                    end
                end
            end
        end
        return msg
    end
end

return {
    description = "GOODBYEWELCOME",
    patterns =
    {
        "^[#!/]([Ss][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee]) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee])$",
        "^[#!/]([Gg][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee])$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee])$",
        "^[#!/]([Pp][Rr][Ee][Vv][Ii][Ee][Ww][Ww][Ee][Ll][Cc][Oo][Mm][Ee])$",
        "^[#!/]([Ss][Ee][Tt][Gg][Oo][Oo][Dd][Bb][Yy][Ee]) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Oo][Oo][Dd][Bb][Yy][Ee])$",
        "^[#!/]([Gg][Ee][Tt][Gg][Oo][Oo][Dd][Bb][Yy][Ee])$",
        "^[#!/]([Pp][Rr][Ee][Vv][Ii][Ee][Ww][Gg][Oo][Oo][Dd][Bb][Yy][Ee])$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Gg][Oo][Oo][Dd][Bb][Yy][Ee])$",
        "^[#!/]([Ss][Ee][Tt][Mm][Ee][Mm][Bb][Ee][Rr][Ss][Ww][Ee][Ll][Cc][Oo][Mm][Ee]) (.*)$",
        "^[#!/]([Gg][Ee][Tt][Mm][Ee][Mm][Bb][Ee][Rr][Ss][Ww][Ee][Ll][Cc][Oo][Mm][Ee])$",
    },
    pre_process = pre_process,
    run = run,
    min_rank = 0,
    syntax =
    {
        "MOD",
        "#getwelcome",
        "#getgoodbye",
        "#previewwelcome",
        "#previewgoodbye",
        "#setwelcome <text>|(<reply_media> [<caption>])",
        "#setgoodbye <text>|(<reply_media> [<caption>])",
        "#unsetwelcome",
        "#unsetgoodbye",
        "#setmemberswelcome <value>",
        "#getmemberswelcome",
    },
}