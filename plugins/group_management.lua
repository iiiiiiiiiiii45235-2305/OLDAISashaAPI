-- REFACTORING OF INPM.LUA INREALM.LUA INGROUP.LUA AND SUPERGROUP.LUA
local adminsContacted = {
    -- chat_id
}
local noticeContacted = {
    -- chat_id = false/true
}
local delAll = {
    -- chat_id = from = msgid, to = msgid + n
}

-- table that contains 'group_id' = message_id to delete old rules messages
local last_rules = { }

local default_permissions = {
    ['can_change_info'] = true,
    ['can_delete_messages'] = true,
    ['can_invite_users'] = true,
    ['can_restrict_members'] = true,
    ['can_pin_messages'] = true,
    ['can_promote_members'] = false,
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
    data[tostring(chat_id)]['set_owner'] = tostring(user.id)
    save_data(config.moderation.data, data)
    if areNoticesEnabled(user.id, chat_id) then
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
    if not data[tostring(chat_id)] then
        return langs[lang].groupNotAdded
    end
    if promoteChatMember(chat_id, user.id, permissions) then
        local promote = false
        for key, var in pairs(permissions) do
            if permissions[key] then
                promote = true
            end
        end
        if promote then
            data[tostring(chat_id)]['moderators'][tostring(user.id)] =(user.username or user.print_name or user.first_name)
            save_data(config.moderation.data, data)
            if areNoticesEnabled(user.id, chat_id) then
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
    if not data[tostring(chat_id)] then
        return langs[lang].groupNotAdded
    end
    if demoteChatMember(chat_id, user.id) then
        if data[tostring(chat_id)]['moderators'][tostring(user.id)] then
            data[tostring(chat_id)]['moderators'][tostring(user.id)] = nil
            save_data(config.moderation.data, data)
        end
        if areNoticesEnabled(user.id, chat_id) then
            sendMessage(user.id, langs[get_lang(user.id)].youHaveBeenDemotedAdmin .. database[tostring(chat_id)].print_name)
        end
        return(user.username or user.print_name or user.first_name) .. langs[lang].demoteModAdmin
    else
        return langs[lang].checkMyPermissions
    end
end

local function promoteMod(chat_id, user)
    local lang = get_lang(chat_id)
    if not data[tostring(chat_id)] then
        return langs[lang].groupNotAdded
    end
    if data[tostring(chat_id)]['moderators'][tostring(user.id)] then
        return(user.username or user.print_name or user.first_name) .. langs[lang].alreadyMod
    end
    data[tostring(chat_id)]['moderators'][tostring(user.id)] =(user.username or user.print_name or user.first_name)
    save_data(config.moderation.data, data)
    if areNoticesEnabled(user.id, chat_id) then
        sendMessage(user.id, langs[get_lang(user.id)].youHaveBeenPromotedMod .. database[tostring(chat_id)].print_name)
    end
    return(user.username or user.print_name or user.first_name) .. langs[lang].promoteMod
end

local function demoteMod(chat_id, user)
    local lang = get_lang(chat_id)
    if not data[tostring(chat_id)] then
        return langs[lang].groupNotAdded
    end
    if not data[tostring(chat_id)]['moderators'][tostring(user.id)] then
        return(user.username or user.print_name or user.first_name) .. langs[lang].notMod
    end
    data[tostring(chat_id)]['moderators'][tostring(user.id)] = nil
    save_data(config.moderation.data, data)
    if areNoticesEnabled(user.id, chat_id) then
        sendMessage(user.id, langs[get_lang(user.id)].youHaveBeenDemotedMod .. database[tostring(chat_id)].print_name)
    end
    return(user.username or user.print_name or user.first_name) .. langs[lang].demoteMod
end

local function modList(msg)
    if not data['groups'][tostring(msg.chat.id)] then
        return langs[msg.lang].groupNotAdded
    end
    -- determine if table is empty
    if next(data[tostring(msg.chat.id)]['moderators']) == nil then
        -- fix way
        return langs[msg.lang].noGroupMods
    end
    local i = 1
    local message = langs[msg.lang].modListStart .. string.gsub(msg.chat.print_name, '_', ' ') .. ':\n'
    for k, v in pairs(data[tostring(msg.chat.id)]['moderators']) do
        message = message .. i .. '. ' .. v .. ' - ' .. k .. '\n'
        i = i + 1
    end
    return message
end
-- end RANKS MANAGEMENT

local function showSettings(target, lang)
    if data[tostring(target)] then
        if data[tostring(target)]['settings'] then
            local settings = data[tostring(target)]['settings']
            local text = langs[lang].groupSettings ..
            langs[lang].arabicLock .. tostring(settings.lock_arabic) ..
            langs[lang].botsLock .. tostring(settings.lock_bots) ..
            langs[lang].censorshipsLock .. tostring(settings.lock_delword) ..
            langs[lang].floodLock .. tostring(settings.flood) ..
            langs[lang].floodSensibility .. tostring(settings.flood_max) ..
            langs[lang].grouplinkLock .. tostring(settings.lock_group_link) ..
            langs[lang].leaveLock .. tostring(settings.lock_leave) ..
            langs[lang].linksLock .. tostring(settings.lock_link) ..
            langs[lang].membersLock .. tostring(settings.lock_member) ..
            langs[lang].rtlLock .. tostring(settings.lock_rtl) ..
            langs[lang].spamLock .. tostring(settings.lock_spam) ..
            langs[lang].strictrules .. tostring(settings.strict) ..
            langs[lang].warnSensibility .. tostring(settings.warn_max)
            return text
        end
    end
end

-- begin LOCK/UNLOCK FUNCTIONS
local function lockSetting(target, setting_type)
    local lang = get_lang(target)
    setting_type = settingsDictionary[setting_type:lower()]
    if setting_type == 'photo' then
        local obj = getChat(target)
        if type(obj) == 'table' then
            if obj.photo then
                data[tostring(target)].photo = obj.photo.big_file_id
            end
        end
    end
    local setting = data[tostring(target)].settings[tostring(setting_type)]
    if setting ~= nil then
        if setting then
            return langs[lang].settingAlreadyLocked
        else
            data[tostring(target)].settings[tostring(setting_type)] = true
            save_data(config.moderation.data, data)
            return langs[lang].settingLocked
        end
    else
        data[tostring(target)].settings[tostring(setting_type)] = true
        save_data(config.moderation.data, data)
        return langs[lang].settingLocked
    end
end

local function unlockSetting(target, setting_type)
    local lang = get_lang(target)
    setting_type = settingsDictionary[setting_type:lower()]
    local setting = data[tostring(target)].settings[tostring(setting_type)]
    if setting ~= nil then
        if setting then
            data[tostring(target)].settings[tostring(setting_type)] = false
            save_data(config.moderation.data, data)
            return langs[lang].settingUnlocked
        else
            return langs[lang].settingAlreadyUnlocked
        end
    else
        data[tostring(target)].settings[tostring(setting_type)] = false
        save_data(config.moderation.data, data)
        return langs[lang].settingUnlocked
    end
end
-- end LOCK/UNLOCK FUNCTIONS

local function run(msg, matches)
    if msg.cb then
        if matches[1] then
            if matches[1] == '###cbgroup_management' then
                if matches[2] == 'DELETE' then
                    if not deleteMessage(msg.chat.id, msg.message_id, true) then
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                    end
                elseif matches[2] == 'BACKSETTINGS' then
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                    local chat_name = ''
                    if data[tostring(matches[3])] then
                        chat_name = data[tostring(matches[3])].set_name or ''
                    end
                    print(matches[3])
                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[3] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].locksIntro .. langs[msg.lang].faq[11], keyboard_settings_list(matches[3], matches[4] or false))
                elseif matches[2] == 'BACKMUTES' then
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                    local chat_name = ''
                    if data[tostring(matches[3])] then
                        chat_name = data[tostring(matches[3])].set_name or ''
                    end
                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].mutesOf .. '(' .. matches[3] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].faq[12], keyboard_mutes_list(matches[3], matches[4] or false))
                elseif matches[2] == 'BACKPERMISSIONS' then
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                    local chat_name = ''
                    if data[tostring(matches[4])] then
                        chat_name = data[tostring(matches[4])].set_name or ''
                    end
                    editMessage(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. matches[4] .. ') ' .. chat_name), 'X', tostring('(' .. matches[3] .. ') ' ..(database[tostring(matches[3])]['print_name'] or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[16], keyboard_permissions_list(matches[4], matches[3], nil, matches[5] or false))
                elseif matches[2] == 'LOCK' then
                    if is_mod2(msg.from.id, matches[4]) then
                        answerCallbackQuery(msg.cb_id, lockSetting(tonumber(matches[4]), matches[3]), false)
                        local chat_name = ''
                        if data[tostring(matches[4])] then
                            chat_name = data[tostring(matches[4])].set_name or ''
                        end
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[4] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].locksIntro .. langs[msg.lang].faq[11], keyboard_settings_list(matches[4], matches[5] or false))
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4] ..(matches[5] or ''))
                    else
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                    end
                elseif matches[2] == 'UNLOCK' then
                    if is_mod2(msg.from.id, matches[4]) then
                        answerCallbackQuery(msg.cb_id, unlockSetting(tonumber(matches[4]), matches[3]), false)
                        local chat_name = ''
                        if data[tostring(matches[4])] then
                            chat_name = data[tostring(matches[4])].set_name or ''
                        end
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[4] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].locksIntro .. langs[msg.lang].faq[11], keyboard_settings_list(matches[4], matches[5] or false))
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4] ..(matches[5] or ''))
                    else
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                    end
                elseif matches[2] == 'MUTE' then
                    if is_mod2(msg.from.id, matches[4]) then
                        if matches[3]:lower() == 'all' or matches[3]:lower() == 'text' then
                            if is_owner2(msg.from.id, matches[4]) then
                                answerCallbackQuery(msg.cb_id, mute(matches[4], matches[3]), false)
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                            end
                        else
                            answerCallbackQuery(msg.cb_id, mute(matches[4], matches[3]), false)
                        end
                        local chat_name = ''
                        if data[tostring(matches[4])] then
                            chat_name = data[tostring(matches[4])].set_name or ''
                        end
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].mutesOf .. '(' .. matches[4] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].faq[12], keyboard_mutes_list(matches[4], matches[5] or false))
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4] ..(matches[5] or ''))
                    else
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                    end
                elseif matches[2] == 'UNMUTE' then
                    if is_mod2(msg.from.id, matches[4]) then
                        if matches[3]:lower() == 'all' or matches[3]:lower() == 'text' then
                            if is_owner2(msg.from.id, matches[4]) then
                                answerCallbackQuery(msg.cb_id, unmute(matches[4], matches[3]), false)
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                            end
                        else
                            answerCallbackQuery(msg.cb_id, unmute(matches[4], matches[3]), false)
                        end
                        local chat_name = ''
                        if data[tostring(matches[4])] then
                            chat_name = data[tostring(matches[4])].set_name or ''
                        end
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].mutesOf .. '(' .. matches[4] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].faq[12], keyboard_mutes_list(matches[4], matches[5] or false))
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4] ..(matches[5] or ''))
                    else
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                    end
                elseif matches[2] == 'FLOODMINUS' or matches[2] == 'FLOODPLUS' then
                    if is_mod2(msg.from.id, matches[4]) then
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4] ..(matches[5] or ''))
                        local flood = matches[3]
                        if matches[2] == 'FLOODPLUS' then
                            flood = flood + 1
                        elseif matches[2] == 'FLOODMINUS' then
                            flood = flood - 1
                        end
                        if tonumber(flood) < 3 or tonumber(flood) > 20 then
                            return answerCallbackQuery(msg.cb_id, langs[msg.lang].errorFloodRange, false)
                        end
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].floodSet .. flood, false)
                        data[tostring(matches[4])].settings.flood_max = flood
                        save_data(config.moderation.data, data)
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set flood to [" .. flood .. "]")
                        local chat_name = ''
                        if data[tostring(matches[4])] then
                            chat_name = data[tostring(matches[4])].set_name or ''
                        end
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[4] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].locksIntro .. langs[msg.lang].faq[11], keyboard_settings_list(matches[4], matches[5] or false))
                    else
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                    end
                elseif matches[2] == 'WARNSMINUS' or matches[2] == 'WARNS' or matches[2] == 'WARNSPLUS' then
                    if is_mod2(msg.from.id, matches[4]) then
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4] ..(matches[5] or ''))
                        local warns = matches[3]
                        if matches[2] == 'WARNSMINUS' then
                            warns = warns - 1
                        elseif matches[2] == 'WARNSPLUS' then
                            warns = warns + 1
                        end
                        if tonumber(warns) < 0 or tonumber(warns) > 10 then
                            return answerCallbackQuery(msg.cb_id, langs[msg.lang].errorWarnRange, false)
                        end
                        if tonumber(warns) == 0 then
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].neverWarn, false)
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].warnSet .. warns, false)
                        end
                        data[tostring(matches[4])].settings.warn_max = warns
                        save_data(config.moderation.data, data)
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set warns to [" .. warns .. "]")
                        local chat_name = ''
                        if data[tostring(matches[4])] then
                            chat_name = data[tostring(matches[4])].set_name or ''
                        end
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. '(' .. matches[4] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].locksIntro .. langs[msg.lang].faq[11], keyboard_settings_list(matches[4], matches[5] or false))
                    else
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                    end
                elseif matches[2] == 'GRANT' then
                    if is_owner2(msg.from.id, matches[5]) then
                        local obj_user = getChatMember(matches[5], matches[3])
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
                            local permissions = adjustPermissions(obj_user)
                            permissions[permissionsDictionary[matches[4]:lower()]] = true
                            local res = promoteTgAdmin(matches[5], obj_user.user, permissions)
                            if res ~= langs[get_lang(matches[5])].checkMyPermissions and res ~= langs[get_lang(matches[5])].notMyGroup then
                                answerCallbackQuery(msg.cb_id, matches[4] .. langs[msg.lang].granted, false)
                                local chat_name = ''
                                if data[tostring(matches[5])] then
                                    chat_name = data[tostring(matches[5])].set_name or ''
                                end
                                editMessage(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. matches[5] .. ') ' .. chat_name), 'X', tostring('(' .. matches[3] .. ') ' ..(database[tostring(matches[3])]['print_name'] or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[16], keyboard_permissions_list(matches[5], matches[3], permissions, matches[6] or false))
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].checkMyPermissions, false)
                            end
                        end
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4] .. matches[5])
                    else
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                    end
                elseif matches[2] == 'DENY' then
                    if is_owner2(msg.from.id, matches[5]) then
                        local obj_user = getChatMember(matches[5], matches[3])
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
                            local permissions = adjustPermissions(obj_user)
                            permissions[permissionsDictionary[matches[4]:lower()]] = false
                            local res = promoteTgAdmin(matches[5], obj_user.user, permissions)
                            if res ~= langs[get_lang(matches[5])].checkMyPermissions and res ~= langs[get_lang(matches[5])].notMyGroup then
                                answerCallbackQuery(msg.cb_id, matches[4] .. langs[msg.lang].denied, false)
                                local chat_name = ''
                                if data[tostring(matches[5])] then
                                    chat_name = data[tostring(matches[5])].set_name or ''
                                end
                                editMessage(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. matches[5] .. ') ' .. chat_name), 'X', tostring('(' .. matches[3] .. ') ' ..(database[tostring(matches[3])]['print_name'] or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[16], keyboard_permissions_list(matches[5], matches[3], permissions, matches[6] or false))
                            else
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].checkMyPermissions, false)
                            end
                        end
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4] .. matches[5])
                    else
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                    end
                end
                return
            end
        end
    end
    if matches[1]:lower() == 'type' then
        if msg.from.is_mod then
            mystat('/type')
            if data[tostring(msg.chat.id)] then
                if data[tostring(msg.chat.id)]['group_type'] then
                    return data[tostring(msg.chat.id)]['group_type']
                else
                    return langs[msg.lang].chatTypeNotFound
                end
            else
                return langs[msg.lang].useYourGroups
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'log' then
        if msg.from.is_owner then
            mystat('/log')
            savelog(msg.chat.id, "log file created by owner/admin")
            return sendDocument(msg.chat.id, "./groups/logs/" .. msg.chat.id .. "log.txt")
        else
            return langs[msg.lang].require_owner
        end
    end
    if matches[1]:lower() == 'admins' then
        mystat('/admins')
        if is_group(msg) or is_super_group(msg) then
            if not adminsContacted[tostring(msg.chat.id)] or is_admin(msg) then
                adminsContacted[tostring(msg.chat.id)] = true
                local hashtag = '#admins' .. tostring(msg.message_id)
                local chat_name = msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']'
                local group_link = data[tostring(msg.chat.id)]['settings']['set_link']
                if group_link then
                    chat_name = "<a href=\"" .. group_link .. "\">" .. html_escape(chat_name) .. "</a>"
                end
                local text = langs[msg.lang].receiver .. chat_name .. '\n' .. langs[msg.lang].sender
                if msg.from.username then
                    text = text .. '@' .. msg.from.username .. ' [' .. msg.from.id .. ']\n'
                else
                    text = text .. html_escape(msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']\n')
                end
                text = text .. langs[msg.lang].msgText .. html_escape(msg.text or msg.caption) .. '\n' ..
                'HASHTAG: ' .. hashtag

                sendMessage(msg.chat.id, hashtag)

                local already_contacted = { }
                already_contacted[tonumber(bot.id)] = bot.id
                already_contacted[tonumber(bot.userVersion.id)] = bot.userVersion.id
                local cant_contact = ''
                local list = getChatAdministrators(msg.chat.id)
                if list then
                    for i, admin in pairs(list.result) do
                        if not already_contacted[tonumber(admin.user.id)] then
                            already_contacted[tonumber(admin.user.id)] = admin.user.id
                            if sendChatAction(admin.user.id, 'typing', true) then
                                if msg.reply then
                                    forwardMessage(admin.user.id, msg.chat.id, msg.reply_to_message.message_id)
                                end
                                sendMessage(admin.user.id, text, 'html')
                            else
                                cant_contact = cant_contact .. admin.user.id .. ' ' ..(admin.user.username or('NOUSER ' .. admin.user.first_name .. ' ' ..(admin.user.last_name or ''))) .. '\n'
                            end
                        end
                    end
                end

                -- owner
                local owner = data[tostring(msg.chat.id)]['set_owner']
                if owner then
                    if not already_contacted[tonumber(owner)] then
                        already_contacted[tonumber(owner)] = owner
                        if sendChatAction(owner, 'typing', true) then
                            if msg.reply then
                                forwardMessage(owner, msg.chat.id, msg.reply_to_message.message_id)
                            end
                            sendMessage(owner, text, 'html')
                        else
                            cant_contact = cant_contact .. owner .. '\n'
                        end
                    end
                end

                -- determine if table is empty
                if next(data[tostring(msg.chat.id)]['moderators']) == nil then
                    -- fix way
                    return
                else
                    for k, v in pairs(data[tostring(msg.chat.id)]['moderators']) do
                        if not already_contacted[tonumber(k)] then
                            already_contacted[tonumber(k)] = k
                            if sendChatAction(k, 'typing', true) then
                                if msg.reply then
                                    forwardMessage(k, msg.chat.id, msg.reply_to_message.message_id)
                                end
                                sendMessage(k, text, 'html')
                            else
                                cant_contact = cant_contact .. k .. ' ' ..(v or '') .. '\n'
                            end
                        end
                    end
                end
                if cant_contact ~= '' then
                    sendMessage(msg.chat.id, langs[msg.lang].cantContact .. cant_contact)
                end
                return
            else
                if not noticeContacted[tostring(msg.chat.id)] then
                    noticeContacted[tostring(msg.chat.id)] = true
                    return langs[msg.lang].dontFloodAdmins
                end
            end
        else
            return langs[msg.lang].useYourGroups
        end
    end

    -- INGROUP/SUPERGROUP
    if (msg.chat.type == 'group' or msg.chat.type == 'supergroup') and data[tostring(msg.chat.id)] then
        if matches[1]:lower() == 'rules' then
            mystat('/rules')
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group rules")
            local tmp = last_rules[tostring(msg.chat.id)]
            if not data[tostring(msg.chat.id)].rules then
                last_rules[tostring(msg.chat.id)] = sendMessage(msg.chat.id, langs[msg.lang].noRules)
                io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' ..(last_rules[tostring(msg.chat.id)].result.message_id or '') .. '"')
            else
                last_rules[tostring(msg.chat.id)] = sendMessage(msg.chat.id, langs[msg.lang].rules .. data[tostring(msg.chat.id)]['rules'])
            end
            if last_rules[tostring(msg.chat.id)] then
                if last_rules[tostring(msg.chat.id)].result then
                    if last_rules[tostring(msg.chat.id)].result.message_id then
                        last_rules[tostring(msg.chat.id)] = last_rules[tostring(msg.chat.id)].result.message_id
                    else
                        last_rules[tostring(msg.chat.id)] = nil
                    end
                else
                    last_rules[tostring(msg.chat.id)] = nil
                end
            end
            if tmp then
                deleteMessage(msg.chat.id, tmp, true)
            end
            io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
        end
        if matches[1]:lower() == 'updategroupinfo' then
            if msg.from.is_mod then
                mystat('/upgradegroupinfo')
                data[tostring(msg.chat.id)].set_name = string.gsub(msg.chat.print_name, '_', ' ')
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
                data[tostring(msg.chat.id)].settings.flood_max = matches[2]
                save_data(config.moderation.data, data)
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set flood to [" .. matches[2] .. "]")
                return langs[msg.lang].floodSet .. matches[2]
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'getwarn' then
            mystat('/getwarn')
            return getWarn(msg.chat.id)
        end
        if matches[1]:lower() == 'setwarn' and matches[2] then
            if msg.from.is_mod then
                mystat('/setwarn')
                if tonumber(matches[2]) < 0 or tonumber(matches[2]) > 10 then
                    return langs[msg.lang].errorWarnRange
                end
                local warn_max = matches[2]
                data[tostring(msg.chat.id)].settings.warn_max = warn_max
                save_data(config.moderation.data, data)
                savelog(msg.chat.id, " [" .. msg.from.id .. "] set warn to [" .. matches[2] .. "]")
                if tonumber(matches[2]) == 0 then
                    return langs[msg.lang].neverWarn
                else
                    return langs[msg.lang].warnSet .. matches[2]
                end
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
        if matches[1]:lower() == 'msgid' then
            mystat('/msgid')
            if msg.reply then
                return msg.reply_to_message.message_id
            else
                return msg.message_id
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
                    if msg.reply_to_message.date > os.time() -48 * 60 * 60 then
                        mystat('/delfrom')
                        delAll[tostring(msg.chat.id)] = delAll[tostring(msg.chat.id)] or { }
                        delAll[tostring(msg.chat.id)].from = msg.reply_to_message.message_id
                        return langs[msg.lang].ok
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
                if msg.reply then
                    mystat('/delto')
                    delAll[tostring(msg.chat.id)] = delAll[tostring(msg.chat.id)] or { }
                    delAll[tostring(msg.chat.id)].to = msg.reply_to_message.message_id
                    return langs[msg.lang].ok
                else
                    return langs[msg.lang].needReply
                end
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
                            mystat('/delall')
                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] deleted all messages from " .. delAll[tostring(msg.chat.id)].from .. " to " .. delAll[tostring(msg.chat.id)].to)
                            print(delAll[tostring(msg.chat.id)].from)
                            print(delAll[tostring(msg.chat.id)].to)
                            for i = delAll[tostring(msg.chat.id)].from, delAll[tostring(msg.chat.id)].to do
                                print(i)
                                deleteMessage(msg.chat.id, i, true)
                            end
                            return langs[msg.lang].messagesDeleted
                        else
                            return langs[msg.lang].delallError
                        end
                    else
                        return langs[msg.lang].delallError
                    end
                else
                    return langs[msg.lang].delallError
                end
                return langs[msg.lang].ok
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
        if matches[1]:lower() == 'lock' then
            if msg.from.is_mod then
                if settingsDictionary[matches[2]:lower()] then
                    mystat('/lock ' .. matches[2]:lower())
                    return lockSetting(msg.chat.id, matches[2]:lower())
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'unlock' then
            if msg.from.is_mod then
                if settingsDictionary[matches[2]:lower()] then
                    mystat('/unlock ' .. matches[2]:lower())
                    return unlockSetting(msg.chat.id, matches[2]:lower())
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'mute' then
            if msg.from.is_mod then
                if mutesDictionary[matches[2]:lower()] then
                    mystat('/mute ' .. matches[2]:lower())
                    if matches[2]:lower() == 'all' or matches[2]:lower() == 'text' then
                        if msg.from.is_owner then
                            return mute(msg.chat.id, matches[2]:lower())
                        else
                            return langs[msg.lang].require_owner
                        end
                    else
                        return mute(msg.chat.id, matches[2]:lower())
                    end
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'unmute' then
            if msg.from.is_mod then
                if mutesDictionary[matches[2]:lower()] then
                    mystat('/unmute ' .. matches[2]:lower())
                    if matches[2]:lower() == 'all' or matches[2]:lower() == 'text' then
                        if msg.from.is_owner then
                            return unmute(msg.chat.id, matches[2]:lower())
                        else
                            return langs[msg.lang].require_owner
                        end
                    else
                        return unmute(msg.chat.id, matches[2]:lower())
                    end
                end
                return
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'muteslist' then
            mystat('/muteslist')
            if msg.from.is_mod then
                local chat_name = ''
                if data[tostring(msg.chat.id)] then
                    chat_name = data[tostring(msg.chat.id)].set_name or ''
                end
                if sendKeyboard(msg.from.id, langs[msg.lang].mutesOf .. '(' .. msg.chat.id .. ') ' .. chat_name .. '\n' .. langs[msg.lang].faq[12], keyboard_mutes_list(msg.chat.id)) then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist")
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendMutesPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                        io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
            else
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist")
                return mutesList(msg.chat.id)
            end
        end
        if matches[1]:lower() == 'textualmuteslist' then
            mystat('/muteslist')
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist")
            return mutesList(msg.chat.id)
        end
        if matches[1]:lower() == 'settings' then
            mystat('/settings')
            if msg.from.is_mod then
                local chat_name = ''
                if data[tostring(msg.chat.id)] then
                    chat_name = data[tostring(msg.chat.id)].set_name or ''
                end
                if sendKeyboard(msg.from.id, langs[msg.lang].settingsOf .. '(' .. msg.chat.id .. ') ' .. chat_name .. '\n' .. langs[msg.lang].locksIntro .. langs[msg.lang].faq[11], keyboard_settings_list(msg.chat.id)) then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group settings ")
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendSettingsPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                        io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
            else
                return showSettings(msg.chat.id, msg.lang)
            end
        end
        if matches[1]:lower() == 'textualsettings' then
            mystat('/settings')
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group settings ")
            return showSettings(msg.chat.id, msg.lang)
        end
        if matches[1]:lower() == 'newlink' then
            if msg.from.is_mod then
                mystat('/newlink')
                local link = exportChatInviteLink(msg.chat.id)
                if link then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] created new group link [" .. tostring(link) .. "]")
                    data[tostring(msg.chat.id)].settings.set_link = tostring(link)
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
                data[tostring(msg.chat.id)].settings.set_link = matches[2]
                save_data(config.moderation.data, data)
                return langs[msg.lang].linkSaved
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'unsetlink' then
            if msg.from.is_owner then
                mystat('/unsetlink')
                data[tostring(msg.chat.id)].settings.set_link = nil
                save_data(config.moderation.data, data)
                return langs[msg.lang].linkDeleted
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'link' then
            mystat('/link')
            if data[tostring(msg.chat.id)].settings.lock_group_link then
                if msg.from.is_mod then
                    if data[tostring(msg.chat.id)].settings.set_link then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group link [" .. data[tostring(msg.chat.id)].settings.set_link .. "]")
                        if sendMessage(msg.from.id, "<a href=\"" .. data[tostring(msg.chat.id)].settings.set_link .. "\">" .. html_escape(msg.chat.title) .. "</a>", 'html') then
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
                if data[tostring(msg.chat.id)].settings.set_link then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group link [" .. data[tostring(msg.chat.id)].settings.set_link .. "]")
                    return sendReply(msg, "<a href=\"" .. data[tostring(msg.chat.id)].settings.set_link .. "\">" .. html_escape(msg.chat.title) .. "</a>", 'html')
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
            local group_owner = data[tostring(msg.chat.id)].set_owner
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
                                    local obj_user = getChat(msg.entities[k].user.id)
                                    if type(obj_user) == 'table' then
                                        if obj_user then
                                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                                return setOwner(obj_user, msg.chat.id)
                                            end
                                        else
                                            return langs[msg.lang].noObject
                                        end
                                    end
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
            return modList(msg)
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
                                    local obj_user = getChat(msg.entities[k].user.id)
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
                                    local obj_user = getChat(msg.entities[k].user.id)
                                    if type(obj_user) == 'table' then
                                        if obj_user then
                                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                                return demoteTgAdmin(msg.chat.id, obj_user)
                                            end
                                        else
                                            return langs[msg.lang].noObject
                                        end
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
                                    local obj_user = getChat(msg.entities[k].user.id)
                                    if type(obj_user) == 'table' then
                                        if obj_user then
                                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                                return promoteMod(msg.chat.id, obj_user)
                                            end
                                        else
                                            return langs[msg.lang].noObject
                                        end
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
                                    local obj_user = getChat(msg.entities[k].user.id)
                                    if type(obj_user) == 'table' then
                                        if obj_user then
                                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                                return demoteMod(msg.chat.id, obj_user)
                                            end
                                        else
                                            return langs[msg.lang].noObject
                                        end
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
                chat_name = data[tostring(msg.chat.id)].set_name or ''
            end
            if msg.reply then
                if msg.from.is_mod then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. msg.reply_to_message.forward_from.id .. ') ' .. msg.reply_to_message.forward_from.first_name .. ' ' ..(msg.reply_to_message.forward_from.last_name or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[16], keyboard_permissions_list(msg.chat.id, msg.reply_to_message.forward_from.id)) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendPermissionsPvt, 'html').result.message_id
                                            io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                            io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
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
                        if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. msg.reply_to_message.from.id .. ') ' .. msg.reply_to_message.from.first_name .. ' ' ..(msg.reply_to_message.from.last_name or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[16], keyboard_permissions_list(msg.chat.id, msg.reply_to_message.from.id)) then
                            if msg.chat.type ~= 'private' then
                                local message_id = sendReply(msg, langs[msg.lang].sendPermissionsPvt, 'html').result.message_id
                                io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
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
                                    local obj_user = getChat(msg.entities[k].user.id)
                                    if type(obj_user) == 'table' then
                                        if obj_user then
                                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                                if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. obj_user.id .. ') ' .. obj_user.first_name .. ' ' ..(obj_user.last_name or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[16], keyboard_permissions_list(msg.chat.id, obj_user.id)) then
                                                    if msg.chat.type ~= 'private' then
                                                        local message_id = sendReply(msg, langs[msg.lang].sendPermissionsPvt, 'html').result.message_id
                                                        io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                                        io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
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
                                    if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. obj_user.id .. ') ' .. obj_user.first_name .. ' ' ..(obj_user.last_name or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[16], keyboard_permissions_list(msg.chat.id, obj_user.id)) then
                                        if msg.chat.type ~= 'private' then
                                            local message_id = sendReply(msg, langs[msg.lang].sendPermissionsPvt, 'html').result.message_id
                                            io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                            io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
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
                                if sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', '(' .. msg.chat.id .. ') ' .. chat_name), 'X', tostring('(' .. obj_user.id .. ') ' .. obj_user.first_name .. ' ' ..(obj_user.last_name or ''))) .. '\n' .. langs[msg.lang].permissionsIntro .. langs[msg.lang].faq[16], keyboard_permissions_list(msg.chat.id, obj_user.id)) then
                                    if msg.chat.type ~= 'private' then
                                        local message_id = sendReply(msg, langs[msg.lang].sendPermissionsPvt, 'html').result.message_id
                                        io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                                        io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
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
                    redis:del('whitelist:' .. msg.chat.tg_cli_id)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned whitelist")
                    return langs[msg.lang].whitelistCleaned
                elseif matches[2]:lower() == 'whitelistgban' then
                    mystat('/clean whitelistgban')
                    redis:del('whitelist:gban:' .. msg.chat.tg_cli_id)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned whitelistgban")
                    return langs[msg.lang].whitelistGbanCleaned
                elseif matches[2]:lower() == 'whitelistlink' then
                    mystat('/clean whitelistlink')
                    data[tostring(msg.chat.id)].settings.links_whitelist = { }
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned links_whitelist")
                    --
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
                        if not is_admin(msg) then
                            sendMessage(msg.chat.id, banUser(bot.id, v.id, msg.chat.id, langs[msg.lang].reasonInviteRealm))
                        end
                    end
                elseif msg.service_type == 'chat_add_user' or msg.service_type == 'chat_add_users' then
                    local text = ''
                    for k, v in pairs(msg.added) do
                        if v.id ~= bot.userVersion.id then
                            -- if not admin and not bot then
                            if not is_admin(msg) then
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
                if data[tostring(msg.chat.id)].settings.lock_name then
                    setChatTitle(msg.chat.id, data[tostring(msg.chat.id)].set_name)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] renamed the chat N")
                else
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] renamed the chat Y")
                end
            elseif msg.service_type == 'chat_change_photo' then
                if data[tostring(msg.chat.id)].settings.lock_photo and data[tostring(msg.chat.id)].photo then
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
                if data[tostring(msg.chat.id)].settings.lock_photo and data[tostring(msg.chat.id)].photo then
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
    adminsContacted = { }
    noticeContacted = { }
