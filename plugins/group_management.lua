-- REFACTORING OF INPM.LUA INREALM.LUA INGROUP.LUA AND SUPERGROUP.LUA
-- table to manage restrictions of a user in a keyboard
local permissionsTable = {
    -- chat_id = { user_id = { permissions } }
}
-- Empty tables for solving multiple problems(thanks to @topkecleon)
local cronTable = {
    adminsContacted =
    {
        -- chat_id
    },
    noticeContacted =
    {
        -- chat_id = false/true
    },
}

local delAll = {
    -- chat_id = { from = msgidBegin, to = msgidEnd }
}

-- tables that contains 'group_id' = message_id to delete old commands responses
local oldResponses = {
    lastRules = { },
    lastModlist = { },
    lastSettings = { },
}

local function showPermissions(chat_id, user_id, lang)
    local obj_user = getChatMember(chat_id, user_id)
    if type(obj_user) == 'table' then
        if obj_user.result then
            obj_user = obj_user.result
        else
            obj_user = nil
        end
    else
        obj_user = nil
    end
    if obj_user then
        if obj_user.status ~= 'creator' then
            if obj_user.status == 'administrator' then
                local text = langs[lang].permissions ..
                langs[lang].permissionCanBeEdited .. tostring(obj_user.can_be_edited or false) ..
                langs[lang].permissionChangeInfo .. tostring(obj_user.can_change_info or false) ..
                langs[lang].permissionDeleteMessages .. tostring(obj_user.can_delete_messages or false) ..
                langs[lang].permissionInviteUsers .. tostring(obj_user.can_invite_users or false) ..
                langs[lang].permissionPinMessages .. tostring(obj_user.can_pin_messages or false) ..
                langs[lang].permissionPromoteMembers .. tostring(obj_user.can_promote_members or false) ..
                langs[lang].permissionRestrictMembers .. tostring(obj_user.can_restrict_members or false)
                return text
            elseif obj_user.status == 'member' or obj_user.status == 'restricted' then
                local obj_bot = getChatMember(chat_id, bot.id)
                if type(obj_bot) == 'table' then
                    if obj_bot.result then
                        obj_bot = obj_bot.result
                    else
                        obj_bot = nil
                    end
                else
                    obj_bot = nil
                end
                if obj_bot then
                    local text = langs[lang].permissions ..
                    langs[lang].permissionCanBeEdited .. tostring(obj_bot.can_promote_members or false) ..
                    langs[lang].permissionChangeInfo .. tostring(false) ..
                    langs[lang].permissionDeleteMessages .. tostring(false) ..
                    langs[lang].permissionInviteUsers .. tostring(false) ..
                    langs[lang].permissionPinMessages .. tostring(false) ..
                    langs[lang].permissionPromoteMembers .. tostring(false) ..
                    langs[lang].permissionRestrictMembers .. tostring(false)
                    return text
                else
                    return langs[lang].errorTryAgain
                end
            end
        end
    else
        return langs[lang].errorTryAgain
    end
end

-- begin RANKS MANAGEMENT
local function setOwner(user, chat_id)
    local lang = get_lang(chat_id)
    data[tostring(chat_id)].owner = tostring(user.id)
    save_data(config.moderation.data, data)
    if arePMNoticesEnabled(user.id, chat_id) then
        sendMessage(user.id, langs[get_lang(user.id)].youHaveBeenPromotedOwner .. database[tostring(chat_id)].print_name)
    end
    return(user.username or user.print_name or user.first_name) .. ' [' .. user.id .. ']' .. langs[lang].setOwner
end

local function getAdmins(chat_id)
    local list = getChatAdministrators(chat_id)
    if list then
        local text = ''
        for i, admin in pairs(list.result) do
            text = text ..(admin.user.username or admin.user.first_name) .. ' [' .. admin.user.id .. ']\n'
        end
        return text
    end
end

local function promoteTgAdmin(chat_id, user, permissions)
    local lang = get_lang(chat_id)
    if promoteChatMember(chat_id, user.id, permissions) then
        local promote = false
        for key, var in pairs(permissions) do
            if permissions[key] then
                promote = true
            end
        end
        if promote then
            data[tostring(chat_id)].moderators[tostring(user.id)] =(user.username or user.print_name or user.first_name)
            save_data(config.moderation.data, data)
            if arePMNoticesEnabled(user.id, chat_id) then
                sendMessage(user.id, langs[get_lang(user.id)].youHaveBeenPromotedAdmin .. database[tostring(chat_id)].print_name)
            end
            return(user.username or user.print_name or user.first_name) .. langs[lang].promoteModAdmin
        end
    else
        return langs[lang].checkMyPermissions
    end
end

local function demoteTgAdmin(chat_id, user)
    local lang = get_lang(chat_id)
    if demoteChatMember(chat_id, user.id) then
        if data[tostring(chat_id)].moderators[tostring(user.id)] then
            data[tostring(chat_id)].moderators[tostring(user.id)] = nil
            save_data(config.moderation.data, data)
        end
        if arePMNoticesEnabled(user.id, chat_id) then
            sendMessage(user.id, langs[get_lang(user.id)].youHaveBeenDemotedAdmin .. database[tostring(chat_id)].print_name)
        end
        return(user.username or user.print_name or user.first_name) .. langs[lang].demoteModAdmin
    else
        return langs[lang].checkMyPermissions
    end
end

local function promoteMod(chat_id, user)
    local lang = get_lang(chat_id)
    if data[tostring(chat_id)].moderators[tostring(user.id)] then
        return(user.username or user.print_name or user.first_name) .. langs[lang].alreadyMod
    end
    data[tostring(chat_id)].moderators[tostring(user.id)] =(user.username or user.print_name or user.first_name)
    save_data(config.moderation.data, data)
    if arePMNoticesEnabled(user.id, chat_id) then
        sendMessage(user.id, langs[get_lang(user.id)].youHaveBeenPromotedMod .. database[tostring(chat_id)].print_name)
    end
    return(user.username or user.print_name or user.first_name) .. langs[lang].promoteMod
end

local function demoteMod(chat_id, user)
    local lang = get_lang(chat_id)
    if not data[tostring(chat_id)].moderators[tostring(user.id)] then
        return(user.username or user.print_name or user.first_name) .. langs[lang].notMod
    end
    data[tostring(chat_id)].moderators[tostring(user.id)] = nil
    save_data(config.moderation.data, data)
    if arePMNoticesEnabled(user.id, chat_id) then
        sendMessage(user.id, langs[get_lang(user.id)].youHaveBeenDemotedMod .. database[tostring(chat_id)].print_name)
    end
    return(user.username or user.print_name or user.first_name) .. langs[lang].demoteMod
end

local function modList(chat_id, lang)
    if not data[tostring(chat_id)] then
        return langs[lang].groupNotAdded
    end
    -- determine if table is empty
    if next(data[tostring(chat_id)].moderators) == nil then
        -- fix way
        return langs[lang].noGroupMods
    end
    local i = 1
    local text = langs[lang].modListStart:gsub('X', data[tostring(chat_id)].name)
    for k, v in pairs(data[tostring(chat_id)].moderators) do
        text = text .. '\n' .. i .. '. ' .. v .. ' - ' .. k
        i = i + 1
    end
    return text
end
-- end RANKS MANAGEMENT

local max_lines = 20
local function logPages(chat_id, page)
    local text = ""
    if not page then
        page = 1
    end
    page = tonumber(page)
    local tot_lines = 0
    local f = assert(io.open("./groups/logs/" .. chat_id .. "log.txt", "rb"))
    local log = f:read("*all")
    f:close()
    local t = log:split('\n')
    local tmp = clone_table(t)
    for k, v in pairs(tmp) do
        if v ~= '' then
            tot_lines = tot_lines + 1
        else
            table.remove(t, k)
        end
    end
    local max_pages = math.floor(tot_lines / max_lines)
    if (tot_lines / max_lines) > math.floor(tot_lines / max_lines) then
        max_pages = max_pages + 1
    end
    if page > max_pages then
        page = max_pages
    end
    tot_lines = 0
    for k, v in pairs(t) do
        if v ~= '' then
            tot_lines = tot_lines + 1
            if tot_lines >=(((page - 1) * max_lines) + 1) and tot_lines <=(max_lines * page) then
                text = text .. v .. '\n'
            end
        end
    end
    return text
end

local function userPermissions(chat_id, user_id)
    local obj_user = getChatMember(chat_id, user_id)
    if type(obj_user) == 'table' then
        if obj_user.result then
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
    if obj_user then
        return adjustPermissions(obj_user)
    end
end

