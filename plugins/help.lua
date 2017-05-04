-- Get commands for that plugin
local function plugin_help(var, chat, rank)
    local lang = get_lang(chat)
    local plugin = ''
    if tonumber(var) then
        local i = 0
        for name in pairsByKeys(plugins) do
            if config.disabled_plugin_on_chat[chat] then
                if not config.disabled_plugin_on_chat[chat][name] or config.disabled_plugin_on_chat[chat][name] == false then
                    i = i + 1
                    if i == tonumber(var) then
                        plugin = plugins[name]
                    end
                end
            else
                i = i + 1
                if i == tonumber(var) then
                    plugin = plugins[name]
                end
            end
        end
    else
        if config.disabled_plugin_on_chat[chat] then
            if not config.disabled_plugin_on_chat[chat][var] or config.disabled_plugin_on_chat[chat][var] == false then
                plugin = plugins[var]
            end
        else
            plugin = plugins[var]
        end
    end
    if not plugin or plugin == "" then
        return nil
    end
    if plugin.min_rank <= tonumber(rank) then
        local help_permission = true
        -- '=========================\n'
        local text = ''
        -- = '=======================\n'
        local textHash = plugin.description:lower()
        if langs[lang][textHash] then
            for i = 1, #langs[lang][plugin.description:lower()], 1 do
                if rank_table[langs[lang][plugin.description:lower()][i]] then
                    if rank_table[langs[lang][plugin.description:lower()][i]] > rank then
                        help_permission = false
                    end
                end
                if help_permission then
                    text = text .. langs[lang][plugin.description:lower()][i] .. '\n'
                end
            end
        end
        return text .. '\n'
    else
        return ''
    end
end

-- !help command
local function telegram_help(chat, rank)
    local lang = get_lang(chat)
    local i = 0
    local text = langs[lang].pluginListStart
    -- Plugins names
    for name in pairsByKeys(plugins) do
        if config.disabled_plugin_on_chat[chat] then
            if not config.disabled_plugin_on_chat[chat][name] or config.disabled_plugin_on_chat[chat][name] == false then
                i = i + 1
                if plugins[name].min_rank <= tonumber(rank) then
                    text = text .. '🅿️ ' .. i .. '. ' .. name .. '\n'
                end
            end
        else
            i = i + 1
            if plugins[name].min_rank <= tonumber(rank) then
                text = text .. '🅿️ ' .. i .. '. ' .. name .. '\n'
            end
        end
    end

    text = text .. '\n' .. langs[lang].helpInfo
    return text
end

-- !helpall command
local function help_all(chat, rank)
    local text = ""
    local i = 0
    local temp
    for name in pairsByKeys(plugins) do
        temp = plugin_help(name, chat, rank)
        if temp ~= nil then
            text = text .. temp
            i = i + 1
        end
    end
    return text
end

-- Get command syntax for that plugin
local function plugin_syntax(var, chat, rank, filter)
    local lang = get_lang(chat)
    local plugin = ''
    if tonumber(var) then
        local i = 0
        for name in pairsByKeys(plugins) do
            if config.disabled_plugin_on_chat[chat] then
                if not config.disabled_plugin_on_chat[chat][name] or config.disabled_plugin_on_chat[chat][name] == false then
                    i = i + 1
                    if i == tonumber(var) then
                        plugin = plugins[name]
                    end
                end
            else
                i = i + 1
                if i == tonumber(var) then
                    plugin = plugins[name]
                end
            end
        end
    else
        if config.disabled_plugin_on_chat[chat] then
            if not config.disabled_plugin_on_chat[chat][var] or config.disabled_plugin_on_chat[chat][var] == false then
                plugin = plugins[var]
            end
        else
            plugin = plugins[var]
        end
    end
    if not plugin or plugin == "" then
        return nil
    end
    if plugin.min_rank <= tonumber(rank) then
        local help_permission = true
        -- '=========================\n'
        local text = ''
        -- = '=======================\n'
        if plugin.syntax then
            for i = 1, #plugin.syntax, 1 do
                if rank_table[plugin.syntax[i]] then
                    if rank_table[plugin.syntax[i]] > rank then
                        help_permission = false
                    end
                end
                if help_permission then
                    if filter then
                        if string.find(plugin.syntax[i], filter:lower()) then
                            text = text .. plugin.syntax[i] .. '\n'
                        end
                    else
                        text = text .. plugin.syntax[i] .. '\n'
                    end
                end
            end
        end
        if filter then
            return text
        else
            return text .. '\n'
        end
    else
        return ''
    end
