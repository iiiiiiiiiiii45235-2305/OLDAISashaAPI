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
                if rank_table[langs[lang][plugin.description:lower()][i]:gsub('<b>', ''):gsub('</b>', '')] then
                    if rank_table[langs[lang][plugin.description:lower()][i]:gsub('<b>', ''):gsub('</b>', '')] > rank then
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
            text = text .. '🅿️ ' .. i .. '. ' .. adjust_plugin_names(name:lower(), lang) .. '\n'
            -- text = text .. '🅿️ ' .. i .. '. ' .. name .. '\n'
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
        if temp ~= nil and temp ~= '' then
            -- if not filter then
            text = text .. '🅿️ ' .. i .. '. ' .. name:upper() .. ' 🅿️\n' .. temp
            -- else
            --     text = text .. temp
            -- end
        end
        i = i + 1
    end
    return text
end

local function run(msg, matches)
    if msg.cb then
        if matches[2] == 'DELETE' then
            if not deleteMessage(msg.chat.id, msg.message_id, true) then
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
            end
        elseif matches[2] == 'PAGES' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].uselessButton, false)
        elseif matches[2] == 'BACK' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].helpIntro, keyboard_help_pages(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true), matches[3] or 1), 'html')
        elseif matches[2]:gsub('%d', '') == 'PAGEMINUS' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].turningPage)
            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].helpIntro, keyboard_help_pages(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true), tonumber(matches[3] or(tonumber(matches[2]:match('%d')) + 1)) - tonumber(matches[2]:match('%d'))), 'html')
        elseif matches[2]:gsub('%d', '') == 'PAGEPLUS' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].turningPage)
            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].helpIntro, keyboard_help_pages(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true), tonumber(matches[3] or(tonumber(matches[2]:match('%d')) -1)) + tonumber(matches[2]:match('%d'))), 'html')
        elseif matches[2] == 'BACKFAQ' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].faqList, keyboard_faq_list(msg.chat.id), 'html')
        elseif matches[2] == 'FAQ' then
            answerCallbackQuery(msg.cb_id, 'FAQ' .. matches[3])
            if langs[msg.lang].faq[tonumber(matches[3])] then
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].faq[tonumber(matches[3])], { inline_keyboard = { { { text = langs[msg.lang].previousPage, callback_data = 'helpBACKFAQ' } } } })
            else
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].faq[0], { inline_keyboard = { { { text = langs[msg.lang].previousPage, callback_data = 'helpBACKFAQ' } } } })
            end
            mystat(matches[1] .. matches[2] .. matches[3])
        else
            answerCallbackQuery(msg.cb_id, matches[2]:lower())
            local temp = plugin_help(matches[2]:lower(), msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))
            if temp ~= nil then
                if temp ~= '' then
                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].helpIntro .. temp, { inline_keyboard = { { { text = langs[msg.lang].previousPage, callback_data = 'helpBACK' ..(matches[3] or 1) } } } }, 'html')
                else
                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_higher, { inline_keyboard = { { { text = langs[msg.lang].previousPage, callback_data = 'helpBACK' ..(matches[3] or 1) } } } })
                end
            else
                editMessage(msg.chat.id, msg.message_id, matches[2]:lower() .. langs[msg.lang].notExists, { inline_keyboard = { { { text = langs[msg.lang].previousPage, callback_data = 'helpBACK' ..(matches[3] or 1) } } } })
            end
            mystat(matches[1] .. matches[2])
        end
        return
    end
    if matches[1]:lower() == 'converttime' and matches[2] then
        if matches[3] and matches[4] and matches[5] and matches[6] then
            local unix = dateToUnix(matches[6], matches[5], matches[4], matches[3], matches[2])
            return unix .. langs[msg.lang].secondsWord
        else
            local seconds, minutes, hours, days, weeks = unixToDate(matches[2])
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
    if matches[1]:lower() == 'helpall' then
        mystat('/helpall')
        if sendMessage(msg.from.id, langs[msg.lang].helpIntro .. help_all(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true)), 'html') then
            if msg.chat.type ~= 'private' then
                local message_id = sendReply(msg, langs[msg.lang].sendHelpPvt, 'html').result.message_id
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                return
            end
        else
            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link .. "?start=helpall" } } } }, false, msg.message_id)
        end
        return
    end
    if matches[1]:lower() == 'help' then
        if not matches[2] then
            mystat('/help')
            if sendKeyboard(msg.from.id, langs[msg.lang].helpIntro, keyboard_help_pages(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true)), 'html') then
                if msg.chat.type ~= 'private' then
                    local message_id = sendReply(msg, langs[msg.lang].sendHelpPvt, 'html').result.message_id
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                    return
                end
            else
                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link .. "?start=help" } } } }, false, msg.message_id)
            end
        else
            mystat('/help <plugin>')
            local temp = plugin_help(matches[2]:lower(), msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))
            if temp ~= nil then
                if temp ~= '' then
                    if sendKeyboard(msg.from.id, langs[msg.lang].helpIntro .. temp, { inline_keyboard = { { { text = langs[msg.lang].previousPage, callback_data = 'helpBACK' } } } }, 'html') then
                        if msg.chat.type ~= 'private' then
                            local message_id = sendReply(msg, langs[msg.lang].sendHelpPvt, 'html').result.message_id
                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                            return
                        end
                    else
                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link .. "?start=help" } } } }, false, msg.message_id)
                    end
                else
                    if sendKeyboard(msg.from.id, langs[msg.lang].require_higher, { inline_keyboard = { { { text = langs[msg.lang].previousPage, callback_data = 'helpBACK' } } } }) then
                        if msg.chat.type ~= 'private' then
                            local message_id = sendReply(msg, langs[msg.lang].sendHelpPvt, 'html').result.message_id
                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                            return
                        end
                    else
                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link .. "?start=help" } } } }, false, msg.message_id)
                    end
                end
            else
                if sendKeyboard(msg.from.id, matches[2]:lower() .. langs[msg.lang].notExists, { inline_keyboard = { { { text = langs[msg.lang].previousPage, callback_data = 'helpBACK' } } } }) then
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendHelpPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link .. "?start=help" } } } }, false, msg.message_id)
                end
            end
        end
    end
    if matches[1]:lower() == 'textualhelp' then
        if not matches[2] then
            mystat('/help')
            return sendReply(msg, langs[msg.lang].helpIntro .. telegram_help(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true)), 'html')
        else
            mystat('/help <plugin>')
            local temp = plugin_help(matches[2]:lower(), msg.chat.id, get_rank(msg.from.id, msg.chat.id, true))
            if temp ~= nil then
                if temp ~= '' then
                    return sendReply(msg, langs[msg.lang].helpIntro .. temp, 'html')
                else
                    return langs[msg.lang].require_higher
                end
            else
                return matches[2]:lower() .. langs[msg.lang].notExists
            end
        end
    end
    if matches[1]:lower() == 'syntaxall' then
        mystat('/syntaxall')
        if sendMessage(msg.from.id, langs[msg.lang].syntaxIntro .. syntax_all(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true)), 'html') then
            if msg.chat.type ~= 'private' then
                local message_id = sendReply(msg, langs[msg.lang].sendSyntaxPvt, 'html').result.message_id
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                return
            end
        else
            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link .. "?start=syntaxall" } } } }, false, msg.message_id)
        end
        return
    end
    if matches[1]:lower() == 'syntax' then
        if #matches[2] >= 3 then
            mystat('/syntax <command>')
            matches[2] = matches[2]:gsub('[#!/]', '/')
            local text = syntax_all(msg.chat.id, get_rank(msg.from.id, msg.chat.id, true), matches[2])
            if text == '' then
                return langs[msg.lang].commandNotFound
            else
                if sendMessage(msg.from.id, langs[msg.lang].syntaxIntro .. text, 'html') then
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendSyntaxPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
                return
            end
        else
            return langs[msg.lang].filterTooShort
        end
    end
    if matches[1]:lower() == 'faq' then
        if not matches[2] then
            mystat('/faq')
            if sendKeyboard(msg.from.id, langs[msg.lang].faqList, keyboard_faq_list(msg.chat.id), 'html') then
                if msg.chat.type ~= 'private' then
                    local message_id = sendReply(msg, langs[msg.lang].sendFAQPvt, 'html').result.message_id
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                    return
                end
            else
                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link .. "?start=faq" } } } }, false, msg.message_id)
            end
        else
            mystat('/faq<n>')
            if langs[msg.lang].faq[tonumber(matches[2])] then
                if sendKeyboard(msg.from.id, langs[msg.lang].faq[tonumber(matches[2])], { inline_keyboard = { { { text = langs[msg.lang].previousPage, callback_data = 'helpBACKFAQ' } } } }) then
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendFAQPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link .. "?start=faq" .. matches[2] } } } }, false, msg.message_id)
                end
            else
                if sendKeyboard(msg.from.id, langs[msg.lang].faq[0], { inline_keyboard = { { { text = langs[msg.lang].previousPage, callback_data = 'helpBACKFAQ' } } } }) then
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendFAQPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link .. "?start=faq" .. matches[2] } } } }, false, msg.message_id)
                end
            end
        end
    end
    if matches[1]:lower() == 'textualfaq' then
        if not matches[2] then
            mystat('/faq')
            return sendReply(msg, langs[msg.lang].faqList, 'html')
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
        "^(###cbhelp)(PAGES)$",
        "^(###cbhelp)(BACKFAQ)$",
        "^(###cbhelp)(BACK)(%d+)$",
        "^(###cbhelp)(BACK)$",
        "^(###cbhelp)(FAQ)(%d+)$",
        "^(###cbhelp)(PAGE%dMINUS)(%d+)$",
        "^(###cbhelp)(PAGE%dPLUS)(%d+)$",
        "^(###cbhelp)(.*)(%d+)$",
        "^(###cbhelp)(.*)$",

        "^[#!/]([Cc][Oo][Nn][Vv][Ee][Rr][Tt][Tt][Ii][Mm][Ee]) (%d+) (%d+) (%d+) (%d+) (%d+)$",
        "^[#!/]([Cc][Oo][Nn][Vv][Ee][Rr][Tt][Tt][Ii][Mm][Ee]) (%d+)$",
        "^[#!/]([Hh][Ee][Ll][Pp][Aa][Ll][Ll])$",
        "^[#!/]([Hh][Ee][Ll][Pp])$",
        "^[#!/]([Hh][Ee][Ll][Pp]) ([^%s]+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Hh][Ee][Ll][Pp])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Hh][Ee][Ll][Pp]) ([^%s]+)$",
        "^[#!/]([Ss][Yy][Nn][Tt][Aa][Xx][Aa][Ll][Ll])$",
        "^[#!/]([Ss][Yy][Nn][Tt][Aa][Xx]) (.+)$",
        "^[#!/]([Ss][Uu][Dd][Oo][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Ff][Aa][Qq])$",
        "^[#!/]([Ff][Aa][Qq])(%d+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ff][Aa][Qq])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ff][Aa][Qq])(%d+)$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/sudolist",
        "/help",
        "/help {plugin_name}|{plugin_number}",
        "/textualhelp",
        "/textualhelp {plugin_name}|{plugin_number}",
        "/helpall",
        "/syntax {filter}",
        "/syntaxall",
        "/faq[{n}]",
        "/textualfaq[{n}]",
        "/converttime {seconds}",
        "/converttime {weeks} {days} {hours} {minutes} {seconds}",
    },
}