end

return {
    description = "GROUP_MANAGEMENT",
    cron = cron,
    patterns =
    {
        "^(###cbgroup_management)(DELETE)$",
        "^(###cbgroup_management)(BACKSETTINGS)(%-%d+)$",
        "^(###cbgroup_management)(BACKSETTINGS)(%-%d+)(.)$",
        "^(###cbgroup_management)(BACKMUTES)(%-%d+)$",
        "^(###cbgroup_management)(BACKMUTES)(%-%d+)(.)$",
        "^(###cbgroup_management)(BACKPERMISSIONS)(%d+)(%-%d+)$",
        "^(###cbgroup_management)(BACKPERMISSIONS)(%d+)(%-%d+)(.)$",
        "^(###cbgroup_management)(LOCK)(.*)(%-%d+)$",
        "^(###cbgroup_management)(LOCK)(.*)(%-%d+)(.)$",
        "^(###cbgroup_management)(UNLOCK)(.*)(%-%d+)$",
        "^(###cbgroup_management)(UNLOCK)(.*)(%-%d+)(.)$",
        "^(###cbgroup_management)(MUTE)(.*)(%-%d+)$",
        "^(###cbgroup_management)(MUTE)(.*)(%-%d+)(.)$",
        "^(###cbgroup_management)(UNMUTE)(.*)(%-%d+)$",
        "^(###cbgroup_management)(UNMUTE)(.*)(%-%d+)(.)$",
        "^(###cbgroup_management)(FLOODPLUS)(%d+)(%-%d+)$",
        "^(###cbgroup_management)(FLOODPLUS)(%d+)(%-%d+)(.)$",
        "^(###cbgroup_management)(FLOODMINUS)(%d+)(%-%d+)$",
        "^(###cbgroup_management)(FLOODMINUS)(%d+)(%-%d+)(.)$",
        "^(###cbgroup_management)(WARNS)(%d+)(%-%d+)$",
        "^(###cbgroup_management)(WARNS)(%d+)(%-%d+)(.)$",
        "^(###cbgroup_management)(WARNSPLUS)(%d+)(%-%d+)$",
        "^(###cbgroup_management)(WARNSPLUS)(%d+)(%-%d+)(.)$",
        "^(###cbgroup_management)(WARNSMINUS)(%d+)(%-%d+)$",
        "^(###cbgroup_management)(WARNSMINUS)(%d+)(%-%d+)(.)$",
        "^(###cbgroup_management)(GRANT)(%d+)(.*)(%-%d+)$",
        "^(###cbgroup_management)(GRANT)(%d+)(.*)(%-%d+)(.)$",
        "^(###cbgroup_management)(DENY)(%d+)(.*)(%-%d+)$",
        "^(###cbgroup_management)(DENY)(%d+)(.*)(%-%d+)(.)$",

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
        "^[#!/]([Tt][Yy][Pp][Ee])$",
        "^[#!/]([Ll][Oo][Gg])$",
        "^[#!/@]([Aa][Dd][Mm][Ii][Nn][Ss])",
        "^[#!/]([Rr][Uu][Ll][Ee][Ss])$",
        "^[#!/]([Aa][Bb][Oo][Uu][Tt])$",
        "^[#!/]([Ss][Ee][Tt][Ff][Ll][Oo][Oo][Dd]) (%d+)$",
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
        "^[#!/]([Mm][Uu][Tt][Ee][Ss][Ll][Ii][Ss][Tt])",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Mm][Uu][Tt][Ee][Ss][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Uu][Nn][Mm][Uu][Tt][Ee]) ([^%s]+)",
        "^[#!/]([Mm][Uu][Tt][Ee]) ([^%s]+)",
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
        "^[#!/]([Uu][Nn][Ll][Oo][Cc][Kk]) ([^%s]+)$",
        "^[#!/]([Mm][Oo][Dd][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Cc][Ll][Ee][Aa][Nn]) ([^%s]+)$",
        "^[#!/]([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) ([^%s]+)$",
        "^[#!/]([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr])$",
        "^[#!/]([Ss][Ee][Tt][Ww][Aa][Rr][Nn]) (%d+)$",
        "^[#!/]([Gg][Ee][Tt][Ww][Aa][Rr][Nn])$",
        "^[#!/]([Mm][Ss][Gg][Ii][Dd])$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "/getwarn",
        "/rules",
        "/modlist",
        "/owner",
        "/admins [{reply}|{text}]",
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
        "/type",
        "/updategroupinfo",
        "/setrules {text}",
        "/setwarn {value}",
        "/setflood {value}",
        "/newlink",
        "/lock arabic|bots|flood|grouplink|leave|link|member|rtl|spam|strict",
        "/unlock arabic|bots|flood|grouplink|leave|link|member|rtl|spam|strict",
        "/mute audio|contact|document|gif|location|photo|sticker|tgservice|video|video_note|voice_note",
        "/unmute audio|contact|document|gif|location|photo|sticker|tgservice|video|video_note|voice_note",
        "/pin {reply}",
        "/silentpin {reply}",
        "/unpin",
        "/settitle {text}",
        "/setdescription {text}",
        "/setphoto {reply}",
        "/unsetphoto",
        "OWNER",
        "/syncmodlist",
        "/log",
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