end

-- !syntaxall command
local function syntax_all(chat, rank, filter)
    local text = ""
    local i = 0
    local temp
    for name in pairsByKeys(plugins) do
        temp = plugin_syntax(name, chat, rank, filter)
        if temp ~= nil then
            text = text .. temp
            i = i + 1
        end
    end
    return text
end

local function keyboard_help_list(chat, user, rank)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local i = 0
    local flag = false
    keyboard.inline_keyboard[row] = { }
    for name in pairsByKeys(plugins) do
        if config.disabled_plugin_on_chat[chat] then
            if not config.disabled_plugin_on_chat[chat][name] or config.disabled_plugin_on_chat[chat][name] == false then
                i = i + 1
                if plugins[name].min_rank <= tonumber(rank) then
                    if flag then
                        flag = false
                        row = row + 1
                        column = 1
                        keyboard.inline_keyboard[row] = { }
                    end
                    keyboard.inline_keyboard[row][column] = { text = '🅿️ ' .. i .. '. ' .. name, callback_data = user .. name }
                    column = column + 1
                end
                if column > 2 then
                    flag = true
                end
            end
        else
            i = i + 1
            if plugins[name].min_rank <= tonumber(rank) then
                if flag then
                    flag = false
                    row = row + 1
                    column = 1
                    keyboard.inline_keyboard[row] = { }
                end
                keyboard.inline_keyboard[row][column] = { text = '🅿️ ' .. i .. '. ' .. name, callback_data = user .. name }
                column = column + 1
            end
            if column > 2 then
                flag = true
            end
        end
    end
    return keyboard
end

