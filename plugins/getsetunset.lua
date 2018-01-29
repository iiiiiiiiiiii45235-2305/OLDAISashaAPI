local function get_variables_hash(msg, global)
    if global then
        if not redis:get(msg.chat.id .. ':gvariables') then
            return 'gvariables'
        end
        return false
    else
        if msg.chat.type == 'private' then
            return 'user:' .. msg.from.id .. ':variables'
        end
        if msg.chat.type == 'group' then
            return 'group:' .. msg.chat.id .. ':variables'
        end
        if msg.chat.type == 'supergroup' then
            return 'supergroup:' .. msg.chat.id .. ':variables'
        end
        if msg.chat.type == 'channel' then
            return 'channel:' .. msg.chat.id .. ':variables'
        end
        return false
    end
end

local function list_variables(msg, global)
    local hash = nil
    if global then
        hash = get_variables_hash(msg, true)
    else
        hash = get_variables_hash(msg, false)
    end

    if hash then
        local names = redis:hkeys(hash)
        local text = ''
        for i = 1, #names do
            text = text .. names[i]:gsub('_', ' ') .. '\n'
        end
        return text
    end
end

local function get_value(msg, var_name)
    var_name = var_name:gsub(' ', '_')
    if not redis:get(msg.chat.id .. ':gvariables') then
        local hash = get_variables_hash(msg, true)
        if hash then
            local value = redis:hget(hash, var_name)
            if value then
                return value
            end
        end
    end

    local hash = get_variables_hash(msg, false)
    if hash then
        local value = redis:hget(hash, var_name)
        if value then
            return value
        end
    end
end

local function get_rules(chat_id)
    local lang = get_lang(chat_id)
    if not data[tostring(chat_id)]['rules'] then
        return langs[lang].noRules
    end
    local rules = data[tostring(chat_id)]['rules']
    return rules
end

