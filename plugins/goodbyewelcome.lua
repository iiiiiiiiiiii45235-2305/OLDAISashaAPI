multiple_kicks = { }

local function set_welcome(chat_id, welcome)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    data[tostring(chat_id)]['welcome'] = welcome
    save_data(config.moderation.data, data)
    return langs[lang].newWelcome .. welcome
end

local function get_welcome(chat_id)
    local data = load_data(config.moderation.data)
    if not data[tostring(chat_id)]['welcome'] then
        return ''
    end
    local welcome = data[tostring(chat_id)]['welcome']
    return welcome
end

local function unset_welcome(chat_id)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    data[tostring(chat_id)]['welcome'] = ''
    save_data(config.moderation.data, data)
    return langs[lang].welcomeRemoved
end

local function set_memberswelcome(chat_id, value)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    data[tostring(chat_id)]['welcomemembers'] = value
    save_data(config.moderation.data, data)
    return string.gsub(langs[lang].newWelcomeNumber, 'X', tostring(value))
end

local function get_memberswelcome(chat_id)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    if not data[tostring(chat_id)]['welcomemembers'] then
        return langs[lang].noSetValue
    end
    local value = data[tostring(chat_id)]['welcomemembers']
    return value
end

local function set_goodbye(chat_id, goodbye)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    data[tostring(chat_id)]['goodbye'] = goodbye
    save_data(config.moderation.data, data)
    return langs[lang].newGoodbye .. goodbye
end

local function get_goodbye(chat_id)
    local data = load_data(config.moderation.data)
    if not data[tostring(chat_id)]['goodbye'] then
        return ''
    end
    local goodbye = data[tostring(chat_id)]['goodbye']
    return goodbye
end

local function unset_goodbye(chat_id)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    data[tostring(chat_id)]['goodbye'] = ''
    save_data(config.moderation.data, data)
    return langs[lang].goodbyeRemoved
end

local function get_rules(chat_id)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    if not data[tostring(chat_id)]['rules'] then
        return langs[lang].noRules
    end
    local rules = data[tostring(chat_id)]['rules']
    return rules
end

local function run(msg, matches)
    if matches[1]:lower() == 'getwelcome' then
        return get_welcome(msg.chat.id)
    end
    if matches[1]:lower() == 'getgoodbye' then
        return get_goodbye(msg.chat.id)
    end
    if matches[1]:lower() == 'setwelcome' and is_mod(msg) then
        if string.match(matches[2], '[Aa][Uu][Tt][Oo][Ee][Xx][Ee][Cc]') then
            return langs[msg.lang].autoexecDenial
        end
        return set_welcome(msg.chat.id, matches[2])
    end
    if matches[1]:lower() == 'setgoodbye' and is_mod(msg) then
        if string.match(matches[2], '[Aa][Uu][Tt][Oo][Ee][Xx][Ee][Cc]') then
            return langs[msg.lang].autoexecDenial
        end
        return set_goodbye(msg.chat.id, matches[2])
    end
    if matches[1]:lower() == 'unsetwelcome' and is_mod(msg) then
        return unset_welcome(msg.chat.id)
    end
    if matches[1]:lower() == 'unsetgoodbye' and is_mod(msg) then
        return unset_goodbye(msg.chat.id)
    end
    if matches[1]:lower() == 'setmemberswelcome' and is_mod(msg) then
        local text = set_memberswelcome(msg.chat.id, matches[2])
        if matches[2] == '0' then
            return langs[msg.lang].neverWelcome
        else
            return text
        end
    end
    if matches[1]:lower() == 'getmemberswelcome' and is_mod(msg) then
        return get_memberswelcome(msg.chat.id)
    end
end

local function pre_process(msg)
    if msg.service then
        if (msg.service_type == "chat_add_user" or msg.service_type == "chat_add_user_link") and get_memberswelcome(msg.chat.id) ~= langs[msg.lang].noSetValue then
            local hash
            if msg.chat.type == 'supergroup' then
                hash = 'channel:welcome' .. msg.chat.id
            end
            if msg.chat.type == 'group' then
                hash = 'chat:welcome' .. msg.chat.id
            end
            redis:incr(hash)
            local hashonredis = redis:get(hash)
            if hashonredis then
                if tonumber(hashonredis) >= tonumber(get_memberswelcome(msg.chat.id)) and tonumber(get_memberswelcome(msg.chat.id)) ~= 0 then
                    sendMessage(msg.chat.id, get_welcome(msg.chat.id) .. '\n' .. get_rules(msg.chat.id))
                    redis:getset(hash, 0)
                end
            else
                redis:set(hash, 0)
            end
        end
        if (msg.service_type == "chat_del_user" or msg.service_type == "chat_add_user_leave") and get_goodbye(msg.chat.id) ~= '' then
            sendMessage(msg.chat.id, get_goodbye(msg.chat.id) .. ' ' .. msg.removed.print_name:gsub('_', ' '))
        end
    end
    return msg
end

return {
    description = "GOODBYEWELCOME",
    patterns =
    {
        "^[#!/]([Ss][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee]) (.*)$",
        "^[#!/]([Gg][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee])$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee])$",
        "^[#!/]([Ss][Ee][Tt][Gg][Oo][Oo][Dd][Bb][Yy][Ee]) (.*)$",
        "^[#!/]([Gg][Ee][Tt][Gg][Oo][Oo][Dd][Bb][Yy][Ee])$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Gg][Oo][Oo][Dd][Bb][Yy][Ee])$",
        "^[#!/]([Ss][Ee][Tt][Mm][Ee][Mm][Bb][Ee][Rr][Ss][Ww][Ee][Ll][Cc][Oo][Mm][Ee]) (.*)$",
        "^[#!/]([Gg][Ee][Tt][Mm][Ee][Mm][Bb][Ee][Rr][Ss][Ww][Ee][Ll][Cc][Oo][Mm][Ee])$",
    },
    pre_process = pre_process,
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#getwelcome: Sasha manda il benvenuto.",
        "#getgoodbye: Sasha manda l'addio.",
        "MOD",
        "#setwelcome <text>: Sasha imposta <text> come benvenuto.",
        "#setgoodbye <text>: Sasha imposta <text> come addio.",
        "#unsetwelcome: Sasha elimina il benvenuto",
        "#unsetgoodbye: Sasha elimina l'addio",
        "#setmemberswelcome <value>: Sasha dopo <value> membri manderà il benvenuto con le regole, se zero il benvenuto non verrà più mandato.",
        "#getmemberswelcome: Sasha manda il numero di membri entrati dopo i quali invia il benvenuto.",
    },
}