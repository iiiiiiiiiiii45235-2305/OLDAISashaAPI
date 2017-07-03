local function run(msg, matches)
    if matches[1]:lower() == 'getalternatives' and matches[2] then
        mystat('/getalternatives')
        local text = langs[msg.lang].listAlternatives:gsub('X', matches[2]:lower()) .. '\n'
        if alternatives.global.cmdAlt[matches[2]:lower()] then
            for k, v in pairs(alternatives.global.cmdAlt[matches[2]:lower()]) do
                text = text .. k .. 'G. ' .. v .. '\n'
            end
        end
        if data[tostring(msg.chat.id)] then
            if alternatives[tostring(msg.chat.id)] then
                matches[2] = matches[2]:gsub('[#!]', '/')
                if alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()] then
                    for k, v in pairs(alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()]) do
                        text = text .. k .. '. ' .. v .. '\n'
                    end
                end
            end
        end
        if text ==(langs[msg.lang].listAlternatives:gsub('X', matches[2]:lower()) .. '\n') then
            return langs[msg.lang].noAlternativeCommands:gsub('X', matches[2])
        else
            return text
        end
    end
    if matches[1]:lower() == 'setalternative' and matches[2] then
        if msg.from.is_mod then
            mystat('/setalternative')
            if matches[3] then
                if #matches[3] > 3 then
                    if string.match(matches[3], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                        return langs[msg.lang].crossexecDenial
                    end
                    matches[2] = matches[2]:gsub('[#!]', '/')
                    if not alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)] then
                        alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)] = { }
                    end
                    table.insert(alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)], matches[3]:lower())
                    alternatives[tostring(msg.chat.id)].altCmd[matches[3]:lower()] = string.sub(matches[2]:lower(), 1, 50)
                    save_alternatives()
                    return matches[3]:lower() .. langs[msg.lang].alternativeSaved
                else
                    return langs[msg.lang].errorCommandTooShort
                end
            elseif msg.reply_to_message.media then
                local file_id = ''
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
                matches[2] = matches[2]:gsub('[#!]', '/')
                if not alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)] then
                    alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)] = { }
                end
                table.insert(alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)], 'media:' .. msg.reply_to_message.media_type .. file_id)
                alternatives[tostring(msg.chat.id)].altCmd['media:' .. msg.reply_to_message.media_type .. file_id] = string.sub(matches[2]:lower(), 1, 50)
                save_alternatives()
                return 'media:' .. msg.reply_to_message.media_type .. file_id .. langs[msg.lang].alternativeSaved
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'setglobalalternative' and matches[2] then
        if is_admin(msg) then
            mystat('/setglobalalternative')
            if matches[3] then
                if #matches[3] > 3 then
                    if string.match(matches[3], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                        return langs[msg.lang].crossexecDenial
                    end
                    matches[2] = matches[2]:gsub('[#!]', '/')
                    if not alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)] then
                        alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)] = { }
                    end
                    table.insert(alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)], matches[3]:lower())
                    alternatives.global.altCmd[matches[3]:lower()] = string.sub(matches[2]:lower(), 1, 50)
                    save_alternatives()
                    return matches[3]:lower() .. langs[msg.lang].gAlternativeSaved
                else
                    return langs[msg.lang].errorCommandTooShort
                end
            elseif msg.reply_to_message.media then
                local file_id = ''
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
                matches[2] = matches[2]:gsub('[#!]', '/')
                if not alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)] then
                    alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)] = { }
                end
                table.insert(alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)], 'media:' .. msg.reply_to_message.media_type .. file_id)
                alternatives.global.altCmd['media:' .. msg.reply_to_message.media_type .. file_id] = string.sub(matches[2]:lower(), 1, 50)
                save_alternatives()
                return 'media:' .. msg.reply_to_message.media_type .. file_id .. langs[msg.lang].gAlternativeSaved
            end
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1]:lower() == 'unsetalternative' then
        if msg.from.is_mod then
            mystat('/unsetalternative')
            if matches[2] then
                if alternatives[tostring(msg.chat.id)].altCmd[matches[2]:lower()] then
                    local tempcmd = alternatives[tostring(msg.chat.id)].altCmd[matches[2]:lower()]
                    alternatives[tostring(msg.chat.id)].altCmd[matches[2]:lower()] = nil
                    if alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd] then
                        local tmptable = { }
                        for k, v in pairs(alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd]) do
                            if v ~= matches[2]:lower() then
                                table.insert(tmptable, v)
                            end
                        end
                        alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd] = tmptable
                    end
                    save_alternatives()
                    return matches[2]:lower() .. langs[msg.lang].alternativeDeleted
                else
                    return langs[msg.lang].noCommandsAlternative:gsub('X', matches[2])
                end
            elseif msg.reply_to_message.media then
                local file_id = ''
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
                if alternatives[tostring(msg.chat.id)].altCmd['media:' .. msg.reply_to_message.media_type .. file_id] then
                    local tempcmd = alternatives[tostring(msg.chat.id)].altCmd['media:' .. msg.reply_to_message.media_type .. file_id]
                    alternatives[tostring(msg.chat.id)].altCmd['media:' .. msg.reply_to_message.media_type .. file_id] = nil
                    if alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd] then
                        local tmptable = { }
                        for k, v in pairs(alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd]) do
                            if v ~= matches[2]:lower() then
                                table.insert(tmptable, v)
                            end
                        end
                        alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd] = tmptable
                    end
                    save_alternatives()
                    return 'media:' .. msg.reply_to_message.media_type .. file_id .. langs[msg.lang].alternativeDeleted
                else
                    return langs[msg.lang].noCommandsAlternative:gsub('X', 'media:' .. msg.reply_to_message.media_type .. file_id)
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'unsetglobalalternative' then
        if is_admin(msg) then
            mystat('/unsetglobalalternative')
            if matches[2] then
                if alternatives.global.altCmd[matches[2]:lower()] then
                    local tempcmd = alternatives.global.altCmd[matches[2]:lower()]
                    alternatives.global.altCmd[matches[2]:lower()] = nil
                    if alternatives.global.cmdAlt[tempcmd] then
                        local tmptable = { }
                        for k, v in pairs(alternatives.global.cmdAlt[tempcmd]) do
                            if v ~= matches[2]:lower() then
                                table.insert(tmptable, v)
                            end
                        end
                        alternatives.global.cmdAlt[tempcmd] = tmptable
                    end
                    save_alternatives()
                    return matches[2]:lower() .. langs[msg.lang].alternativegDeleted
                else
                    return langs[msg.lang].noCommandsAlternative:gsub('X', matches[2])
                end
            elseif msg.reply_to_message.media then
                local file_id = ''
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
                if alternatives.global.altCmd['media:' .. msg.reply_to_message.media_type .. file_id] then
                    local tempcmd = alternatives.global.altCmd['media:' .. msg.reply_to_message.media_type .. file_id]
                    alternatives.global.altCmd['media:' .. msg.reply_to_message.media_type .. file_id] = nil
                    if alternatives.global.cmdAlt[tempcmd] then
                        local tmptable = { }
                        for k, v in pairs(alternatives.global.cmdAlt[tempcmd]) do
                            if v ~= matches[2]:lower() then
                                table.insert(tmptable, v)
                            end
                        end
                        alternatives.global.cmdAlt[tempcmd] = tmptable
                    end
                    save_alternatives()
                    return 'media:' .. msg.reply_to_message.media_type .. file_id .. langs[msg.lang].alternativegDeleted
                else
                    return langs[msg.lang].noCommandsAlternative:gsub('X', 'media:' .. msg.reply_to_message.media_type .. file_id)
                end
            end
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1]:lower() == 'unsetalternatives' and matches[2] then
        if msg.from.is_owner then
            mystat('/unsetalternatives')
            matches[2] = matches[2]:gsub('[#!]', '/')
            if alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()] then
                local temptable = alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()]
                alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()] = nil
                for k, v in pairs(temptable) do
                    alternatives[tostring(msg.chat.id)].altCmd[v] = nil
                end
                save_alternatives()
                return langs[msg.lang].alternativesDeleted:gsub('X', matches[2])
            else
                return langs[msg.lang].noAlternativeCommands:gsub('X', matches[2])
            end
        else
            return langs[msg.lang].require_owner
        end
    end
