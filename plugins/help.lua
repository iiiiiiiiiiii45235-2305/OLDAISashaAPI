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
    elseif p == 'scheduled_commands' then
        return langs[lang].pluginScheduled_commands or 'ERR'
    elseif p == 'shout' then
        return langs[lang].pluginShout or 'ERR'
    elseif p == 'spam' then
        return langs[lang].pluginSpam or 'ERR'
    elseif p == 'stats' then
        return langs[lang].pluginStats or 'ERR'
    elseif p == 'strings' then
        return langs[lang].pluginStrings or 'ERR'
    elseif p == 'test' then
        return 'TEST' or 'ERR'
    elseif p == 'tempmessage' then
        return langs[lang].pluginTempmessage or 'ERR'
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
                    text = text .. adjust_plugin_names(plugin.description:lower(), lang) .. '\n'
                    -- text = text .. langs[lang][plugin.description:lower()][i] .. '\n'
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

local function run(msg, matches)
    if msg.cb then
        if matches[1] == '###cbhelp' then
            if matches[2] == 'DELETE' then
                if not deleteMessage(msg.chat.id, msg.message_id, true) then
                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                end
            elseif matches[2] == 'BACK' then
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].helpIntro, keyboard_help_list(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true)))
                answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
            elseif matches[2] == 'BACKFAQ' then
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].faqList, keyboard_faq_list(msg.chat.id))
                answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
            elseif matches[2] == 'FAQ' then
                mystat('###cbhelp' .. matches[2] .. matches[3])
                if langs[msg.lang].faq[tonumber(matches[3])] then
                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].faq[tonumber(matches[3])], { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACKFAQ' } } } })
                else
                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].faq[0], { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACKFAQ' } } } })
                end
            else
                mystat('###cbhelp' .. matches[2])
                local temp = plugin_help(matches[2]:lower(), msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))
                if temp ~= nil then
                    if temp ~= '' then
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].helpIntro .. temp, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } })
                    else
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_higher, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } })
                    end
                else
                    editMessage(msg.chat.id, msg.message_id, matches[2]:lower() .. langs[msg.lang].notExists, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } })
                end
            end
            return
        end
    end
    if matches[1]:lower() == 'converttime' then
        if matches[2] and matches[3] and matches[4] and matches[5] and matches[6] then
            local time, weeks, days, hours, minutes, seconds = 0
            weeks = tonumber(matches[2])
            days = tonumber(matches[3])
            hours = tonumber(matches[4])
            minutes = tonumber(matches[5])
            seconds = tonumber(matches[6])
            time =(weeks * 7 * 24 * 60 * 60) +(days * 24 * 60 * 60) +(hours * 60 * 60) +(minutes * 60) + seconds
            return time .. langs[msg.lang].secondsWord
        else
            local remainder, weeks, days, hours, minutes, seconds = 0
            weeks = math.floor(matches[2] / 604800)
            remainder = matches[2] % 604800
            days = math.floor(remainder / 86400)
            remainder = remainder % 86400
            hours = math.floor(remainder / 3600)
            remainder = remainder % 3600
            minutes = math.floor(remainder / 60)
            seconds = remainder % 60
            return weeks .. langs[msg.lang].weeksWord .. days .. langs[msg.lang].daysWord .. hours .. langs[msg.lang].hoursWord .. minutes .. langs[msg.lang].minutesWord .. seconds .. langs[msg.lang].secondsWord
        end
    end
    if matches[1]:lower() == 'sudolist' then
        mystat('/sudolist')
        local text = 'SUDO INFO'
        for k, v in pairs(config.sudo_users) do
            local lang = get_lang(msg.chat.id)
            if type(v) == 'table' then
                if v.first_name then
                    text = text .. langs[lang].name .. v.first_name
                end
                if v.last_name then
                    text = text .. langs[lang].surname .. v.last_name
                end
                if v.username then
                    text = text .. langs[lang].username .. '@' .. v.username
                end
                local msgs = tonumber(redis:get('msgs:' .. v.id .. ':' .. msg.chat.id) or 0)
                text = text .. langs[lang].date .. os.date('%c') ..
                langs[lang].totalMessages .. msgs
            else
                text = text .. '\n🆔: ' .. k .. '\n\n'
            end
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
                    local message_id = sendReply(msg, langs[msg.lang].sendHelpPvt).result.message_id
                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                    return
                end
            else
                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
            end
        else
            mystat('/help <plugin>')
            local temp = plugin_help(matches[2]:lower(), msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))
            if temp ~= nil then
                if temp ~= '' then
                    if sendKeyboard(msg.from.id, langs[msg.lang].helpIntro .. temp, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } }) then
                        if msg.chat.type ~= 'private' then
                            local message_id = sendReply(msg, langs[msg.lang].sendHelpPvt).result.message_id
                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                            return
                        end
                    else
                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                    end
                else
                    if sendKeyboard(msg.from.id, langs[msg.lang].require_higher, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } }) then
                        if msg.chat.type ~= 'private' then
                            local message_id = sendReply(msg, langs[msg.lang].sendHelpPvt).result.message_id
                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                            return
                        end
                    else
                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                    end
                end
            else
                if sendKeyboard(msg.from.id, matches[2]:lower() .. langs[msg.lang].notExists, { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACK' } } } }) then
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendHelpPvt).result.message_id
                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
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
            if sendKeyboard(msg.from.id, langs[msg.lang].faqList, keyboard_faq_list(msg.chat.id)) then
                if msg.chat.type ~= 'private' then
                    local message_id = sendReply(msg, langs[msg.lang].sendFAQPvt).result.message_id
                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                    io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                    return
                end
            else
                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
            end
        else
            mystat('/faq<n>')
            if langs[msg.lang].faq[tonumber(matches[2])] then
                if sendKeyboard(msg.from.id, langs[msg.lang].faq[tonumber(matches[2])], { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACKFAQ' } } } }) then
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendFAQPvt).result.message_id
                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                end
            else
                if sendKeyboard(msg.from.id, langs[msg.lang].faq[0], { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'helpBACKFAQ' } } } }) then
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendFAQPvt).result.message_id
                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                        io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                end
            end
        end
    end
    if matches[1]:lower() == 'textualfaq' then
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
        "^(###cbhelp)(DELETE)$",
        "^(###cbhelp)(BACKFAQ)$",
        "^(###cbhelp)(BACK)$",
        "^(###cbhelp)(FAQ)(%d+)$",
        "^(###cbhelp)(.*)(%-?%d+)$",
        "^(###cbhelp)(.*)$",

        "^[#!/]([Cc][Oo][Nn][Vv][Ee][Rr][Tt][Tt][Ii][Mm][Ee]) (%d+) (%d+) (%d+) (%d+) (%d+)$",
        "^[#!/]([Cc][Oo][Nn][Vv][Ee][Rr][Tt][Tt][Ii][Mm][Ee]) (%d+)$",
        -- "^[#!/]([Hh][Ee][Ll][Pp][Aa][Ll][Ll])$",
        "^[#!/]([Hh][Ee][Ll][Pp])$",
        "^[#!/]([Hh][Ee][Ll][Pp]) ([^%s]+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Hh][Ee][Ll][Pp])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Hh][Ee][Ll][Pp]) ([^%s]+)$",
        -- "^[#!/]([Ss][Yy][Nn][Tt][Aa][Xx][Aa][Ll][Ll])$",
        "^[#!/]([Ss][Yy][Nn][Tt][Aa][Xx]) (.*)$",
        "^[#!/]([Ss][Uu][Dd][Oo][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Ff][Aa][Qq])$",
        "^[#!/]([Ff][Aa][Qq])@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt]$",
        "^[#!/]([Ff][Aa][Qq])(%d+)$",
        "^[#!/]([Ff][Aa][Qq])(%d+)@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt]$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ff][Aa][Qq])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ff][Aa][Qq])@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt]$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ff][Aa][Qq])(%d+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ff][Aa][Qq])(%d+)@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt]$",
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
        "#textualfaq[<n>]",
        "#converttime <seconds>",
        "#converttime <weeks> <days> <hours> <minutes> <seconds>",
    },
}