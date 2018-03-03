-- global
function add_from_other_plugin(keyboard, from_other_plugin)
    for k1, v1 in pairs(keyboard.inline_keyboard) do
        for k2, v2 in pairs(v1) do
            keyboard.inline_keyboard[k1][k2].callback_data = keyboard.inline_keyboard[k1][k2].callback_data .. from_other_plugin
        end
    end
    return keyboard
end
function add_useful_buttons(keyboard, chat_id, plugin, page, max_pages)
    local lang = get_lang(chat_id)
    local rows = 0
    for k, v in pairs(keyboard.inline_keyboard) do
        rows = rows + 1
    end
    local row = rows + 1

    keyboard.inline_keyboard[row] = { }
    if page > 1 then
        table.insert(keyboard.inline_keyboard[row], { text = langs[lang].previousPage, callback_data = plugin .. 'PAGE1MINUS' .. page })
    end
    table.insert(keyboard.inline_keyboard[row], { text = langs[lang].updateKeyboard, callback_data = plugin .. 'BACK' .. page })
    table.insert(keyboard.inline_keyboard[row], { text = page .. '/' .. max_pages, callback_data = plugin .. 'PAGES' })
    table.insert(keyboard.inline_keyboard[row], { text = langs[lang].deleteMessage, callback_data = plugin .. 'DELETE' })
    if page < max_pages then
        table.insert(keyboard.inline_keyboard[row], { text = langs[lang].nextPage, callback_data = plugin .. 'PAGE1PLUS' .. page })
    end
    -- more buttons to speed things up
    row = row + 1
    keyboard.inline_keyboard[row] = { }
    if max_pages > 7 and page > 7 then
        table.insert(keyboard.inline_keyboard[row], { text = langs[lang].previousPage .. langs[lang].sevenNumber, callback_data = plugin .. 'PAGE7MINUS' .. page })
    end
    if max_pages > 3 and page > 3 then
        table.insert(keyboard.inline_keyboard[row], { text = langs[lang].previousPage .. langs[lang].threeNumber, callback_data = plugin .. 'PAGE3MINUS' .. page })
    end
    if max_pages > 3 and page <= max_pages - 3 then
        table.insert(keyboard.inline_keyboard[row], { text = langs[lang].threeNumber .. langs[lang].nextPage, callback_data = plugin .. 'PAGE3PLUS' .. page })
    end
    if max_pages > 7 and page <= max_pages - 7 then
        table.insert(keyboard.inline_keyboard[row], { text = langs[lang].sevenNumber .. langs[lang].nextPage, callback_data = plugin .. 'PAGE7PLUS' .. page })
    end
    return keyboard
end
function keyboard_less_time(plugin, chat_id, time)
    if not time then
        time = 0
    end
    local seconds, minutes, hours = unixToDate(time)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    for i = 1, 8 do
        keyboard.inline_keyboard[i] = { }
    end

    keyboard.inline_keyboard[1][1] = { text = langs[lang].seconds:gsub('X', seconds), callback_data = plugin .. time .. 'SECONDS0' .. chat_id }
    keyboard.inline_keyboard[2][1] = { text = "-10", callback_data = plugin .. time .. 'SECONDS-10' .. chat_id }
    keyboard.inline_keyboard[2][2] = { text = "-5", callback_data = plugin .. time .. 'SECONDS-5' .. chat_id }
    keyboard.inline_keyboard[2][3] = { text = "-1", callback_data = plugin .. time .. 'SECONDS-1' .. chat_id }
    keyboard.inline_keyboard[2][4] = { text = "+1", callback_data = plugin .. time .. 'SECONDS+1' .. chat_id }
    keyboard.inline_keyboard[2][5] = { text = "+5", callback_data = plugin .. time .. 'SECONDS+5' .. chat_id }
    keyboard.inline_keyboard[2][6] = { text = "+10", callback_data = plugin .. time .. 'SECONDS+10' .. chat_id }

    keyboard.inline_keyboard[3][1] = { text = langs[lang].minutes:gsub('X', minutes), callback_data = plugin .. time .. 'MINUTES0' .. chat_id }

    keyboard.inline_keyboard[4][1] = { text = "-10", callback_data = plugin .. time .. 'MINUTES-10' .. chat_id }
    keyboard.inline_keyboard[4][2] = { text = "-5", callback_data = plugin .. time .. 'MINUTES-5' .. chat_id }
    keyboard.inline_keyboard[4][3] = { text = "-1", callback_data = plugin .. time .. 'MINUTES-1' .. chat_id }
    keyboard.inline_keyboard[4][4] = { text = "+1", callback_data = plugin .. time .. 'MINUTES+1' .. chat_id }
    keyboard.inline_keyboard[4][5] = { text = "+5", callback_data = plugin .. time .. 'MINUTES+5' .. chat_id }
    keyboard.inline_keyboard[4][6] = { text = "+10", callback_data = plugin .. time .. 'MINUTES+10' .. chat_id }

    keyboard.inline_keyboard[5][1] = { text = langs[lang].hours:gsub('X', hours), callback_data = plugin .. time .. 'HOURS0' .. chat_id }

    keyboard.inline_keyboard[6][1] = { text = "-5", callback_data = plugin .. time .. 'HOURS-5' .. chat_id }
    keyboard.inline_keyboard[6][2] = { text = "-3", callback_data = plugin .. time .. 'HOURS-3' .. chat_id }
    keyboard.inline_keyboard[6][3] = { text = "-1", callback_data = plugin .. time .. 'HOURS-1' .. chat_id }
    keyboard.inline_keyboard[6][4] = { text = "+1", callback_data = plugin .. time .. 'HOURS+1' .. chat_id }
    keyboard.inline_keyboard[6][5] = { text = "+3", callback_data = plugin .. time .. 'HOURS+3' .. chat_id }
    keyboard.inline_keyboard[6][6] = { text = "+5", callback_data = plugin .. time .. 'HOURS+5' .. chat_id }

    keyboard.inline_keyboard[7][1] = { text = "OK " .. hours .. langs[lang].hoursWord .. minutes .. langs[lang].minutesWord .. seconds .. langs[lang].secondsWord, callback_data = plugin .. time .. 'DONE' .. chat_id }

    keyboard.inline_keyboard[8][1] = { text = langs[lang].updateKeyboard, callback_data = plugin .. time .. 'BACK' .. chat_id }
    keyboard.inline_keyboard[8][2] = { text = langs[lang].deleteMessage, callback_data = plugin .. 'DELETE' }
    return keyboard