local function run(msg, matches)
    if msg.cb then
        if matches[2] == 'DELETE' then
            if not deleteMessage(msg.chat.id, msg.message_id, true) then
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
            end
        elseif matches[2] == 'PAGES' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].uselessButton, false)
        elseif matches[2] == 'BACKLOG' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
            editMessage(msg.chat.id, msg.message_id, logPages(matches[4], matches[3]), keyboard_log_pages(matches[4], matches[3]))
        elseif matches[2]:gsub('%d', '') == 'PAGEMINUS' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].turningPage)
            editMessage(msg.chat.id, msg.message_id, logPages(matches[4], tonumber(matches[3] or(tonumber(matches[2]:match('%d')) + 1)) - tonumber(matches[2]:match('%d'))), keyboard_log_pages(matches[4], tonumber(matches[3] or(tonumber(matches[2]:match('%d')) + 1)) - tonumber(matches[2]:match('%d'))))
        elseif matches[2]:gsub('%d', '') == 'PAGEPLUS' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].turningPage)
            editMessage(msg.chat.id, msg.message_id, logPages(matches[4], tonumber(matches[3] or(tonumber(matches[2]:match('%d')) -1)) + tonumber(matches[2]:match('%d'))), keyboard_log_pages(matches[4], tonumber(matches[3] or(tonumber(matches[2]:match('%d')) -1)) + tonumber(matches[2]:match('%d'))))
        elseif matches[2] == 'BACKPERMISSIONS' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
            local chat_name = ''
            if data[tostring(matches[4])] then
                chat_name = data[tostring(matches[4])].name or ''
            end
            editMessage(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. matches[4] .. ') ' .. chat_name), 'X', tostring('(' .. matches[3] .. ') ' ..(database[tostring(matches[3])]['print_name'] or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[15], keyboard_permissions_list(matches[4], matches[3], nil, matches[5] or false))
        elseif matches[2] == 'GRANT' then
            permissionsTable[tostring(matches[5])] = permissionsTable[tostring(matches[5])] or { }
            permissionsTable[tostring(matches[5])][tostring(matches[3])] = permissionsTable[tostring(matches[5])][tostring(matches[3])] or clone_table(default_permissions)
            answerCallbackQuery(msg.cb_id, langs[msg.lang].granted, false)
            local chat_name = ''
            if data[tostring(matches[5])] then
                chat_name = data[tostring(matches[5])].name or ''
            end
            permissionsTable[tostring(matches[5])][tostring(matches[3])][permissionsDictionary[matches[4]:lower()]] = true
            editMessage(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. matches[5] .. ') ' .. chat_name), 'X', tostring('(' .. matches[3] .. ') ' ..(database[tostring(matches[3])]['print_name'] or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[15], keyboard_permissions_list(matches[5], matches[3], permissionsTable[tostring(matches[5])][tostring(matches[3])], matches[6] or false))
            mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] .. matches[5])
        elseif matches[2] == 'DENY' then
            permissionsTable[tostring(matches[5])] = permissionsTable[tostring(matches[5])] or { }
            permissionsTable[tostring(matches[5])][tostring(matches[3])] = permissionsTable[tostring(matches[5])][tostring(matches[3])] or clone_table(default_permissions)
            answerCallbackQuery(msg.cb_id, langs[msg.lang].denied, false)
            local chat_name = ''
            if data[tostring(matches[5])] then
                chat_name = data[tostring(matches[5])].name or ''
            end
            permissionsTable[tostring(matches[5])][tostring(matches[3])][permissionsDictionary[matches[4]:lower()]] = false
            editMessage(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. matches[5] .. ') ' .. chat_name), 'X', tostring('(' .. matches[3] .. ') ' ..(database[tostring(matches[3])]['print_name'] or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[15], keyboard_permissions_list(matches[5], matches[3], permissionsTable[tostring(matches[5])][tostring(matches[3])], matches[6] or false))
            mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] .. matches[5])
        elseif matches[2] == 'PERMISSIONSDONE' then
            permissionsTable[tostring(matches[4])] = permissionsTable[tostring(matches[4])] or { }
            permissionsTable[tostring(matches[4])][tostring(matches[3])] = permissionsTable[tostring(matches[4])][tostring(matches[3])] or clone_table(default_permissions)
            if is_owner2(msg.from.id, matches[4]) then
                local obj_user = getChatMember(matches[4], matches[3])
                if type(obj_user) == 'table' then
                    if obj_user.result then
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
                if obj_user then
                    local res = promoteTgAdmin(matches[4], obj_user.user, permissionsTable[tostring(matches[4])][tostring(matches[3])])
                    if res ~= langs[get_lang(matches[4])].checkMyPermissions and res ~= langs[get_lang(matches[4])].notMyGroup then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].done, false)
                        permissionsTable[tostring(matches[4])][tostring(matches[3])] = nil
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].done)
                    else
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].checkMyPermissions, false)
                    end
                end
                mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
            else
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
            end
        elseif matches[2] == 'BACKSETTINGS' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
            local chat_name = ''
            if data[tostring(matches[4])] then
                chat_name = data[tostring(matches[4])].name or ''
            end
            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[4] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[4], matches[3], nil, matches[5] or false))
        elseif matches[2] == 'GOTOLOCKS' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].locksWord, false)
            local chat_name = ''
            if data[tostring(matches[3])] then
                chat_name = data[tostring(matches[3])].name or ''
            end
            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[3] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[3], 1, nil, matches[4] or false))
        elseif matches[2] == 'GOTOMUTES' then
            answerCallbackQuery(msg.cb_id, langs[msg.lang].mutesWord, false)
            local chat_name = ''
            if data[tostring(matches[3])] then
                chat_name = data[tostring(matches[3])].name or ''
            end
            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[3] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[3], 2, nil, matches[4] or false))
        elseif matches[2] == 'LOCK' then
            if is_mod2(msg.from.id, matches[5]) then
                if (groupDataDictionary[matches[3]:lower()] == 'groupnotices' or groupDataDictionary[matches[3]:lower()] == 'pmnotices' or groupDataDictionary[matches[3]:lower()] == 'tagalert') and not is_owner2(msg.from.id, matches[5]) then
                    return editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                end
                answerCallbackQuery(msg.cb_id, lockSetting(matches[5], matches[3]), false)
                local chat_name = ''
                if data[tostring(matches[5])] then
                    chat_name = data[tostring(matches[5])].name or ''
                end
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[5] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[5], matches[4], nil, matches[6] or false))
                mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] .. matches[5] ..(matches[6] or ''))
            else
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
            end
        elseif matches[2] == 'UNLOCK' then
            if is_mod2(msg.from.id, matches[5]) then
                if (groupDataDictionary[matches[3]:lower()] == 'groupnotices' or groupDataDictionary[matches[3]:lower()] == 'pmnotices' or groupDataDictionary[matches[3]:lower()] == 'tagalert') and not is_owner2(msg.from.id, matches[5]) then
                    return editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                end
                answerCallbackQuery(msg.cb_id, unlockSetting(matches[5], matches[3]), false)
                local chat_name = ''
                if data[tostring(matches[5])] then
                    chat_name = data[tostring(matches[5])].name or ''
                end
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[5] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[5], matches[4], nil, matches[6] or false))
                mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] .. matches[5] ..(matches[6] or ''))
            else
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
            end
        elseif matches[2] == 'FLOOD--' or matches[2] == 'FLOOD++' then
            if is_mod2(msg.from.id, matches[4]) then
                mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] ..(matches[5] or ''))
                local flood = data[tostring(matches[4])].settings.max_flood
                if matches[2] == 'FLOOD++' then
                    flood = flood + 1
                elseif matches[2] == 'FLOOD--' then
                    flood = flood - 1
                end
                if tonumber(flood) < 3 or tonumber(flood) > 20 then
                    return answerCallbackQuery(msg.cb_id, langs[msg.lang].errorFloodRange, false)
                end
                answerCallbackQuery(msg.cb_id, langs[msg.lang].floodSet .. flood, false)
                data[tostring(matches[4])].settings.max_flood = flood
                save_data(config.moderation.data, data)
                savelog(matches[4], msg.from.print_name .. " [" .. msg.from.id .. "] set flood to [" .. flood .. "]")
                local chat_name = ''
                if data[tostring(matches[4])] then
                    chat_name = data[tostring(matches[4])].name or ''
                end
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[4] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[4], matches[3], nil, matches[5] or false))
            else
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
            end
        elseif matches[2] == 'WARNS--' or matches[2] == 'WARNS++' then
            if is_mod2(msg.from.id, matches[4]) then
                mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] ..(matches[5] or ''))
                local warns = data[tostring(matches[4])].settings.max_warns
                if matches[2] == 'WARNS--' then
                    warns = warns - 1
                elseif matches[2] == 'WARNS++' then
                    warns = warns + 1
                end
                if tonumber(warns) < 1 or tonumber(warns) > 10 then
                    return answerCallbackQuery(msg.cb_id, langs[msg.lang].errorWarnRange, false)
                end
                answerCallbackQuery(msg.cb_id, langs[msg.lang].warnSet .. warns, false)
                data[tostring(matches[4])].settings.max_warns = warns
                save_data(config.moderation.data, data)
                savelog(matches[4], msg.from.print_name .. " [" .. msg.from.id .. "] set warns to [" .. warns .. "]")
                local chat_name = ''
                if data[tostring(matches[4])] then
                    chat_name = data[tostring(matches[4])].name or ''
                end
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[4] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[4], matches[3], nil, matches[5] or false))
            else
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
            end
        elseif matches[2] == 'time_ban' or matches[2] == 'time_restrict' then
            local time = tonumber(matches[3])
            local chat_name = ''
            if data[tostring(matches[5])] then
                chat_name = data[tostring(matches[5])].name or ''
            end
            if matches[4] == 'BACK' then
                answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                editMessage(msg.chat.id, msg.message_id, '(' .. matches[5] .. ')' .. chat_name .. langs[msg.lang].tempActionIntro, keyboard_time_punishments(matches[2], matches[5], time, matches[6] or false))
            elseif matches[4] == 'SECONDS' or matches[4] == 'MINUTES' or matches[4] == 'HOURS' or matches[4] == 'DAYS' or matches[4] == 'WEEKS' then
                local seconds, minutes, hours, days, weeks = unixToDate(time)
                if matches[4] == 'SECONDS' then
                    if tonumber(matches[5]) == 0 then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].secondsReset, false)
                        time = time - dateToUnix(seconds, 0, 0, 0, 0)
                    else
                        if (time + dateToUnix(tonumber(matches[5]), 0, 0, 0, 0)) >= 0 then
                            time = time + dateToUnix(tonumber(matches[5]), 0, 0, 0, 0)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTimeRange, true)
                        end
                    end
                elseif matches[4] == 'MINUTES' then
                    if tonumber(matches[5]) == 0 then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].minutesReset, false)
                        time = time - dateToUnix(0, minutes, 0, 0, 0)
                    else
                        if (time + dateToUnix(0, tonumber(matches[5]), 0, 0, 0)) >= 0 then
                            time = time + dateToUnix(0, tonumber(matches[5]), 0, 0, 0)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTimeRange, true)
                        end
                    end
                elseif matches[4] == 'HOURS' then
                    if tonumber(matches[5]) == 0 then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].hoursReset, false)
                        time = time - dateToUnix(0, 0, hours, 0, 0)
                    else
                        if (time + dateToUnix(0, 0, tonumber(matches[5]), 0, 0)) >= 0 then
                            time = time + dateToUnix(0, 0, tonumber(matches[5]), 0, 0)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTimeRange, true)
                        end
                    end
                elseif matches[4] == 'DAYS' then
                    if tonumber(matches[5]) == 0 then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].daysReset, false)
                        time = time - dateToUnix(0, 0, 0, days, 0)
                    else
                        if (time + dateToUnix(0, 0, 0, tonumber(matches[5]), 0)) >= 0 then
                            time = time + dateToUnix(0, 0, 0, tonumber(matches[5]), 0)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTimeRange, true)
                        end
                    end
                elseif matches[4] == 'WEEKS' then
                    if tonumber(matches[5]) == 0 then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].weeksReset, false)
                        time = time - dateToUnix(0, 0, 0, 0, weeks)
                    else
                        if (time + dateToUnix(0, 0, 0, 0, tonumber(matches[5]))) >= 0 then
                            time = time + dateToUnix(0, 0, 0, 0, tonumber(matches[5]))
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTimeRange, true)
                        end
                    end
                end
                editMessage(msg.chat.id, msg.message_id, '(' .. matches[6] .. ') ' .. chat_name .. langs[msg.lang].tempActionIntro, keyboard_time_punishments(matches[2], matches[6], time, matches[7] or false))
                mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] .. matches[5] .. matches[6] ..(matches[7] or ''))
            elseif matches[4] == 'DONE' then
                if time > 30 and time < dateToUnix(0, 0, 0, 366, 0) then
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].done, false)
                    data[tostring(matches[5])].settings[groupDataDictionary[matches[2]:lower()]] = time
                    save_data(config.moderation.data, data)
                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[5] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[5], 1, nil, matches[6] or false))
                else
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTimeRangePunishments, true)
                end
            end
        elseif matches[2]:match('^%d$') then
            -- change punishment
            if groupDataDictionary[matches[3]:lower()] then
                if (groupDataDictionary[matches[3]:lower()] == 'all' or groupDataDictionary[matches[3]:lower()] == 'text') and not is_owner2(msg.from.id, matches[5]) then
                    return editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                end
                local new_punishment = adjust_punishment(matches[3]:lower(), matches[2])
                answerCallbackQuery(msg.cb_id, setPunishment(matches[5], groupDataDictionary[matches[3]:lower()], new_punishment), false)
                savelog(matches[5], msg.from.print_name .. " [" .. msg.from.id .. "] set punishment of " .. groupDataDictionary[matches[3]:lower()] .. " to " .. tostring(new_punishment))
                local chat_name = ''
                if data[tostring(matches[5])] then
                    chat_name = data[tostring(matches[5])].name or ''
                end
                editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[5] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[5], matches[4], nil, matches[6] or false))
                mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] .. matches[5] ..(matches[6] or ''))
            else
                answerCallbackQuery(msg.cb_id, langs[msg.lang].settingNotFound, true)
            end
        else
            if groupDataDictionary[matches[2]:lower()] then
                local updatePunishment = false
                if matches[3] then
                    if matches[3]:match('%d') then
                        updatePunishment = true
                    end
                end
                if updatePunishment then
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].selectNewPunishment, false)
                    local chat_name = ''
                    if data[tostring(matches[4])] then
                        chat_name = data[tostring(matches[4])].name or ''
                    end
                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[4] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[4], matches[3], groupDataDictionary[matches[2]:lower()], matches[5] or false))
                    mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] ..(matches[5] or ''))
                else
                    -- info of variable
                    mystat(matches[1] .. matches[2] ..(matches[3] or ''))
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].settingsDictionary[groupDataDictionary[matches[2]:lower()]], true)
                end
            else
                answerCallbackQuery(msg.cb_id, langs[msg.lang].settingNotFound, true)
            end
        end
        return
    end

    if matches[1]:lower() == 'log' then
        if msg.from.is_owner then
            mystat('/log')
            if sendKeyboard(msg.from.id, logPages(msg.chat.id), keyboard_log_pages(msg.chat.id)) then
                savelog(msg.chat.id, "log keyboard requested by owner/admin")
                if msg.chat.type ~= 'private' then
                    local message_id = sendReply(msg, langs[msg.lang].sendLogPvt, 'html').result.message_id
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                    return
                end
            else
                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
            end
        else
            return langs[msg.lang].require_owner
        end
    end
    if matches[1]:lower() == 'sendlog' then
        if msg.from.is_owner then
            mystat('/log')
            savelog(msg.chat.id, "log file created by owner/admin")
            return sendDocument(msg.chat.id, "./groups/logs/" .. msg.chat.id .. "log.txt")
        else
            return langs[msg.lang].require_owner
        end
    end
    if matches[1]:lower() == 'admin' or matches[1]:lower() == 'admins' then
        mystat('/admins')
        if not cronTable.adminsContacted[tostring(msg.chat.id)] or is_admin(msg) then
            cronTable.adminsContacted[tostring(msg.chat.id)] = true
            local hashtag = '#admins' .. tostring(msg.message_id)
            local chat_name = msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']'
            local group_link = data[tostring(msg.chat.id)].link
            if group_link then
                chat_name = "<a href=\"" .. group_link .. "\">" .. html_escape(chat_name) .. "</a>"
            end
            local text = langs[msg.lang].receiver .. chat_name .. '\n' .. langs[msg.lang].sender
            if msg.from.username then
                text = text .. '@' .. msg.from.username .. ' [' .. msg.from.id .. ']\n'
            else
                text = text .. html_escape(msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']\n')
            end
            text = text .. langs[msg.lang].msgText .. html_escape(msg.text or '') .. '\n' ..
            'HASHTAG: ' .. hashtag
            text = text:gsub('"', '\\"')
            if msg.reply then
                io.popen('lua timework.lua "contactadmins" "0.5" "' .. msg.chat.id .. '" "' .. msg.reply_to_message.message_id .. '" "' .. hashtag .. '" "' .. text .. '"')
            else
                io.popen('lua timework.lua "contactadmins" "0.5" "' .. msg.chat.id .. '" "false" "' .. hashtag .. '" "' .. text .. '"')
            end
            return
        else
            if not cronTable.noticeContacted[tostring(msg.chat.id)] then
                cronTable.noticeContacted[tostring(msg.chat.id)] = true
                return langs[msg.lang].dontFloodAdmins
            end
        end
    end

    -- INGROUP/SUPERGROUP
    if (msg.chat.type == 'group' or msg.chat.type == 'supergroup') and data[tostring(msg.chat.id)] then
        if matches[1]:lower() == 'rules' then
            mystat('/rules')
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group rules")
            if msg.from.is_mod then
                local tmp = oldResponses.lastRules[tostring(msg.chat.id)]
                if not data[tostring(msg.chat.id)].rules then
                    oldResponses.lastRules[tostring(msg.chat.id)] = sendReply(msg, langs[msg.lang].noRules)
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' ..(oldResponses.lastRules[tostring(msg.chat.id)].result.message_id or '') .. '"')
                else
                    oldResponses.lastRules[tostring(msg.chat.id)] = sendReply(msg, langs[msg.lang].rules:gsub('X', msg.chat.title) .. '\n' .. data[tostring(msg.chat.id)].rules)
                end
                if oldResponses.lastRules[tostring(msg.chat.id)] then
                    if oldResponses.lastRules[tostring(msg.chat.id)].result then
                        if oldResponses.lastRules[tostring(msg.chat.id)].result.message_id then
                            oldResponses.lastRules[tostring(msg.chat.id)] = oldResponses.lastRules[tostring(msg.chat.id)].result.message_id
                        else
                            oldResponses.lastRules[tostring(msg.chat.id)] = nil
                        end
                    else
                        oldResponses.lastRules[tostring(msg.chat.id)] = nil
                    end
                end
                if tmp then
                    deleteMessage(msg.chat.id, tmp, true)
                end
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                return
            else
                local txt = ''
                if not data[tostring(msg.chat.id)].rules then
                    txt = langs[msg.lang].noRules
                else
                    txt = langs[msg.lang].rules:gsub('X', msg.chat.title) .. '\n' .. data[tostring(msg.chat.id)].rules
                end
                local tmp = ''
                if not sendMessage(msg.from.id, txt) then
                    tmp = sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id).result.message_id
                else
                    tmp = sendReply(msg, langs[msg.lang].generalSendPvt, 'html').result.message_id
                end
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
            end
            return
        end
        if matches[1]:lower() == 'updategroupinfo' then
            if msg.from.is_mod then
                mystat('/upgradegroupinfo')
                data[tostring(msg.chat.id)].name = string.gsub(msg.chat.print_name, '_', ' ')
                local list = getChatAdministrators(msg.chat.id)
                if list then
                    if list.result then
                        for i, admin in pairs(list.result) do
                            if admin.status == 'creator' or admin.status == 'administrator' then
                                if admin.user.id ~= bot.userVersion.id and admin.user.id ~= bot.id then
                                    data[tostring(msg.chat.id)].moderators[tostring(admin.user.id)] =(admin.user.username or(admin.user.first_name ..(admin.user.last_name or '')))
                                end
                            end
                        end
                    end
                end
                save_data(config.moderation.data, data)
                return langs[msg.lang].groupInfoUpdated
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'syncmodlist' then
            if msg.from.is_owner then
                mystat('/syncmodlist')
                data[tostring(msg.chat.id)].moderators = { }
                local list = getChatAdministrators(msg.chat.id)
                if list then
                    if list.result then
                        for i, admin in pairs(list.result) do
                            if admin.status == 'creator' or admin.status == 'administrator' then
                                if admin.user.id ~= bot.userVersion.id and admin.user.id ~= bot.id then
                                    data[tostring(msg.chat.id)].moderators[tostring(admin.user.id)] =(admin.user.username or(admin.user.first_name ..(admin.user.last_name or '')))
                                end
                            end
                        end
                    end
                end
                save_data(config.moderation.data, data)
                return langs[msg.lang].modListSynced
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'setrules' then
            mystat('/setrules')
            if msg.from.is_mod then
                data[tostring(msg.chat.id)].rules = matches[2]
                save_data(config.moderation.data, data)
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] has changed group rules to [" .. matches[2] .. "]")
                return langs[msg.lang].newRules .. matches[2]
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'setflood' then
            if msg.from.is_mod then
                if tonumber(matches[2]) < 3 or tonumber(matches[2]) > 20 then
                    return langs[msg.lang].errorFloodRange
                end
                mystat('/setflood')
                data[tostring(msg.chat.id)].settings.max_flood = matches[2]
                save_data(config.moderation.data, data)
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set flood to [" .. matches[2] .. "]")
                return langs[msg.lang].floodSet .. matches[2]
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'getwarn' then
            mystat('/getwarn')
            if msg.from.is_mod then
                return getWarn(msg.chat.id)
            else
                local tmp = ''
                if not sendMessage(msg.from.id, getWarn(msg.chat.id)) then
                    tmp = sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id).result.message_id
                else
                    tmp = sendReply(msg, langs[msg.lang].generalSendPvt, 'html').result.message_id
                end
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
            end
            return
        end
        if matches[1]:lower() == 'setwarn' and matches[2] then
            if msg.from.is_mod then
                mystat('/setwarn')
                if tonumber(matches[2]) < 1 or tonumber(matches[2]) > 10 then
                    return langs[msg.lang].errorWarnRange
                end
                data[tostring(msg.chat.id)].settings.max_warns = tonumber(matches[2])
                save_data(config.moderation.data, data)
                savelog(msg.chat.id, " [" .. msg.from.id .. "] set warn to [" .. matches[2] .. "]")
                return langs[msg.lang].warnSet .. matches[2]
            else
                return langs[msg.msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'settitle' then
            if msg.from.is_mod then
                mystat('/settitle')
                return setChatTitle(msg.chat.id, matches[2])
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'setdescription' then
            if msg.from.is_mod then
                mystat('/setdescription')
                return setChatDescription(msg.chat.id, matches[2])
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'setphoto' then
            if msg.from.is_mod then
                if msg.reply then
                    if msg.reply_to_message.media then
                        local file_id = ''
                        local caption = matches[3] or ''
                        if msg.reply_to_message.media_type == 'photo' then
                            local bigger_pic_id = ''
                            local size = 0
                            for k, v in pairsByKeys(msg.reply_to_message.photo) do
                                if v.file_size then
                                    if v.file_size > size then
                                        size = v.file_size
                                        bigger_pic_id = v.file_id
                                    end
                                end
                            end
                            file_id = bigger_pic_id
                            mystat('/setphoto')
                            return setChatPhotoId(msg.chat.id, file_id)
                        else
                            return langs[msg.lang].needPhoto
                        end
                    else
                        return langs[msg.lang].needPhoto
                    end
                else
                    return langs[msg.lang].needReply
                end
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'unsetphoto' then
            if msg.from.is_mod then
                mystat('/unsetphoto')
                return deleteChatPhoto(msg.chat.id)
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'silentpin' then
            if msg.from.is_mod then
                if msg.reply then
                    mystat('/silentpin')
                    if pinChatMessage(msg.chat.id, msg.reply_to_message.message_id) then
                        return sendMessage(msg.chat.id, '#pin' .. tostring(msg.chat.id):gsub('-', ''))
                    end
                else
                    return langs[msg.lang].needReply
                end
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'pin' then
            if msg.from.is_mod then
                if msg.reply then
                    mystat('/pin')
                    if pinChatMessage(msg.chat.id, msg.reply_to_message.message_id, true) then
                        return sendMessage(msg.chat.id, '#pin' .. tostring(msg.chat.id):gsub('-', ''))
                    end
                else
                    return langs[msg.lang].needReply
                end
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'unpin' then
            if msg.from.is_mod then
                mystat('/unpin')
                return unpinChatMessage(msg.chat.id)
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'del' then
            if msg.from.is_mod then
                mystat('/del')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] deleted a message")
                if not deleteMessage(msg.chat.id, msg.message_id, true) then
                    -- sendMessage(msg.chat.id, langs[msg.lang].cantDeleteMessage)
                end
                if msg.reply then
                    if not deleteMessage(msg.chat.id, msg.reply_to_message.message_id, true) then
                        sendMessage(msg.chat.id, langs[msg.lang].cantDeleteMessage)
                    end
                end
            else
                return langs[msg.lang].require_mod
            end
            return
        end
        if matches[1]:lower() == 'delfrom' then
            if msg.from.is_mod then
                if msg.reply then
                    if msg.reply_to_message.date > os.time() - dateToUnix(0, 0, 48, 0, 0) then
                        mystat('/delfrom')
                        delAll[tostring(msg.chat.id)] = delAll[tostring(msg.chat.id)] or { }
                        delAll[tostring(msg.chat.id)].from = msg.reply_to_message.message_id
                        local message_id = sendReply(msg, langs[msg.lang].ok).result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                    else
                        return langs[msg.lang].messageTooOld
                    end
                else
                    return langs[msg.lang].needReply
                end
            else
                return langs[msg.lang].require_mod
            end
            return
        end
        if matches[1]:lower() == 'delto' then
            if msg.from.is_mod then
                mystat('/delto')
                delAll[tostring(msg.chat.id)] = delAll[tostring(msg.chat.id)] or { }
                if msg.reply then
                    delAll[tostring(msg.chat.id)].to = msg.reply_to_message.message_id
                else
                    delAll[tostring(msg.chat.id)].to = msg.message_id
                end
                local message_id = sendReply(msg, langs[msg.lang].ok).result.message_id
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
            else
                return langs[msg.lang].require_mod
            end
            return
        end
        if matches[1]:lower() == 'delall' then
            if msg.from.is_mod then
                if delAll[tostring(msg.chat.id)] then
                    if delAll[tostring(msg.chat.id)].from and delAll[tostring(msg.chat.id)].to then
                        if delAll[tostring(msg.chat.id)].to > delAll[tostring(msg.chat.id)].from then
                            if delAll[tostring(msg.chat.id)].to - delAll[tostring(msg.chat.id)].from > 70 and msg.from.is_owner then
                                mystat('/delall')
                                local counter = 1
                                local t = { }
                                for i = delAll[tostring(msg.chat.id)].from, delAll[tostring(msg.chat.id)].to do
                                    -- 10 Deletion of per second
                                    t[counter] = t[counter] or ''
                                    t[counter] = t[counter] .. i .. ','
                                    if i - delAll[tostring(msg.chat.id)].from > counter * 10 then
                                        counter = counter + 1
                                    end
                                end
                                local time = 1
                                for key, var in pairs(t) do
                                    time = time + 5
                                    io.popen('lua timework.lua "deletemessage" "' .. time .. '" "' .. msg.chat.id .. '" "' .. var:sub(1, -2) .. '"')
                                end
                                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] deleted all messages from " .. delAll[tostring(msg.chat.id)].from .. " to " .. delAll[tostring(msg.chat.id)].to)
                                local message_id = sendReply(msg, langs[msg.lang].deletingMessages).result.message_id
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                            elseif delAll[tostring(msg.chat.id)].to - delAll[tostring(msg.chat.id)].from <= 70 then
                                mystat('/delall')
                                for i = delAll[tostring(msg.chat.id)].from, delAll[tostring(msg.chat.id)].to do
                                    local rndtime = math.random(1, 15)
                                    io.popen('lua timework.lua "deletemessage" "' .. rndtime .. '" "' .. msg.chat.id .. '" "' .. i .. '"')
                                end
                                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] deleted all messages from " .. delAll[tostring(msg.chat.id)].from .. " to " .. delAll[tostring(msg.chat.id)].to)
                                local message_id = sendReply(msg, langs[msg.lang].deletingMessages).result.message_id
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                            else
                                return langs[msg.lang].errorDelall
                            end
                        else
                            return langs[msg.lang].errorDelall
                        end
                    else
                        return langs[msg.lang].errorDelall
                    end
                else
                    return langs[msg.lang].errorDelall
                end
            else
                return langs[msg.lang].require_mod
            end
            return
        end
        if matches[1]:lower() == 'delkeyboard' then
            if msg.reply then
                if msg.reply_to_message.from.id == bot.id then
                    if msg.reply_to_message.text or msg.reply_to_message.caption then
                        if msg.from.is_mod then
                            mystat('/delkeyboard')
                            return editMessage(msg.chat.id, msg.reply_to_message.message_id, msg.reply_to_message.text or msg.reply_to_message.caption)
                        else
                            return langs[msg.lang].require_mod
                        end
                    end
                else
                    return langs[msg.lang].cantDeleteMessage
                end
            else
                return langs[msg.lang].needReply
            end
            return
        end
        if matches[1]:lower() == 'settimerestrict' then
            if matches[2] then
                if matches[3] and matches[4] and matches[5] and matches[6] then
                    local unix = dateToUnix(matches[6], matches[5], matches[4], matches[3], matches[2])
                    if unix > 30 and unix < dateToUnix(0, 0, 0, 366, 0) then
                        data[tostring(msg.chat.id)].settings['time_restrict'] = unix
                        save_data(config.moderation.data, data)
                        return langs[msg.lang].done
                    else
                        return langs[msg.lang].errorTimeRangePunishments
                    end
                else
                    if tonumber(matches[2]) > 30 and tonumber(matches[2]) < dateToUnix(0, 0, 0, 366, 0) then
                        data[tostring(msg.chat.id)].settings['time_restrict'] = tonumber(matches[2])
                        save_data(config.moderation.data, data)
                        return langs[msg.lang].done
                    else
                        return langs[msg.lang].errorTimeRangePunishments
                    end
                end
            else
                if sendKeyboard(msg.from.id, '(' .. msg.chat.id .. ') ' .. msg.chat.title .. langs[msg.lang].tempActionIntro, keyboard_time_punishments('time_restrict', msg.chat.id, data[tostring(msg.chat.id)].settings.time_restrict)) then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested to change time_restrict ")
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendKeyboardPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
            end
        end
        if matches[1]:lower() == 'settimeban' then
            if matches[2] then
                if matches[3] and matches[4] and matches[5] and matches[6] then
                    local unix = dateToUnix(matches[6], matches[5], matches[4], matches[3], matches[2])
                    if unix > 30 and unix < dateToUnix(0, 0, 0, 366, 0) then
                        data[tostring(msg.chat.id)].settings['time_ban'] = unix
                        save_data(config.moderation.data, data)
                        return langs[msg.lang].done
                    else
                        return langs[msg.lang].errorTimeRangePunishments
                    end
                else
                    if tonumber(matches[2]) > 30 and tonumber(matches[2]) < dateToUnix(0, 0, 0, 366, 0) then
                        data[tostring(msg.chat.id)].settings['time_ban'] = tonumber(matches[2])
                        save_data(config.moderation.data, data)
                        return langs[msg.lang].done
                    else
                        return langs[msg.lang].errorTimeRangePunishments
                    end
                end
            else
                if sendKeyboard(msg.from.id, '(' .. msg.chat.id .. ') ' .. msg.chat.title .. langs[msg.lang].tempActionIntro, keyboard_time_punishments('time_ban', msg.chat.id, data[tostring(msg.chat.id)].settings.time_ban)) then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested to change time_ban ")
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendKeyboardPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
            end
        end
        if matches[1]:lower() == 'lock' then
            if msg.from.is_mod then
                if groupDataDictionary[matches[2]:lower()] then
                    mystat('/lock ' .. matches[2]:lower() .. ' ' ..(matches[3] or ''):lower())
                    if (groupDataDictionary[matches[2]:lower()] == 'groupnotices' or groupDataDictionary[matches[2]:lower()] == 'pmnotices' or groupDataDictionary[matches[2]:lower()] == 'tagalert' or groupDataDictionary[matches[2]:lower()] == 'all' or groupDataDictionary[matches[2]:lower()] == 'text') and not msg.from.is_owner then
                        return langs[msg.lang].require_owner
                    end
                    return lockSetting(msg.chat.id, matches[2]:lower(),(matches[3] or ''):lower())
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'unlock' then
            if msg.from.is_mod then
                if groupDataDictionary[matches[2]:lower()] then
                    mystat('/unlock ' .. matches[2]:lower())
                    if (groupDataDictionary[matches[2]:lower()] == 'groupnotices' or groupDataDictionary[matches[2]:lower()] == 'pmnotices' or groupDataDictionary[matches[2]:lower()] == 'tagalert' or groupDataDictionary[matches[2]:lower()] == 'all' or groupDataDictionary[matches[2]:lower()] == 'text') and not msg.from.is_owner then
                        return langs[msg.lang].require_owner
                    end
                    return unlockSetting(msg.chat.id, matches[2]:lower())
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'mute' then
            if msg.from.is_mod then
                if groupDataDictionary[matches[2]:lower()] then
                    mystat('/mute ' .. matches[2]:lower() .. ' ' ..(matches[3] or ''):lower())
                    if (groupDataDictionary[matches[2]:lower()] == 'groupnotices' or groupDataDictionary[matches[2]:lower()] == 'pmnotices' or groupDataDictionary[matches[2]:lower()] == 'tagalert' or groupDataDictionary[matches[2]:lower()] == 'all' or groupDataDictionary[matches[2]:lower()] == 'text') and not msg.from.is_owner then
                        return langs[msg.lang].require_owner
                    end
                    return lockSetting(msg.chat.id, matches[2]:lower(),(matches[3] or ''):lower())
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'unmute' then
            if msg.from.is_mod then
                if groupDataDictionary[matches[2]:lower()] then
                    mystat('/unmute ' .. matches[2]:lower())
                    if (groupDataDictionary[matches[2]:lower()] == 'groupnotices' or groupDataDictionary[matches[2]:lower()] == 'pmnotices' or groupDataDictionary[matches[2]:lower()] == 'tagalert' or groupDataDictionary[matches[2]:lower()] == 'all' or groupDataDictionary[matches[2]:lower()] == 'text') and not msg.from.is_owner then
                        return langs[msg.lang].require_owner
                    end
                    return unlockSetting(msg.chat.id, matches[2]:lower())
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'muteslist' then
            mystat('/muteslist')
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist")
            if msg.from.is_mod then
                local chat_name = ''
                if data[tostring(msg.chat.id)] then
                    chat_name = data[tostring(msg.chat.id)].name or ''
                end
                if sendKeyboard(msg.from.id, langs[msg.lang].mutesOf .. '(' .. msg.chat.id .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(msg.chat.id, 2)) then
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendMutesPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
            else
                local tmp = ''
                if not sendMessage(msg.from.id, showSettings(msg.chat.id, msg.lang)) then
                    tmp = sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id).result.message_id
                else
                    tmp = sendReply(msg, langs[msg.lang].generalSendPvt, 'html').result.message_id
                end
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
            end
            return
        end
        if matches[1]:lower() == 'textualmuteslist' then
            mystat('/muteslist')
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist")
            if msg.from.is_mod then
                local tmp = oldResponses.lastSettings[tostring(msg.chat.id)]
                oldResponses.lastSettings[tostring(msg.chat.id)] = sendReply(msg, showSettings(msg.chat.id, msg.lang))
                if oldResponses.lastSettings[tostring(msg.chat.id)] then
                    if oldResponses.lastSettings[tostring(msg.chat.id)].result then
                        if oldResponses.lastSettings[tostring(msg.chat.id)].result.message_id then
                            oldResponses.lastSettings[tostring(msg.chat.id)] = oldResponses.lastSettings[tostring(msg.chat.id)].result.message_id
                        else
                            oldResponses.lastSettings[tostring(msg.chat.id)] = nil
                        end
                    else
                        oldResponses.lastSettings[tostring(msg.chat.id)] = nil
                    end
                end
                if tmp then
                    deleteMessage(msg.chat.id, tmp, true)
                end
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
            else
                local tmp = ''
                if not sendMessage(msg.from.id, showSettings(msg.chat.id, msg.lang)) then
                    tmp = sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id).result.message_id
                else
                    tmp = sendReply(msg, langs[msg.lang].generalSendPvt, 'html').result.message_id
                end
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
            end
            return
        end
        if matches[1]:lower() == 'settings' then
            mystat('/settings')
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group settings ")
            if msg.from.is_mod then
                local chat_name = ''
                if data[tostring(msg.chat.id)] then
                    chat_name = data[tostring(msg.chat.id)].name or ''
                end
                if sendKeyboard(msg.from.id, langs[msg.lang].settingsOf .. '(' .. msg.chat.id .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(msg.chat.id, 1)) then
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendSettingsPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
            else
                local tmp = ''
                if not sendMessage(msg.from.id, showSettings(msg.chat.id, msg.lang)) then
                    tmp = sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id).result.message_id
                else
                    tmp = sendReply(msg, langs[msg.lang].generalSendPvt, 'html').result.message_id
                end
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
            end
            return
        end
        if matches[1]:lower() == 'textualsettings' then
            mystat('/settings')
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group settings ")
            if msg.from.is_mod then
                local tmp = oldResponses.lastSettings[tostring(msg.chat.id)]
                oldResponses.lastSettings[tostring(msg.chat.id)] = sendReply(msg, showSettings(msg.chat.id, msg.lang))
                if oldResponses.lastSettings[tostring(msg.chat.id)] then
                    if oldResponses.lastSettings[tostring(msg.chat.id)].result then
                        if oldResponses.lastSettings[tostring(msg.chat.id)].result.message_id then
                            oldResponses.lastSettings[tostring(msg.chat.id)] = oldResponses.lastSettings[tostring(msg.chat.id)].result.message_id
                        else
                            oldResponses.lastSettings[tostring(msg.chat.id)] = nil
                        end
                    else
                        oldResponses.lastSettings[tostring(msg.chat.id)] = nil
                    end
                end
                if tmp then
                    deleteMessage(msg.chat.id, tmp, true)
                end
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
            else
                local tmp = ''
                if not sendMessage(msg.from.id, showSettings(msg.chat.id, msg.lang)) then
                    tmp = sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id).result.message_id
                else
                    tmp = sendReply(msg, langs[msg.lang].generalSendPvt, 'html').result.message_id
                end
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
            end
            return
        end
        if matches[1]:lower() == 'newlink' then
            if msg.from.is_mod then
                mystat('/newlink')
                local link = exportChatInviteLink(msg.chat.id, true)
                if link then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] created new group link [" .. tostring(link) .. "]")
                    data[tostring(msg.chat.id)].link = tostring(link)
                    save_data(config.moderation.data, data)
                    return langs[msg.lang].linkCreated
                else
                    return langs[msg.lang].sendMeLink
                end
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'setlink' and matches[2] then
            if msg.from.is_owner then
                mystat('/setlink')
                data[tostring(msg.chat.id)].link = matches[2]
                save_data(config.moderation.data, data)
                return langs[msg.lang].linkSaved
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'unsetlink' then
            if msg.from.is_owner then
                mystat('/unsetlink')
                data[tostring(msg.chat.id)].link = nil
                save_data(config.moderation.data, data)
                return langs[msg.lang].linkDeleted
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'link' then
            mystat('/link')
            if data[tostring(msg.chat.id)].settings.lock_grouplink then
                if msg.from.is_mod then
                    if data[tostring(msg.chat.id)].link then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group link [" .. data[tostring(msg.chat.id)].link .. "]")
                        if sendMessage(msg.from.id, "<a href=\"" .. data[tostring(msg.chat.id)].link .. "\">" .. html_escape(msg.chat.title) .. "</a>", 'html') then
                            if msg.chat.type ~= 'private' then
                                return sendReply(msg, langs[msg.lang].sendLinkPvt, 'html')
                            end
                        else
                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                        end
                    else
                        return langs[msg.lang].createLink
                    end
                else
                    return langs[msg.lang].require_mod
                end
            else
                if data[tostring(msg.chat.id)].link then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group link [" .. data[tostring(msg.chat.id)].link .. "]")
                    return sendReply(msg, "<a href=\"" .. data[tostring(msg.chat.id)].link .. "\">" .. html_escape(msg.chat.title) .. "</a>", 'html')
                else
                    return langs[msg.lang].createLink
                end
            end
        end
        if matches[1]:lower() == 'getadmins' then
            if msg.from.is_owner then
                mystat('/getadmins')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup Admins list")
                return getAdmins(msg.chat.id)
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'owner' then
            mystat('/owner')
            local group_owner = data[tostring(msg.chat.id)].owner
            if not group_owner then
                return langs[msg.lang].noOwnerCallAdmin
            end
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] used /owner")
            return langs[msg.lang].ownerIs .. group_owner
        end
        if matches[1]:lower() == 'setowner' then
            if msg.from.is_owner then
                mystat('/setowner')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return setOwner(msg.reply_to_message.forward_from, msg.chat.id)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return setOwner(msg.reply_to_message.from, msg.chat.id)
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set [" .. msg.entities[k].user.id .. "] as owner")
                                    return setOwner(msg.entities[k].user, msg.chat.id)
                                end
                            end
                        end
                    end
                    matches[2] = tostring(matches[2]):gsub(' ', '')
                    if string.match(matches[2], '^%d+$') then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set [" .. matches[2] .. "] as owner")
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return setOwner(obj_user, msg.chat.id)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return setOwner(obj_user, msg.chat.id)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'modlist' then
            mystat('/modlist')
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group modlist")
            if msg.from.is_mod then
                local tmp = oldResponses.lastModlist[tostring(msg.chat.id)]
                oldResponses.lastModlist[tostring(msg.chat.id)] = sendReply(msg, modList(msg.chat.id, msg.lang))
                if oldResponses.lastModlist[tostring(msg.chat.id)] then
                    if oldResponses.lastModlist[tostring(msg.chat.id)].result then
                        if oldResponses.lastModlist[tostring(msg.chat.id)].result.message_id then
                            oldResponses.lastModlist[tostring(msg.chat.id)] = oldResponses.lastModlist[tostring(msg.chat.id)].result.message_id
                        else
                            oldResponses.lastModlist[tostring(msg.chat.id)] = nil
                        end
                    else
                        oldResponses.lastModlist[tostring(msg.chat.id)] = nil
                    end
                end
                if tmp then
                    deleteMessage(msg.chat.id, tmp, true)
                end
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
            else
                local tmp = ''
                if not sendMessage(msg.from.id, modList(msg.chat.id, msg.lang)) then
                    tmp = sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id).result.message_id
                else
                    tmp = sendReply(msg, langs[msg.lang].generalSendPvt, 'html').result.message_id
                end
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
            end
            return
        end
        if matches[1]:lower() == 'promoteadmin' then
            if msg.from.is_owner then
                mystat('/promoteadmin')
                local permissions = clone_table(default_permissions)
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    if matches[3] then
                                        permissions = adjustPermissions(matches[3]:lower())
                                    end
                                    return promoteTgAdmin(msg.chat.id, msg.reply_to_message.forward_from, permissions)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        else
                            if matches[2] then
                                permissions = adjustPermissions(matches[2]:lower())
                            end
                            return promoteTgAdmin(msg.chat.id, msg.reply_to_message.from, permissions)
                        end
                    else
                        if matches[2] then
                            permissions = adjustPermissions(matches[2]:lower())
                        end
                        return promoteTgAdmin(msg.chat.id, msg.reply_to_message.from, permissions)
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    if matches[3] then
                                        permissions = adjustPermissions(matches[3]:lower())
                                    end
                                    return promoteTgAdmin(msg.chat.id, msg.entities[k].user, permissions)
                                end
                            end
                        end
                    end
                    matches[2] = tostring(matches[2]):gsub(' ', '')
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    if matches[3] then
                                        permissions = adjustPermissions(matches[3]:lower())
                                    end
                                    return promoteTgAdmin(msg.chat.id, obj_user, permissions)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                if matches[3] then
                                    permissions = adjustPermissions(matches[3]:lower())
                                end
                                return promoteTgAdmin(msg.chat.id, obj_user, permissions)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'demoteadmin' then
            if msg.from.is_owner then
                mystat('/demoteadmin')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return demoteTgAdmin(msg.chat.id, msg.reply_to_message.forward_from)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return demoteTgAdmin(msg.chat.id, msg.reply_to_message.from)
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return demoteTgAdmin(msg.chat.id, msg.entities[k].user)
                                end
                            end
                        end
                    end
                    matches[2] = tostring(matches[2]):gsub(' ', '')
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return demoteTgAdmin(msg.chat.id, obj_user)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return demoteTgAdmin(msg.chat.id, obj_user)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'promote' then
            if msg.from.is_owner then
                mystat('/promote')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return promoteMod(msg.chat.id, msg.reply_to_message.forward_from)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return promoteMod(msg.chat.id, msg.reply_to_message.from)
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return promoteMod(msg.chat.id, msg.entities[k].user)
                                end
                            end
                        end
                    end
                    matches[2] = tostring(matches[2]):gsub(' ', '')
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return promoteMod(msg.chat.id, obj_user)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return promoteMod(msg.chat.id, obj_user)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'demote' then
            if msg.from.is_owner then
                mystat('/demote')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return demoteMod(msg.chat.id, msg.reply_to_message.forward_from)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return demoteMod(msg.chat.id, msg.reply_to_message.from)
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return demoteMod(msg.chat.id, msg.entities[k].user)
                                end
                            end
                        end
                    end
                    matches[2] = tostring(matches[2]):gsub(' ', '')
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return demoteMod(msg.chat.id, obj_user)
                                else
                                    return langs[msg.lang].noObject .. '\n' .. demoteMod(msg.chat.id, { username = "Unknown", id = matches[2] })
                                end
                            else
                                return langs[msg.lang].noObject .. '\n' .. demoteMod(msg.chat.id, { username = "Unknown", id = matches[2] })
                            end
                        else
                            return langs[msg.lang].noObject .. '\n' .. demoteMod(msg.chat.id, { username = "Unknown", id = matches[2] })
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return demoteMod(msg.chat.id, obj_user)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'permissions' then
            mystat('/permissions')
            local chat_name = ''
            if data[tostring(msg.chat.id)] then
                chat_name = data[tostring(msg.chat.id)].name or ''
            end
            permissionsTable[tostring(msg.chat.id)] = permissionsTable[tostring(msg.chat.id)] or { }
            if msg.reply then
                if msg.from.is_mod then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. msg.reply_to_message.forward_from.id .. ') ' .. msg.reply_to_message.forward_from.first_name .. ' ' ..(msg.reply_to_message.forward_from.last_name or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[15], keyboard_permissions_list(msg.chat.id, msg.reply_to_message.forward_from.id)) then
                                        permissionsTable[tostring(msg.chat.id)][tostring(msg.reply_to_message.forward_from.id)] = userPermissions(msg.chat.id, msg.reply_to_message.forward_from.id)
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendPermissionsPvt, 'html').result.message_id
                                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                    end
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. msg.reply_to_message.from.id .. ') ' .. msg.reply_to_message.from.first_name .. ' ' ..(msg.reply_to_message.from.last_name or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[15], keyboard_permissions_list(msg.chat.id, msg.reply_to_message.from.id)) then
                            permissionsTable[tostring(msg.chat.id)][tostring(msg.reply_to_message.from.id)] = userPermissions(msg.chat.id, msg.reply_to_message.from.id)
                            if msg.chat.type ~= 'private' then
                                local message_id = sendReply(msg, langs[msg.lang].sendPermissionsPvt, 'html').result.message_id
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                                return
                            end
                        else
                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                        end
                    end
                else
                    return langs[msg.lang].require_mod
                end
            elseif matches[2] and matches[2] ~= '' then
                if msg.from.is_mod then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. msg.entities[k].user.id .. ') ' .. msg.entities[k].user.first_name .. ' ' ..(msg.entities[k].user.last_name or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[15], keyboard_permissions_list(msg.chat.id, msg.entities[k].user.id)) then
                                        permissionsTable[tostring(msg.chat.id)][tostring(msg.entities[k].user.id)] = userPermissions(msg.chat.id, msg.entities[k].user.id)
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendPermissionsPvt, 'html').result.message_id
                                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                    end
                                end
                            end
                        end
                    end
                    matches[2] = tostring(matches[2]):gsub(' ', '')
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. obj_user.id .. ') ' .. obj_user.first_name .. ' ' ..(obj_user.last_name or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[15], keyboard_permissions_list(msg.chat.id, obj_user.id)) then
                                        permissionsTable[tostring(msg.chat.id)][tostring(obj_user.id)] = userPermissions(msg.chat.id, obj_user.id)
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendPermissionsPvt, 'html').result.message_id
                                            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                                            return
                                        end
                                    else
                                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                    end
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. obj_user.id .. ') ' .. obj_user.first_name .. ' ' ..(obj_user.last_name or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[15], keyboard_permissions_list(msg.chat.id, obj_user.id)) then
                                    permissionsTable[tostring(msg.chat.id)][tostring(obj_user.id)] = userPermissions(msg.chat.id, obj_user.id)
                                    if msg.chat.type ~= 'private' then
                                        local message_id = sendReply(msg, langs[msg.lang].sendPermissionsPvt, 'html').result.message_id
                                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                                        return
                                    end
                                else
                                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                                end
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                else
                    return langs[msg.lang].require_mod
                end
            else
                return showPermissions(msg.chat.id, msg.from.id, msg.lang)
            end
            return
        end
        if matches[1]:lower() == 'textualpermissions' then
            mystat('/permissions')
            if msg.reply then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                return showPermissions(msg.chat.id, msg.reply_to_message.forward_from.id, msg.lang)
                            else
                                return langs[msg.lang].cantDoThisToChat
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    else
                        return showPermissions(msg.chat.id, msg.reply_to_message.from.id, msg.lang)
                    end
                else
                    return showPermissions(msg.chat.id, msg.reply_to_message.from.id, msg.lang)
                end
            elseif matches[2] and matches[2] ~= '' then
                if msg.entities then
                    for k, v in pairs(msg.entities) do
                        -- check if there's a text_mention
                        if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                            if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                return showPermissions(msg.chat.id, msg.entities[k].user.id, msg.lang)
                            end
                        end
                    end
                end
                matches[2] = tostring(matches[2]):gsub(' ', '')
                if string.match(matches[2], '^%d+$') then
                    return showPermissions(msg.chat.id, matches[2], msg.lang)
                else
                    local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            return showPermissions(msg.chat.id, obj_user.id, msg.lang)
                        end
                    else
                        return langs[msg.lang].noObject
                    end
                end
            else
                return showPermissions(msg.chat.id, msg.from.id, msg.lang)
            end
        end
        if matches[1]:lower() == 'clean' then
            if msg.from.is_owner then
                if matches[2]:lower() == 'banlist' then
                    mystat('/clean banlist')
                    redis:del('banned:' .. msg.chat.id)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned banlist")
                    return langs[msg.lang].banlistCleaned
                elseif matches[2]:lower() == 'modlist' then
                    mystat('/clean modlist')
                    data[tostring(msg.chat.id)].moderators = { }
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned modlist")
                    return langs[msg.lang].modlistCleaned
                elseif matches[2]:lower() == 'rules' then
                    mystat('/clean rules')
                    data[tostring(msg.chat.id)].rules = nil
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned rules")
                    return langs[msg.lang].rulesCleaned
                elseif matches[2]:lower() == 'whitelist' then
                    mystat('/clean whitelist')
                    data[tostring(msg.chat.id)].whitelist.users = { }
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned whitelist")
                    return langs[msg.lang].whitelistCleaned
                elseif matches[2]:lower() == 'whitelistgban' then
                    mystat('/clean whitelistgban')
                    data[tostring(msg.chat.id)].whitelist.gbanned = { }
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned whitelistgban")
                    return langs[msg.lang].whitelistGbanCleaned
                elseif matches[2]:lower() == 'whitelistlink' then
                    mystat('/clean whitelistlink')
                    data[tostring(msg.chat.id)].settings.whitelist.links = { }
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned links_whitelist")
                    return langs[msg.lang].whitelistLinkCleaned
                end
                return
            else
                return langs[msg.lang].require_owner
            end
        end
    end