local function adjust_value(value, msg, parse_mode)
    -- chat
    local chat = msg.chat
    if string.find(value, '$chatid') then
        value = value:gsub('$chatid', chat.id)
    end
    if string.find(value, '$chatname') then
        value = value:gsub('$chatname', chat.title)
    end
    if string.find(value, '$chatusername') then
        if chat.username then
            value = value:gsub('$chatusername', '@' .. chat.username)
        else
            value = value:gsub('$chatusername', 'NO CHAT USERNAME')
        end
    end
    if string.find(value, '$rules') then
        value = value:gsub('$rules', get_rules(chat.id))
    end
    if string.find(value, '$grouplink') then
        if data[tostring(chat.id)].settings.set_link then
            value = value:gsub('$grouplink', data[tostring(chat.id)].settings.set_link)
        else
            value = value:gsub('$grouplink', 'NO GROUP LINK SET')
        end
    end

    -- user
    local user = msg.from
    if string.find(value, '$userid') then
        value = value:gsub('$userid', user.id)
    end
    if string.find(value, '$firstname') then
        value = value:gsub('$firstname', user.first_name)
    end
    if string.find(value, '$lastname') then
        if user.last_name then
            value = value:gsub('$lastname', user.last_name)
        end
    end
    if string.find(value, '$printname') then
        user.print_name = user.first_name
        if user.last_name then
            user.print_name = user.print_name .. ' ' .. user.last_name
        end
        value = value:gsub('$printname', user.print_name)
    end
    if string.find(value, '$username') then
        if user.username then
            value = value:gsub('$username', '@' .. user.username)
        else
            value = value:gsub('$username', 'NO USERNAME')
        end
    end
    if string.find(value, '$mention') then
        if not parse_mode then
            value = value:gsub('$mention', '[' .. user.first_name .. '](tg://user?id=' .. user.id .. ')')
        else
            if parse_mode == 'html' then
                value = value:gsub('$mention', '<a href="tg://user?id=' .. user.id .. '">' .. html_escape(user.first_name) .. '</a>')
            elseif parse_mode == 'markdown' then
                value = value:gsub('$mention', '[' .. user.first_name:mEscape_hard() .. '](tg://user?id=' .. user.id .. ')')
            end
        end
    end

    -- replyuser
    local replyuser = user
    if msg.reply then
        replyuser = msg.reply_to_message.from
    end
    if string.find(value, '$replyuserid') then
        value = value:gsub('$replyuserid', replyuser.id)
    end
    if string.find(value, '$replyfirstname') then
        value = value:gsub('$replyfirstname', replyuser.first_name)
    end
    if string.find(value, '$replylastname') then
        if replyuser.last_name then
            value = value:gsub('$replylastname', replyuser.last_name)
        end
    end
    if string.find(value, '$replyprintname') then
        replyuser.print_name = replyuser.first_name
        if replyuser.last_name then
            replyuser.print_name = replyuser.print_name .. ' ' .. replyuser.last_name
        end
        value = value:gsub('$replyprintname', replyuser.print_name)
    end
    if string.find(value, '$replyusername') then
        if replyuser.username then
            value = value:gsub('$replyusername', '@' .. replyuser.username)
        else
            value = value:gsub('$replyusername', 'NO USERNAME')
        end
    end
    if string.find(value, '$replymention') then
        if not parse_mode then
            value = value:gsub('$replymention', '[' .. replyuser.first_name .. '](tg://user?id=' .. replyuser.id .. ')')
        else
            if parse_mode == 'html' then
                value = value:gsub('$replymention', '<a href="tg://user?id=' .. replyuser.id .. '">' .. html_escape(replyuser.first_name) .. '</a>')
            elseif parse_mode == 'markdown' then
                value = value:gsub('$replymention', '[' .. replyuser.first_name:mEscape_hard() .. '](tg://user?id=' .. replyuser.id .. ')')
            end
        end
    end

    -- forward chat
    local fwd_chat = chat
    if msg.forward and msg.forward_from_chat then
        fwd_chat = msg.forward_from_chat
    end
    if string.find(value, '$forwardchatid') then
        value = value:gsub('$forwardchatid', fwd_chat.id)
    end
    if string.find(value, '$forwardchatname') then
        value = value:gsub('$forwardchatname', fwd_chat.title)
    end
    if string.find(value, '$forwardchatusername') then
        if fwd_chat.username then
            value = value:gsub('$forwardchatusername', '@' .. fwd_chat.username)
        else
            value = value:gsub('$forwardchatusername', 'NO CHAT USERNAME')
        end
    end

    -- forward user
    local fwd_user = user
    if msg.forward and msg.forward_from then
        fwd_user = msg.forward_from
    end
    if string.find(value, '$forwarduserid') then
        value = value:gsub('$forwarduserid', fwd_user.id)
    end
    if string.find(value, '$forwardfirstname') then
        value = value:gsub('$forwardfirstname', fwd_user.first_name)
    end
    if string.find(value, '$forwardlastname') then
        if fwd_user.last_name then
            value = value:gsub('$forwardlastname', fwd_user.last_name)
        end
    end
    if string.find(value, '$forwardprintname') then
        fwd_user.print_name = fwd_user.first_name
        if fwd_user.last_name then
            fwd_user.print_name = fwd_user.print_name .. ' ' .. fwd_user.last_name
        end
        value = value:gsub('$forwardprintname', fwd_user.print_name)
    end
    if string.find(value, '$forwardusername') then
        if fwd_user.username then
            value = value:gsub('$forwardusername', '@' .. fwd_user.username)
        else
            value = value:gsub('$forwardusername', 'NO USERNAME')
        end
    end
    if string.find(value, '$forwardmention') then
        if not parse_mode then
            value = value:gsub('$forwardmention', '[' .. fwd_user.first_name .. '](tg://user?id=' .. fwd_user.id .. ')')
        else
            if parse_mode == 'html' then
                value = value:gsub('$forwardmention', '<a href="tg://user?id=' .. fwd_user.id .. '">' .. html_escape(fwd_user.first_name) .. '</a>')
            elseif parse_mode == 'markdown' then
                value = value:gsub('$forwardmention', '[' .. fwd_user.first_name:mEscape_hard() .. '](tg://user?id=' .. fwd_user.id .. ')')
            end
        end
    end
    return value
end

local function set_unset_variables_hash(msg, global)
    if global then
        return 'gvariables'
    else
        if msg.chat.type == 'private' then
            return 'user:' .. msg.from.id .. ':variables'
        end
        if msg.chat.type == 'group' then
            return 'group:' .. msg.chat.id .. ':variables'
        end
        if msg.chat.type == 'supergroup' then
            return 'supergroup:' .. msg.chat.id .. ':variables'
        end
        if msg.chat.type == 'channel' then
            return 'channel:' .. msg.chat.id .. ':variables'
        end
        return false
    end
end

local function set_value(msg, name, value, global)
    if (not name or not value) then
        return langs[msg.lang].errorTryAgain
    end

    local hash = set_unset_variables_hash(msg, global)
    if hash then
        redis:hset(hash, name, value)
        if global then
            return name .. langs[msg.lang].gSaved
        else
            return name .. langs[msg.lang].saved
        end
    end
