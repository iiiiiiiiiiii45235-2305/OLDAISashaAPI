local function enable_channel(chat_id, to_id)
    if not to_id then
        to_id = chat_id
    end
    local lang = get_lang(chat_id)

    if not config.disabled_channels then
        config.disabled_channels = { }
    end

    if config.disabled_channels[chat_id] == nil then
        return sendMessage(to_id, langs[lang].botOn)
    end

    config.disabled_channels[chat_id] = false

    save_config()
    return sendMessage(to_id, langs[lang].botOn)
end

local function disable_channel(chat_id, to_id)
    if not to_id then
        to_id = chat_id
    end
    local lang = get_lang(chat_id)

    if not config.disabled_channels then
        config.disabled_channels = { }
    end

    config.disabled_channels[chat_id] = true

    save_config()
    return sendMessage(to_id, langs[lang].botOff)
end

local function run(msg, matches)
    if is_owner(msg) then
        if not string.match(matches[1], '^%d+$') then
            if matches[1]:lower() == 'on' then
                enable_channel(msg.chat.id)
            end
            if matches[1]:lower() == 'off' then
                disable_channel(msg.chat.id)
            end
        elseif is_admin(msg) then
            if matches[2]:lower() == 'on' then
                enable_channel(matches[1], msg.chat.id)
            end
            if matches[2]:lower() == 'off' then
                disable_channel(matches[1], msg.chat.id)
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
        "^[#!/][Bb][Oo][Tt] ([Oo][Nn])",
        "^[#!/][Bb][Oo][Tt] ([Oo][Ff][Ff])",
        "^[#!/][Bb][Oo][Tt] (%d+) ([Oo][Nn])",
        "^[#!/][Bb][Oo][Tt] (%d+) ([Oo][Ff][Ff])",
        -- bot
        "^[Ss][Aa][Ss][Hh][Aa] ([Oo][Nn])",
        "^[Ss][Aa][Ss][Hh][Aa] ([Oo][Ff][Ff])",
        "^[Ss][Aa][Ss][Hh][Aa] (%d+) ([Oo][Nn])",
        "^[Ss][Aa][Ss][Hh][Aa] (%d+) ([Oo][Ff][Ff])",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "OWNER",
        "#bot|sasha on|off",
        "ADMIN",
        "#bot|sasha [<group_id>] on|off",
    }
}