end

local function pre_process(msg)
    if msg then
        if msg.service then
            if is_realm(msg) then
                if msg.service_type == 'chat_add_user_link' then
                    if msg.from.id ~= bot.userVersion.id then
                        -- if not admin and not bot then
                        if not is_admin(msg) and not globalCronTable.punishedTable[tostring(msg.chat.id)][tostring(msg.from.id)] then
                            sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonInviteRealm))
                        end
                    end
                elseif msg.service_type == 'chat_add_user' or msg.service_type == 'chat_add_users' then
                    local text = ''
                    for k, v in pairs(msg.added) do
                        if v.id ~= bot.userVersion.id then
                            -- if not admin and not bot then
                            if not is_admin(msg) and not globalCronTable.punishedTable[tostring(msg.chat.id)][tostring(v.id)] then
                                text = text .. banUser(bot.id, v.id, msg.chat.id) .. '\n'
                            end
                        end
                    end
                    sendMessage(msg.chat.id, text .. langs[msg.lang].reasonInviteRealm)
                end
            end
            if msg.service_type == 'chat_add_user_link' then
                if is_owner2(msg.from.id, msg.chat.id, true) then
                    local bot_member = getChatMember(msg.chat.id, bot.id)
                    if bot_member.result then
                        bot_member = bot_member.result
                        bot_member = adjustPermissions(bot_member)
                        if bot_member.can_promote_members then
                            sendMessage(msg.chat.id, promoteTgAdmin(msg.chat.id, msg.from, bot_member))
                        else
                            sendMessage(msg.chat.id, langs[msg.lang].checkMyPermissions)
                        end
                    end
                end
            end
            if msg.service_type == 'chat_add_user' or msg.service_type == 'chat_add_users' then
                local text = ''
                local promote = false
                local bot_member = getChatMember(msg.chat.id, bot.id)
                if bot_member.result then
                    bot_member = bot_member.result
                    bot_member = adjustPermissions(bot_member)
                    if bot_member.can_promote_members then
                        promote = true
                    end
                end
                for k, v in pairs(msg.added) do
                    text = text .. v.id .. ' '
                    if is_owner2(v.id, msg.chat.id, true) then
                        if promote then
                            sendMessage(msg.chat.id, promoteTgAdmin(msg.chat.id, v, bot_member))
                        else
                            sendMessage(msg.chat.id, langs[msg.lang].checkMyPermissions)
                        end
                    end
                end
            end
            if msg.service_type == 'chat_rename' then
                if data[tostring(msg.chat.id)].settings.lock_groupname then
                    setChatTitle(msg.chat.id, data[tostring(msg.chat.id)].name)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] renamed the chat N")
                else
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] renamed the chat Y")
                end
            elseif msg.service_type == 'chat_change_photo' then
                if data[tostring(msg.chat.id)].settings.lock_groupphoto and data[tostring(msg.chat.id)].photo then
                    setChatPhotoId(msg.chat.id, data[tostring(msg.chat.id)].photo)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] changed chat's photo N")
                else
                    local bigger_pic_id = ''
                    local size = 0
                    for k, v in pairsByKeys(msg.new_chat_photo) do
                        if v.file_size then
                            if v.file_size > size then
                                size = v.file_size
                                bigger_pic_id = v.file_id
                            end
                        end
                    end
                    data[tostring(msg.chat.id)].photo = bigger_pic_id
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] changed chat's photo Y")
                end
            elseif msg.service_type == 'delete_chat_photo' then
                if data[tostring(msg.chat.id)].settings.lock_groupphoto and data[tostring(msg.chat.id)].photo then
                    setChatPhotoId(msg.chat.id, data[tostring(msg.chat.id)].photo)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] deleted chat's photo N")
                else
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] deleted chat's photo Y")
                end
            elseif msg.service_type == 'pinned_message' then
                sendReply(msg, '#pin' .. tostring(msg.chat.id):gsub('-', ''))
            end
        end
        return msg
    end