end

local function unset_var(msg, name, global)
    if (not name) then
        return langs[msg.lang].errorTryAgain
    end

    local hash = set_unset_variables_hash(msg, global)
    if hash then
        redis:hdel(hash, name:lower())
        if global then
            return name:lower() .. langs[msg.lang].gDeleted
        else
            return name:lower() .. langs[msg.lang].deleted
        end
    end
end

local function check_word(msg, word, pre)
    if msg.text then
        if pre then
            if not string.match(msg.text, "^[#!/][Gg][Ee][Tt] (.*)$") and not string.match(msg.text, "^[#!/][Uu][Nn][Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll] ([^%s]+)$") and not string.match(msg.text, "^[#!/]([Ii][Mm][Pp][Oo][Rr][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Ss][Ee][Tt][Ss]) (.+)$") and not string.match(msg.text, "^[#!/][Uu][Nn][Ss][Ee][Tt] ([^%s]+)$") and not string.match(msg.text, "^[Uu][Nn][Ss][Ee][Tt][Tt][Aa] ([^%s]+)$") and not string.match(msg.text, "^[Ss][Aa][Ss][Hh][Aa] [Uu][Nn][Ss][Ee][Tt][Tt][Aa] ([^%s]+)$") and not string.match(msg.text, "^[#!/]([Ii][Mm][Pp][Oo][Rr][Tt][Gg][Rr][Oo][Uu][Pp][Ss][Ee][Tt][Ss]) (.+)$") then
                if string.match(msg.text:lower(), word) then
                    local value = get_value(msg, word)
                    if value then
                        print('GET FOUND')
                        return value
                    end
                end
            end
        else
            if string.match(msg.text:lower(), word) then
                local value = get_value(msg, word)
                if value then
                    print('GET FOUND')
                    return value
                end
            end
        end
    end
    if msg.media then
        if msg.caption then
            if string.match(msg.caption:lower(), word) then
                local value = get_value(msg, word)
                if value then
                    print('GET FOUND')
                    return value
                end
            end
        end
    end
    return false
end

