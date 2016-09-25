local function get_variables_hash(msg, global)
    if global then
        return 'gvariables'
    else
        if msg.chat.type == 'channel' then
            return 'channel:' .. msg.chat.id .. ':variables'
        end
        if msg.chat.type == 'supergroup' then
            return 'supergroup:' .. msg.chat.id .. ':variables'
        end
        if msg.chat.type == 'group' then
            return 'group:' .. msg.chat.id .. ':variables'
        end
        if msg.chat.type == 'private' then
            return 'user:' .. msg.from.id .. ':variables'
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
        redis:hset(hash, 'waiting', name)
        return langs[msg.lang].sendMedia
    end
end

local function run(msg, matches)
    if matches[1]:lower() == 'cancel' or matches[1]:lower() == 'sasha annulla' or matches[1]:lower() == 'annulla' then
        mystat('/cancel')
        if is_mod(msg) then
            local hash = get_variables_hash(msg, false)
            redis:hdel(hash, 'waiting')
            return langs[msg.lang].cancelled
        else
            return langs[msg.lang].require_mod
        end
    end

    if matches[1]:lower() == 'setmedia' or matches[1]:lower() == 'sasha setta media' or matches[1]:lower() == 'setta media' then
        mystat('/setmedia')
        if is_mod(msg) then
            return set_media(msg, string.sub(matches[2]:lower(), 1, 50))
        else
            return langs[msg.lang].require_mod
        end
    end

    if matches[1]:lower() == 'set' or matches[1]:lower() == 'sasha setta' or matches[1]:lower() == 'setta' then
        mystat('/set')
        if is_mod(msg) then
            return set_value(msg, string.sub(matches[2]:lower(), 1, 50), string.sub(matches[3], 1, 4096), false)
        else
            return langs[msg.lang].require_mod
        end
    end

    if matches[1]:lower() == 'setglobal' then
        mystat('/setglobal')
        if is_admin(msg) then
            return set_value(msg, string.sub(matches[2]:lower(), 1, 50), string.sub(matches[3], 1, 4096), true)
        else
            return langs[msg.lang].require_admin
        end
    end
end

local function pre_process(msg)
    if msg.media then
        local hash = get_variables_hash(msg, false)
        if hash then
            local name = redis:hget(hash, 'waiting')
            if name then
                if is_mod(msg) then
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
                        elseif msg.media_type == 'audio' then
                            file_id = msg.audio.file_id
                        elseif msg.media_type == 'voice' then
                            file_id = msg.voice.file_id
                        elseif msg.media_type == 'document' then
                            file_id = msg.document.file_id
                        elseif msg.media_type == 'sticker' then
                            file_id = msg.sticker.file_id
                        else
                            sendMessage(msg.chat.id, langs[msg.lang].useQuoteOnFile)
                        end
                        redis:hset(hash, name, msg.media_type .. file_id)
                        redis:hdel(hash, 'waiting')
                        sendMessage(msg.chat.id, langs[msg.lang].mediaSaved)
                    end
                else
                    sendMessage(msg.chat.id, langs[msg.lang].require_mod)
                end
            end
        else
            sendMessage(msg.chat.id, langs[msg.lang].nothingToSet)
        end
    end
    return msg
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
    pre_process = pre_process,
    run = run,
    min_rank = 1,
    syntax =
    {
        "MOD",
        "(#set|[sasha] setta) <var_name> <text>",
        "(#setmedia|[sasha] setta media) <var_name>",
        "(#cancel|[sasha] annulla)",
        "ADMIN",
        "#setglobal <var_name> <text>",
    },
}