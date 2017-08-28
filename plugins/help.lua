local function adjust_plugin_names(p, lang)
    if p == 'administrator' then
        return langs[lang].pluginAdministrator or 'ERR'
    elseif p == 'alternatives' then
        return langs[lang].pluginAlternatives or 'ERR'
    elseif p == 'anti_spam' then
        return langs[lang].pluginAnti_spam or 'ERR'
    elseif p == 'banhammer' then
        return langs[lang].pluginBanhammer or 'ERR'
    elseif p == 'bot' then
        return langs[lang].pluginBot or 'ERR'
    elseif p == 'check_tag' then
        return langs[lang].pluginCheck_tag or 'ERR'
    elseif p == 'database' then
        return langs[lang].pluginDatabase or 'ERR'
    elseif p == 'delword' then
        return langs[lang].pluginDelword or 'ERR'
    elseif p == 'dogify' then
        return langs[lang].pluginDogify or 'ERR'
    elseif p == 'fakecommand' then
        return langs[lang].pluginFakecommand or 'ERR'
    elseif p == 'feedback' then
        return langs[lang].pluginFeedback or 'ERR'
    elseif p == 'filemanager' then
        return langs[lang].pluginFilemanager or 'ERR'
    elseif p == 'flame' then
        return langs[lang].pluginFlame or 'ERR'
    elseif p == 'getsetunset' then
        return langs[lang].pluginGetsetunset or 'ERR'
    elseif p == 'goodbyewelcome' then
        return langs[lang].pluginGoodbyewelcome or 'ERR'
    elseif p == 'group_management' then
        return langs[lang].pluginGroup_management or 'ERR'
    elseif p == 'help' then
        return langs[lang].pluginHelp or 'ERR'
    elseif p == 'info' then
        return langs[lang].pluginInfo or 'ERR'
    elseif p == 'interact' then
        return langs[lang].pluginInteract or 'ERR'
    elseif p == 'likecounter' then
        return langs[lang].pluginLikecounter or 'ERR'
    elseif p == 'lua_exec' then
        return langs[lang].pluginLua_exec or 'ERR'
    elseif p == 'me' then
        return langs[lang].pluginMe or 'ERR'
    elseif p == 'msg_checks' then
        return langs[lang].pluginMsg_checks or 'ERR'
    elseif p == 'multiple_commands' then
        return langs[lang].pluginMultiple_commands or 'ERR'
    elseif p == 'news' then
        return langs[lang].pluginNews or 'ERR'
    elseif p == 'plugins' then
        return langs[lang].pluginPlugins or 'ERR'
    elseif p == 'pokedex' then
        return langs[lang].pluginPokedex or 'ERR'
    elseif p == 'qr' then
        return langs[lang].pluginQr or 'ERR'
    elseif p == 'shout' then
        return langs[lang].pluginShout or 'ERR'
    elseif p == 'stats' then
        return langs[lang].pluginStats or 'ERR'
    elseif p == 'strings' then
        return langs[lang].pluginStrings or 'ERR'
    elseif p == 'test' then
        return 'TEST' or 'ERR'
    elseif p == 'tgcli_to_api_migration' then
        return langs[lang].pluginTgcli_to_api_migration or 'ERR'
    elseif p == 'urbandictionary' then
        return langs[lang].pluginUrbandictionary or 'ERR'
    elseif p == 'webshot' then
        return langs[lang].pluginWebshot or 'ERR'
    elseif p == 'whitelist' then
        return langs[lang].pluginWhitelist or 'ERR'
    end
    return 'ERR'
end

-- Get commands for that plugin
local function plugin_help(var, chat, rank)
    local lang = get_lang(chat)
    local plugin = ''
    if tonumber(var) then
        local i = 0
        for name in pairsByKeys(plugins) do
            i = i + 1
            if i == tonumber(var) then
                plugin = plugins[name]
            end
        end
    else
        plugin = plugins[var]
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
        i = i + 1
        if plugins[name].min_rank <= tonumber(rank) then
            text = text .. '🅿️ ' .. i .. '. ' .. name .. '\n'
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
            i = i + 1
            if i == tonumber(var) then
                plugin = plugins[name]
            end
        end
    else
        plugin = plugins[var]
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
            if not filter then
                text = text .. '🅿️ ' .. i .. '. ' .. name:lower() .. '\n' .. temp
            else
                text = text .. temp
            end
            i = i + 1
        end
    end
    return text
end

local function keyboard_help_list(chat_id, rank)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local i = 0
    local flag = false
    keyboard.inline_keyboard[row] = { }
    for name in pairsByKeys(plugins) do
        i = i + 1
        if plugins[name].min_rank <= tonumber(rank) then
            if flag then
                flag = false
                row = row + 1
                column = 1
                keyboard.inline_keyboard[row] = { }
            end
            keyboard.inline_keyboard[row][column] = { text = --[[ '🅿️ ' .. ]] i .. '. ' .. name:lower(), callback_data = 'help' .. name }
            column = column + 1
        end
        if column > 2 then
            flag = true
        end
    end
    row = row + 1
    column = 1
    keyboard.inline_keyboard[row] = { }
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].updateKeyboard, callback_data = 'helpBACK' }
    column = column + 1
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].deleteKeyboard, callback_data = 'helpDELETE' }
    return keyboard
end