local function run(msg, matches)
    if matches[1]:lower() == 'get' or matches[1]:lower() == 'getlist' then
        if not matches[2] then
            mystat('/get')
            return list_variables(msg, false)
        else
            mystat('/get <var_name>')
            local vars = list_variables(msg, false)
            if vars ~= nil then
                local t = vars:split('\n')
                for i, word in pairs(t) do
                    local answer = check_word(msg, word:lower(), false)
                    if answer then
                        return langs[msg.lang].getCommand:gsub('X', word:lower()) .. answer
                    end
                end
            end
            local vars = list_variables(msg, true)
            if vars ~= nil then
                local t = vars:split('\n')
                for i, word in pairs(t) do
                    local answer = check_word(msg, word:lower(), false)
                    if answer then
                        return langs[msg.lang].getCommand:gsub('X', word:lower()) .. answer
                    end
                end
            end
            return langs[msg.lang].noSetValue
        end
    end

    if matches[1]:lower() == 'getglobal' or matches[1]:lower() == 'getgloballist' then
        mystat('/getglobal')
        return list_variables(msg, true)
    end

    if matches[1]:lower() == 'exportgroupsets' then
        mystat('/exportgroupsets')
        if msg.from.is_owner then
            if list_variables(msg, false) then
                local tab = list_variables(msg, false):split('\n')
                local newtab = { }
                for i, word in pairs(tab) do
                    newtab[word] = get_value(msg, word:lower())
                end
                local text = ''
                for word, answer in pairs(newtab) do
                    text = text .. '/set ' .. word:gsub(' ', '_') .. ' ' .. answer .. '\nXXXxxxXXX\n'
                end
                return text
            end
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'exportglobalsets' then
        mystat('/exportglobalsets')
        if is_admin(msg) then
            if list_variables(msg, true) then
                local tab = list_variables(msg, true):split('\n')
                local newtab = { }
                for i, word in pairs(tab) do
                    newtab[word] = get_value(msg, word:lower())
                end
                local text = ''
                for word, answer in pairs(newtab) do
                    text = text .. '/setglobal ' .. word:gsub(' ', '_') .. ' ' .. answer .. '\nXXXxxxXXX\n'
                end
                return text
            end
        else
            return langs[msg.lang].require_admin
        end
    end

    if matches[1]:lower() == 'enableglobal' then
        mystat('/enableglobal')
        if msg.from.is_owner then
            redis:del(msg.chat.id .. ':gvariables')
            return langs[msg.lang].globalEnable
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'disableglobal' then
        mystat('/disableglobal')
        if msg.from.is_owner then
            redis:set(msg.chat.id .. ':gvariables', true)
            return langs[msg.lang].globalDisable
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'setmedia' then
        if msg.from.is_mod then
            mystat('/setmedia')
            if msg.reply then
                if not matches[2] then
                    return langs[msg.lang].errorTryAgain
                end

                local hash = set_unset_variables_hash(msg)
                if hash then
                    if msg.reply_to_message.media then
                        local file_id = ''
                        local caption = matches[3] or ''
                        if msg.reply_to_message.media_type == 'photo' then
                            local bigger_pic_id = ''
                            local size = 0
                            for k, v in pairsByKeys(msg.reply_to_message.photo) do
                                if v.file_size then
                                    if v.file_size > size then
                                        size = v.file_size
                                        bigger_pic_id = v.file_id
                                    end
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
                            return langs[msg.lang].useQuoteOnFile
                        end
                        if caption ~= '' then
                            caption = ' ' .. caption
                        end
                        if pcall( function()
                                string.match(string.sub(matches[2]:lower(), 1, 50), string.sub(matches[2]:lower(), 1, 50))
                            end ) then
                            redis:hset(hash, string.sub(matches[2]:lower(), 1, 50), msg.reply_to_message.media_type .. file_id .. caption)
                            return langs[msg.lang].mediaSaved
                        else
                            return langs[msg.lang].errorTryAgain
                        end
                    end
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end

    if matches[1]:lower() == 'set' then
        if msg.from.is_mod then
            mystat('/set')
            if string.match(matches[3], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            if pcall( function()
                    string.match(string.sub(matches[2]:lower(), 1, 50), string.sub(matches[2]:lower(), 1, 50))
                end ) then
                return set_value(msg, string.sub(matches[2]:lower(), 1, 50), string.sub(matches[3], 1, 4096), false)
            else
                return langs[msg.lang].errorTryAgain
            end
        else
            return langs[msg.lang].require_mod
        end
    end

    if matches[1]:lower() == 'setglobal' then
        if is_admin(msg) then
            mystat('/setglobal')
            if string.match(matches[3], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            if pcall( function()
                    string.match(string.sub(matches[2]:lower(), 1, 50), string.sub(matches[2]:lower(), 1, 50))
                end ) then
                return set_value(msg, string.sub(matches[2]:lower(), 1, 50), string.sub(matches[3], 1, 4096), true)
            else
                return langs[msg.lang].errorTryAgain
            end
        else
            return langs[msg.lang].require_admin
        end
    end

    if matches[1]:lower() == 'unset' then
        mystat('/unset')
        if msg.from.is_mod then
            return unset_var(msg, string.gsub(string.sub(matches[2], 1, 50), ' ', '_'):lower(), false)
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'unsetglobal' then
        mystat('/unsetglobal')
        if is_admin(msg) then
            return unset_var(msg, string.gsub(string.sub(matches[2], 1, 50), ' ', '_'):lower(), true)
        else
            return langs[msg.lang].require_admin
        end
    end
end

local function pre_process(msg)
    if msg then
        -- local
        local vars = list_variables(msg, false)
        if vars ~= nil then
            local t = vars:split('\n')
            for i, word in pairs(t) do
                local answer = check_word(msg, word:lower(), true)
                if answer then
                    if string.match(answer, '^photo') then
                        answer = answer:gsub('^photo', '')
                        local media_id = answer:match('^([^%s]+)')
                        local caption = answer:match('^[^%s]+ (.*)')
                        sendPhotoId(msg.chat.id, media_id, caption, msg.message_id)
                        return msg
                    elseif string.match(answer, '^video') then
                        answer = answer:gsub('^video', '')
                        local media_id = answer:match('^([^%s]+)')
                        local caption = answer:match('^[^%s]+ (.*)')
                        sendVideoId(msg.chat.id, media_id, caption, msg.message_id)
                        return msg
                    elseif string.match(answer, '^video_note') then
                        answer = answer:gsub('^video_note', '')
                        local media_id = answer:match('^([^%s]+)')
                        sendVideoNoteId(msg.chat.id, media_id, msg.message_id)
                        return msg
                    elseif string.match(answer, '^audio') then
                        answer = answer:gsub('^audio', '')
                        local media_id = answer:match('^([^%s]+)')
                        local caption = answer:match('^[^%s]+ (.*)')
                        sendAudioId(msg.chat.id, media_id, caption, msg.message_id)
                        return msg
                    elseif string.match(answer, '^voice_note') or string.match(answer, '^voice') then
                        answer = answer:gsub('^voice_note', '')
                        answer = answer:gsub('^voice', '')
                        local media_id = answer:match('^([^%s]+)')
                        local caption = answer:match('^[^%s]+ (.*)')
                        sendVoiceId(msg.chat.id, media_id, caption, msg.message_id)
                        return msg
                    elseif string.match(answer, '^gif') then
                        answer = answer:gsub('^gif', '')
                        local media_id = answer:match('^([^%s]+)')
                        local caption = answer:match('^[^%s]+ (.*)')
                        sendDocumentId(msg.chat.id, media_id, caption, msg.message_id)
                        return msg
                    elseif string.match(answer, '^document') then
                        answer = answer:gsub('^document', '')
                        local media_id = answer:match('^([^%s]+)')
                        local caption = answer:match('^[^%s]+ (.*)')
                        sendDocumentId(msg.chat.id, media_id, caption, msg.message_id)
                        return msg
                    elseif string.match(answer, '^sticker') then
                        answer = answer:gsub('^sticker', '')
                        local media_id = answer:match('^([^%s]+)')
                        sendStickerId(msg.chat.id, media_id, msg.message_id)
                        return msg
                    else
                        if string.find(answer, '$mention') or string.find(answer, '$replymention') or string.find(answer, '$forwardmention') then
                            if not sendReply(msg, adjust_value(answer, msg, 'markdown'), 'markdown') then
                                if not sendReply(msg, adjust_value(answer, msg, 'html'), 'html') then
                                    sendReply(msg, adjust_value(answer, msg))
                                end
                            end
                        else
                            sendReply(msg, adjust_value(answer, msg))
                        end
                        return msg
                    end
                end
            end
        end
        -- global
        local vars = list_variables(msg, true)
        if vars ~= nil then
            local t = vars:split('\n')
            for i, word in pairs(t) do
                local answer = check_word(msg, word:lower(), true)
                if answer then
                    if string.find(answer, '$mention') or string.find(answer, '$replymention') or string.find(answer, '$forwardmention') then
                        if not sendReply(msg, adjust_value(answer, msg, 'markdown'), 'markdown') then
                            if not sendReply(msg, adjust_value(answer, msg, 'html'), 'html') then
                                sendReply(msg, adjust_value(answer, msg))
                            end
                        end
                    else
                        sendReply(msg, adjust_value(answer, msg))
                    end
                    return msg
                end
            end
        end
        return msg
    end
end

return {
    description = "GETSETUNSET",
    patterns =
    {
        --- GET
        "^[#!/]([Gg][Ee][Tt]) (.*)$",
        "^[#!/]([Gg][Ee][Tt][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Gg][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Ee][Nn][Aa][Bb][Ll][Ee][Gg][Ll][Oo][Bb][Aa][Ll])$",
        "^[#!/]([Dd][Ii][Ss][Aa][Bb][Ll][Ee][Gg][Ll][Oo][Bb][Aa][Ll])$",
        "^[#!/]([Ee][Xx][Pp][Oo][Rr][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Ss][Ee][Tt][Ss])$",
        -- "^[#!/]([Ee][Xx][Pp][Oo][Rr][Tt][Gg][Rr][Oo][Uu][Pp][Ss][Ee][Tt][Ss])$",
        -- getlist
        "^[#!/]([Gg][Ee][Tt])$",
        -- getgloballist
        "^[#!/]([Gg][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll])$",

        --- SET
        "^[#!/]([Ss][Ee][Tt]) ([^%s]+) (.+)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll]) ([^%s]+) (.+)$",
        "^[#!/]([Ss][Ee][Tt][Mm][Ee][Dd][Ii][Aa]) ([^%s]+) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Mm][Ee][Dd][Ii][Aa]) ([^%s]+)$",

        --- UNSET
        "^[#!/]([Uu][Nn][Ss][Ee][Tt]) (.*)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll]) (.*)$",
    },
    pre_process = pre_process,
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "/get {var_name}",
        "(/getlist|/get)",
        "(/getgloballist|/getglobal)",
        "MOD",
        "/set {var_name}|{pattern} {text}",
        "/setmedia {var_name}|{pattern} {reply_media} [{caption}]",
        "/unset {var_name}|{pattern}",
        "OWNER",
        "/enableglobal",
        "/disableglobal",
        "ADMIN",
        "/setglobal {var_name}|{pattern} {text}",
        "/unsetglobal {var_name}|{pattern}",
    },
}