-- banhammer
function keyboard_restrictions_list(chat_id, user_id, param_restrictions)
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
                    keyboard.inline_keyboard[row][column] = { text = '✅' .. reverseRestrictionsDictionary[var], callback_data = 'banhammerRESTRICT' .. user_id .. reverseRestrictionsDictionary[var] .. chat_id }
                else
                    keyboard.inline_keyboard[row][column] = { text = '🚫' .. reverseRestrictionsDictionary[var], callback_data = 'banhammerUNRESTRICT' .. user_id .. reverseRestrictionsDictionary[var] .. chat_id }
                end
                row = row + 1
                keyboard.inline_keyboard[row] = { }
            end
        end
        keyboard.inline_keyboard[row][column] = { text = langs[lang].updateKeyboard, callback_data = 'banhammerBACK' .. user_id .. chat_id }
        column = column + 1
        keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'banhammerDELETE' }
        return keyboard
    else
        local keyboard = { }
        keyboard.inline_keyboard = { }
        local row = 1
        local column = 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'banhammerDELETE' }
        return keyboard
    end
end
function keyboard_time(op, chat_id, user_id, time)
    if not time then
        time = 16115430
    end
    local remainder, weeks, days, hours, minutes, seconds = 0
    weeks = math.floor(time / 604800)
    remainder = time % 604800
    days = math.floor(remainder / 86400)
    remainder = remainder % 86400
    hours = math.floor(remainder / 3600)
    remainder = remainder % 3600
    minutes = math.floor(remainder / 60)
    seconds = remainder % 60
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    for i = 1, 12 do
        keyboard.inline_keyboard[i] = { }
    end

    keyboard.inline_keyboard[1][1] = { text = langs[lang].seconds:gsub('X', seconds), callback_data = 'banhammer' .. op .. time .. 'SECONDS0' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][1] = { text = "-10", callback_data = 'banhammer' .. op .. time .. 'SECONDS-10' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][2] = { text = "-5", callback_data = 'banhammer' .. op .. time .. 'SECONDS-5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][3] = { text = "-1", callback_data = 'banhammer' .. op .. time .. 'SECONDS-1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][4] = { text = "+1", callback_data = 'banhammer' .. op .. time .. 'SECONDS+1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][5] = { text = "+5", callback_data = 'banhammer' .. op .. time .. 'SECONDS+5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[2][6] = { text = "+10", callback_data = 'banhammer' .. op .. time .. 'SECONDS+10' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[3][1] = { text = langs[lang].minutes:gsub('X', minutes), callback_data = 'banhammer' .. op .. time .. 'MINUTES0' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[4][1] = { text = "-10", callback_data = 'banhammer' .. op .. time .. 'MINUTES-10' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[4][2] = { text = "-5", callback_data = 'banhammer' .. op .. time .. 'MINUTES-5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[4][3] = { text = "-1", callback_data = 'banhammer' .. op .. time .. 'MINUTES-1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[4][4] = { text = "+1", callback_data = 'banhammer' .. op .. time .. 'MINUTES+1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[4][5] = { text = "+5", callback_data = 'banhammer' .. op .. time .. 'MINUTES+5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[4][6] = { text = "+10", callback_data = 'banhammer' .. op .. time .. 'MINUTES+10' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[5][1] = { text = langs[lang].hours:gsub('X', hours), callback_data = 'banhammer' .. op .. time .. 'HOURS0' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[6][1] = { text = "-10", callback_data = 'banhammer' .. op .. time .. 'HOURS-10' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[6][2] = { text = "-5", callback_data = 'banhammer' .. op .. time .. 'HOURS-5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[6][3] = { text = "-1", callback_data = 'banhammer' .. op .. time .. 'HOURS-1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[6][4] = { text = "+1", callback_data = 'banhammer' .. op .. time .. 'HOURS+1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[6][5] = { text = "+5", callback_data = 'banhammer' .. op .. time .. 'HOURS+5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[6][6] = { text = "+10", callback_data = 'banhammer' .. op .. time .. 'HOURS+10' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[7][1] = { text = langs[lang].days:gsub('X', days), callback_data = 'banhammer' .. op .. time .. 'DAYS0' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[8][1] = { text = "-5", callback_data = 'banhammer' .. op .. time .. 'DAYS-5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[8][2] = { text = "-3", callback_data = 'banhammer' .. op .. time .. 'DAYS-3' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[8][3] = { text = "-1", callback_data = 'banhammer' .. op .. time .. 'DAYS-1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[8][4] = { text = "+1", callback_data = 'banhammer' .. op .. time .. 'DAYS+1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[8][5] = { text = "+3", callback_data = 'banhammer' .. op .. time .. 'DAYS+3' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[8][6] = { text = "+5", callback_data = 'banhammer' .. op .. time .. 'DAYS+5' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[9][1] = { text = langs[lang].weeks:gsub('X', weeks), callback_data = 'banhammer' .. op .. time .. 'WEEKS0' .. chat_id .. '$' .. user_id }

    keyboard.inline_keyboard[10][1] = { text = "-10", callback_data = 'banhammer' .. op .. time .. 'WEEKS-10' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[10][2] = { text = "-5", callback_data = 'banhammer' .. op .. time .. 'WEEKS-5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[10][3] = { text = "-1", callback_data = 'banhammer' .. op .. time .. 'WEEKS-1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[10][4] = { text = "+1", callback_data = 'banhammer' .. op .. time .. 'WEEKS+1' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[10][5] = { text = "+5", callback_data = 'banhammer' .. op .. time .. 'WEEKS+5' .. chat_id .. '$' .. user_id }
    keyboard.inline_keyboard[10][6] = { text = "+10", callback_data = 'banhammer' .. op .. time .. 'WEEKS+10' .. chat_id .. '$' .. user_id }

    if time < 30 or time > 31622400 then
        keyboard.inline_keyboard[11][1] = { text = op:gsub('TEMP', '') .. ' ' .. langs[lang].forever, callback_data = 'banhammer' .. op .. time .. 'DONE' .. user_id .. chat_id }
    else
        keyboard.inline_keyboard[11][1] = { text = op:gsub('TEMP', '') .. ' ' ..(days + weeks * 7) .. langs[lang].daysWord .. hours .. langs[lang].hoursWord .. minutes .. langs[lang].minutesWord .. seconds .. langs[lang].secondsWord, callback_data = 'banhammer' .. op .. time .. 'DONE' .. user_id .. chat_id }
    end

    keyboard.inline_keyboard[12][1] = { text = langs[lang].updateKeyboard, callback_data = 'banhammer' .. op .. time .. 'BACK' .. user_id .. chat_id }
    keyboard.inline_keyboard[12][2] = { text = langs[lang].deleteMessage, callback_data = 'banhammerDELETE' }
    return keyboard
end

-- bot
-- strings
function keyboard_langs()
    local keyboard = { }
    keyboard.inline_keyboard = { }
    keyboard.inline_keyboard[1] = { }
    keyboard.inline_keyboard[1][1] = { text = langs.italian, callback_data = 'botIT' }
    keyboard.inline_keyboard[1][2] = { text = langs.english, callback_data = 'botEN' }
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
    else
        keyboard.inline_keyboard[1] = { }
        keyboard.inline_keyboard[1][1] = { text = langs[lang].deleteUp, callback_data = 'check_tagDELETEUP' .. user_id .. chat_id }
    end

    return keyboard
end

-- delword
function keyboard_scheduledelword(chat_id, time)
    if not time then
        time = 0
    end
    local remainder, hours, minutes, seconds = 0
    hours = math.floor(time / 3600)
    remainder = time % 3600
    minutes = math.floor(remainder / 60)
    seconds = remainder % 60
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    for i = 1, 8 do
        keyboard.inline_keyboard[i] = { }
    end

    keyboard.inline_keyboard[1][1] = { text = langs[lang].seconds:gsub('X', seconds), callback_data = 'delword' .. time .. 'SECONDS0' .. chat_id }
    keyboard.inline_keyboard[2][1] = { text = "-10", callback_data = 'delword' .. time .. 'SECONDS-10' .. chat_id }
    keyboard.inline_keyboard[2][2] = { text = "-5", callback_data = 'delword' .. time .. 'SECONDS-5' .. chat_id }
    keyboard.inline_keyboard[2][3] = { text = "-1", callback_data = 'delword' .. time .. 'SECONDS-1' .. chat_id }
    keyboard.inline_keyboard[2][4] = { text = "+1", callback_data = 'delword' .. time .. 'SECONDS+1' .. chat_id }
    keyboard.inline_keyboard[2][5] = { text = "+5", callback_data = 'delword' .. time .. 'SECONDS+5' .. chat_id }
    keyboard.inline_keyboard[2][6] = { text = "+10", callback_data = 'delword' .. time .. 'SECONDS+10' .. chat_id }

    keyboard.inline_keyboard[3][1] = { text = langs[lang].minutes:gsub('X', minutes), callback_data = 'delword' .. time .. 'MINUTES0' .. chat_id }

    keyboard.inline_keyboard[4][1] = { text = "-10", callback_data = 'delword' .. time .. 'MINUTES-10' .. chat_id }
    keyboard.inline_keyboard[4][2] = { text = "-5", callback_data = 'delword' .. time .. 'MINUTES-5' .. chat_id }
    keyboard.inline_keyboard[4][3] = { text = "-1", callback_data = 'delword' .. time .. 'MINUTES-1' .. chat_id }
    keyboard.inline_keyboard[4][4] = { text = "+1", callback_data = 'delword' .. time .. 'MINUTES+1' .. chat_id }
    keyboard.inline_keyboard[4][5] = { text = "+5", callback_data = 'delword' .. time .. 'MINUTES+5' .. chat_id }
    keyboard.inline_keyboard[4][6] = { text = "+10", callback_data = 'delword' .. time .. 'MINUTES+10' .. chat_id }

    keyboard.inline_keyboard[5][1] = { text = langs[lang].hours:gsub('X', hours), callback_data = 'delword' .. time .. 'HOURS0' .. chat_id }

    keyboard.inline_keyboard[6][1] = { text = "-5", callback_data = 'delword' .. time .. 'HOURS-5' .. chat_id }
    keyboard.inline_keyboard[6][2] = { text = "-3", callback_data = 'delword' .. time .. 'HOURS-3' .. chat_id }
    keyboard.inline_keyboard[6][3] = { text = "-1", callback_data = 'delword' .. time .. 'HOURS-1' .. chat_id }
    keyboard.inline_keyboard[6][4] = { text = "+1", callback_data = 'delword' .. time .. 'HOURS+1' .. chat_id }
    keyboard.inline_keyboard[6][5] = { text = "+3", callback_data = 'delword' .. time .. 'HOURS+3' .. chat_id }
    keyboard.inline_keyboard[6][6] = { text = "+5", callback_data = 'delword' .. time .. 'HOURS+5' .. chat_id }

    keyboard.inline_keyboard[7][1] = { text = "OK " .. hours .. langs[lang].hoursWord .. minutes .. langs[lang].minutesWord .. seconds .. langs[lang].secondsWord, callback_data = 'delword' .. time .. 'DONE' .. chat_id }

    keyboard.inline_keyboard[8][1] = { text = langs[lang].updateKeyboard, callback_data = 'delword' .. time .. 'BACK' .. chat_id }
    keyboard.inline_keyboard[8][2] = { text = langs[lang].deleteMessage, callback_data = 'delwordDELETE' }
    return keyboard
end

-- help
function keyboard_help_list(chat_id, rank)
    local lang = get_lang(chat_id)
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
    keyboard.inline_keyboard[row][column] = { text = langs[lang].updateKeyboard, callback_data = 'helpBACK' }
    column = column + 1
    keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'helpDELETE' }
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
function keyboard_permissions_list(chat_id, user_id, param_permissions)
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
                    keyboard.inline_keyboard[row][column] = { text = '✅ ' .. reversePermissionsDictionary[var], callback_data = 'group_managementDENY' .. user_id .. reversePermissionsDictionary[var] .. chat_id }
                else
                    keyboard.inline_keyboard[row][column] = { text = '☑️ ' .. reversePermissionsDictionary[var], callback_data = 'group_managementGRANT' .. user_id .. reversePermissionsDictionary[var] .. chat_id }
                end
                row = row + 1
                keyboard.inline_keyboard[row] = { }
            end
        end
        keyboard.inline_keyboard[row][column] = { text = langs[lang].updateKeyboard, callback_data = 'group_managementBACKPERMISSIONS' .. user_id .. chat_id }
        column = column + 1
        keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'group_managementDELETE' }
        return keyboard
    else
        local keyboard = { }
        keyboard.inline_keyboard = { }
        local row = 1
        local column = 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'group_managementDELETE' }
        return keyboard
    end
end
function keyboard_settings_list(chat_id, from_other_plugin)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local flag = false
    keyboard.inline_keyboard[row] = { }
    for var, value in pairsByKeys(data[tostring(chat_id)].settings) do
        if reverseAdjustSettingType(var) ~= 'flood' then
            if type(value) == 'boolean' then
                if flag then
                    flag = false
                    row = row + 1
                    column = 1
                    keyboard.inline_keyboard[row] = { }
                end
                if value then
                    if from_other_plugin then
                        keyboard.inline_keyboard[row][column] = { text = '✅ ' .. reverseAdjustSettingType(var), callback_data = 'group_managementUNLOCK' .. var .. chat_id .. 'I' }
                    else
                        keyboard.inline_keyboard[row][column] = { text = '✅ ' .. reverseAdjustSettingType(var), callback_data = 'group_managementUNLOCK' .. var .. chat_id }
                    end
                else
                    if from_other_plugin then
                        keyboard.inline_keyboard[row][column] = { text = '☑️ ' .. reverseAdjustSettingType(var), callback_data = 'group_managementLOCK' .. var .. chat_id .. 'I' }
                    else
                        keyboard.inline_keyboard[row][column] = { text = '☑️ ' .. reverseAdjustSettingType(var), callback_data = 'group_managementLOCK' .. var .. chat_id }
                    end
                end
                column = column + 1
                if column > 2 then
                    flag = true
                end
            end
        end
    end

    row = row + 1
    column = 1
    keyboard.inline_keyboard[row] = { }
    -- start flood part
    if from_other_plugin then
        keyboard.inline_keyboard[row][column] = { text = '-', callback_data = 'group_managementFLOODMINUS' .. data[tostring(chat_id)].settings.flood_max .. chat_id .. 'I' }
    else
        keyboard.inline_keyboard[row][column] = { text = '-', callback_data = 'group_managementFLOODMINUS' .. data[tostring(chat_id)].settings.flood_max .. chat_id }
    end
    column = column + 1
    if data[tostring(chat_id)].settings.flood then
        if from_other_plugin then
            keyboard.inline_keyboard[row][column] = { text = '✅ flood (' .. data[tostring(chat_id)].settings.flood_max .. ')', callback_data = 'group_managementUNLOCKflood' .. chat_id .. 'I' }
        else
            keyboard.inline_keyboard[row][column] = { text = '✅ flood (' .. data[tostring(chat_id)].settings.flood_max .. ')', callback_data = 'group_managementUNLOCKflood' .. chat_id }
        end
    else
        if from_other_plugin then
            keyboard.inline_keyboard[row][column] = { text = '☑️ flood (' .. data[tostring(chat_id)].settings.flood_max .. ')', callback_data = 'group_managementLOCKflood' .. chat_id .. 'I' }
        else
            keyboard.inline_keyboard[row][column] = { text = '☑️ flood (' .. data[tostring(chat_id)].settings.flood_max .. ')', callback_data = 'group_managementLOCKflood' .. chat_id }
        end
    end
    column = column + 1
    if from_other_plugin then
        keyboard.inline_keyboard[row][column] = { text = '+', callback_data = 'group_managementFLOODPLUS' .. data[tostring(chat_id)].settings.flood_max .. chat_id .. 'I' }
    else
        keyboard.inline_keyboard[row][column] = { text = '+', callback_data = 'group_managementFLOODPLUS' .. data[tostring(chat_id)].settings.flood_max .. chat_id }
    end
    -- end flood part

    row = row + 1
    column = 1
    keyboard.inline_keyboard[row] = { }
    -- start warn part
    if from_other_plugin then
        keyboard.inline_keyboard[row][column] = { text = '-', callback_data = 'group_managementWARNSMINUS' .. data[tostring(chat_id)].settings.warn_max .. chat_id .. 'I' }
    else
        keyboard.inline_keyboard[row][column] = { text = '-', callback_data = 'group_managementWARNSMINUS' .. data[tostring(chat_id)].settings.warn_max .. chat_id }
    end
    column = column + 1
    if tonumber(data[tostring(chat_id)].settings.warn_max) ~= 0 then
        -- disable warns
        if from_other_plugin then
            keyboard.inline_keyboard[row][column] = { text = '✅ warns (' .. data[tostring(chat_id)].settings.warn_max .. ')', callback_data = 'group_managementWARNS0' .. chat_id .. 'I' }
        else
            keyboard.inline_keyboard[row][column] = { text = '✅ warns (' .. data[tostring(chat_id)].settings.warn_max .. ')', callback_data = 'group_managementWARNS0' .. chat_id }
        end
    else
        -- default warns
        if from_other_plugin then
            keyboard.inline_keyboard[row][column] = { text = '☑️ warns (' .. data[tostring(chat_id)].settings.warn_max .. ')', callback_data = 'group_managementWARNS3' .. chat_id .. 'I' }
        else
            keyboard.inline_keyboard[row][column] = { text = '☑️ warns (' .. data[tostring(chat_id)].settings.warn_max .. ')', callback_data = 'group_managementWARNS3' .. chat_id }
        end
    end
    column = column + 1
    if from_other_plugin then
        keyboard.inline_keyboard[row][column] = { text = '+', callback_data = 'group_managementWARNSPLUS' .. data[tostring(chat_id)].settings.warn_max .. chat_id .. 'I' }
    else
        keyboard.inline_keyboard[row][column] = { text = '+', callback_data = 'group_managementWARNSPLUS' .. data[tostring(chat_id)].settings.warn_max .. chat_id }
    end
    -- end warn part

    row = row + 1
    column = 1
    keyboard.inline_keyboard[row] = { }
    if from_other_plugin then
        keyboard.inline_keyboard[row][column] = { text = langs[lang].updateKeyboard, callback_data = 'group_managementBACKSETTINGS' .. chat_id .. 'I' }
    else
        keyboard.inline_keyboard[row][column] = { text = langs[lang].updateKeyboard, callback_data = 'group_managementBACKSETTINGS' .. chat_id }
    end
    column = column + 1
    keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'group_managementDELETE' }
    if from_other_plugin then
        row = row + 1
        column = 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][column] = { text = langs[lang].goBack, callback_data = 'infoBACK' .. chat_id }
    end
    return keyboard
end
function keyboard_mutes_list(chat_id, from_other_plugin)
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local flag = false
    keyboard.inline_keyboard[row] = { }
    for var, value in pairsByKeys(data[tostring(chat_id)].settings.mutes) do
        if flag then
            flag = false
            row = row + 1
            column = 1
            keyboard.inline_keyboard[row] = { }
        end
        if value then
            if from_other_plugin then
                keyboard.inline_keyboard[row][column] = { text = '🔇 ' .. var, callback_data = 'group_managementUNMUTE' .. var .. chat_id .. 'I' }
            else
                keyboard.inline_keyboard[row][column] = { text = '🔇 ' .. var, callback_data = 'group_managementUNMUTE' .. var .. chat_id }
            end
        else
            if from_other_plugin then
                keyboard.inline_keyboard[row][column] = { text = '🔊 ' .. var, callback_data = 'group_managementMUTE' .. var .. chat_id .. 'I' }
            else
                keyboard.inline_keyboard[row][column] = { text = '🔊 ' .. var, callback_data = 'group_managementMUTE' .. var .. chat_id }
            end
        end
        column = column + 1
        if column > 2 then
            flag = true
        end
    end
    row = row + 1
    column = 1
    keyboard.inline_keyboard[row] = { }
    if from_other_plugin then
        keyboard.inline_keyboard[row][column] = { text = langs[lang].updateKeyboard, callback_data = 'group_managementBACKMUTES' .. chat_id .. 'I' }
    else
        keyboard.inline_keyboard[row][column] = { text = langs[lang].updateKeyboard, callback_data = 'group_managementBACKMUTES' .. chat_id }
    end
    column = column + 1
    keyboard.inline_keyboard[row][column] = { text = langs[lang].deleteMessage, callback_data = 'group_managementDELETE' }
    if from_other_plugin then
        row = row + 1
        column = 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][column] = { text = langs[lang].goBack, callback_data = 'infoBACK' .. chat_id }
    end
    return keyboard
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
            if deeper == 'ADMIN COMMANDS' then
                local is_executer_admin = is_admin2(executer)
                if is_executer_admin then
                    row = row + 1
                    keyboard.inline_keyboard[row] = { }
                    if isGbanned(obj.id) then
                        keyboard.inline_keyboard[row][column] = { text = '✅ GBANNED', callback_data = 'infoUNGBAN' .. obj.id .. chat_id }
                    else
                        keyboard.inline_keyboard[row][column] = { text = '☑️ GBANNED', callback_data = 'infoGBAN' .. obj.id .. chat_id }
                    end
                end
            elseif deeper == 'IN GROUP COMMANDS' then
            end
            if tonumber(chat_id) < 0 then
                local status = ''
                local chat_member = getChatMember(chat_id, obj.id)
                local is_executer_owner = false
                local is_executer_mod = false
                if type(chat_member) == 'table' then
                    if chat_member.result then
                        chat_member = chat_member.result
                        if chat_member.status then
                            status = chat_member.status
                            if chat_member.status == 'creator' then
                                is_executer_owner = true
                                is_executer_mod = true
                            elseif chat_member.status == 'administrator' then
                                is_executer_mod = true
                            end
                        end
                    end
                end
                if is_executer_mod or is_mod2(executer, chat_id, true) then
                    row = row + 1
                    keyboard.inline_keyboard[row] = { }
                    if isBanned(obj.id, chat_id) then
                        keyboard.inline_keyboard[row][column] = { text = '✅ BANNED', callback_data = 'infoUNBAN' .. obj.id .. chat_id }
                    else
                        keyboard.inline_keyboard[row][column] = { text = '☑️ BANNED', callback_data = 'infoBAN' .. obj.id .. chat_id }
                    end
                    row = row + 1
                    keyboard.inline_keyboard[row] = { }
                    if isMutedUser(chat_id, obj.id) then
                        keyboard.inline_keyboard[row][column] = { text = '✅ MUTED', callback_data = 'infoMUTEUSER' .. obj.id .. chat_id }
                    else
                        keyboard.inline_keyboard[row][column] = { text = '☑️ MUTED', callback_data = 'infoMUTEUSER' .. obj.id .. chat_id }
                    end
                    if string.match(getUserWarns(obj.id, chat_id), '%d+') then
                        if status ~= 'kicked' and status ~= 'left' then
                            row = row + 1
                            keyboard.inline_keyboard[row] = { }
                            -- start warn part
                            keyboard.inline_keyboard[row][column] = { text = '-', callback_data = 'infoWARNSMINUS' .. obj.id .. chat_id }
                            column = column + 1
                            keyboard.inline_keyboard[row][column] = { text = 'WARN ' .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. '/' ..(data[tostring(chat_id)].settings.warn_max or 0), callback_data = 'infoWARNS' .. obj.id .. chat_id }
                            column = column + 1
                            keyboard.inline_keyboard[row][column] = { text = '+', callback_data = 'infoWARNSPLUS' .. obj.id .. chat_id }
                            -- end warn part
                        end
                    end
                    if is_executer_owner or is_owner2(executer, chat_id, true) then
                        row = row + 1
                        column = 1
                        keyboard.inline_keyboard[row] = { }
                        if isWhitelisted(id_to_cli(chat_id), obj.id) then
                            keyboard.inline_keyboard[row][column] = { text = '✅ WHITELISTED', callback_data = 'infoWHITELIST' .. obj.id .. chat_id }
                        else
                            keyboard.inline_keyboard[row][column] = { text = '☑️ WHITELISTED', callback_data = 'infoWHITELIST' .. obj.id .. chat_id }
                        end
                        row = row + 1
                        keyboard.inline_keyboard[row] = { }
                        if isWhitelistedGban(id_to_cli(chat_id), obj.id) then
                            keyboard.inline_keyboard[row][column] = { text = '✅ GBANWHITELISTED', callback_data = 'infoGBANWHITELIST' .. obj.id .. chat_id }
                        else
                            keyboard.inline_keyboard[row][column] = { text = '☑️ GBANWHITELISTED', callback_data = 'infoGBANWHITELIST' .. obj.id .. chat_id }
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
            local is_executer_admin = is_admin2(executer)
            if is_executer_admin then
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                if isGbanned(obj.id) then
                    keyboard.inline_keyboard[row][column] = { text = '✅ GBANNED', callback_data = 'infoUNGBAN' .. obj.id .. chat_id }
                else
                    keyboard.inline_keyboard[row][column] = { text = '☑️ GBANNED', callback_data = 'infoGBAN' .. obj.id .. chat_id }
                end
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                if isBlocked(obj.id) then
                    keyboard.inline_keyboard[row][column] = { text = '✅ PM BLOCKED', callback_data = 'infoPMUNBLOCK' .. obj.id .. chat_id }
                else
                    keyboard.inline_keyboard[row][column] = { text = '☑️ PM BLOCKED', callback_data = 'infoPMBLOCK' .. obj.id .. chat_id }
                end
            end
            if tonumber(chat_id) < 0 then
                local status = ''
                local chat_member = getChatMember(chat_id, obj.id)
                local is_executer_owner = false
                local is_executer_mod = false
                if type(chat_member) == 'table' then
                    if chat_member.result then
                        chat_member = chat_member.result
                        if chat_member.status then
                            status = chat_member.status
                            if chat_member.status == 'creator' then
                                is_executer_owner = true
                                is_executer_mod = true
                            elseif chat_member.status == 'administrator' then
                                is_executer_mod = true
                            end
                        end
                    end
                end
                if is_executer_mod or is_mod2(executer, chat_id, true) then
                    row = row + 1
                    keyboard.inline_keyboard[row] = { }
                    if isBanned(obj.id, chat_id) then
                        keyboard.inline_keyboard[row][column] = { text = '✅ BANNED', callback_data = 'infoUNBAN' .. obj.id .. chat_id }
                    else
                        keyboard.inline_keyboard[row][column] = { text = '☑️ BANNED', callback_data = 'infoBAN' .. obj.id .. chat_id }
                    end
                    row = row + 1
                    keyboard.inline_keyboard[row] = { }
                    if isMutedUser(chat_id, obj.id) then
                        keyboard.inline_keyboard[row][column] = { text = '✅ MUTED', callback_data = 'infoMUTEUSER' .. obj.id .. chat_id }
                    else
                        keyboard.inline_keyboard[row][column] = { text = '☑️ MUTED', callback_data = 'infoMUTEUSER' .. obj.id .. chat_id }
                    end
                    if string.match(getUserWarns(obj.id, chat_id), '%d+') then
                        if status ~= 'kicked' and status ~= 'left' then
                            row = row + 1
                            keyboard.inline_keyboard[row] = { }
                            keyboard.inline_keyboard[row][column] = { text = '-', callback_data = 'infoWARNSMINUS' .. obj.id .. chat_id }
                            column = column + 1
                            keyboard.inline_keyboard[row][column] = { text = 'WARN ' .. string.match(getUserWarns(obj.id, chat_id), '%d+') .. '/' ..(data[tostring(chat_id)].settings.warn_max or 0), callback_data = 'infoWARNS' .. obj.id .. chat_id }
                            column = column + 1
                            keyboard.inline_keyboard[row][column] = { text = '+', callback_data = 'infoWARNSPLUS' .. obj.id .. chat_id }
                        end
                    end
                    if is_executer_owner or is_owner2(executer, chat_id, true) then
                        row = row + 1
                        column = 1
                        keyboard.inline_keyboard[row] = { }
                        if isWhitelisted(id_to_cli(chat_id), obj.id) then
                            keyboard.inline_keyboard[row][column] = { text = '✅ WHITELISTED', callback_data = 'infoWHITELIST' .. obj.id .. chat_id }
                        else
                            keyboard.inline_keyboard[row][column] = { text = '☑️ WHITELISTED', callback_data = 'infoWHITELIST' .. obj.id .. chat_id }
                        end
                        row = row + 1
                        keyboard.inline_keyboard[row] = { }
                        if isWhitelistedGban(id_to_cli(chat_id), obj.id) then
                            keyboard.inline_keyboard[row][column] = { text = '✅ GBANWHITELISTED', callback_data = 'infoGBANWHITELIST' .. obj.id .. chat_id }
                        else
                            keyboard.inline_keyboard[row][column] = { text = '☑️ GBANWHITELISTED', callback_data = 'infoGBANWHITELIST' .. obj.id .. chat_id }
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
                keyboard.inline_keyboard[row][column] = { text = langs[lang].muteslistWord, callback_data = 'group_managementBACKMUTES' .. obj.id .. 'I' }
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                keyboard.inline_keyboard[row][column] = { text = langs[lang].settingsWord, callback_data = 'group_managementBACKSETTINGS' .. obj.id .. 'I' }
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
                keyboard.inline_keyboard[row][column] = { text = langs[lang].muteslistWord, callback_data = 'group_managementBACKMUTES' .. obj.id .. 'I' }
                row = row + 1
                keyboard.inline_keyboard[row] = { }
                keyboard.inline_keyboard[row][column] = { text = langs[lang].settingsWord, callback_data = 'group_managementBACKSETTINGS' .. obj.id .. 'I' }
            end
        elseif obj.type == 'channel' then
            -- nothing
        else
            -- nothing
        end
        row = row + 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][1] = { text = langs[lang].updateKeyboard, callback_data = 'infoBACK' .. obj.id .. chat_id }
        keyboard.inline_keyboard[row][2] = { text = langs[lang].deleteKeyboard, callback_data = 'infoDELETE' .. obj.id .. chat_id }
        row = row + 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][1] = { text = langs[lang].deleteMessage, callback_data = 'infoDELETE' }
        return keyboard
    else
        return { inline_keyboard = { { { text = langs[lang].deleteKeyboard, callback_data = 'infoDELETE' .. obj.id .. chat_id }, { text = langs[lang].deleteMessage, callback_data = 'infoDELETE' } } } }
    end
end

-- plugins
function keyboard_plugins_list(user_id, privileged, chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local flag = false
    keyboard.inline_keyboard[row] = { }
    for k, name in pairs(plugins_names()) do
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
            keyboard.inline_keyboard[row][column] = { text = status .. ' ' .. name, callback_data = 'pluginsDISABLE' .. name }
        else
            keyboard.inline_keyboard[row][column] = { text = status .. ' ' .. name, callback_data = 'pluginsENABLE' .. name }
        end
        if not privileged then
            keyboard.inline_keyboard[row][column].callback_data = keyboard.inline_keyboard[row][column].callback_data .. chat_id
        end
        column = column + 1
        if column > 2 then
            flag = true
        end
    end
    row = row + 1
    column = 1
    keyboard.inline_keyboard[row] = { }
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(user_id)].updateKeyboard, callback_data = 'pluginsBACK' }
    if not privileged then
        keyboard.inline_keyboard[row][column].callback_data = keyboard.inline_keyboard[row][column].callback_data .. chat_id
    end
    column = column + 1
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(user_id)].deleteMessage, callback_data = 'pluginsDELETE' }
    return keyboard
end

-- tempmessage
function keyboard_tempmessage(chat_id, time)
    if not time then
        time = 88230
    end
    local remainder, hours, minutes, seconds = 0
    hours = math.floor(time / 3600)
    remainder = time % 3600
    minutes = math.floor(remainder / 60)
    seconds = remainder % 60
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    for i = 1, 8 do
        keyboard.inline_keyboard[i] = { }
    end

    keyboard.inline_keyboard[1][1] = { text = langs[lang].seconds:gsub('X', seconds), callback_data = 'tempmessage' .. time .. 'SECONDS0' .. chat_id }
    keyboard.inline_keyboard[2][1] = { text = "-10", callback_data = 'tempmessage' .. time .. 'SECONDS-10' .. chat_id }
    keyboard.inline_keyboard[2][2] = { text = "-5", callback_data = 'tempmessage' .. time .. 'SECONDS-5' .. chat_id }
    keyboard.inline_keyboard[2][3] = { text = "-1", callback_data = 'tempmessage' .. time .. 'SECONDS-1' .. chat_id }
    keyboard.inline_keyboard[2][4] = { text = "+1", callback_data = 'tempmessage' .. time .. 'SECONDS+1' .. chat_id }
    keyboard.inline_keyboard[2][5] = { text = "+5", callback_data = 'tempmessage' .. time .. 'SECONDS+5' .. chat_id }
    keyboard.inline_keyboard[2][6] = { text = "+10", callback_data = 'tempmessage' .. time .. 'SECONDS+10' .. chat_id }

    keyboard.inline_keyboard[3][1] = { text = langs[lang].minutes:gsub('X', minutes), callback_data = 'tempmessage' .. time .. 'MINUTES0' .. chat_id }

    keyboard.inline_keyboard[4][1] = { text = "-10", callback_data = 'tempmessage' .. time .. 'MINUTES-10' .. chat_id }
    keyboard.inline_keyboard[4][2] = { text = "-5", callback_data = 'tempmessage' .. time .. 'MINUTES-5' .. chat_id }
    keyboard.inline_keyboard[4][3] = { text = "-1", callback_data = 'tempmessage' .. time .. 'MINUTES-1' .. chat_id }
    keyboard.inline_keyboard[4][4] = { text = "+1", callback_data = 'tempmessage' .. time .. 'MINUTES+1' .. chat_id }
    keyboard.inline_keyboard[4][5] = { text = "+5", callback_data = 'tempmessage' .. time .. 'MINUTES+5' .. chat_id }
    keyboard.inline_keyboard[4][6] = { text = "+10", callback_data = 'tempmessage' .. time .. 'MINUTES+10' .. chat_id }

    keyboard.inline_keyboard[5][1] = { text = langs[lang].hours:gsub('X', hours), callback_data = 'tempmessage' .. time .. 'HOURS0' .. chat_id }

    keyboard.inline_keyboard[6][1] = { text = "-5", callback_data = 'tempmessage' .. time .. 'HOURS-5' .. chat_id }
    keyboard.inline_keyboard[6][2] = { text = "-3", callback_data = 'tempmessage' .. time .. 'HOURS-3' .. chat_id }
    keyboard.inline_keyboard[6][3] = { text = "-1", callback_data = 'tempmessage' .. time .. 'HOURS-1' .. chat_id }
    keyboard.inline_keyboard[6][4] = { text = "+1", callback_data = 'tempmessage' .. time .. 'HOURS+1' .. chat_id }
    keyboard.inline_keyboard[6][5] = { text = "+3", callback_data = 'tempmessage' .. time .. 'HOURS+3' .. chat_id }
    keyboard.inline_keyboard[6][6] = { text = "+5", callback_data = 'tempmessage' .. time .. 'HOURS+5' .. chat_id }

    keyboard.inline_keyboard[7][1] = { text = "OK " .. hours .. langs[lang].hoursWord .. minutes .. langs[lang].minutesWord .. seconds .. langs[lang].secondsWord, callback_data = 'tempmessage' .. time .. 'DONE' .. chat_id }

    keyboard.inline_keyboard[8][1] = { text = langs[lang].updateKeyboard, callback_data = 'tempmessage' .. time .. 'BACK' .. chat_id }
    keyboard.inline_keyboard[8][2] = { text = langs[lang].deleteMessage, callback_data = 'tempmessageDELETE' }
    return keyboard
end