end

local function cron()
    -- clear those tables on the top of the plugin
    cronTable = {
        adminsContacted = { },
        noticeContacted = { },
    }
end

return {
    description = "GROUP_MANAGEMENT",
    cron = cron,
    patterns =
    {
        "^(###cbgroup_management)(DELETE)(%u)$",
        "^(###cbgroup_management)(DELETE)$",
        "^(###cbgroup_management)(PAGES)$",
        "^(###cbgroup_management)(PAGES)$",
        "^(###cbgroup_management)(BACKLOG)(%d+)(%-?%d+)$",
        "^(###cbgroup_management)(PAGE%dMINUS)(%d+)(%-?%d+)$",
        "^(###cbgroup_management)(PAGE%dPLUS)(%d+)(%-?%d+)$",
        "^(###cbgroup_management)(BACKPERMISSIONS)(%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(BACKPERMISSIONS)(%d+)(%-%d+)$",
        "^(###cbgroup_management)(GRANT)(%d+)(.*)(%-%d+)(%u)$",
        "^(###cbgroup_management)(GRANT)(%d+)(.*)(%-%d+)$",
        "^(###cbgroup_management)(DENY)(%d+)(.*)(%-%d+)(%u)$",
        "^(###cbgroup_management)(DENY)(%d+)(.*)(%-%d+)$",
        "^(###cbgroup_management)(PERMISSIONSDONE)(%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(PERMISSIONSDONE)(%d+)(%-%d+)$",
        "^(###cbgroup_management)(BACKSETTINGS)(%d)(%-%d+)(%u)$",
        "^(###cbgroup_management)(BACKSETTINGS)(%d)(%-%d+)$",
        "^(###cbgroup_management)(GOTOLOCKS)(%-%d+)(%u)$",
        "^(###cbgroup_management)(GOTOLOCKS)(%-%d+)$",
        "^(###cbgroup_management)(GOTOMUTES)(%-%d+)(%u)$",
        "^(###cbgroup_management)(GOTOMUTES)(%-%d+)$",
        "^(###cbgroup_management)(LOCK)([%w_]+)(%d)(%-%d+)(%u)$",
        "^(###cbgroup_management)(LOCK)([%w_]+)(%d)(%-%d+)$",
        "^(###cbgroup_management)(UNLOCK)([%w_]+)(%d)(%-%d+)(%u)$",
        "^(###cbgroup_management)(UNLOCK)([%w_]+)(%d)(%-%d+)$",
        "^(###cbgroup_management)(FLOOD%+%+)(%d)(%-%d+)(%u)$",
        "^(###cbgroup_management)(FLOOD%+%+)(%d)(%-%d+)$",
        "^(###cbgroup_management)(FLOOD%-%-)(%d)(%-%d+)(%u)$",
        "^(###cbgroup_management)(FLOOD%-%-)(%d)(%-%d+)$",
        "^(###cbgroup_management)(WARNS%+%+)(%d)(%-%d+)(%u)$",
        "^(###cbgroup_management)(WARNS%+%+)(%d)(%-%d+)$",
        "^(###cbgroup_management)(WARNS%-%-)(%d)(%-%d+)(%u)$",
        "^(###cbgroup_management)(WARNS%-%-)(%d)(%-%d+)$",
        "^(###cbgroup_management)(time_ban)(%d+)(BACK)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_ban)(%d+)(SECONDS)([%+%-]?%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_ban)(%d+)(MINUTES)([%+%-]?%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_ban)(%d+)(HOURS)([%+%-]?%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_ban)(%d+)(DAYS)([%+%-]?%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_ban)(%d+)(WEEKS)([%+%-]?%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_ban)(%d+)(DONE)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_ban)(%d+)(BACK)(%-%d+)$",
        "^(###cbgroup_management)(time_ban)(%d+)(SECONDS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbgroup_management)(time_ban)(%d+)(MINUTES)([%+%-]?%d+)(%-%d+)$",
        "^(###cbgroup_management)(time_ban)(%d+)(HOURS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbgroup_management)(time_ban)(%d+)(DAYS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbgroup_management)(time_ban)(%d+)(WEEKS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbgroup_management)(time_ban)(%d+)(DONE)(%-%d+)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(BACK)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(SECONDS)([%+%-]?%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(MINUTES)([%+%-]?%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(HOURS)([%+%-]?%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(DAYS)([%+%-]?%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(WEEKS)([%+%-]?%d+)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(DONE)(%-%d+)(%u)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(BACK)(%-%d+)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(SECONDS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(MINUTES)([%+%-]?%d+)(%-%d+)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(HOURS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(DAYS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(WEEKS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbgroup_management)(time_restrict)(%d+)(DONE)(%-%d+)$",
        -- punishments row
        "^(###cbgroup_management)(%d)([%w_]+)(%d)(%-%d+)(%u)$",
        "^(###cbgroup_management)(%d)([%w_]+)(%d)(%-%d+)$",
        -- info of the setting
        "^(###cbgroup_management)([%w_]+)(%u)$",
        "^(###cbgroup_management)([%w_]+)$",
        -- punishment increase
        "^(###cbgroup_management)([%w_]+)(%d)(%-%d+)(%u)$",
        "^(###cbgroup_management)([%w_]+)(%d)(%-%d+)$",

        -- SUPERGROUP
        "^[#!/]([Gg][Ee][Tt][Aa][Dd][Mm][Ii][Nn][Ss])$",
        "^[#!/]([Pp][Ii][Nn])$",
        "^[#!/]([Ss][Ii][Ll][Ee][Nn][Tt][Pp][Ii][Nn])$",
        "^[#!/]([Uu][Nn][Pp][Ii][Nn])$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Tt][Ll][Ee]) (.+)$",
        "^[#!/]([Ss][Ee][Tt][Dd][Ee][Ss][Cc][Rr][Ii][Pp][Tt][Ii][Oo][Nn]) (.+)$",
        "^[#!/]([Ss][Ee][Tt][Pp][Hh][Oo][Tt][Oo])$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Pp][Hh][Oo][Tt][Oo])$",

        -- COMMON
        "^[#!/]([Dd][Ee][Ll])$",
        "^[#!/]([Dd][Ee][Ll][Kk][Ee][Yy][Bb][Oo][Aa][Rr][Dd])$",
        "^[#!/]([Dd][Ee][Ll][Ff][Rr][Oo][Mm])$",
        "^[#!/]([Dd][Ee][Ll][Tt][Oo])$",
        "^[#!/]([Dd][Ee][Ll][Aa][Ll][Ll])$",
        "^[#!/]([Ll][Oo][Gg])$",
        "^[#!/]([Ss][Ee][Nn][Dd][Ll][Oo][Gg])$",
        "^[#!/@]([Aa][Dd][Mm][Ii][Nn][Ss]?)",
        "^[#!/]([Rr][Uu][Ll][Ee][Ss])$",
        "^[#!/]([Aa][Bb][Oo][Uu][Tt])$",
        "^[#!/]([Ss][Ee][Tt][Ff][Ll][Oo][Oo][Dd]) (%d+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Mm][Ee][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) (%d+) (%d+) (%d+) (%d+) (%d+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Mm][Ee][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) (%d+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Mm][Ee][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt])$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Mm][Ee][Bb][Aa][Nn]) (%d+) (%d+) (%d+) (%d+) (%d+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Mm][Ee][Bb][Aa][Nn]) (%d+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Mm][Ee][Bb][Aa][Nn])$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss])$",
        "^[#!/]([Pp][Ee][Rr][Mm][Ii][Ss][Ss][Ii][Oo][Nn][Ss]) ([^%s]+)$",
        "^[#!/]([Pp][Ee][Rr][Mm][Ii][Ss][Ss][Ii][Oo][Nn][Ss])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Pp][Ee][Rr][Mm][Ii][Ss][Ss][Ii][Oo][Nn][Ss]) ([^%s]+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Pp][Ee][Rr][Mm][Ii][Ss][Ss][Ii][Oo][Nn][Ss])$",
        "^[#!/]([Pp][Rr][Oo][Mm][Oo][Tt][Ee][Aa][Dd][Mm][Ii][Nn]) ([^%s]+) (.*)$",
        "^[#!/]([Pp][Rr][Oo][Mm][Oo][Tt][Ee][Aa][Dd][Mm][Ii][Nn]) (.*)$",
        "^[#!/]([Pp][Rr][Oo][Mm][Oo][Tt][Ee][Aa][Dd][Mm][Ii][Nn])$",
        "^[#!/]([Dd][Ee][Mm][Oo][Tt][Ee][Aa][Dd][Mm][Ii][Nn]) ([^%s]+)$",
        "^[#!/]([Dd][Ee][Mm][Oo][Tt][Ee][Aa][Dd][Mm][Ii][Nn])$",
        "^[#!/]([Pp][Rr][Oo][Mm][Oo][Tt][Ee]) ([^%s]+)$",
        "^[#!/]([Pp][Rr][Oo][Mm][Oo][Tt][Ee])$",
        "^[#!/]([Dd][Ee][Mm][Oo][Tt][Ee]) ([^%s]+)$",
        "^[#!/]([Dd][Ee][Mm][Oo][Tt][Ee])$",
        "^[#!/]([Mm][Uu][Tt][Ee][Ss][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Mm][Uu][Tt][Ee][Ss][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Mm][Uu][Tt][Ee]) ([^%s]+)$",
        "^[#!/]([Mm][Uu][Tt][Ee]) ([^%s]+) ([^%s]+)$",
        "^[#!/]([Uu][Nn][Mm][Uu][Tt][Ee]) ([^%s]+)$",
        "^[#!/]([Nn][Ee][Ww][Ll][Ii][Nn][Kk])$",
        "^[#!/]([Ss][Ee][Tt][Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        "^[#!/]([Ss][Ee][Tt][Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        "^[#!/]([Ss][Ee][Tt][Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt].[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        "^[#!/]([Ss][Ee][Tt][Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Dd][Oo][Gg]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Ll][Ii][Nn][Kk])$",
        "^[#!/]([Ll][Ii][Nn][Kk])$",
        "^[#!/]([Uu][Pp][Dd][Aa][Tt][Ee][Gg][Rr][Oo][Uu][Pp][Ii][Nn][Ff][Oo])$",
        "^[#!/]([Ss][Yy][Nn][Cc][Mm][Oo][Dd][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss]) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Aa][Bb][Oo][Uu][Tt]) (.*)$",
        "^[#!/]([Oo][Ww][Nn][Ee][Rr])$",
        "^[#!/]([Ll][Oo][Cc][Kk]) ([^%s]+)$",
        "^[#!/]([Ll][Oo][Cc][Kk]) ([^%s]+) ([^%s]+)$",
        "^[#!/]([Uu][Nn][Ll][Oo][Cc][Kk]) ([^%s]+)$",
        "^[#!/]([Mm][Oo][Dd][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Cc][Ll][Ee][Aa][Nn]) ([^%s]+)$",
        "^[#!/]([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) ([^%s]+)$",
        "^[#!/]([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr])$",
        "^[#!/]([Ss][Ee][Tt][Ww][Aa][Rr][Nn]) (%d+)$",
        "^[#!/]([Gg][Ee][Tt][Ww][Aa][Rr][Nn])$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/getwarn",
        "/rules",
        "/modlist",
        "/owner",
        "/admin[s] [{reply}|{text}]",
        "/link",
        "/settings",
        "/textualsettings",
        "/muteslist",
        "/textualmuteslist",
        "/permissions",
        "/textualpermissions",
        "MOD",
        "/del [{reply}]",
        "/delkeyboard {reply}",
        "/delfrom {reply}",
        "/delto [{reply}]",
        "/delall",
        "/updategroupinfo",
        "/setrules {text}",
        "/setwarn {value}",
        "/setflood {value}",
        "/newlink",
        "/settimerestrict",
        "/settimeban",
        "/settimerestrict {seconds}",
        "/settimeban {seconds}",
        "/settimerestrict {weeks} {days} {hours} {minutes} {seconds}",
        "/settimeban {weeks} {days} {hours} {minutes} {seconds}",
        "/lock|/mute all|arabic|audios|bots|contacts|delword|documents|flood|forward|games|gbanned|gifs|grouplink|groupname|groupnotices|groupphoto|leave|links|locations|members|photos|pmnotices|rtl|spam|stickers|strict|tagalert|text|tgservices|username|videos|video_notes|voice_notes|warns_punishment {punishment}",
        "/unlock|/unmute all|arabic|audios|bots|contacts|delword|documents|flood|forward|games|gbanned|gifs|grouplink|groupname|groupnotices|groupphoto|leave|links|locations|members|photos|pmnotices|rtl|spam|stickers|strict|tagalert|text|tgservices|username|videos|video_notes|voice_notes|warns_punishment",
        "/pin {reply}",
        "/silentpin {reply}",
        "/unpin",
        "/settitle {text}",
        "/setdescription {text}",
        "/setphoto {reply}",
        "/unsetphoto",
        "OWNER",
        "/syncmodlist",
        "/[send]log",
        "/getadmins",
        "/setlink {link}",
        "/unsetlink",
        "/promote {user}",
        "/demote {user}",
        "/promoteadmin {user} [change_info] [delete_messages] [invite_users] [restrict_members] [pin_messages] [promote_members]",
        "/demoteadmin {user}",
        "/setowner {id}|{username}|{reply}",
        "/mute all|text",
        "/unmute all|text",
        "/clean banlist|modlist|rules|whitelist|whitelistgban|whitelistlink",
    },
}