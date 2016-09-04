local function get_variables_hash(msg, global)
    if global then
        if not redis:get(msg.chat.id .. ':gvariables') then
            return 'gvariables'
        end
        return false
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

local function check_word(msg, word)
    if msg.text then
        if not string.match(msg.text, "^[#!/][Uu][Nn][Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll] ([^%s]+)$") and not string.match(msg.text, "^[#!/]([Ii][Mm][Pp][Oo][Rr][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Ss][Ee][Tt][Ss]) (.+)$") and not string.match(msg.text, "^[#!/][Uu][Nn][Ss][Ee][Tt] ([^%s]+)$") and not string.match(msg.text, "^[Uu][Nn][Ss][Ee][Tt][Tt][Aa] ([^%s]+)$") and not string.match(msg.text, "^[Ss][Aa][Ss][Hh][Aa] [Uu][Nn][Ss][Ee][Tt][Tt][Aa] ([^%s]+)$") and not string.match(msg.text, "^[#!/]([Ii][Mm][Pp][Oo][Rr][Tt][Gg][Rr][Oo][Uu][Pp][Ss][Ee][Tt][Ss]) (.+)$") then
            if string.match(msg.text:lower(), word) then
                local value = get_value(msg, word)
                if value then
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
                    return value
                end
            end
        end
    end
    return false
end

local function run(msg, matches)
    if (matches[1]:lower() == 'get' or matches[1]:lower() == 'getlist' or matches[1]:lower() == 'sasha lista') then
        return list_variables(msg, false)
    end

    if (matches[1]:lower() == 'getglobal' or matches[1]:lower() == 'getgloballist' or matches[1]:lower() == 'sasha lista globali') then
        return list_variables(msg, true)
    end

    if matches[1]:lower() == 'exportgroupsets' then
        if is_owner(msg) then
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
                sendMessage(msg.chat.id, text)
            end
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'exportglobalsets' then
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
                sendMessage(msg.chat.id, text)
            end
        else
            return langs[msg.lang].require_admin
        end
    end

    if matches[1]:lower() == 'enableglobal' then
        if is_owner(msg) then
            redis:del(msg.chat.id .. ':gvariables')
            return langs[msg.lang].globalEnable
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'disableglobal' then
        if is_owner(msg) then
            redis:set(msg.chat.id .. ':gvariables', true)
            return langs[msg.lang].globalDisable
        else
            return langs[msg.lang].require_owner
        end
    end
end

local function pre_process(msg, matches)
    local vars = list_variables(msg, true)
    if vars ~= nil then
        local t = vars:split('\n')
        for i, word in pairs(t) do
            local answer = check_word(msg, word:lower())
            if answer then
                sendReply(msg, answer)
            end
        end
    end

    local vars = list_variables(msg, false)
    if vars ~= nil then
        local t = vars:split('\n')
        for i, word in pairs(t) do
            local answer = check_word(msg, word:lower())
            if answer then
                sendPhotoId(msg.chat.id, answer)
                sendStickerId(msg.chat.id, answer)
                sendVoiceId(msg.chat.id, answer)
                sendAudioId(msg.chat.id, answer)
                sendVideoId(msg.chat.id, answer)
                sendDocumentId(msg.chat.id, answer)
                sendReply(msg, answer)
            end
        end
    end
    return msg
end

return {
    description = "GET",
    patterns =
    {
        "^[#!/]([Gg][Ee][Tt][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Gg][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Ee][Nn][Aa][Bb][Ll][Ee][Gg][Ll][Oo][Bb][Aa][Ll])$",
        "^[#!/]([Dd][Ii][Ss][Aa][Bb][Ll][Ee][Gg][Ll][Oo][Bb][Aa][Ll])$",
        "^[#!/]([Ee][Xx][Pp][Oo][Rr][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Ss][Ee][Tt][Ss])$",
        "^[#!/]([Ee][Xx][Pp][Oo][Rr][Tt][Gg][Rr][Oo][Uu][Pp][Ss][Ee][Tt][Ss])$",
        -- getlist
        "^[#!/]([Gg][Ee][Tt])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Ss][Tt][Aa])$",
        -- getgloballist
        "^[#!/]([Gg][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Ss][Tt][Aa] [Gg][Ll][Oo][Bb][Aa][Ll][Ii])$",
    },
    pre_process = pre_process,
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "(#getlist|#get|sasha lista)",
        "(#getgloballist|#getglobal|sasha lista globali)",
        "OWNER",
        "#enableglobal",
        "#disableglobal",
    },
}