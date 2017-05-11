local function get_variables_hash(msg, global)
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

    local hash = get_variables_hash(msg, global)
    if hash then
        redis:hset(hash, name, value)
        if global then
            return name .. langs[msg.lang].gSaved
        else
            return name .. langs[msg.lang].saved
        end
    end
end

local function set_media(msg, name)
    if not name then
        return langs[msg.lang].errorTryAgain
    end

    local hash = get_variables_hash(msg)
    if hash then
        if msg.reply_to_message.media then
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
            elseif msg.reply_to_message.media_type == 'audio' then
                file_id = msg.reply_to_message.audio.file_id
            elseif msg.reply_to_message.media_type == 'voice' then
                file_id = msg.reply_to_message.voice.file_id
            elseif msg.reply_to_message.media_type == 'document' then
                file_id = msg.reply_to_message.document.file_id
            elseif msg.reply_to_message.media_type == 'sticker' then
                file_id = msg.reply_to_message.sticker.file_id
            else
                sendMessage(msg.chat.id, langs[msg.lang].useQuoteOnFile)
            end
            redis:hset(hash, name, msg.reply_to_message.media_type .. file_id)
            sendMessage(msg.chat.id, langs[msg.lang].mediaSaved)
        end
    end
end

local function run(msg, matches)
    if matches[1]:lower() == 'setmedia' or matches[1]:lower() == 'sasha setta media' or matches[1]:lower() == 'setta media' then
        if msg.from.is_mod then
            mystat('/setmedia')
            if msg.reply then
                return set_media(msg, string.sub(matches[2]:lower(), 1, 50))
            end
        else
            return langs[msg.lang].require_mod
        end
    end

    if matches[1]:lower() == 'set' or matches[1]:lower() == 'sasha setta' or matches[1]:lower() == 'setta' then
        if msg.from.is_mod then
            mystat('/set')
            if string.match(matches[3], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            return set_value(msg, string.sub(matches[2]:lower(), 1, 50), string.sub(matches[3], 1, 4096), false)
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
            return set_value(msg, string.sub(matches[2]:lower(), 1, 50), string.sub(matches[3], 1, 4096), true)
        else
            return langs[msg.lang].require_admin
        end
    end
end

return {
    description = "SET",
    patterns =
    {
        "^[#!/]([Ss][Ee][Tt]) ([^%s]+) (.+)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll]) ([^%s]+) (.+)$",
        "^[#!/]([Ss][Ee][Tt][Mm][Ee][Dd][Ii][Aa]) ([^%s]+)$",
        "^[#!/]([Cc][Aa][Nn][Cc][Ee][Ll])$",
        -- set
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Ee][Tt][Tt][Aa]) ([^%s]+) (.+)$",
        "^([Ss][Ee][Tt][Tt][Aa]) ([^%s]+) (.+)$",
        -- setmedia
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Ee][Tt][Tt][Aa] [Mm][Ee][Dd][Ii][Aa]) ([^%s]+)$",
        "^([Ss][Ee][Tt][Tt][Aa] [Mm][Ee][Dd][Ii][Aa]) ([^%s]+)$",
        -- cancel
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Nn][Nn][Uu][Ll][Ll][Aa])$",
        "^([Aa][Nn][Nn][Uu][Ll][Ll][Aa])$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "MOD",
        "(#set|[sasha] setta) <var_name>|<pattern> <text>",
        "(#setmedia|[sasha] setta media) <var_name>|<pattern> <reply>",
        "ADMIN",
        "#setglobal <var_name>|<pattern> <text>",
    },
}