local function run(msg, matches)
    if matches[1] == '###cb' and matches[2] and matches[3] then
        if msg.from.id == tonumber(matches[2]) then
            if matches[3] == 'BACK' then
                return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].helpIntro, keyboard_help_list(msg.chat.id, msg.from.id, get_rank(msg.from.id, msg.chat.id)))
            else
                mystat('###cbhelp' .. matches[3])
                local temp = plugin_help(matches[3]:lower(), msg.chat.id, get_rank(msg.from.id, msg.chat.id))
                if temp ~= nil then
                    if temp ~= '' then
                        return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].helpIntro .. temp, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'BACK' } } } })
                    else
                        return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_higher, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'BACK' } } } })
                    end
                else
                    return editMessageText(msg.chat.id, msg.message_id, matches[3]:lower() .. langs[msg.lang].notExists, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'BACK' } } } })
                end
            end
        end
        return
    end

    if matches[1]:lower() == "sudolist" or matches[1]:lower() == "sasha lista sudo" then
        mystat('/sudolist')
        local text = 'SUDO INFO'
        for v, user in pairs(sudoers) do
            local lang = get_lang(msg.chat.id)
            if user.first_name then
                text = text .. langs[lang].name .. user.first_name
            end
            if user.last_name then
                text = text .. langs[lang].surname .. user.last_name
            end
            if user.username then
                text = text .. langs[lang].username .. '@' .. user.username
            end
            local msgs = tonumber(redis:get('msgs:' .. user.id .. ':' .. msg.chat.id) or 0)
            text = text .. langs[lang].date .. os.date('%c') ..
            langs[lang].totalMessages .. msgs
            text = text .. '\n🆔: ' .. user.id .. '\n\n'
        end
        return text
    end

    table.sort(plugins)
    if matches[1]:lower() == "helpall" or matches[1]:lower() == "sasha aiuto tutto" then
        mystat('/helpall')
        return langs[msg.lang].helpIntro .. help_all(msg.chat.id, get_rank(msg.from.id, msg.chat.id))
    end
    if matches[1]:lower() == "help" or matches[1]:lower() == "sasha aiuto" then
        if not matches[2] then
            mystat('/help')
            return langs[msg.lang].helpIntro .. telegram_help(msg.chat.id, get_rank(msg.from.id, msg.chat.id))
        else
            mystat('/help <plugin>')
            local temp = plugin_help(matches[2]:lower(), msg.chat.id, get_rank(msg.from.id, msg.chat.id))
            if temp ~= nil then
                if temp ~= '' then
                    return langs[msg.lang].helpIntro .. temp
                else
                    return langs[msg.lang].require_higher
                end
            else
                return matches[2]:lower() .. langs[msg.lang].notExists
            end
        end
    end
    if matches[1]:lower() == "tryhelp" then
        return sendKeyboard(msg.chat.id, langs[msg.lang].helpIntro, keyboard_help_list(msg.chat.id, msg.from.id, get_rank(msg.from.id, msg.chat.id)))
    end

    if matches[1]:lower() == "syntaxall" or matches[1]:lower() == "sasha sintassi tutto" then
        mystat('/syntaxall')
        return langs[msg.lang].helpIntro .. syntax_all(msg.chat.id, get_rank(msg.from.id, msg.chat.id))
    end
    if matches[1]:lower() == "syntax" or matches[1]:lower() == "sasha sintassi" and matches[2] then
        mystat('/syntax <command>')
        matches[2] = matches[2]:gsub('[#!/]', '#')
        local text = syntax_all(msg.chat.id, get_rank(msg.from.id, msg.chat.id), matches[2])
        if text == '' then
            return langs[msg.lang].commandNotFound
        else
            return langs[msg.lang].helpIntro .. text
        end
    end
    if matches[1]:lower() == "faq" then
        if not matches[2] then
            mystat('/faq')
            return langs[msg.lang].faqList
        else
            mystat('/faq<n>')
            return langs[msg.lang].faq[tonumber(matches[2])]
        end
    end
end

return {
    description = "HELP",
    patterns =
    {
        "^(###cb)(%d+)(.*)$",
        "^[#!/]([Hh][Ee][Ll][Pp][Aa][Ll][Ll])$",
        "^[#!/]([Hh][Ee][Ll][Pp])$",
        "^[#!/]([Tt][Rr][Yy][Hh][Ee][Ll][Pp])$",
        "^[#!/]([Hh][Ee][Ll][Pp]) ([^%s]+)$",
        "^[#!/]([Ss][Yy][Nn][Tt][Aa][Xx][Aa][Ll][Ll])$",
        "^[#!/]([Ss][Yy][Nn][Tt][Aa][Xx]) (.*)$",
        "^[#!/]([Ss][Uu][Dd][Oo][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Ff][Aa][Qq])$",
        "^[#!/]([Ff][Aa][Qq])(%d+)$",
        "^[#!/]([Ff][Aa][Qq])(%d+)@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt]$",
        -- helpall
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Ii][Uu][Tt][Oo] [Tt][Uu][Tt][Tt][Oo])$",
        -- help
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Ii][Uu][Tt][Oo])$",
        -- help <plugin_name>|<plugin_number>
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Ii][Uu][Tt][Oo]) ([^%s]+)$",
        -- syntaxall
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Ii][Nn][Tt][Aa][Ss][Ss][Ii] [Tt][Uu][Tt][Tt][Oo])$",
        -- syntax <filter>
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Ii][Nn][Tt][Aa][Ss][Ss][Ii]) (.*)$",
        -- sudolist
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Ss][Tt][Aa] [Ss][Uu][Dd][Oo])$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "(#sudolist|sasha lista sudo)",
        "(#help|sasha aiuto)",
        "(#help|sasha aiuto) <plugin_name>|<plugin_number>",
        "(#helpall|sasha aiuto tutto)",
        "(#syntax|sasha sintassi) <filter>",
        "(#syntaxall|sasha sintassi tutto)",
        "#faq[<n>]",
    },
}