end

local function pre_process(msg)
    if msg then
        if not msg.service then
            if data[tostring(msg.chat.id)] then
                if alternatives[tostring(msg.chat.id)] then
                    for k, v in pairs(alternatives[tostring(msg.chat.id)].altCmd) do
                        if msg.media then
                            local file_id = ''
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
                            else
                                return msg
                            end
                            if ('media:' .. msg.media_type .. file_id) == k then
                                -- one match is enough
                                msg.text = v
                                return msg
                            end
                        elseif string.match(msg.text:lower(), '^' .. k) then
                            -- one match is enough
                            msg.text = string.gsub(msg.text:lower(), '^' .. k, v)
                            return msg
                        end
                    end
                end
                if alternatives.global then
                    for k, v in pairs(alternatives.global.altCmd) do
                        if msg.media then
                            local file_id = ''
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
                            else
                                return msg
                            end
                            if ('media:' .. msg.media_type .. file_id) == k then
                                -- one match is enough
                                msg.text = v
                                return msg
                            end
                        elseif string.match(msg.text:lower(), '^' .. k) then
                            -- one match is enough
                            msg.text = string.gsub(msg.text:lower(), '^' .. k, v)
                            return msg
                        end
                    end
                end
            end
        end
        return msg
    end
end

return {
    description = "ALTERNATIVES",
    patterns =
    {
        "^[#!/]([Gg][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss]) ([#!/][^%s]+)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) (.*)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee])$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss]) ([#!/].*)$",
        "^[#!/]([Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) ([#!/][^%s]+) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) ([#!/][^%s]+)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) ([#!/][^%s]+) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) ([#!/][^%s]+)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) (.*)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee])$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#getalternatives /<command>",
        "MOD",
        "#setalternative /<command> <alternative>|<reply_media>",
        "#unsetalternative <alternative>|<reply_media>",
        "OWNER",
        "#unsetalternatives /<command>",
        "ADMIN",
        "#setglobalalternative /<command> <alternative>|<reply_media>",
        "#unsetglobalalternative <alternative>|<reply_media>",
    },
}