local function run(msg, matches)
    if msg.cb then
        if matches[1] == '###cbhelp' and matches[2] then
            if matches[2] == 'DELETE' then
                deleteMessage(msg.chat.id, msg.message_id)
            elseif matches[2] == 'BACK' then
                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].helpIntro, keyboard_help_list(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true)))
            else
                mystat('###cbhelp' .. matches[2])
                local temp = plugin_help(matches[2]:lower(), msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))
                if temp ~= nil then
                    if temp ~= '' then
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].helpIntro .. temp, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } })
                    else
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_higher, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } })
                    end
                else
                    editMessageText(msg.chat.id, msg.message_id, matches[2]:lower() .. langs[msg.lang].notExists, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } })
                end
            end
            return
        end
    end

    if matches[1]:lower() == 'sudolist' then
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
    --[[if matches[1]:lower() == 'helpall' then
        mystat('/helpall')
        return langs[msg.lang].helpIntro .. help_all(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))
    end]]

    if matches[1]:lower() == 'help' then
        if not matches[2] then
            mystat('/help')
            if sendKeyboard(msg.from.id, langs[msg.lang].helpIntro, keyboard_help_list(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))) then
                if msg.chat.type ~= 'private' then
                    return sendMessage(msg.chat.id, langs[msg.lang].sendHelpPvt)
                end
            else
                return langs[msg.lang].cantSendPvt
            end
        else
            mystat('/help <plugin>')
            local temp = plugin_help(matches[2]:lower(), msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))
            if temp ~= nil then
                if temp ~= '' then
                    if sendKeyboard(msg.from.id, langs[msg.lang].helpIntro .. temp, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } }) then
                        if msg.chat.type ~= 'private' then
                            return sendMessage(msg.chat.id, langs[msg.lang].sendHelpPvt)
                        end
                    else
                        return langs[msg.lang].cantSendPvt
                    end
                else
                    if sendKeyboard(msg.from.id, langs[msg.lang].require_higher, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } }) then
                        if msg.chat.type ~= 'private' then
                            return sendMessage(msg.chat.id, langs[msg.lang].sendHelpPvt)
                        end
                    else
                        return langs[msg.lang].cantSendPvt
                    end
                end
            else
                if sendKeyboard(msg.from.id, matches[2]:lower() .. langs[msg.lang].notExists, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } }) then
                    if msg.chat.type ~= 'private' then
                        return sendMessage(msg.chat.id, langs[msg.lang].sendHelpPvt)
                    end
                else
                    return langs[msg.lang].cantSendPvt
                end
            end
        end
    end

    if matches[1]:lower() == 'textualhelp' then
        if not matches[2] then
            mystat('/help')
            return langs[msg.lang].helpIntro .. telegram_help(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))
        else
            mystat('/help <plugin>')
            local temp = plugin_help(matches[2]:lower(), msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))
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

    --[[if matches[1]:lower() == 'syntaxall' then
        mystat('/syntaxall')
        return langs[msg.lang].helpIntro .. syntax_all(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))
    end]]

    if matches[1]:lower() == 'syntax' and matches[2] then
        mystat('/syntax <command>')
        matches[2] = matches[2]:gsub('[#!/]', '#')
        local text = syntax_all(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true), matches[2])
        if text == '' then
            return langs[msg.lang].commandNotFound
        else
            return langs[msg.lang].helpIntro .. text
        end
    end

    if matches[1]:lower() == 'faq' then
        if not matches[2] then
            mystat('/faq')
            return langs[msg.lang].faqList
        else
            mystat('/faq<n>')
            return langs[msg.lang].faq[tonumber(matches[2])]
        end
    end

    if matches[1]:lower() == 'deletekeyboard' then
        if msg.reply then
            if msg.reply_to_message.from.id == bot.id then
                if msg.reply_to_message.text then
                    mystat('/deletekeyboard')
                    return editMessageText(msg.chat.id, msg.reply_to_message.message_id, msg.reply_to_message.text)
                end
            end
        end
    end
end

return {
    description = "HELP",
    patterns =
    {
        "^(###cbhelp)(.*)(%-?%d+)$",
        "^(###cbhelp)(.*)$",
        -- "^[#!/]([Hh][Ee][Ll][Pp][Aa][Ll][Ll])$",
        "^[#!/]([Hh][Ee][Ll][Pp])$",
        "^[#!/]([Hh][Ee][Ll][Pp]) ([^%s]+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Hh][Ee][Ll][Pp])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Hh][Ee][Ll][Pp]) ([^%s]+)$",
        -- "^[#!/]([Ss][Yy][Nn][Tt][Aa][Xx][Aa][Ll][Ll])$",
        "^[#!/]([Ss][Yy][Nn][Tt][Aa][Xx]) (.*)$",
        "^[#!/]([Ss][Uu][Dd][Oo][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Dd][Ee][Ll][Ee][Tt][Ee][Kk][Ee][Yy][Bb][Oo][Aa][Rr][Dd])$",
        "^[#!/]([Ff][Aa][Qq])$",
        "^[#!/]([Ff][Aa][Qq])(%d+)$",
        "^[#!/]([Ff][Aa][Qq])(%d+)@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt]$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#sudolist",
        "#help",
        "#help <plugin_name>|<plugin_number>",
        "#textualhelp",
        "#textualhelp <plugin_name>|<plugin_number>",
        -- "#helpall",
        "#syntax <filter>",
        -- "#syntaxall",
        "#faq[<n>]",
        "#deletekeyboard <reply>",
    },
}