-- Get commands for that plugin
local function plugin_help(var, chat, rank)
    local lang = get_lang(chat)
    local plugin = ''
    if tonumber(var) then
        local i = 0
        for name in pairsByKeys(plugins) do
            if _config.disabled_plugin_on_chat[chat] then
                if not _config.disabled_plugin_on_chat[chat][name] or _config.disabled_plugin_on_chat[chat][name] == false then
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
        if _config.disabled_plugin_on_chat[chat] then
            if not _config.disabled_plugin_on_chat[chat][var] or _config.disabled_plugin_on_chat[chat][var] == false then
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
        if _config.disabled_plugin_on_chat[chat] then
            if not _config.disabled_plugin_on_chat[chat][name] or _config.disabled_plugin_on_chat[chat][name] == false then
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
local function plugin_syntax(var, chat, rank)
    local lang = get_lang(chat)
    local plugin = ''
    if tonumber(var) then
        local i = 0
        for name in pairsByKeys(plugins) do
            if _config.disabled_plugin_on_chat[chat] then
                if not _config.disabled_plugin_on_chat[chat][name] or _config.disabled_plugin_on_chat[chat][name] == false then
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
        if _config.disabled_plugin_on_chat[chat] then
            if not _config.disabled_plugin_on_chat[chat][var] or _config.disabled_plugin_on_chat[chat][var] == false then
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
                    text = text .. plugin.syntax[i] .. '\n'
                end
            end
        end
        return text .. '\n'
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

local function run(msg, matches)
    if matches[1]:lower() == "sudolist" or matches[1]:lower() == "sasha lista sudo" then
        for v, user in pairs(_config.sudo_users) do
            if user ~= bot.id then
                local obj_user = getChat(user)
                local lang = get_lang(msg.chat.id)
                local text = 'SUDO INFO'
                if obj_user.first_name then
                    text = text .. langs[lang].name .. obj_user.first_name
                end
                if obj_user.last_name then
                    text = text .. langs[lang].surname .. obj_user.last_name
                end
                if obj_user.username then
                    text = text .. langs[lang].username .. '@' .. obj_user.username
                end
                local msgs = tonumber(redis:get('msgs:' .. user .. ':' .. msg.chat.tg_cli_id) or 0)
                text = text .. langs[lang].date .. os.date('%c') ..
                langs[lang].totalMessages .. msgs
                text = text .. '\n🆔: ' .. user .. '\n\n'
            end
        end
        return sendMessage(msg.chat.id, text)
    end

    table.sort(plugins)
    if matches[1]:lower() == "helpall" or matches[1]:lower() == "sasha aiuto tutto" then
        return sendMessage(msg.chat.id, langs[msg.lang].helpIntro .. help_all(msg.chat.id, get_rank(msg.from.id, msg.chat.id)))
    end
    if matches[1]:lower() == "help" or matches[1]:lower() == "sasha aiuto" then
        if not matches[2] then
            return sendMessage(msg.chat.id, langs[msg.lang].helpIntro .. telegram_help(msg.chat.id, get_rank(msg.from.id, msg.chat.id)))
        else
            local temp = plugin_help(matches[2]:lower(), msg.chat.id, get_rank(msg.from.id, msg.chat.id))
            if temp ~= nil then
                if temp ~= '' then
                    return sendMessage(msg.chat.id, langs[msg.lang].helpIntro .. temp)
                else
                    return langs[msg.lang].require_higher
                end
            else
                return matches[2]:lower() .. langs[msg.lang].notExists
            end
        end
    end

    if matches[1]:lower() == "syntaxall" or matches[1]:lower() == "sasha sintassi tutto" then
        return sendMessage(msg.chat.id, langs[msg.lang].helpIntro .. syntax_all(msg.chat.id, get_rank(msg.from.id, msg.chat.id)))
    end
    if matches[1]:lower() == "syntax" or matches[1]:lower() == "sasha sintassi" and matches[2] then
        local cmd_find = false
        local text = ''
        for name, plugin in pairsByKeys(plugins) do
            if plugin.syntax then
                for k, v in pairsByKeys(plugin.syntax) do
                    if string.find(v, matches[2]:lower()) then
                        cmd_find = true
                        text = text .. v .. '\n'
                    end
                end
            end
        end
        if not cmd_find then
            return sendMessage(msg.chat.id, langs[msg.lang].commandNotFound)
        else
            return sendMessage(msg.chat.id, langs[msg.lang].helpIntro .. text)
        end
    end
end

return {
    description = "HELP",
    patterns =
    {
        "^[#!/]([Hh][Ee][Ll][Pp][Aa][Ll][Ll])$",
        "^[#!/]([Hh][Ee][Ll][Pp])$",
        "^[#!/]([Hh][Ee][Ll][Pp]) ([^%s]+)$",
        "^[#!/]([Aa][Ll][Ll][Ss][Yy][Nn][Tt][Aa][Xx])$",
        "^[#!/]([Ss][Yy][Nn][Tt][Aa][Xx]) (.*)$",
        "^[#!/]([Ss][Uu][Dd][Oo][Ll][Ii][Ss][Tt])$",
        -- helpall
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Ii][Uu][Tt][Oo] [Tt][Uu][Tt][Tt][Oo])$",
        -- help
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Ii][Uu][Tt][Oo])$",
        -- help <plugin_name>|<plugin_number>
        "^([Ss][Aa][Ss][Hh][Aa] [Aa][Ii][Uu][Tt][Oo]) ([^%s]+)$",
        -- allsyntax
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
    },
}