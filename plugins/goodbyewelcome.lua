preview_user = {
    id = '1234567890',
    first_name = 'FIRST_NAME',
    last_name = 'LAST_NAME',
    username = '@USERNAME',
    print_name = 'FIRST_NAME LAST_NAME'
}

local function set_welcome(chat_id, welcome)
    local lang = get_lang(chat_id)
    data[tostring(chat_id)]['welcome'] = welcome
    save_data(config.moderation.data, data)
    return langs[lang].newWelcome .. welcome
end

local function get_welcome(chat_id)
    if not data[tostring(chat_id)]['welcome'] then
        return ''
    end
    local welcome = data[tostring(chat_id)]['welcome']
    return welcome
end

local function unset_welcome(chat_id)
    local lang = get_lang(chat_id)
    data[tostring(chat_id)]['welcome'] = ''
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
    if not data[tostring(chat_id)]['goodbye'] then
        return ''
    end
    local goodbye = data[tostring(chat_id)]['goodbye']
    return goodbye
end

local function unset_goodbye(chat_id)
    local lang = get_lang(chat_id)
    data[tostring(chat_id)]['goodbye'] = ''
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
    if string.find(goodbyewelcome, '$chatid') then
        goodbyewelcome:gsub('$chatid', chat.id)
    end
    if string.find(goodbyewelcome, '$chatname') then
        goodbyewelcome:gsub('$chatname', chat.title)
    end
    if string.find(goodbyewelcome, '$chatusername') then
        if chat.username then
            goodbyewelcome:gsub('$chatusername', '@' .. chat.username)
        else
            goodbyewelcome:gsub('$chatusername', chat.title)
        end
    end
    if string.find(goodbyewelcome, '$rules') then
        if not data[tostring(chat_id)]['rules'] then
            local lang = get_lang(chat_id)
            goodbyewelcome:gsub('$rules', langs[lang].noRules)
        end
        goodbyewelcome:gsub('$rules', data[tostring(chat_id)]['rules'])
    end
    if string.find(goodbyewelcome, '$userid') then
        goodbyewelcome:gsub('$userid', user.id)
    end
    if string.find(goodbyewelcome, '$firstname') then
        goodbyewelcome:gsub('$firstname', user.first_name)
    end
    if string.find(goodbyewelcome, '$lastname') then
        if user.last_name then
            goodbyewelcome:gsub('$lastname', user.last_name)
        end
    end
    if string.find(goodbyewelcome, '$printname') then
        goodbyewelcome:gsub('$printname', user.print_name:gsub('_', ' '))
    end
    if string.find(goodbyewelcome, '$username') then
        if user.username then
            goodbyewelcome:gsub('$username', '@' .. user.username)
        else
            goodbyewelcome:gsub('$username', user.first_name)
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
                return adjust_goodbyewelcome(get_welcome(msg.to.id), msg.to, preview_user)
            end
            if matches[1]:lower() == 'previewgoodbye' then
                mystat('/previewgoodbye')
                return adjust_goodbyewelcome(get_goodbye(msg.to.id), msg.to, preview_user)
            end
            if matches[1]:lower() == 'setwelcome' then
                mystat('/setwelcome')
                return set_welcome(msg.chat.id, matches[2])
            end
            if matches[1]:lower() == 'setgoodbye' then
                mystat('/setgoodbye')
                return set_goodbye(msg.chat.id, matches[2])
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
        end
    end
end

local function pre_process(msg)
    if msg.service then
        if is_realm(msg) or is_group(msg) or is_super_group(msg) then
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
                        sendMessage(msg.chat.id, adjust_goodbyewelcome(get_welcome(msg.chat.id), msg.chat, msg.added))
                        redis:getset(hash, 0)
                    end
                else
                    redis:set(hash, 0)
                end
            end
            if (msg.service_type == "chat_del_user" or msg.service_type == "chat_add_user_leave") and get_goodbye(msg.chat.id) ~= '' then
                sendMessage(msg.chat.id, adjust_goodbyewelcome(get_goodbye(msg.chat.id), msg.chat, msg.removed))
            end
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
        "^[#!/]([Pp][Rr][Ee][Vv][Ii][Ee][Ww][Ww][Ee][Ll][Cc][Oo][Mm][Ee])$",
        "^[#!/]([Ss][Ee][Tt][Gg][Oo][Oo][Dd][Bb][Yy][Ee]) (.*)$",
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
        "#setwelcome <text>",
        "#setgoodbye <text>",
        "#unsetwelcome",
        "#unsetgoodbye",
        "#setmemberswelcome <value>",
        "#getmemberswelcome",
    },
}