end
function keyboard_time(plugin, op, chat_id, user_id, time, from_other_plugin)
    if not time then
        time = 16115430
    end
    local seconds, minutes, hours, days, weeks = unixToDate(time)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    for i = 1, 12 do
        keyboard.inline_keyboard[i] = { }
    end

    keyboard.inline_keyboard[1][1] = { text = langs[lang].seconds:gsub('X', seconds), callback_data = plugin .. op .. time .. 'SECONDS0' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][1] = { text = "-10", callback_data = plugin .. op .. time .. 'SECONDS-10' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][2] = { text = "-5", callback_data = plugin .. op .. time .. 'SECONDS-5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][3] = { text = "-1", callback_data = plugin .. op .. time .. 'SECONDS-1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][4] = { text = "+1", callback_data = plugin .. op .. time .. 'SECONDS+1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][5] = { text = "+5", callback_data = plugin .. op .. time .. 'SECONDS+5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][6] = { text = "+10", callback_data = plugin .. op .. time .. 'SECONDS+10' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[3][1] = { text = langs[lang].minutes:gsub('X', minutes), callback_data = plugin .. op .. time .. 'MINUTES0' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[4][1] = { text = "-10", callback_data = plugin .. op .. time .. 'MINUTES-10' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[4][2] = { text = "-5", callback_data = plugin .. op .. time .. 'MINUTES-5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[4][3] = { text = "-1", callback_data = plugin .. op .. time .. 'MINUTES-1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[4][4] = { text = "+1", callback_data = plugin .. op .. time .. 'MINUTES+1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[4][5] = { text = "+5", callback_data = plugin .. op .. time .. 'MINUTES+5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[4][6] = { text = "+10", callback_data = plugin .. op .. time .. 'MINUTES+10' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[5][1] = { text = langs[lang].hours:gsub('X', hours), callback_data = plugin .. op .. time .. 'HOURS0' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[6][1] = { text = "-10", callback_data = plugin .. op .. time .. 'HOURS-10' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[6][2] = { text = "-5", callback_data = plugin .. op .. time .. 'HOURS-5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[6][3] = { text = "-1", callback_data = plugin .. op .. time .. 'HOURS-1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[6][4] = { text = "+1", callback_data = plugin .. op .. time .. 'HOURS+1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[6][5] = { text = "+5", callback_data = plugin .. op .. time .. 'HOURS+5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[6][6] = { text = "+10", callback_data = plugin .. op .. time .. 'HOURS+10' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[7][1] = { text = langs[lang].days:gsub('X', days), callback_data = plugin .. op .. time .. 'DAYS0' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[8][1] = { text = "-5", callback_data = plugin .. op .. time .. 'DAYS-5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[8][2] = { text = "-3", callback_data = plugin .. op .. time .. 'DAYS-3' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[8][3] = { text = "-1", callback_data = plugin .. op .. time .. 'DAYS-1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[8][4] = { text = "+1", callback_data = plugin .. op .. time .. 'DAYS+1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[8][5] = { text = "+3", callback_data = plugin .. op .. time .. 'DAYS+3' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[8][6] = { text = "+5", callback_data = plugin .. op .. time .. 'DAYS+5' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[9][1] = { text = langs[lang].weeks:gsub('X', weeks), callback_data = plugin .. op .. time .. 'WEEKS0' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[10][1] = { text = "-10", callback_data = plugin .. op .. time .. 'WEEKS-10' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[10][2] = { text = "-5", callback_data = plugin .. op .. time .. 'WEEKS-5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[10][3] = { text = "-1", callback_data = plugin .. op .. time .. 'WEEKS-1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[10][4] = { text = "+1", callback_data = plugin .. op .. time .. 'WEEKS+1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[10][5] = { text = "+5", callback_data = plugin .. op .. time .. 'WEEKS+5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[10][6] = { text = "+10", callback_data = plugin .. op .. time .. 'WEEKS+10' .. chat_id .. '$' .. user_id }

    if time < 30 or time > 31622400 then
        keyboard.inline_keyboard[11][1] = { text = op:gsub('TEMP', '') .. ' ' .. langs[lang].forever, callback_data = plugin .. op .. time .. 'DONE' .. user_id .. chat_id }
    else
        keyboard.inline_keyboard[11][1] = { text = op:gsub('TEMP', '') .. ' ' ..(days + weeks * 7) .. langs[lang].daysWord .. hours .. langs[lang].hoursWord .. minutes .. langs[lang].minutesWord .. seconds .. langs[lang].secondsWord, callback_data = plugin .. op .. time .. 'DONE' .. user_id .. chat_id }
    end

    local column = 1
    keyboard.inline_keyboard[12] = { }
    keyboard.inline_keyboard[12][column] = { text = langs[lang].updateKeyboard, callback_data = plugin .. op .. time .. 'BACK' .. user_id .. chat_id }
    column = column + 1
    if plugin == 'banhammer' and from_other_plugin then
        keyboard = add_from_other_plugin(keyboard, from_other_plugin)
        table.insert(keyboard.inline_keyboard[12], 1, { text = langs[lang].infoPage, callback_data = 'infoPUNISHMENTS' .. user_id .. chat_id })
        column = column + 1
    end
    keyboard.inline_keyboard[12][column] = { text = langs[lang].deleteMessage, callback_data = plugin .. 'DELETE' }
    return keyboard
end

-- administrator
local max_groups = 10
function keyboard_list_groups_pages(chat_id, page)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local tot_groups = 0
    page = tonumber(page) or 1
    for k, v in pairsByGroupName(data) do
        if data[tostring(k)] then
            tot_groups = tot_groups + 1
        end
    end
    local max_pages = math.floor(tot_groups / max_groups)
    if (tot_groups / max_groups) > math.floor(tot_groups / max_groups) then
        max_pages = max_pages + 1
    end
    if page > max_pages then
        page = max_pages
    end

    keyboard = add_useful_buttons(keyboard, chat_id, 'administratorGROUPS', page, max_pages)
    return keyboard
end
local max_requests_lines = 40
function keyboard_requests_pages(page)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local tot_lines = 0
    page = tonumber(page) or 1
    local f = assert(io.open("./groups/logs/requestslog.txt", "rb"))
    local log = f:read("*all")
    f:close()
    local t = log:split('\n')
    for k, v in pairs(t) do
        if v ~= '' then
            tot_lines = tot_lines + 1
        end
    end

    local max_pages = math.floor(tot_lines / max_requests_lines)
    if (tot_lines / max_requests_lines) > math.floor(tot_lines / max_requests_lines) then
        max_pages = max_pages + 1
    end
    if page > max_pages then
        page = max_pages
    end

    keyboard = add_useful_buttons(keyboard, nil, 'administratorREQUESTS', page, max_pages)
    return keyboard
end

-- banhammer
function keyboard_restrictions_list(chat_id, user_id, param_restrictions, from_other_plugin)
    local lang = get_lang(chat_id)
    if not param_restrictions then
        local obj_user = getChatMember(chat_id, user_id)
        if type(obj_user) == 'table' then
            if obj_user.result then
                -- assign user to restrictions
                obj_user = obj_user.result
                if obj_user.status == 'creator' or obj_user.status == 'left' or obj_user.status == 'kicked' then
                    obj_user = nil
                end
            else
                obj_user = nil
            end
        else
            obj_user = nil
        end
        param_restrictions = obj_user
    end
    if param_restrictions then
        local restrictions = adjustRestrictions(param_restrictions)
        local keyboard = { }
        keyboard.inline_keyboard = { }
        local row = 1
        local column = 1
        keyboard.inline_keyboard[row] = { }
        for var, value in pairsByKeys(restrictions) do
            if type(value) == 'boolean' then
                if value then
                    keyboard.inline_keyboard[row][column] = { text = '✅ ' ..(reverseRestrictionsDictionary[var:lower()] or var:lower()) .. ' ✅', callback_data = 'banhammerRESTRICT' .. user_id .. reverseRestrictionsDictionary[var:lower()] .. chat_id }
                else
                    keyboard.inline_keyboard[row][column] = { text = '🚫 ' ..(reverseRestrictionsDictionary[var:lower()] or var:lower()) .. ' 🚫', callback_data = 'banhammerUNRESTRICT' .. user_id .. reverseRestrictionsDictionary[var:lower()] .. chat_id }
                end
                row = row + 1
                keyboard.inline_keyboard[row] = { }
            end
        end
        keyboard.inline_keyboard[row][column] = { text = '💎 ' .. langs[lang].done .. ' 💎', callback_data = 'banhammerRESTRICTIONSDONE' .. user_id .. chat_id }

        row = row + 1
        column = 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][column] = { text = langs[lang].updateKeyboard, callback_data = 'banhammerBACK' .. user_id .. chat_id }
        column = column + 1
        if from_other_plugin then
            keyboard = add_from_other_plugin(keyboard, from_other_plugin)
            table.insert(keyboard.inline_keyboard[row], 1, { text = langs[lang].infoPage, callback_data = 'infoPUNISHMENTS' .. user_id .. chat_id })
            column = column + 1
        end
        keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'banhammerDELETE' }
        return keyboard
    else
        local keyboard = { }
        keyboard.inline_keyboard = { }
        local row = 1
        local column = 1
        keyboard.inline_keyboard[row] = { }
        if from_other_plugin then
            keyboard.inline_keyboard[row][column] = { text = langs[lang].infoPage, callback_data = 'infoPUNISHMENTS' .. user_id .. chat_id }
            column = column + 1
        end
        keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'banhammerDELETE' }
        return keyboard
    end
end
function keyboard_whitelist_gbanned(chat_id, user_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    keyboard.inline_keyboard[1] = { }
    keyboard.inline_keyboard[1][1] = { text = 'WHITELISTGBAN', callback_data = 'banhammerWHITELISTGBAN' .. user_id .. chat_id }
    return keyboard
end

-- bot
function keyboard_tagalert_tutorial(lang)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    keyboard.inline_keyboard[1] = { }
    keyboard.inline_keyboard[1][1] = { text = langs[lang].tagalertWord, callback_data = 'check_tagREGISTER' }
    -- keyboard.inline_keyboard[2] = { }
    -- keyboard.inline_keyboard[2][1] = { text = langs[lang].tutorialWord, url = 'http://telegra.ph/TUTORIAL-AISASHABOT-09-15' }
    return keyboard
end
-- strings
function keyboard_langs(plugin)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    keyboard.inline_keyboard[1] = { }
    keyboard.inline_keyboard[1][1] = { text = langs.italian, callback_data = 'langsIT' ..(plugin or 'B') }
    keyboard.inline_keyboard[1][2] = { text = langs.english, callback_data = 'langsEN' ..(plugin or 'B') }
    return keyboard
end

-- check_tag
function keyboard_tag(chat_id, message_id, callback, user_id)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }

    if not callback then
        keyboard.inline_keyboard[1] = { }
        keyboard.inline_keyboard[1][1] = { text = langs[lang].gotoMessage, callback_data = 'check_tagGOTO' .. message_id .. chat_id }

        keyboard.inline_keyboard[2] = { }
        keyboard.inline_keyboard[2][1] = { text = langs[lang].alreadyRead, callback_data = 'check_tagALREADYREAD' }

        if data[tostring(chat_id)] then
            if is_mod2(user_id, chat_id) or(not data[tostring(chat_id)].settings.lock_grouplink) then
                if data[tostring(chat_id)].link then
                    keyboard.inline_keyboard[3] = { }
                    keyboard.inline_keyboard[3][1] = { text = langs[lang].gotoGroup, url = data[tostring(chat_id)].link }
                end
            end
        end
    else
        keyboard.inline_keyboard[1] = { }
        keyboard.inline_keyboard[1][1] = { text = langs[lang].deleteUp, callback_data = 'check_tagDELETEUP' .. user_id .. chat_id }
    end

    return keyboard
end

-- filemanager
local max_filemanager_buttons = 15
function keyboard_filemanager(folder, page)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local flag = false
    local count = 0
    keyboard.inline_keyboard[row] = { }
    page = tonumber(page) or 1
    local dir = io.popen('sudo ls -a "' .. folder .. '"'):read("*all")
    local t = dir:split('\n')
    count = #t
    local max_pages = math.floor(count / max_filemanager_buttons)
    if (count / max_filemanager_buttons) > math.floor(count / max_filemanager_buttons) then
        max_pages = max_pages + 1
    end
    if page > max_pages then
        page = max_pages
    end
    count = 0
    for i, object in pairs(t) do
        count = count + 1
        if count >=(((page - 1) * max_filemanager_buttons) + 1) and count <=(max_filemanager_buttons * page) then
            if flag then
                flag = false
                row = row + 1
                column = 1
                keyboard.inline_keyboard[row] = { }
            end
            local tst = io.popen('sudo ls -a "' .. folder .. object .. '/"'):read("*all")
            if tst ~= '' then
                keyboard.inline_keyboard[row][column] = { text = '📁 ' .. object, callback_data = 'filemanagerCD' .. object }
            else
                keyboard.inline_keyboard[row][column] = { text = '📄 ' .. object, callback_data = 'filemanagerUP' .. object }
            end
            column = column + 1
            if column > 2 then
                flag = true
            end
        end
    end

    keyboard = add_useful_buttons(keyboard, 41400331, 'filemanager', page, max_pages)
    return keyboard
end

-- help
local max_help_buttons = 10
function keyboard_help_pages(chat_id, rank, page)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local index = 0
    local plugins_available_for_rank = 0
    local flag = false
    keyboard.inline_keyboard[row] = { }
    page = tonumber(page) or 1
    for name in pairsByKeys(plugins) do
        if plugins[name].min_rank <= tonumber(rank) then
            plugins_available_for_rank = plugins_available_for_rank + 1
        end
    end
    local max_pages = math.floor(plugins_available_for_rank / max_help_buttons)
    if (plugins_available_for_rank / max_help_buttons) > math.floor(plugins_available_for_rank / max_help_buttons) then
        max_pages = max_pages + 1
    end
    if page > max_pages then
        page = max_pages
    end
    plugins_available_for_rank = 0
    for name in pairsByKeys(plugins) do
        index = index + 1
        -- index between the last plugin of the previous page and the last plugin of this page
        if plugins[name].min_rank <= tonumber(rank) then
            plugins_available_for_rank = plugins_available_for_rank + 1
            if plugins_available_for_rank >=(((page - 1) * max_help_buttons) + 1) and plugins_available_for_rank <=(max_help_buttons * page) then
                if flag then
                    flag = false
                    row = row + 1
                    column = 1
                    keyboard.inline_keyboard[row] = { }
                end
                -- keyboard.inline_keyboard[row][column] = { text = --[[ '🅿️ ' .. ]] index .. '. ' .. name:lower(), callback_data = 'help' .. name }
                keyboard.inline_keyboard[row][column] = { text = --[[ '🅿️ ' .. ]] index .. '. ' .. adjust_plugin_names(name:lower(), lang), callback_data = 'help' .. name .. page }
                column = column + 1
                if column > 2 then
                    flag = true
                end
            end
        end
    end

    keyboard = add_useful_buttons(keyboard, chat_id, 'help', page, max_pages)
    return keyboard
end
function keyboard_faq_list(chat_id)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local flag = false
    keyboard.inline_keyboard[row] = { }
    for k, v in pairsByKeys(langs[lang].faq) do
        if flag then
            flag = false
            row = row + 1
            column = 1
            keyboard.inline_keyboard[row] = { }
        end
        if k > 0 then
            keyboard.inline_keyboard[row][column] = { text = 'FAQ' .. k, callback_data = 'helpFAQ' .. k }
            column = column + 1
        end
        if column > 3 then
            flag = true
        end
    end
    row = row + 1
    column = 1
    keyboard.inline_keyboard[row] = { }
    keyboard.inline_keyboard[row][column] = { text = langs[lang].updateKeyboard, callback_data = 'helpBACKFAQ' }
    column = column + 1
    keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'helpDELETE' }
    return keyboard
end

-- group_management
local max_log_lines = 20
function keyboard_log_pages(chat_id, page)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local tot_lines = 0
    page = tonumber(page) or 1
    local f = assert(io.open("./groups/logs/" .. chat_id .. "log.txt", "rb"))
    local log = f:read("*all")
    f:close()
    local t = log:split('\n')
    for k, v in pairs(t) do
        if v ~= '' then
            tot_lines = tot_lines + 1
        end
    end

    local max_pages = math.floor(tot_lines / max_log_lines)
    if (tot_lines / max_log_lines) > math.floor(tot_lines / max_log_lines) then
        max_pages = max_pages + 1
    end
    if page > max_pages then
        page = max_pages
    end

    keyboard = add_useful_buttons(keyboard, chat_id, 'group_management', page, max_pages)
    -- adjust buttons
    for k, v in pairs(keyboard.inline_keyboard[1]) do
        if keyboard.inline_keyboard[1][k].text == langs[lang].updateKeyboard then
            keyboard.inline_keyboard[1][k].callback_data = 'group_managementBACKLOG' .. page .. chat_id
        elseif keyboard.inline_keyboard[1][k].text == langs[lang].previousPage then
            keyboard.inline_keyboard[1][k].callback_data = 'group_managementPAGE1MINUS' .. page .. chat_id
        elseif keyboard.inline_keyboard[1][k].text == langs[lang].nextPage then
            keyboard.inline_keyboard[1][k].callback_data = 'group_managementPAGE1PLUS' .. page .. chat_id
        end
    end
    for k, v in pairs(keyboard.inline_keyboard[2]) do
        if keyboard.inline_keyboard[2][k].text == langs[lang].previousPage .. langs[lang].sevenNumber then
            keyboard.inline_keyboard[2][k].callback_data = 'group_managementPAGE7MINUS' .. page .. chat_id
        elseif keyboard.inline_keyboard[2][k].text == langs[lang].previousPage .. langs[lang].threeNumber then
            keyboard.inline_keyboard[2][k].callback_data = 'group_managementPAGE3MINUS' .. page .. chat_id
        elseif keyboard.inline_keyboard[2][k].text == langs[lang].threeNumber .. langs[lang].nextPage then
            keyboard.inline_keyboard[2][k].callback_data = 'group_managementPAGE3PLUS' .. page .. chat_id
        elseif keyboard.inline_keyboard[2][k].text == langs[lang].sevenNumber .. langs[lang].nextPage then
            keyboard.inline_keyboard[2][k].callback_data = 'group_managementPAGE7PLUS' .. page .. chat_id
        end
    end
    return keyboard
end
function keyboard_permissions_list(chat_id, user_id, param_permissions, from_other_plugin)
    local lang = get_lang(chat_id)
    if not param_permissions then
        local obj_user = getChatMember(chat_id, user_id)
        if type(obj_user) == 'table' then
            if obj_user.result then
                -- assign user to permissions
                obj_user = obj_user.result
                if obj_user.status == 'creator' or obj_user.status == 'left' or obj_user.status == 'kicked' then
                    obj_user = nil
                end
            else
                obj_user = nil
            end
        else
            obj_user = nil
        end
        param_permissions = obj_user
    end
    if param_permissions then
        local permissions = adjustPermissions(param_permissions)
        local keyboard = { }
        keyboard.inline_keyboard = { }
        local row = 1
        local column = 1
        keyboard.inline_keyboard[row] = { }
        for var, value in pairsByKeys(permissions) do
            if type(value) == 'boolean' then
                if value then
                    keyboard.inline_keyboard[row][column] = { text = '✅ ' ..(reversePermissionsDictionary[var:lower()] or var:lower()) .. ' ✅', callback_data = 'group_managementDENY' .. user_id .. reversePermissionsDictionary[var:lower()] .. chat_id }
                else
                    keyboard.inline_keyboard[row][column] = { text = '☑️ ' ..(reversePermissionsDictionary[var:lower()] or var:lower()) .. ' ☑️', callback_data = 'group_managementGRANT' .. user_id .. reversePermissionsDictionary[var:lower()] .. chat_id }
                end
                row = row + 1
                keyboard.inline_keyboard[row] = { }
            end
        end
        keyboard.inline_keyboard[row][column] = { text = '💎 ' .. langs[lang].done .. ' 💎', callback_data = 'group_managementPERMISSIONSDONE' .. user_id .. chat_id }

        row = row + 1
        column = 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][column] = { text = langs[lang].updateKeyboard, callback_data = 'group_managementBACKPERMISSIONS' .. chat_id }
        column = column + 1
        if from_other_plugin then
            keyboard = add_from_other_plugin(keyboard, from_other_plugin)
            table.insert(keyboard.inline_keyboard[row], 1, { text = langs[lang].infoPage, callback_data = 'infoPROMOTIONS' .. user_id .. chat_id })
            column = column + 1
        end
        keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'group_managementDELETE' }
        return keyboard
    else
        local keyboard = { }
        keyboard.inline_keyboard = { }
        local row = 1
        local column = 1
        keyboard.inline_keyboard[row] = { }
        if from_other_plugin then
            keyboard.inline_keyboard[row][column] = { text = langs[lang].infoPage, callback_data = 'infoPROMOTIONS' .. user_id .. chat_id }
            column = column + 1
        end
        keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'group_managementDELETE' }
        return keyboard
    end
end
function keyboard_settings_list(chat_id, page, setting_add_row, from_other_plugin)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    page = tonumber(page) or 1
    setting_add_row = tostring(setting_add_row):lower() or ''

    local row = 1
    if data[tostring(chat_id)] then
        keyboard.inline_keyboard[row] = { }
        -- keyboard.inline_keyboard[row][1] = { text = langs[lang].infoEmoji .. reverseGroupDataDictionary['groupnotices'], callback_data = 'group_management' .. reverseGroupDataDictionary['groupnotices'] }
        keyboard.inline_keyboard[row][1] = { text = langs[lang].infoEmoji .. reverseGroupDataDictionary['pmnotices'], callback_data = 'group_management' .. reverseGroupDataDictionary['pmnotices'] }
        keyboard.inline_keyboard[row][2] = { text = langs[lang].infoEmoji .. reverseGroupDataDictionary['tagalert'], callback_data = 'group_management' .. reverseGroupDataDictionary['tagalert'] }
        row = row + 1
        keyboard.inline_keyboard[row] = { }
        --[[if data[tostring(chat_id)].settings.groupnotices then
            keyboard.inline_keyboard[row][1] = { text = '✅ ' .. reverseGroupDataDictionary['groupnotices'], callback_data = 'group_managementUNLOCK' .. reverseGroupDataDictionary['groupnotices'] .. page .. chat_id }
        else
            keyboard.inline_keyboard[row][1] = { text = '☑️ ' .. reverseGroupDataDictionary['groupnotices'], callback_data = 'group_managementLOCK' .. reverseGroupDataDictionary['groupnotices'] .. page .. chat_id }
        end]]
        if data[tostring(chat_id)].settings.pmnotices then
            keyboard.inline_keyboard[row][1] = { text = '✅ ' .. reverseGroupDataDictionary['pmnotices'], callback_data = 'group_managementUNLOCK' .. reverseGroupDataDictionary['pmnotices'] .. page .. chat_id }
        else
            keyboard.inline_keyboard[row][1] = { text = '☑️ ' .. reverseGroupDataDictionary['pmnotices'], callback_data = 'group_managementLOCK' .. reverseGroupDataDictionary['pmnotices'] .. page .. chat_id }
        end
        if data[tostring(chat_id)].settings.tagalert then
            keyboard.inline_keyboard[row][2] = { text = '✅ ' .. reverseGroupDataDictionary['tagalert'], callback_data = 'group_managementUNLOCK' .. reverseGroupDataDictionary['tagalert'] .. page .. chat_id }
        else
            keyboard.inline_keyboard[row][2] = { text = '☑️ ' .. reverseGroupDataDictionary['tagalert'], callback_data = 'group_managementLOCK' .. reverseGroupDataDictionary['tagalert'] .. page .. chat_id }
        end
        row = row + 1
        keyboard.inline_keyboard[row] = { }
        if tonumber(page) == 1 then
            keyboard.inline_keyboard[row][1] = { text = langs[lang].infoEmoji .. reverseGroupDataDictionary['lock_grouplink'], callback_data = 'group_management' .. reverseGroupDataDictionary['lock_grouplink'] }
            keyboard.inline_keyboard[row][2] = { text = langs[lang].infoEmoji .. reverseGroupDataDictionary['lock_name'], callback_data = 'group_management' .. reverseGroupDataDictionary['lock_name'] }
            keyboard.inline_keyboard[row][3] = { text = langs[lang].infoEmoji .. reverseGroupDataDictionary['lock_photo'], callback_data = 'group_management' .. reverseGroupDataDictionary['lock_photo'] }
            row = row + 1
            keyboard.inline_keyboard[row] = { }
            if data[tostring(chat_id)].settings.lock_grouplink then
                keyboard.inline_keyboard[row][1] = { text = '✅ ' .. reverseGroupDataDictionary['lock_grouplink'], callback_data = 'group_managementUNLOCK' .. reverseGroupDataDictionary['lock_grouplink'] .. page .. chat_id }
            else
                keyboard.inline_keyboard[row][1] = { text = '☑️ ' .. reverseGroupDataDictionary['lock_grouplink'], callback_data = 'group_managementLOCK' .. reverseGroupDataDictionary['lock_grouplink'] .. page .. chat_id }
            end
            if data[tostring(chat_id)].settings.lock_name then
                keyboard.inline_keyboard[row][2] = { text = '✅ ' .. reverseGroupDataDictionary['lock_name'], callback_data = 'group_managementUNLOCK' .. reverseGroupDataDictionary['lock_name'] .. page .. chat_id }
            else
                keyboard.inline_keyboard[row][2] = { text = '☑️ ' .. reverseGroupDataDictionary['lock_name'], callback_data = 'group_managementLOCK' .. reverseGroupDataDictionary['lock_name'] .. page .. chat_id }
            end
            if data[tostring(chat_id)].settings.lock_photo then
                keyboard.inline_keyboard[row][3] = { text = '✅ ' .. reverseGroupDataDictionary['lock_photo'], callback_data = 'group_managementUNLOCK' .. reverseGroupDataDictionary['lock_photo'] .. page .. chat_id }
            else
                keyboard.inline_keyboard[row][3] = { text = '☑️ ' .. reverseGroupDataDictionary['lock_photo'], callback_data = 'group_managementLOCK' .. reverseGroupDataDictionary['lock_photo'] .. page .. chat_id }
            end
            row = row + 1
            keyboard.inline_keyboard[row] = { }
            for var, value in pairsByKeys(data[tostring(chat_id)].settings.locks) do
                if var:lower() == 'flood' then
                    keyboard.inline_keyboard[row][1] = { text = '--', callback_data = 'group_managementFLOOD--' .. page .. chat_id }
                    keyboard.inline_keyboard[row][2] = { text = reverseGroupDataDictionary['max_flood'] .. ' (' .. data[tostring(chat_id)].settings.max_flood .. ')', callback_data = 'group_management' .. reverseGroupDataDictionary['max_flood'] }
                    keyboard.inline_keyboard[row][3] = { text = '++', callback_data = 'group_managementFLOOD++' .. page .. chat_id }
                    row = row + 1
                    keyboard.inline_keyboard[row] = { }
                end
                keyboard.inline_keyboard[row][1] = { text = langs[lang].infoEmoji .. reverseGroupDataDictionary[var:lower()], callback_data = 'group_management' .. reverseGroupDataDictionary[var:lower()] }
                keyboard.inline_keyboard[row][2] = { text = reverse_punishments_table_emoji[value] .. reverse_punishments_table[value], callback_data = 'group_management' .. reverseGroupDataDictionary[var:lower()] .. page .. chat_id }
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                if groupDataDictionary[setting_add_row] == var:lower() then
                    local row1, row2 = add_punishments_rows(chat_id, page, setting_add_row)
                    keyboard.inline_keyboard[row] = row1
                    row = row + 1
                    keyboard.inline_keyboard[row] = row2
                    row = row + 1
                    keyboard.inline_keyboard[row] = { }
                end
            end
            keyboard.inline_keyboard[row][1] = { text = langs[lang].gotoMutes, callback_data = 'group_managementGOTOMUTES' .. chat_id }
        elseif tonumber(page) == 2 then
            for var, value in pairsByKeys(data[tostring(chat_id)].settings.mutes) do
                keyboard.inline_keyboard[row][1] = { text = langs[lang].infoEmoji .. reverseGroupDataDictionary[var:lower()], callback_data = 'group_management' .. reverseGroupDataDictionary[var:lower()] }
                keyboard.inline_keyboard[row][2] = { text = reverse_punishments_table_emoji[value] .. reverse_punishments_table[value], callback_data = 'group_management' .. reverseGroupDataDictionary[var:lower()] .. page .. chat_id }
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                if groupDataDictionary[setting_add_row] == var:lower() then
                    local row1, row2 = add_punishments_rows(chat_id, page, setting_add_row)
                    keyboard.inline_keyboard[row] = row1
                    row = row + 1
                    keyboard.inline_keyboard[row] = row2
                    row = row + 1
                    keyboard.inline_keyboard[row] = { }
                end
            end
            keyboard.inline_keyboard[row][1] = { text = langs[lang].gotoLocks, callback_data = 'group_managementGOTOLOCKS' .. chat_id }
        end
        row = row + 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][1] = { text = '⌨️⏳ ' .. reverseGroupDataDictionary['time_ban'] .. ' ⏳⌨️', callback_data = 'group_management' .. reverseGroupDataDictionary['time_ban'] .. data[tostring(chat_id)].settings.time_ban .. 'BACK' .. chat_id }
        keyboard.inline_keyboard[row][2] = { text = '⌨️⏳ ' .. reverseGroupDataDictionary['time_restrict'] .. ' ⏳⌨️', callback_data = 'group_management' .. reverseGroupDataDictionary['time_restrict'] .. data[tostring(chat_id)].settings.time_restrict .. 'BACK' .. chat_id }
        row = row + 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][1] = { text = langs[lang].infoEmoji .. reverseGroupDataDictionary['strict'], callback_data = 'group_management' .. reverseGroupDataDictionary['strict'] }
        if data[tostring(chat_id)].settings.strict then
            keyboard.inline_keyboard[row][2] = { text = '✅ ' .. reverseGroupDataDictionary['strict'], callback_data = 'group_managementUNLOCK' .. reverseGroupDataDictionary['strict'] .. page .. chat_id }
        else
            keyboard.inline_keyboard[row][2] = { text = '☑️ ' .. reverseGroupDataDictionary['strict'], callback_data = 'group_managementLOCK' .. reverseGroupDataDictionary['strict'] .. page .. chat_id }
        end
        row = row + 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][1] = { text = '--', callback_data = 'group_managementWARNS--' .. page .. chat_id }
        keyboard.inline_keyboard[row][2] = { text = reverseGroupDataDictionary['max_warns'] .. ' (' .. data[tostring(chat_id)].settings.max_warns .. ')', callback_data = 'group_management' .. reverseGroupDataDictionary['max_warns'] }
        keyboard.inline_keyboard[row][3] = { text = '++', callback_data = 'group_managementWARNS++' .. page .. chat_id }
        row = row + 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][1] = { text = langs[lang].infoEmoji .. reverseGroupDataDictionary['warns_punishment'], callback_data = 'group_management' .. reverseGroupDataDictionary['warns_punishment'] }
        keyboard.inline_keyboard[row][2] = { text = reverse_punishments_table_emoji[data[tostring(chat_id)].settings.warns_punishment] .. reverse_punishments_table[data[tostring(chat_id)].settings.warns_punishment], callback_data = 'group_management' .. reverseGroupDataDictionary['warns_punishment'] .. page .. chat_id }
        if groupDataDictionary[setting_add_row] == 'warns_punishment' then
            row = row + 1
            keyboard.inline_keyboard[row] = { }
            local row1, row2 = add_punishments_rows(chat_id, page, setting_add_row)
            keyboard.inline_keyboard[row] = row1
            row = row + 1
            keyboard.inline_keyboard[row] = row2
        end
    end
    row = row + 1
    local column = 1
    keyboard.inline_keyboard[row] = { }
    keyboard.inline_keyboard[row][column] = { text = langs[lang].updateKeyboard, callback_data = 'group_managementBACKSETTINGS' .. page .. chat_id }
    column = column + 1
    if from_other_plugin then
        keyboard = add_from_other_plugin(keyboard, from_other_plugin)
        table.insert(keyboard.inline_keyboard[row], 1, { text = langs[lang].infoPage, callback_data = 'infoBACK' .. chat_id })
        column = column + 1
    end
    keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'group_managementDELETE' }
    return keyboard
end
function keyboard_time_punishments(punishment, chat_id, time, from_other_plugin)
    if not time then
        time = 16115430
    end
    local seconds, minutes, hours, days, weeks = unixToDate(time)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    for i = 1, 12 do
        keyboard.inline_keyboard[i] = { }
    end

    keyboard.inline_keyboard[1][1] = { text = langs[lang].seconds:gsub('X', seconds), callback_data = 'group_management' .. punishment .. time .. 'SECONDS0' .. chat_id }
    keyboard.inline_keyboard[2][1] = { text = "-10", callback_data = 'group_management' .. punishment .. time .. 'SECONDS-10' .. chat_id }
    keyboard.inline_keyboard[2][2] = { text = "-5", callback_data = 'group_management' .. punishment .. time .. 'SECONDS-5' .. chat_id }
    keyboard.inline_keyboard[2][3] = { text = "-1", callback_data = 'group_management' .. punishment .. time .. 'SECONDS-1' .. chat_id }
    keyboard.inline_keyboard[2][4] = { text = "+1", callback_data = 'group_management' .. punishment .. time .. 'SECONDS+1' .. chat_id }
    keyboard.inline_keyboard[2][5] = { text = "+5", callback_data = 'group_management' .. punishment .. time .. 'SECONDS+5' .. chat_id }
    keyboard.inline_keyboard[2][6] = { text = "+10", callback_data = 'group_management' .. punishment .. time .. 'SECONDS+10' .. chat_id }

    keyboard.inline_keyboard[3][1] = { text = langs[lang].minutes:gsub('X', minutes), callback_data = 'group_management' .. punishment .. time .. 'MINUTES0' .. chat_id }

    keyboard.inline_keyboard[4][1] = { text = "-10", callback_data = 'group_management' .. punishment .. time .. 'MINUTES-10' .. chat_id }
    keyboard.inline_keyboard[4][2] = { text = "-5", callback_data = 'group_management' .. punishment .. time .. 'MINUTES-5' .. chat_id }
    keyboard.inline_keyboard[4][3] = { text = "-1", callback_data = 'group_management' .. punishment .. time .. 'MINUTES-1' .. chat_id }
    keyboard.inline_keyboard[4][4] = { text = "+1", callback_data = 'group_management' .. punishment .. time .. 'MINUTES+1' .. chat_id }
    keyboard.inline_keyboard[4][5] = { text = "+5", callback_data = 'group_management' .. punishment .. time .. 'MINUTES+5' .. chat_id }
    keyboard.inline_keyboard[4][6] = { text = "+10", callback_data = 'group_management' .. punishment .. time .. 'MINUTES+10' .. chat_id }

    keyboard.inline_keyboard[5][1] = { text = langs[lang].hours:gsub('X', hours), callback_data = 'group_management' .. punishment .. time .. 'HOURS0' .. chat_id }

    keyboard.inline_keyboard[6][1] = { text = "-10", callback_data = 'group_management' .. punishment .. time .. 'HOURS-10' .. chat_id }
    keyboard.inline_keyboard[6][2] = { text = "-5", callback_data = 'group_management' .. punishment .. time .. 'HOURS-5' .. chat_id }
    keyboard.inline_keyboard[6][3] = { text = "-1", callback_data = 'group_management' .. punishment .. time .. 'HOURS-1' .. chat_id }
    keyboard.inline_keyboard[6][4] = { text = "+1", callback_data = 'group_management' .. punishment .. time .. 'HOURS+1' .. chat_id }
    keyboard.inline_keyboard[6][5] = { text = "+5", callback_data = 'group_management' .. punishment .. time .. 'HOURS+5' .. chat_id }
    keyboard.inline_keyboard[6][6] = { text = "+10", callback_data = 'group_management' .. punishment .. time .. 'HOURS+10' .. chat_id }

    keyboard.inline_keyboard[7][1] = { text = langs[lang].days:gsub('X', days), callback_data = 'group_management' .. punishment .. time .. 'DAYS0' .. chat_id }

    keyboard.inline_keyboard[8][1] = { text = "-5", callback_data = 'group_management' .. punishment .. time .. 'DAYS-5' .. chat_id }
    keyboard.inline_keyboard[8][2] = { text = "-3", callback_data = 'group_management' .. punishment .. time .. 'DAYS-3' .. chat_id }
    keyboard.inline_keyboard[8][3] = { text = "-1", callback_data = 'group_management' .. punishment .. time .. 'DAYS-1' .. chat_id }
    keyboard.inline_keyboard[8][4] = { text = "+1", callback_data = 'group_management' .. punishment .. time .. 'DAYS+1' .. chat_id }
    keyboard.inline_keyboard[8][5] = { text = "+3", callback_data = 'group_management' .. punishment .. time .. 'DAYS+3' .. chat_id }
    keyboard.inline_keyboard[8][6] = { text = "+5", callback_data = 'group_management' .. punishment .. time .. 'DAYS+5' .. chat_id }

    keyboard.inline_keyboard[9][1] = { text = langs[lang].weeks:gsub('X', weeks), callback_data = 'group_management' .. punishment .. time .. 'WEEKS0' .. chat_id }

    keyboard.inline_keyboard[10][1] = { text = "-10", callback_data = 'group_management' .. punishment .. time .. 'WEEKS-10' .. chat_id }
    keyboard.inline_keyboard[10][2] = { text = "-5", callback_data = 'group_management' .. punishment .. time .. 'WEEKS-5' .. chat_id }
    keyboard.inline_keyboard[10][3] = { text = "-1", callback_data = 'group_management' .. punishment .. time .. 'WEEKS-1' .. chat_id }
    keyboard.inline_keyboard[10][4] = { text = "+1", callback_data = 'group_management' .. punishment .. time .. 'WEEKS+1' .. chat_id }
    keyboard.inline_keyboard[10][5] = { text = "+5", callback_data = 'group_management' .. punishment .. time .. 'WEEKS+5' .. chat_id }
    keyboard.inline_keyboard[10][6] = { text = "+10", callback_data = 'group_management' .. punishment .. time .. 'WEEKS+10' .. chat_id }

    if time < 30 or time > 31622400 then
        keyboard.inline_keyboard[11][1] = { text = punishment .. ' ' .. langs[lang].forever, callback_data = 'group_management' .. punishment .. time .. 'DONE' .. chat_id }
    else
        keyboard.inline_keyboard[11][1] = { text = punishment .. ' ' ..(days + weeks * 7) .. langs[lang].daysWord .. hours .. langs[lang].hoursWord .. minutes .. langs[lang].minutesWord .. seconds .. langs[lang].secondsWord, callback_data = 'group_management' .. punishment .. time .. 'DONE' .. chat_id }
    end

    keyboard.inline_keyboard[12] = { }
    keyboard.inline_keyboard[12][1] = { text = langs[lang].previousPage, callback_data = 'group_managementBACKSETTINGS1' .. chat_id }
    keyboard.inline_keyboard[12][2] = { text = langs[lang].updateKeyboard, callback_data = 'group_management' .. punishment .. time .. 'BACK' .. chat_id }
    if from_other_plugin then
        keyboard = add_from_other_plugin(keyboard, from_other_plugin)
    end
    keyboard.inline_keyboard[12][3] = { text = langs[lang].deleteMessage, callback_data = 'group_managementDELETE' }
    return keyboard
end
function add_punishments_rows(chat_id, page, setting)
    local row1 = { }
    row1[1] = { text = reverse_punishments_table_emoji[false], callback_data = 'group_management0' .. reverseGroupDataDictionary[setting] .. page .. chat_id }
    row1[2] = { text = reverse_punishments_table_emoji[1], callback_data = 'group_management1' .. reverseGroupDataDictionary[setting] .. page .. chat_id }
    row1[3] = { text = reverse_punishments_table_emoji[2], callback_data = 'group_management2' .. reverseGroupDataDictionary[setting] .. page .. chat_id }
    row1[4] = { text = reverse_punishments_table_emoji[3], callback_data = 'group_management3' .. reverseGroupDataDictionary[setting] .. page .. chat_id }
    local row2 = { }
    row2[1] = { text = reverse_punishments_table_emoji[4], callback_data = 'group_management4' .. reverseGroupDataDictionary[setting] .. page .. chat_id }
    row2[2] = { text = reverse_punishments_table_emoji[5], callback_data = 'group_management5' .. reverseGroupDataDictionary[setting] .. page .. chat_id }
    row2[3] = { text = reverse_punishments_table_emoji[6], callback_data = 'group_management6' .. reverseGroupDataDictionary[setting] .. page .. chat_id }
    row2[4] = { text = reverse_punishments_table_emoji[7], callback_data = 'group_management7' .. reverseGroupDataDictionary[setting] .. page .. chat_id }
    return row1, row2
end

-- info
function get_object_info_keyboard(executer, obj, chat_id, deeper)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    keyboard.inline_keyboard[row] = { }
    if obj then
        if obj.type == 'bot' or obj.is_bot then
            if obj.first_name then
                if obj.first_name == '' then
                    if database[tostring(obj.id)] then
                        return { inline_keyboard = { { { text = langs[lang].deleteKeyboard, callback_data = 'infoDELETE' .. obj.id .. chat_id }, { text = langs[lang].deleteMessage, callback_data = 'infoDELETE' } } } }
                    else
                        return { inline_keyboard = { { { text = langs[lang].deleteMessage, callback_data = 'infoDELETE' } } } }
                    end
                end
            end
            if not deeper then
                local is_executer_admin = is_admin2(executer)
                if is_executer_admin then
                    row = row + 1
                    keyboard.inline_keyboard[row] = { }
                    keyboard.inline_keyboard[row][column] = { text = langs[lang].adminCommands, callback_data = 'infoADMINCOMMANDS' .. obj.id .. chat_id }
                end
                if tonumber(chat_id) < 0 then
                    local chat_member_executer = getChatMember(chat_id, executer)
                    local is_executer_owner = false
                    local is_executer_mod = false
                    if type(chat_member_executer) == 'table' then
                        if chat_member_executer.result then
                            chat_member_executer = chat_member_executer.result
                            if chat_member_executer.status then
                                if chat_member_executer.status == 'creator' then
                                    is_executer_owner = true
                                    is_executer_mod = true
                                elseif chat_member_executer.status == 'administrator' then
                                    is_executer_mod = true
                                end
                            end
                        end
                    end
                    if is_executer_mod or is_mod2(executer, chat_id, true) then
                        row = row + 1
                        keyboard.inline_keyboard[row] = { }
                        keyboard.inline_keyboard[row][column] = { text = langs[lang].promotionsCommands, callback_data = 'infoPROMOTIONS' .. obj.id .. chat_id }
                    end
                    if is_executer_mod or is_mod2(executer, chat_id, true) then
                        row = row + 1
                        keyboard.inline_keyboard[row] = { }
                        keyboard.inline_keyboard[row][column] = { text = langs[lang].punishmentsCommands, callback_data = 'infoPUNISHMENTS' .. obj.id .. chat_id }
                    end
                end
            else
                if deeper == 'ADMINCOMMANDS' then
                    local is_executer_admin = is_admin2(executer)
                    if is_executer_admin then
                        row = row + 1
                        keyboard.inline_keyboard[row] = { }
                        if isGbanned(obj.id) then
                            keyboard.inline_keyboard[row][column] = { text = '✅ GBANNED ✅', callback_data = 'infoUNGBAN' .. obj.id .. chat_id }
                        else
                            keyboard.inline_keyboard[row][column] = { text = '☑️ GBANNED ☑️', callback_data = 'infoGBAN' .. obj.id .. chat_id }
                        end
                    end
                else
                    if tonumber(chat_id) < 0 then
                        local chat_member_executer = getChatMember(chat_id, executer)
                        local is_executer_owner = false
                        local is_executer_mod = false
                        if type(chat_member_executer) == 'table' then
                            if chat_member_executer.result then
                                chat_member_executer = chat_member_executer.result
                                if chat_member_executer.status then
                                    if chat_member_executer.status == 'creator' then
                                        is_executer_owner = true
                                        is_executer_mod = true
                                    elseif chat_member_executer.status == 'administrator' then
                                        is_executer_mod = true
                                    end
                                end
                            end
                        end
                        local status = ''
                        local chat_member_target = getChatMember(chat_id, obj.id)
                        if type(chat_member_target) == 'table' then
                            if chat_member_target.result then
                                chat_member_target = chat_member_target.result
                                if chat_member_target.status then
                                    status = chat_member_target.status
                                end
                            end
                        end
                        if deeper == 'PUNISHMENTS' then
                            if is_executer_mod or is_mod2(executer, chat_id, true) then
                                row = row + 1
                                keyboard.inline_keyboard[row] = { }
                                if isMutedUser(chat_id, obj.id) then
                                    keyboard.inline_keyboard[row][column] = { text = '✅ MUTED ✅', callback_data = 'infoMUTEUSER' .. obj.id .. chat_id }
                                else
                                    keyboard.inline_keyboard[row][column] = { text = '☑️ MUTED ☑️', callback_data = 'infoMUTEUSER' .. obj.id .. chat_id }
                                end
                                if string.match(getUserWarns(obj.id, chat_id), '%d+') then
                                    if status ~= 'kicked' and status ~= 'left' then
                                        row = row + 1
                                        keyboard.inline_keyboard[row] = { }
                                        -- start warn part
                                        keyboard.inline_keyboard[row][column] = { text = '-', callback_data = 'infoWARNS--' .. obj.id .. chat_id }
                                        column = column + 1
                                        keyboard.inline_keyboard[row][column] = { text = 'WARN ' .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. '/' ..(data[tostring(chat_id)].settings.max_warns or 0), callback_data = 'infoWARNS' .. obj.id .. chat_id }
                                        column = column + 1
                                        keyboard.inline_keyboard[row][column] = { text = '+', callback_data = 'infoWARNS++' .. obj.id .. chat_id }
                                        -- end warn part
                                    end
                                end
                                row = row + 1
                                column = 1
                                keyboard.inline_keyboard[row] = { }
                                if isBanned(obj.id, chat_id) or status == 'kicked' then
                                    keyboard.inline_keyboard[row][column] = { text = '✅ BANNED ✅', callback_data = 'infoUNBAN' .. obj.id .. chat_id }
                                else
                                    keyboard.inline_keyboard[row][column] = { text = '☑️ BANNED ☑️', callback_data = 'infoBAN' .. obj.id .. chat_id }
                                end
                                if tostring(chat_id):starts('-100') then
                                    row = row + 1
                                    keyboard.inline_keyboard[row] = { }
                                    keyboard.inline_keyboard[row][column] = { text = '⌨️⏳ TEMPBAN ⏳⌨️', callback_data = 'banhammerTEMPBAN0BACK' .. obj.id .. chat_id .. 'I' }
                                    row = row + 1
                                    keyboard.inline_keyboard[row] = { }
                                    keyboard.inline_keyboard[row][column] = { text = '⌨️ RESTRICTIONS ⌨️', callback_data = 'banhammerBACK' .. obj.id .. chat_id .. 'I' }
                                    row = row + 1
                                    keyboard.inline_keyboard[row] = { }
                                    keyboard.inline_keyboard[row][column] = { text = '⌨️⏳ TEMPRESTRICT ⏳⌨️ ', callback_data = 'banhammerTEMPRESTRICT0BACK' .. obj.id .. chat_id .. 'I' }
                                end
                            end
                        elseif deeper == 'PROMOTIONS' then
                            if is_executer_owner or is_owner2(executer, chat_id, true) then
                                row = row + 1
                                keyboard.inline_keyboard[row] = { }
                                if isWhitelisted(chat_id, obj.id) then
                                    keyboard.inline_keyboard[row][column] = { text = '✅ WHITELISTED ✅', callback_data = 'infoWHITELIST' .. obj.id .. chat_id }
                                else
                                    keyboard.inline_keyboard[row][column] = { text = '☑️ WHITELISTED ☑️', callback_data = 'infoWHITELIST' .. obj.id .. chat_id }
                                end
                                row = row + 1
                                keyboard.inline_keyboard[row] = { }
                                if isWhitelistedGban(chat_id, obj.id) then
                                    keyboard.inline_keyboard[row][column] = { text = '✅ WHITELISTEDGBAN ✅', callback_data = 'infoWHITELISTGBAN' .. obj.id .. chat_id }
                                else
                                    keyboard.inline_keyboard[row][column] = { text = '☑️ WHITELISTEDGBAN ☑️', callback_data = 'infoWHITELISTGBAN' .. obj.id .. chat_id }
                                end
                            end
                            if tostring(chat_id):starts('-100') then
                                -- supergroup
                                row = row + 1
                                keyboard.inline_keyboard[row] = { }
                                keyboard.inline_keyboard[row][column] = { text = langs[lang].permissionsWord, callback_data = 'group_managementBACKPERMISSIONS' .. obj.id .. chat_id .. 'I' }
                            end
                        end
                    end
                end
            end
        elseif obj.type == 'private' or obj.type == 'user' then
            if obj.first_name then
                if obj.first_name == '' then
                    if database[tostring(obj.id)] then
                        return { inline_keyboard = { { { text = langs[lang].deleteKeyboard, callback_data = 'infoDELETE' .. obj.id .. chat_id }, { text = langs[lang].deleteMessage, callback_data = 'infoDELETE' } } } }
                    else
                        return { inline_keyboard = { { { text = langs[lang].deleteMessage, callback_data = 'infoDELETE' } } } }
                    end
                end
            end
            if not deeper then
                local is_executer_admin = is_admin2(executer)
                if is_executer_admin then
                    row = row + 1
                    keyboard.inline_keyboard[row] = { }
                    keyboard.inline_keyboard[row][column] = { text = langs[lang].adminCommands, callback_data = 'infoADMINCOMMANDS' .. obj.id .. chat_id }
                end
                if tonumber(chat_id) < 0 then
                    local chat_member_executer = getChatMember(chat_id, executer)
                    local is_executer_owner = false
                    local is_executer_mod = false
                    if type(chat_member_executer) == 'table' then
                        if chat_member_executer.result then
                            chat_member_executer = chat_member_executer.result
                            if chat_member_executer.status then
                                if chat_member_executer.status == 'creator' then
                                    is_executer_owner = true
                                    is_executer_mod = true
                                elseif chat_member_executer.status == 'administrator' then
                                    is_executer_mod = true
                                end
                            end
                        end
                    end
                    if is_executer_mod or is_mod2(executer, chat_id, true) then
                        row = row + 1
                        keyboard.inline_keyboard[row] = { }
                        keyboard.inline_keyboard[row][column] = { text = langs[lang].promotionsCommands, callback_data = 'infoPROMOTIONS' .. obj.id .. chat_id }
                    end
                    if is_executer_mod or is_mod2(executer, chat_id, true) then
                        row = row + 1
                        keyboard.inline_keyboard[row] = { }
                        keyboard.inline_keyboard[row][column] = { text = langs[lang].punishmentsCommands, callback_data = 'infoPUNISHMENTS' .. obj.id .. chat_id }
                    end
                end
            else
                if deeper == 'ADMINCOMMANDS' then
                    local is_executer_admin = is_admin2(executer)
                    if is_executer_admin then
                        row = row + 1
                        keyboard.inline_keyboard[row] = { }
                        if isGbanned(obj.id) then
                            keyboard.inline_keyboard[row][column] = { text = '✅ GBANNED ✅', callback_data = 'infoUNGBAN' .. obj.id .. chat_id }
                        else
                            keyboard.inline_keyboard[row][column] = { text = '☑️ GBANNED ☑️', callback_data = 'infoGBAN' .. obj.id .. chat_id }
                        end
                        row = row + 1
                        keyboard.inline_keyboard[row] = { }
                        if isBlocked(obj.id) then
                            keyboard.inline_keyboard[row][column] = { text = '✅ PM BLOCKED ✅', callback_data = 'infoPMUNBLOCK' .. obj.id .. chat_id }
                        else
                            keyboard.inline_keyboard[row][column] = { text = '☑️ PM BLOCKED ☑️', callback_data = 'infoPMBLOCK' .. obj.id .. chat_id }
                        end
                    end
                else
                    if tonumber(chat_id) < 0 then
                        local chat_member_executer = getChatMember(chat_id, executer)
                        local is_executer_owner = false
                        local is_executer_mod = false
                        if type(chat_member_executer) == 'table' then
                            if chat_member_executer.result then
                                chat_member_executer = chat_member_executer.result
                                if chat_member_executer.status then
                                    if chat_member_executer.status == 'creator' then
                                        is_executer_owner = true
                                        is_executer_mod = true
                                    elseif chat_member_executer.status == 'administrator' then
                                        is_executer_mod = true
                                    end
                                end
                            end
                        end
                        local status = ''
                        local chat_member_target = getChatMember(chat_id, obj.id)
                        if type(chat_member_target) == 'table' then
                            if chat_member_target.result then
                                chat_member_target = chat_member_target.result
                                if chat_member_target.status then
                                    status = chat_member_target.status
                                end
                            end
                        end
                        if deeper == 'PUNISHMENTS' then
                            if is_executer_mod or is_mod2(executer, chat_id, true) then
                                row = row + 1
                                keyboard.inline_keyboard[row] = { }
                                if isMutedUser(chat_id, obj.id) then
                                    keyboard.inline_keyboard[row][column] = { text = '✅ MUTED ✅', callback_data = 'infoMUTEUSER' .. obj.id .. chat_id }
                                else
                                    keyboard.inline_keyboard[row][column] = { text = '☑️ MUTED ☑️', callback_data = 'infoMUTEUSER' .. obj.id .. chat_id }
                                end
                                if string.match(getUserWarns(obj.id, chat_id), '%d+') then
                                    if status ~= 'kicked' and status ~= 'left' then
                                        row = row + 1
                                        keyboard.inline_keyboard[row] = { }
                                        keyboard.inline_keyboard[row][column] = { text = '-', callback_data = 'infoWARNS--' .. obj.id .. chat_id }
                                        column = column + 1
                                        keyboard.inline_keyboard[row][column] = { text = 'WARN ' .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. '/' ..(data[tostring(chat_id)].settings.max_warns or 0), callback_data = 'infoWARNS' .. obj.id .. chat_id }
                                        column = column + 1
                                        keyboard.inline_keyboard[row][column] = { text = '+', callback_data = 'infoWARNS++' .. obj.id .. chat_id }
                                    end
                                end
                                row = row + 1
                                column = 1
                                keyboard.inline_keyboard[row] = { }
                                if isBanned(obj.id, chat_id) or status == 'kicked' then
                                    keyboard.inline_keyboard[row][column] = { text = '✅ BANNED ✅', callback_data = 'infoUNBAN' .. obj.id .. chat_id }
                                else
                                    keyboard.inline_keyboard[row][column] = { text = '☑️ BANNED ☑️', callback_data = 'infoBAN' .. obj.id .. chat_id }
                                end
                                if tostring(chat_id):starts('-100') then
                                    row = row + 1
                                    keyboard.inline_keyboard[row] = { }
                                    keyboard.inline_keyboard[row][column] = { text = '⌨️⏳ TEMPBAN ⏳⌨️', callback_data = 'banhammerTEMPBAN0BACK' .. obj.id .. chat_id .. 'I' }
                                    row = row + 1
                                    keyboard.inline_keyboard[row] = { }
                                    keyboard.inline_keyboard[row][column] = { text = '⌨️ RESTRICTIONS ⌨️', callback_data = 'banhammerBACK' .. obj.id .. chat_id .. 'I' }
                                    row = row + 1
                                    keyboard.inline_keyboard[row] = { }
                                    keyboard.inline_keyboard[row][column] = { text = '⌨️⏳ TEMPRESTRICT ⏳⌨️', callback_data = 'banhammerTEMPRESTRICT0BACK' .. obj.id .. chat_id .. 'I' }
                                end
                            end
                        elseif deeper == 'PROMOTIONS' then
                            if is_executer_mod or is_mod2(executer, chat_id, true) then
                                if not userInChat(chat_id, obj.id, true) then
                                    row = row + 1
                                    keyboard.inline_keyboard[row] = { }
                                    keyboard.inline_keyboard[row][column] = { text = '📨 INVITE 📨', callback_data = 'infoINVITE' .. obj.id .. chat_id }
                                end
                                if is_executer_owner or is_owner2(executer, chat_id, true) then
                                    row = row + 1
                                    keyboard.inline_keyboard[row] = { }
                                    if isWhitelisted(chat_id, obj.id) then
                                        keyboard.inline_keyboard[row][column] = { text = '✅ WHITELISTED ✅', callback_data = 'infoWHITELIST' .. obj.id .. chat_id }
                                    else
                                        keyboard.inline_keyboard[row][column] = { text = '☑️ WHITELISTED ☑️', callback_data = 'infoWHITELIST' .. obj.id .. chat_id }
                                    end
                                    row = row + 1
                                    keyboard.inline_keyboard[row] = { }
                                    if isWhitelistedGban(chat_id, obj.id) then
                                        keyboard.inline_keyboard[row][column] = { text = '✅ WHITELISTEDGBAN ✅', callback_data = 'infoWHITELISTGBAN' .. obj.id .. chat_id }
                                    else
                                        keyboard.inline_keyboard[row][column] = { text = '☑️ WHITELISTEDGBAN ☑️', callback_data = 'infoWHITELISTGBAN' .. obj.id .. chat_id }
                                    end
                                    row = row + 1
                                    keyboard.inline_keyboard[row] = { }
                                    if is_mod2(obj.id, chat_id, true) then
                                        keyboard.inline_keyboard[row][column] = { text = '✅ MODERATOR ✅', callback_data = 'infoDEMOTE' .. obj.id .. chat_id }
                                    else
                                        keyboard.inline_keyboard[row][column] = { text = '☑️ MODERATOR ☑️', callback_data = 'infoPROMOTE' .. obj.id .. chat_id }
                                    end
                                end
                                if tostring(chat_id):starts('-100') then
                                    -- supergroup
                                    row = row + 1
                                    keyboard.inline_keyboard[row] = { }
                                    keyboard.inline_keyboard[row][column] = { text = langs[lang].permissionsWord, callback_data = 'group_managementBACKPERMISSIONS' .. obj.id .. chat_id .. 'I' }
                                end
                            end
                        end
                    end
                end
            end
        elseif obj.type == 'group' then
            if is_mod2(executer, obj.id) then
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                keyboard.inline_keyboard[row][column] = { text = langs[lang].linkWord, callback_data = 'infoLINK' .. obj.id }
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                keyboard.inline_keyboard[row][column] = { text = langs[lang].muteslistWord, callback_data = 'group_managementBACKSETTINGS2' .. obj.id .. 'I' }
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                keyboard.inline_keyboard[row][column] = { text = langs[lang].settingsWord, callback_data = 'group_managementBACKSETTINGS1' .. obj.id .. 'I' }
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                keyboard.inline_keyboard[row][column] = { text = langs[lang].pluginsWord, callback_data = 'pluginsBACK1' .. obj.id .. 'I' }
            end
        elseif obj.type == 'supergroup' then
            if is_mod2(executer, obj.id) then
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                keyboard.inline_keyboard[row][column] = { text = langs[lang].linkWord, callback_data = 'infoLINK' .. obj.id }
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                keyboard.inline_keyboard[row][column] = { text = langs[lang].newlinkWord, callback_data = 'infoNEWLINK' .. obj.id }
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                keyboard.inline_keyboard[row][column] = { text = langs[lang].muteslistWord, callback_data = 'group_managementBACKSETTINGS2' .. obj.id .. 'I' }
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                keyboard.inline_keyboard[row][column] = { text = langs[lang].settingsWord, callback_data = 'group_managementBACKSETTINGS1' .. obj.id .. 'I' }
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                keyboard.inline_keyboard[row][column] = { text = langs[lang].pluginsWord, callback_data = 'pluginsBACK1' .. obj.id .. 'I' }
            end
        elseif obj.type == 'channel' then
            -- nothing
        else
            -- nothing
        end
        if deeper then
            row = row + 1
            keyboard.inline_keyboard[row] = { }
            keyboard.inline_keyboard[row][1] = { text = langs[lang].infoPage, callback_data = 'infoBACK' .. obj.id .. chat_id }
            keyboard.inline_keyboard[row][2] = { text = langs[lang].updateKeyboard, callback_data = 'info' .. deeper .. obj.id .. chat_id }
            keyboard.inline_keyboard[row][3] = { text = langs[lang].deleteKeyboard, callback_data = 'infoDELETE' .. obj.id .. chat_id }
            keyboard.inline_keyboard[row][4] = { text = langs[lang].deleteMessage, callback_data = 'infoDELETE' }
        else
            row = row + 1
            keyboard.inline_keyboard[row] = { }
            keyboard.inline_keyboard[row][1] = { text = langs[lang].updateKeyboard, callback_data = 'infoBACK' .. obj.id .. chat_id }
            keyboard.inline_keyboard[row][2] = { text = langs[lang].deleteKeyboard, callback_data = 'infoDELETE' .. obj.id .. chat_id }
            keyboard.inline_keyboard[row][3] = { text = langs[lang].deleteMessage, callback_data = 'infoDELETE' }
        end
        return keyboard
    else
        return { inline_keyboard = { { { text = langs[lang].deleteMessage, callback_data = 'infoDELETE' } } } }
    end
end

-- plugins
local max_plugins_buttons = 12
function keyboard_plugins_pages(user_id, privileged, page, chat_id, from_other_plugin)
    local lang = get_lang(user_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local flag = false
    keyboard.inline_keyboard[row] = { }
    page = tonumber(page) or 1
    local tot_plugins = 0
    for k, name in pairs(plugins_names()) do
        tot_plugins = tot_plugins + 1
    end
    local max_pages = math.floor(tot_plugins / max_plugins_buttons)
    if (tot_plugins / max_plugins_buttons) > math.floor(tot_plugins / max_plugins_buttons) then
        max_pages = max_pages + 1
    end
    if page > max_pages then
        page = max_pages
    end
    tot_plugins = 0

    for k, name in pairs(plugins_names()) do
        tot_plugins = tot_plugins + 1
        if tot_plugins >=(((page - 1) * max_plugins_buttons) + 1) and tot_plugins <=(max_plugins_buttons * page) then
            --  ✅ enabled, ☑️ disabled
            local status = '☑️'
            local enabled = false
            -- get the name
            name = string.match(name, "(.*)%.lua")
            -- Check if is enabled
            if plugin_enabled(name) then
                status = '✅'
                enabled = true
            end
            -- Check if system plugin, if not check if disabled on chat
            if system_plugin(name) then
                status = '💻'
            elseif not privileged then
                if plugin_disabled_on_chat(name, chat_id) then
                    status = '🚫'
                    enabled = false
                end
            end
            if flag then
                flag = false
                row = row + 1
                column = 1
                keyboard.inline_keyboard[row] = { }
            end
            if enabled then
                keyboard.inline_keyboard[row][column] = { text = status .. ' ' .. name, callback_data = 'pluginsDISABLE' .. name .. page }
            else
                keyboard.inline_keyboard[row][column] = { text = status .. ' ' .. name, callback_data = 'pluginsENABLE' .. name .. page }
            end
            if not privileged then
                keyboard.inline_keyboard[row][column].callback_data = keyboard.inline_keyboard[row][column].callback_data .. chat_id
            end
            column = column + 1
            if column > 2 then
                flag = true
            end
        end
    end

    keyboard = add_useful_buttons(keyboard, user_id, 'plugins', page, max_pages)
    -- adjust buttons
    for k, v in pairs(keyboard.inline_keyboard[row + 1]) do
        if keyboard.inline_keyboard[row + 1][k].text == langs[lang].previousPage or
            keyboard.inline_keyboard[row + 1][k].text == langs[lang].updateKeyboard or
            keyboard.inline_keyboard[row + 1][k].text == langs[lang].nextPage then
            if not privileged then
                keyboard.inline_keyboard[row + 1][k].callback_data = keyboard.inline_keyboard[row + 1][k].callback_data .. chat_id
            end
        end
    end
    for k, v in pairs(keyboard.inline_keyboard[row + 2]) do
        if keyboard.inline_keyboard[row + 2][k].text == langs[lang].previousPage .. langs[lang].sevenNumber or
            keyboard.inline_keyboard[row + 2][k].text == langs[lang].previousPage .. langs[lang].threeNumber or
            keyboard.inline_keyboard[row + 2][k].text == langs[lang].threeNumber .. langs[lang].nextPage or
            keyboard.inline_keyboard[row + 2][k].text == langs[lang].sevenNumber .. langs[lang].nextPage then
            if not privileged then
                keyboard.inline_keyboard[row + 2][k].callback_data = keyboard.inline_keyboard[row + 2][k].callback_data .. chat_id
            end
        end
    end
    if from_other_plugin then
        keyboard = add_from_other_plugin(keyboard, from_other_plugin)
        table.insert(keyboard.inline_keyboard[row + 1], 1, { text = langs[lang].infoPage, callback_data = 'infoBACK' .. chat_id })
    end
    return keyboard
end