local function enable_channel(chat_id)
    local lang = get_lang(chat_id)

    if not config.disabled_channels then
        config.disabled_channels = { }
    end

    if config.disabled_channels[chat_id] == nil then
        return langs[lang].botOn
    end

    config.disabled_channels[chat_id] = false

    save_config()
    return langs[lang].botOn
end

local function disable_channel(chat_id)
    local lang = get_lang(chat_id)

    if not config.disabled_channels then
        config.disabled_channels = { }
    end

    config.disabled_channels[chat_id] = true

    save_config()
    return langs[lang].botOff
end

local function keyboard_langs(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local i = 0
    local flag = false
    keyboard.inline_keyboard[row] = { }
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].italian, callback_data = 'botIT' }
    column = column + 1
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].english, callback_data = 'botEN' }
    return keyboard
end

local function run(msg, matches)
    if msg.cb then
        if matches[1] == '###cbbot' and matches[2] then
            if matches[2] == 'IT' then
                redis:set('lang:' .. msg.chat.id, 'it')
                return editMessageText(msg.chat.id, msg.message_id, langs['it'].startMessage)
            elseif matches[2] == 'EN' then
                redis:set('lang:' .. msg.chat.id, 'en')
                return editMessageText(msg.chat.id, msg.message_id, langs['en'].startMessage)
            end
            return
        end
    end
    if matches[1]:lower() == '/start' and msg.bot then
        sendKeyboard(msg.chat.id, langs[msg.lang].startMessage, keyboard_langs(msg.chat.id))
        mystat('/start' ..(matches[2] or ''):lower())
        if matches[2] then
            msg.text = '/' .. matches[2]
            if msg_valid(msg) then
                msg = pre_process_msg(msg)
                if msg then
                    match_plugins(msg)
                end
            end
        end
    elseif msg.from.is_owner then
        if not matches[2] then
            if matches[1]:lower() == 'on' then
                mystat('/bot on')
                return enable_channel(msg.chat.id)
            end
            if matches[1]:lower() == 'off' then
                mystat('/bot off')
                return disable_channel(msg.chat.id)
            end
        elseif is_admin(msg) then
            if matches[1]:lower() == 'on' then
                mystat('/bot on <group_id>')
                return enable_channel(matches[2])
            end
            if matches[1]:lower() == 'off' then
                mystat('/bot off <group_id>')
                return disable_channel(matches[2])
            end
        else
            return langs[msg.lang].require_admin
        end
    else
        return langs[msg.lang].require_owner
    end
end

return {
    description = "BOT",
    patterns =
    {
        "^(###cbbot)(..)$",
        "^(/[Ss][Tt][Aa][Rr][Tt])$",
        "^(/[Ss][Tt][Aa][Rr][Tt]) (.*)$",
        "^(/[Ss][Tt][Aa][Rr][Tt])@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt]$",
        "^(/[Ss][Tt][Aa][Rr][Tt])@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt] (.*)$",
        "^[#!/][Bb][Oo][Tt] ([Oo][Nn])$",
        "^[#!/][Bb][Oo][Tt] ([Oo][Ff][Ff])$",
        "^[#!/][Bb][Oo][Tt] ([Oo][Nn]) (%-?%d+)$",
        "^[#!/][Bb][Oo][Tt] ([Oo][Ff][Ff]) (%-?%d+)$",
        -- bot
        "^[Ss][Aa][Ss][Hh][Aa] ([Oo][Nn])$",
        "^[Ss][Aa][Ss][Hh][Aa] ([Oo][Ff][Ff])$",
        "^[Ss][Aa][Ss][Hh][Aa] ([Oo][Nn]) (%-?%d+)$",
        "^[Ss][Aa][Ss][Hh][Aa] ([Oo][Ff][Ff]) (%-?%d+)$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "/start[@AISashaBot]",
        "OWNER",
        "#bot|sasha on|off",
        "ADMIN",
        "#bot|sasha on|off [<group_id>]",
    }
}