-- REFACTORING OF INPM.LUA INREALM.LUA INGROUP.LUA AND SUPERGROUP.LUA
default_settings = {
    goodbye = nil,
    group_type = 'Unknown',
    moderators = { },
    photo = nil,
    rules = nil,
    set_name = 'TITLE',
    set_owner = '41400331',
    settings =
    {
        flood = true,
        flood_max = 5,
        lock_arabic = false,
        lock_bots = false,
        lock_group_link = true,
        lock_leave = false,
        lock_link = false,
        lock_member = false,
        lock_name = false,
        lock_photo = false,
        lock_rtl = false,
        lock_spam = false,
        mutes =
        {
            all = false,
            audio = false,
            contact = false,
            document = false,
            gif = false,
            location = false,
            photo = false,
            sticker = false,
            text = false,
            tgservice = false,
            video = false,
            video_note = false,
            voice_note = false,
        },
        strict = false,
        warn_max = 3,
    },
    welcome = nil,
    welcomemembers = 0,
}
default_permissions = {
    ['can_change_info'] = true,
    ['can_delete_messages'] = true,
    ['can_invite_users'] = true,
    ['can_restrict_members'] = true,
    ['can_pin_messages'] = true,
    ['can_promote_members'] = false,
}

-- INREALM
-- begin ADD/REM GROUPS
local function addGroup(msg)
    if is_group(msg) then
        return langs[msg.lang].groupAlreadyAdded
    end
    local list = getChatAdministrators(msg.chat.id)
    if list then
        if list.result then
            for i, admin in pairs(list.result) do
                if admin.status == 'creator' then
                    -- Group configuration
                    data[tostring(msg.chat.id)] = clone_table(default_settings)
                    data[tostring(msg.chat.id)].group_type = 'Group'
                    data[tostring(msg.chat.id)].set_name = string.gsub(msg.chat.print_name, '_', ' ')
                    data[tostring(msg.chat.id)].set_owner = tostring(admin.user.id)
                    save_data(config.moderation.data, data)
                    if not data['groups'] then
                        data['groups'] = { }
                        save_data(config.moderation.data, data)
                    end
                    data['groups'][tostring(msg.chat.id)] = msg.chat.id
                    save_data(config.moderation.data, data)
                end
            end
            if data[tostring(msg.chat.id)] then
                for i, admin in pairs(list.result) do
                    if admin.status == 'creator' or admin.status == 'administrator' then
                        if admin.user.id ~= bot.userVersion.id and admin.user.id ~= bot.id then
                            data[tostring(msg.chat.id)].moderators[tostring(admin.user.id)] =(admin.user.username or(admin.user.first_name ..(admin.user.last_name or '')))
                        end
                    end
                end
                save_data(config.moderation.data, data)
            end
            return langs[msg.lang].groupAddedOwner
        end
    end
end

local function remGroup(msg)
    if not is_group(msg) then
        return langs[msg.lang].groupNotAdded
    end
    -- Group configuration removal
    data[tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    if not data['groups'] then
        data['groups'] = nil
        save_data(config.moderation.data, data)
    end
    data['groups'][tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    alternatives[tostring(msg.chat.id)] = nil
    save_data(config.alternatives.db, alternatives)
    local likecounter = load_data(config.likecounter.db)
    likecounter[tostring(msg.chat.id)] = nil
    save_data(config.likecounter.db, likecounter)
    return langs[msg.lang].groupRemoved
end

local function addRealm(msg)
    if is_realm(msg) then
        return langs[msg.lang].realmAlreadyAdded
    end
    local list = getChatAdministrators(msg.chat.id)
    if list then
        if list.result then
            for i, admin in pairs(list.result) do
                if admin.status == 'creator' then
                    -- Realm configuration
                    data[tostring(msg.chat.id)] = clone_table(default_settings)
                    data[tostring(msg.chat.id)].group_type = 'Realm'
                    data[tostring(msg.chat.id)].set_name = string.gsub(msg.chat.print_name, '_', ' ')
                    data[tostring(msg.chat.id)].set_owner = tostring(admin.user.id)
                    save_data(config.moderation.data, data)
                    if not data['realms'] then
                        data['realms'] = { }
                        save_data(config.moderation.data, data)
                    end
                    data['realms'][tostring(msg.chat.id)] = msg.chat.id
                    save_data(config.moderation.data, data)
                    return langs[msg.lang].realmAdded
                end
            end
        end
    end
end

local function remRealm(msg)
    if not is_realm(msg) then
        return langs[msg.lang].realmNotAdded
    end
    -- Realm configuration removal
    data[tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    if not data['realms'] then
        data['realms'] = nil
        save_data(config.moderation.data, data)
    end
    data['realms'][tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    alternatives[tostring(msg.chat.id)] = nil
    save_data(config.alternatives.db, alternatives)
    local likecounter = load_data(config.likecounter.db)
    likecounter[tostring(msg.chat.id)] = nil
    save_data(config.likecounter.db, likecounter)
    return langs[msg.lang].realmRemoved
end

local function addSuperGroup(msg)
    if is_super_group(msg) then
        return langs[msg.lang].supergroupAlreadyAdded
    end
    local list = getChatAdministrators(msg.chat.id)
    if list then
        if list.result then
            for i, admin in pairs(list.result) do
                if admin.status == 'creator' then
                    -- SuperGroup configuration
                    data[tostring(msg.chat.id)] = clone_table(default_settings)
                    data[tostring(msg.chat.id)].group_type = 'SuperGroup'
                    data[tostring(msg.chat.id)].set_name = string.gsub(msg.chat.print_name, '_', ' ')
                    data[tostring(msg.chat.id)].set_owner = tostring(admin.user.id)
                    save_data(config.moderation.data, data)
                    if not data['groups'] then
                        data['groups'] = { }
                        save_data(config.moderation.data, data)
                    end
                    data['groups'][tostring(msg.chat.id)] = msg.chat.id
                    save_data(config.moderation.data, data)
                end
            end
            if data[tostring(msg.chat.id)] then
                for i, admin in pairs(list.result) do
                    if admin.status == 'creator' or admin.status == 'administrator' then
                        if admin.user.id ~= bot.userVersion.id and admin.user.id ~= bot.id then
                            data[tostring(msg.chat.id)].moderators[tostring(admin.user.id)] =(admin.user.username or(admin.user.first_name ..(admin.user.last_name or '')))
                        end
                    end
                end
                save_data(config.moderation.data, data)
            end
            return langs[msg.lang].groupAddedOwner
        end
    end
end

local function remSuperGroup(msg)
    if not is_super_group(msg) then
        return langs[msg.lang].groupNotAdded
    end
    -- Group configuration removal
    data[tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    if not data['groups'] then
        data['groups'] = nil
        save_data(config.moderation.data, data)
    end
    data['groups'][tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    alternatives[tostring(msg.chat.id)] = nil
    save_data(config.alternatives.db, alternatives)
    local likecounter = load_data(config.likecounter.db)
    likecounter[tostring(msg.chat.id)] = nil
    save_data(config.likecounter.db, likecounter)
    return langs[msg.lang].supergroupRemoved
end
-- end ADD/REM GROUPS

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
        if obj_user.status ~= 'creator' or obj_user.status ~= 'administrator' then
            local text = langs[lang].permissions ..
            langs[lang].permissionCanBeEdited .. tostring(obj_user.can_be_edited or false) ..
            langs[lang].permissionChangeInfo .. tostring(obj_user.can_change_info or false) ..
            langs[lang].permissionDeleteMessages .. tostring(obj_user.can_delete_messages or false) ..
            langs[lang].permissionInviteUsers .. tostring(obj_user.can_invite_users or false) ..
            langs[lang].permissionPinMessages .. tostring(obj_user.can_pin_messages or false) ..
            langs[lang].permissionPromoteMembers .. tostring(obj_user.can_promote_members or false) ..
            langs[lang].permissionRestrictMembers .. tostring(obj_user.can_restrict_members or false)
            return text
        else
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
    else
        return langs[lang].errorTryAgain
    end
end

local function reverseAdjustPermissions(permission_type)
    if permission_type == 'can_change_info' then
        permission_type = 'change_info'
    end
    if permission_type == 'can_delete_messages' then
        permission_type = 'delete_messages'
    end
    if permission_type == 'can_invite_users' then
        permission_type = 'invite_users'
    end
    if permission_type == 'can_restrict_members' then
        permission_type = 'restrict_members'
    end
    if permission_type == 'can_pin_messages' then
        permission_type = 'pin_messages'
    end
    if permission_type == 'can_promote_members' then
        permission_type = 'promote_members'
    end
    return permission_type
end

local function adjustPermissions(param_permissions)
    local permissions = {
        ['can_change_info'] = false,
        ['can_delete_messages'] = false,
        ['can_invite_users'] = false,
        ['can_restrict_members'] = false,
        ['can_pin_messages'] = false,
        ['can_promote_members'] = false,
    }
    if param_permissions then
        if type(param_permissions) == 'table' then
            for k, v in pairs(param_permissions) do
                if v == 'can_change_info' or v == 'can_delete_messages' or v == 'can_invite_users' or v == 'can_restrict_members' or v == 'can_pin_messages' or v == 'can_promote_members' then
                    permissions[tostring(v)] = param_permissions[tostring(v)]
                end
            end
        elseif type(param_permissions) == 'string' then
            local permission_type = ''
            param_permissions = param_permissions:lower()
            for k, v in pairs(param_permissions:split(' ')) do
                if v == 'change_info' then
                    permission_type = 'can_change_info'
                end
                if v == 'delete_messages' then
                    permission_type = 'can_delete_messages'
                end
                if v == 'invite_users' then
                    permission_type = 'can_invite_users'
                end
                if v == 'restrict_members' then
                    permission_type = 'can_restrict_members'
                end
                if v == 'pin_messages' then
                    permission_type = 'can_pin_messages'
                end
                if v == 'promote_members' then
                    permission_type = 'can_promote_members'
                end
                if permission_type ~= '' then
                    permissions[tostring(permission_type)] = true
                end
                permission_type = ''
            end
        end
    end
    return permissions
end

-- begin RANKS MANAGEMENT
local function setOwner(user, chat_id)
    local lang = get_lang(chat_id)
    data[tostring(chat_id)]['set_owner'] = tostring(user.id)
    save_data(config.moderation.data, data)
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
        data[tostring(chat_id)]['moderators'][tostring(user.id)] =(user.username or user.print_name or user.first_name)
        save_data(config.moderation.data, data)
        return(user.username or user.print_name or user.first_name) .. langs[lang].promoteModAdmin
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

local function contactMods(msg)
    local hashtag = '#admins' .. tostring(msg.message_id)
    local text = langs[msg.lang].receiver .. msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']\n' .. langs[msg.lang].sender
    if msg.from.username then
        text = text .. '@' .. msg.from.username .. ' [' .. msg.from.id .. ']\n'
    else
        text = text .. msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']\n'
    end
    text = text .. langs[msg.lang].msgText ..(msg.text or msg.caption) .. '\n' ..
    'HASHTAG: ' .. hashtag

    sendMessage(msg.chat.id, hashtag)

    local already_contacted = { }
    local cant_contact = ''
    local list = getChatAdministrators(msg.chat.id)
    if list then
        for i, admin in pairs(list.result) do
            already_contacted[tonumber(admin.user.id)] = admin.user.id
            if sendChatAction(admin.user.id, 'typing') then
                if msg.reply then
                    forwardMessage(admin.user.id, msg.chat.id, msg.reply_to_message.message_id)
                end
                sendMessage(admin.user.id, text)
            else
                cant_contact = cant_contact .. admin.user.id .. ' ' .. admin.user.username or('NOUSER ' .. admin.user.first_name .. ' ' ..(admin.user.last_name or '')) .. '\n'
            end
        end
    end

    -- owner
    local owner = data[tostring(msg.chat.id)]['set_owner']
    if owner then
        if not already_contacted[tonumber(owner)] then
            already_contacted[tonumber(owner)] = owner
            if sendChatAction(admin.user.id, 'typing') then
                if msg.reply then
                    forwardMessage(owner, msg.chat.id, msg.reply_to_message.message_id)
                end
                sendMessage(owner, text)
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
                if sendChatAction(admin.user.id, 'typing') then
                    already_contacted[tonumber(k)] = k
                    if msg.reply then
                        forwardMessage(k, msg.chat.id, msg.reply_to_message.message_id)
                    end
                    sendMessage(k, text)
                else
                    cant_contact = cant_contact .. k .. '\n'
                end
            end
        end
    end
    if cant_contact ~= '' then
        sendMessage(msg.chat.id, langs[msg.lang].cantContact .. cant_contact)
    end
end
-- end RANKS MANAGEMENT

local function showSettings(target, lang)
    if data[tostring(target)] then
        if data[tostring(target)]['settings'] then
            local settings = data[tostring(target)]['settings']
            local text = langs[lang].groupSettings ..
            langs[lang].arabicLock .. tostring(settings.lock_arabic) ..
            langs[lang].botsLock .. tostring(settings.lock_bots) ..
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
local function adjustSettingType(setting_type)
    if setting_type == 'arabic' then
        setting_type = 'lock_arabic'
    end
    if setting_type == 'bots' then
        setting_type = 'lock_bots'
    end
    if setting_type == 'flood' then
        setting_type = 'flood'
    end
    if setting_type == 'grouplink' then
        setting_type = 'lock_group_link'
    end
    if setting_type == 'leave' then
        setting_type = 'lock_leave'
    end
    if setting_type == 'link' then
        setting_type = 'lock_link'
    end
    if setting_type == 'member' then
        setting_type = 'lock_member'
    end
    if setting_type == 'name' then
        setting_type = 'lock_name'
    end
    if setting_type == 'photo' then
        setting_type = 'lock_photo'
    end
    if setting_type == 'rtl' then
        setting_type = 'lock_rtl'
    end
    if setting_type == 'spam' then
        setting_type = 'lock_spam'
    end
    if setting_type == 'strict' then
        setting_type = 'strict'
    end
    return setting_type
end

local function reverseAdjustSettingType(setting_type)
    if setting_type == 'lock_arabic' then
        setting_type = 'arabic'
    end
    if setting_type == 'lock_bots' then
        setting_type = 'bots'
    end
    if setting_type == 'flood' then
        setting_type = 'flood'
    end
    if setting_type == 'lock_group_link' then
        setting_type = 'grouplink'
    end
    if setting_type == 'lock_leave' then
        setting_type = 'leave'
    end
    if setting_type == 'lock_link' then
        setting_type = 'link'
    end
    if setting_type == 'lock_member' then
        setting_type = 'member'
    end
    if setting_type == 'lock_name' then
        setting_type = 'name'
    end
    if setting_type == 'lock_photo' then
        setting_type = 'photo'
    end
    if setting_type == 'lock_rtl' then
        setting_type = 'rtl'
    end
    if setting_type == 'lock_spam' then
        setting_type = 'spam'
    end
    if setting_type == 'strict' then
        setting_type = 'strict'
    end
    return setting_type
end

function lockSetting(target, setting_type)
    local lang = get_lang(target)
    setting_type = adjustSettingType(setting_type)
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

function unlockSetting(target, setting_type)
    local lang = get_lang(target)
    setting_type = adjustSettingType(setting_type)
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

local function checkMatchesLockUnlock(txt)
    if txt:lower() == 'arabic' then
        return true
    end
    if txt:lower() == 'bots' then
        return true
    end
    if txt:lower() == 'flood' then
        return true
    end
    if txt:lower() == 'grouplink' then
        return true
    end
    if txt:lower() == 'leave' then
        return true
    end
    if txt:lower() == 'link' then
        return true
    end
    if txt:lower() == 'member' then
        return true
    end
    if txt:lower() == 'name' then
        return true
    end
    if txt:lower() == 'photo' then
        return true
    end
    if txt:lower() == 'rtl' then
        return true
    end
    if txt:lower() == 'spam' then
        return true
    end
    if txt:lower() == 'strict' then
        return true
    end
    return false
end
-- end LOCK/UNLOCK FUNCTIONS

local function checkMatchesMuteUnmute(txt)
    if txt:lower() == 'all' then
        return true
    end
    if txt:lower() == 'audio' then
        return true
    end
    if txt:lower() == 'contact' then
        return true
    end
    if txt:lower() == 'document' then
        return true
    end
    if txt:lower() == 'gif' then
        return true
    end
    if txt:lower() == 'location' then
        return true
    end
    if txt:lower() == 'photo' then
        return true
    end
    if txt:lower() == 'sticker' then
        return true
    end
    if txt:lower() == 'text' then
        return true
    end
    if txt:lower() == 'tgservice' then
        return true
    end
    if txt:lower() == 'video' then
        return true
    end
    if txt:lower() == 'video_note' then
        return true
    end
    if txt:lower() == 'voice_note' then
        return true
    end
    return false
end

local function keyboard_permissions_list(chat_id, user_id)
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
        local permissions = adjustPermissions(obj_user)
        local keyboard = { }
        keyboard.inline_keyboard = { }
        local row = 1
        local column = 1
        local flag = false
        keyboard.inline_keyboard[row] = { }
        for var, value in pairs(permissions) do
            if type(value) == 'boolean' then
                if flag then
                    flag = false
                    row = row + 1
                    column = 1
                    keyboard.inline_keyboard[row] = { }
                end
                if value then
                    keyboard.inline_keyboard[row][column] = { text = '✅ ' .. reverseAdjustPermissions(var), callback_data = 'group_managementDENY' .. user_id .. var .. chat_id }
                else
                    keyboard.inline_keyboard[row][column] = { text = '☑️ ' .. reverseAdjustPermissions(var), callback_data = 'group_managementGRANT' .. user_id .. var .. chat_id }
                end
                column = column + 1
                if column > 1 then
                    flag = true
                end
            end
        end
        row = row + 1
        column = 1
        keyboard.inline_keyboard[row] = { }
        keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].updateKeyboard, callback_data = 'group_managementBACKPERMISSIONS' .. user_id .. chat_id }
        column = column + 1
        keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].deleteKeyboard, callback_data = 'group_managementDELETE' }
        return keyboard
    end
end

local function keyboard_settings_list(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local flag = false
    keyboard.inline_keyboard[row] = { }
    for var, value in pairs(data[tostring(chat_id)].settings) do
        if reverseAdjustSettingType(var) ~= 'flood' then
            if type(value) == 'boolean' then
                if flag then
                    flag = false
                    row = row + 1
                    column = 1
                    keyboard.inline_keyboard[row] = { }
                end
                if value then
                    keyboard.inline_keyboard[row][column] = { text = '✅ ' .. reverseAdjustSettingType(var), callback_data = 'group_managementUNLOCK' .. var .. chat_id }
                else
                    keyboard.inline_keyboard[row][column] = { text = '☑️ ' .. reverseAdjustSettingType(var), callback_data = 'group_managementLOCK' .. var .. chat_id }
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
    keyboard.inline_keyboard[row][column] = { text = '➖', callback_data = 'group_managementFLOODMINUS' .. data[tostring(chat_id)].settings.flood_max .. chat_id }
    column = column + 1
    if data[tostring(chat_id)].settings.flood then
        keyboard.inline_keyboard[row][column] = { text = '✅ flood (' .. data[tostring(chat_id)].settings.flood_max .. ')', callback_data = 'group_managementUNLOCKflood' .. chat_id }
    else
        keyboard.inline_keyboard[row][column] = { text = '☑️ flood (' .. data[tostring(chat_id)].settings.flood_max .. ')', callback_data = 'group_managementLOCKflood' .. chat_id }
    end
    column = column + 1
    keyboard.inline_keyboard[row][column] = { text = '➕', callback_data = 'group_managementFLOODPLUS' .. data[tostring(chat_id)].settings.flood_max .. chat_id }
    -- end flood part

    row = row + 1
    column = 1
    keyboard.inline_keyboard[row] = { }
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].updateKeyboard, callback_data = 'group_managementBACKSETTINGS' .. chat_id }
    column = column + 1
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].deleteKeyboard, callback_data = 'group_managementDELETE' }
    return keyboard
end

local function keyboard_mutes_list(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local flag = false
    keyboard.inline_keyboard[row] = { }
    for var, value in pairs(data[tostring(chat_id)].settings.mutes) do
        if flag then
            flag = false
            row = row + 1
            column = 1
            keyboard.inline_keyboard[row] = { }
        end
        if value then
            keyboard.inline_keyboard[row][column] = { text = '🔇 ' .. var, callback_data = 'group_managementUNMUTE' .. var .. chat_id }
        else
            keyboard.inline_keyboard[row][column] = { text = '🔊 ' .. var, callback_data = 'group_managementMUTE' .. var .. chat_id }
        end
        column = column + 1
        if column > 2 then
            flag = true
        end
    end
    row = row + 1
    column = 1
    keyboard.inline_keyboard[row] = { }
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].updateKeyboard, callback_data = 'group_managementBACKMUTES' .. chat_id }
    column = column + 1
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].deleteKeyboard, callback_data = 'group_managementDELETE' }
    return keyboard
end

local function run(msg, matches)
    if msg.service then
        print('service')
        if is_realm(msg) then
            if msg.service_type == 'chat_add_user_link' then
                if msg.from.id ~= bot.userVersion.id then
                    -- if not admin and not bot then
                    if not is_admin(msg) then
                        return banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonInviteRealm)
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
                return text .. langs[msg.lang].reasonInviteRealm
            end
        end
        if is_group(msg) then
            if msg.service_type == 'chat_del_user' then
                return savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] deleted user  " .. 'user#id' .. msg.removed.id)
            end
        end
        if msg.service_type == 'chat_rename' then
            if data[tostring(msg.chat.id)].settings.lock_name then
                return setChatTitle(msg.chat.id, data[tostring(msg.chat.id)].set_name)
            end
        elseif msg.service_type == 'chat_change_photo' then
            if data[tostring(msg.chat.id)].settings.lock_photo and data[tostring(msg.chat.id)].photo then
                return setChatPhotoId(msg.chat.id, data[tostring(msg.chat.id)].photo)
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
                return
            end
        elseif msg.service_type == 'delete_chat_photo' then
            if data[tostring(msg.chat.id)].settings.lock_photo and data[tostring(msg.chat.id)].photo then
                return setChatPhotoId(msg.chat.id, data[tostring(msg.chat.id)].photo)
            end
        end
    end
    if msg.cb then
        if matches[1] then
            if matches[1] == '###cbgroup_management' then
                if matches[2] then
                    if matches[2] == 'DELETE' then
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                    elseif matches[2] == 'BACKSETTINGS' then
                        if matches[3] then
                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. matches[3] .. '\n' .. langs[msg.lang].locksIntro, keyboard_settings_list(matches[3]))
                        end
                    elseif matches[2] == 'BACKMUTES' then
                        if matches[3] then
                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].mutesOf .. matches[3], keyboard_mutes_list(matches[3]))
                        end
                    elseif matches[2] == 'BACKPERMISSIONS' then
                        if matches[3] and matches[4] then
                            editMessageText(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', matches[4]), 'X', tostring(matches[3])) .. '\n' .. langs[msg.lang].permissionsIntro, keyboard_permissions_list(matches[4], matches[3]))
                        end
                    elseif matches[3] and matches[4] then
                        if matches[2] == 'LOCK' then
                            if is_mod2(msg.from.id, matches[4]) then
                                mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4])
                                answerCallbackQuery(msg.cb_id, lockSetting(tonumber(matches[4]), matches[3]), false)
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. matches[4] .. '\n' .. langs[msg.lang].locksIntro, keyboard_settings_list(matches[4]))
                            else
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                            end
                        elseif matches[2] == 'UNLOCK' then
                            if is_mod2(msg.from.id, matches[4]) then
                                mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4])
                                answerCallbackQuery(msg.cb_id, unlockSetting(tonumber(matches[4]), matches[3]), false)
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. matches[4] .. '\n' .. langs[msg.lang].locksIntro, keyboard_settings_list(matches[4]))
                            else
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                            end
                        elseif matches[2] == 'MUTE' then
                            if is_owner2(msg.from.id, matches[4]) then
                                mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4])
                                answerCallbackQuery(msg.cb_id, mute(tonumber(matches[4]), matches[3]), false)
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].mutesOf .. matches[4], keyboard_mutes_list(matches[4]))
                            else
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                            end
                        elseif matches[2] == 'UNMUTE' then
                            if is_owner2(msg.from.id, matches[4]) then
                                mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4])
                                answerCallbackQuery(msg.cb_id, unmute(tonumber(matches[4]), matches[3]), false)
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].mutesOf .. matches[4], keyboard_mutes_list(matches[4]))
                            else
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                            end
                        elseif matches[2] == 'FLOODPLUS' or matches[2] == 'FLOODMINUS' then
                            if is_mod2(msg.from.id, matches[4]) then
                                local flood = matches[3]
                                if matches[2] == 'FLOODPLUS' then
                                    flood = flood + 1
                                elseif matches[2] == 'FLOODMINUS' then
                                    flood = flood - 1
                                end
                                if tonumber(flood) < 3 or tonumber(flood) > 20 then
                                    return answerCallbackQuery(msg.cb_id, langs[msg.lang].errorFloodRange, false)
                                end
                                mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4])
                                data[tostring(matches[4])].settings.flood_max = flood
                                save_data(config.moderation.data, data)
                                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set flood to [" .. flood .. "]")
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].floodSet .. flood, false)
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. matches[4] .. '\n' .. langs[msg.lang].locksIntro, keyboard_settings_list(matches[4]))
                            else
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                            end
                        elseif matches[5] then
                            if matches[2] == 'GRANT' then
                                if is_owner2(msg.from.id, matches[5]) then
                                    mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4] .. matches[5])
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
                                        local permissions = adjustPermissions(obj_user)
                                        if promoteTgAdmin(matches[5], obj_user, permissions) ~= langs[msg.lang].checkMyPermissions then
                                            answerCallbackQuery(msg.cb_id, matches[4] .. langs[msg.lang].granted, false)
                                            editMessageText(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', matches[5]), 'X', tostring(matches[3])) .. '\n' .. langs[msg.lang].permissionsIntro, keyboard_permissions_list(matches[5], matches[3]))
                                        else
                                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].checkMyPermissions)
                                        end
                                    end
                                else
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                                end
                            elseif matches[2] == 'DENY' then
                                if is_owner2(msg.from.id, matches[5]) then
                                    mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4] .. matches[5])
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
                                        local permissions = adjustPermissions(obj_user)
                                        if promoteTgAdmin(matches[5], obj_user, permissions) ~= langs[msg.lang].checkMyPermissions then
                                            answerCallbackQuery(msg.cb_id, matches[4] .. langs[msg.lang].denied, false)
                                            editMessageText(msg.chat.id, msg.message_id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', matches[5]), 'X', tostring(matches[3])) .. '\n' .. langs[msg.lang].permissionsIntro, keyboard_permissions_list(matches[5], matches[3]))
                                        else
                                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].checkMyPermissions)
                                        end
                                    end
                                else
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                                end
                            end
                        end
                    end
                    return
                end
            end
        end
    end
    if matches[1]:lower() == 'type' then
        if msg.from.is_mod then
            mystat('/type')
            if data[tostring(msg.chat.id)] then
                if not data[tostring(msg.chat.id)]['group_type'] then
                    if msg.chat.type == 'group' and not is_realm(msg) then
                        data[tostring(msg.chat.id)]['group_type'] = 'Group'
                        save_data(config.moderation.data, data)
                    elseif msg.chat.type == 'supergroup' then
                        data[tostring(msg.chat.id)]['group_type'] = 'SuperGroup'
                        save_data(config.moderation.data, data)
                    end
                end
                return data[tostring(msg.chat.id)]['group_type']
            else
                return langs[msg.lang].chatTypeNotFound
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
            return contactMods(msg)
        else
            return langs[msg.lang].useYourGroups
        end
    end

    -- INREALM
    if is_realm(msg) then
        if matches[1]:lower() == 'rem' and string.match(matches[2], '^%-?%d+$') then
            if is_admin(msg) then
                mystat('/rem <group_id>')
                -- Group configuration removal
                data[tostring(matches[2])] = nil
                save_data(config.moderation.data, data)
                if not data[tostring('groups')] then
                    data[tostring('groups')] = nil
                    save_data(config.moderation.data, data)
                end
                data[tostring('groups')][tostring(matches[2])] = nil
                save_data(config.moderation.data, data)
                return langs[msg.lang].chat .. matches[2] .. langs[msg.lang].removed
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'lock' and matches[2] and matches[3] then
            if is_admin(msg) then
                if checkMatchesLockUnlock(matches[3]) then
                    mystat('/lock <group_id> ' .. matches[3]:lower())
                    return lockSetting(matches[2], matches[3]:lower())
                end
                return
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'unlock' and matches[2] and matches[3] then
            if is_admin(msg) then
                if checkMatchesLockUnlock(matches[3]) then
                    mystat('/unlock <group_id> ' .. matches[3]:lower())
                    return unlockSetting(matches[2], matches[3]:lower())
                end
                return
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'mute' and matches[2] and matches[3] then
            if is_admin(msg) then
                if checkMatchesMuteUnmute(matches[3]) then
                    mystat('/mute <group_id> ' .. matches[3]:lower())
                    return mute(msg.chat.id, matches[3]:lower())
                end
                return
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'unmute' and matches[2] and matches[3] then
            if is_admin(msg) then
                if checkMatchesMuteUnmute(matches[3]) then
                    mystat('/unmute <group_id> ' .. matches[3]:lower())
                    return unmute(msg.chat.id, matches[3]:lower())
                end
                return
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'muteslist' and matches[2] then
            if is_admin(msg) then
                if msg.chat.type ~= 'private' then
                    sendMessage(msg.chat.id, langs[msg.lang].sendMutesPvt)
                end
                mystat('/muteslist <group_id>')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist " .. matches[2])
                sendKeyboard(msg.from.id, langs[msg.lang].mutesOf .. matches[2], keyboard_mutes_list(matches[2]))
                return
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'textualmuteslist' and matches[2] then
            if is_admin(msg) then
                mystat('/muteslist <group_id>')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist " .. matches[2])
                return mutesList(matches[2])
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'settings' and matches[2] then
            if is_admin(msg) then
                if msg.chat.type ~= 'private' then
                    sendReply(msg, langs[msg.lang].sendSettingsPvt)
                end
                mystat('/settings <group_id>')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group settings " .. matches[2])
                sendKeyboard(msg.from.id, langs[msg.lang].settingsOf .. matches[2] .. '\n' .. langs[msg.lang].locksIntro, keyboard_settings_list(matches[2]))
                return
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'textualsettings' and matches[2] then
            if is_admin(msg) then
                mystat('/settings <group_id>')
                return showSettings(matches[2], msg.lang)
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'setgprules' and matches[2] and matches[3] then
            if is_admin(msg) then
                mystat('/setgprules <group_id>')
                data[tostring(matches[2])].rules = matches[3]
                save_data(config.moderation.data, data)
                return langs[msg.lang].newRules .. matches[3]
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'setgpowner' and matches[2] and matches[3] then
            if is_admin(msg) then
                if data[tostring(matches[2])] then
                    mystat('/setgpowner <group_id> <user_id>')
                    data[tostring(matches[2])].set_owner = matches[3]
                    save_data(config.moderation.data, data)
                    sendMessage(matches[2], matches[3] .. langs[get_lang(matches[2])].setOwner)
                    return matches[3] .. langs[msg.lang].setOwner
                end
            else
                return langs[msg.lang].require_admin
            end
        end
    end

    -- INGROUP/SUPERGROUP
    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
        if matches[1]:lower() == 'add' and not matches[2] then
            if is_admin(msg) then
                if is_realm(msg) then
                    return langs[msg.lang].errorAlreadyRealm
                end
                if msg.chat.type == 'group' then
                    mystat('/add')
                    if is_group(msg) then
                        return langs[msg.lang].groupAlreadyAdded
                    end
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added group [ " .. msg.chat.id .. " ]")
                    print("group " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") added")
                    return addGroup(msg)
                elseif msg.chat.type == 'supergroup' then
                    mystat('/add')
                    if is_super_group(msg) then
                        return langs[msg.lang].supergroupAlreadyAdded
                    end
                    print("SuperGroup " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") added")
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added SuperGroup")
                    return addSuperGroup(msg)
                end
            else
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] attempted to add group [ " .. msg.chat.id .. " ]")
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'add' and matches[2]:lower() == 'realm' then
            if is_sudo(msg) then
                if is_group(msg) then
                    return langs[msg.lang].errorAlreadyGroup
                end
                mystat('/add realm')
                if msg.chat.type == 'group' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added realm [ " .. msg.chat.id .. " ]")
                    print("group " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") added as a realm")
                    return addRealm(msg)
                end
            else
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] attempted to add realm [ " .. msg.chat.id .. " ]")
                return langs[msg.lang].require_sudo
            end
        end
        if matches[1]:lower() == 'rem' and not matches[2] then
            if is_admin(msg) then
                if is_realm(msg) then
                    return langs[msg.lang].errorRealm
                end
                if msg.chat.type == 'group' then
                    if not is_group(msg) then
                        return langs[msg.lang].groupRemoved
                    end
                    mystat('/rem')
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed group [ " .. msg.chat.id .. " ]")
                    print("group " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") removed")
                    return remGroup(msg)
                elseif msg.chat.type == 'supergroup' then
                    if not is_super_group(msg) then
                        return langs[msg.lang].supergroupRemoved
                    end
                    mystat('/rem')
                    print("SuperGroup " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") removed")
                    return remSuperGroup(msg)
                end
            else
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] attempted to remove group [ " .. msg.chat.id .. " ]")
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'rem' and matches[2]:lower() == 'realm' then
            if is_sudo(msg) then
                if not is_realm(msg) then
                    return langs[msg.lang].errorNotRealm
                end
                mystat('/rem realm')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed realm [ " .. msg.chat.id .. " ]")
                print("group " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") removed as a realm")
                return remRealm(msg)
            else
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] attempted to remove realm [ " .. msg.chat.id .. " ]")
                return langs[msg.lang].require_sudo
            end
        end
        if data[tostring(msg.chat.id)] then
            if matches[1]:lower() == 'rules' then
                mystat('/rules')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group rules")
                if not data[tostring(msg.chat.id)].rules then
                    return langs[msg.lang].noRules
                end
                return langs[msg.lang].rules .. data[tostring(msg.chat.id)]['rules']
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
                    local txt = setWarn(msg.from.id, msg.chat.id, matches[2])
                    if matches[2] == '0' then
                        return langs[msg.lang].neverWarn
                    else
                        return txt
                    end
                else
                    return langs[msg.lang].require_mod
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
                        return pinChatMessage(msg.chat.id, msg.reply_to_message.message_id)
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
                        return pinChatMessage(msg.chat.id, msg.reply_to_message.message_id, true)
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
            if matches[1]:lower() == 'lock' then
                if msg.from.is_mod then
                    if checkMatchesLockUnlock(matches[2]) then
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
                    if checkMatchesLockUnlock(matches[2]) then
                        mystat('/unlock ' .. matches[2]:lower())
                        return unlockSetting(msg.chat.id, matches[2]:lower())
                    end
                    return
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'mute' then
                if msg.from.is_owner then
                    if checkMatchesMuteUnmute(matches[2]) then
                        mystat('/mute ' .. matches[2]:lower())
                        return mute(msg.chat.id, matches[2]:lower())
                    end
                    return
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == 'unmute' then
                if msg.from.is_owner then
                    if checkMatchesMuteUnmute(matches[2]) then
                        mystat('/unmute ' .. matches[2]:lower())
                        return unmute(msg.chat.id, matches[2]:lower())
                    end
                    return
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == 'muteslist' then
                if msg.from.is_mod then
                    if msg.chat.type ~= 'private' then
                        sendMessage(msg.chat.id, langs[msg.lang].sendMutesPvt)
                    end
                    mystat('/muteslist')
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist")
                    sendKeyboard(msg.from.id, langs[msg.lang].mutesOf .. msg.chat.id, keyboard_mutes_list(msg.chat.id))
                    return
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'textualmuteslist' then
                if msg.from.is_mod then
                    mystat('/muteslist')
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist")
                    return mutesList(msg.chat.id)
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'del' then
                if msg.from.is_mod then
                    mystat('/del')
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] deleted a message")
                    if msg.reply then
                        deleteMessage(msg.chat.id, msg.reply_to_message.message_id)
                    end
                    return deleteMessage(msg.chat.id, msg.message_id)
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'settings' then
                mystat('/settings')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group settings ")
                if msg.from.is_mod then
                    if msg.chat.type ~= 'private' then
                        sendReply(msg, langs[msg.lang].sendSettingsPvt)
                    end
                    sendKeyboard(msg.from.id, langs[msg.lang].settingsOf .. msg.chat.id .. '\n' .. langs[msg.lang].locksIntro, keyboard_settings_list(msg.chat.id))
                    return
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
                            return msg.chat.title .. '\n' .. data[tostring(msg.chat.id)].settings.set_link
                        else
                            return langs[msg.lang].createLink
                        end
                    else
                        return langs[msg.lang].require_mod
                    end
                else
                    if data[tostring(msg.chat.id)].settings.set_link then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group link [" .. data[tostring(msg.chat.id)].settings.set_link .. "]")
                        return msg.chat.title .. '\n' .. data[tostring(msg.chat.id)].settings.set_link
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
                    local permissions = default_permissions
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
                        if string.match(matches[2], '^%d+$') then
                            local obj_user = getChat(matches[2])
                            if type(obj_user) == 'table' then
                                if obj_user then
                                    if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                        return demoteMod(msg.chat.id, obj_user)
                                    end
                                else
                                    return langs[msg.lang].noObject
                                end
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
                if msg.reply then
                    if msg.from.is_mod then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        if msg.chat.type ~= 'private' then
                                            sendReply(msg, langs[msg.lang].sendPermissionsPvt)
                                        end
                                        sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', msg.chat.id), 'X', tostring(msg.reply_to_message.forward_from.id)) .. '\n' .. langs[msg.lang].permissionsIntro, keyboard_permissions_list(msg.chat.id, msg.reply_to_message.forward_from.id))
                                        return
                                    else
                                        return langs[msg.lang].cantDoThisToChat
                                    end
                                else
                                    return langs[msg.lang].errorNoForward
                                end
                            end
                        else
                            if msg.chat.type ~= 'private' then
                                sendReply(msg, langs[msg.lang].sendPermissionsPvt)
                            end
                            sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', msg.chat.id), 'X', tostring(msg.reply_to_message.from.id)) .. '\n' .. langs[msg.lang].permissionsIntro, keyboard_permissions_list(msg.chat.id, msg.reply_to_message.from.id))
                            return
                        end
                    else
                        return langs[msg.lang].require_mod
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.from.is_mod then
                        if string.match(matches[2], '^%d+$') then
                            local obj_user = getChat(matches[2])
                            if type(obj_user) == 'table' then
                                if obj_user then
                                    if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                        if msg.chat.type ~= 'private' then
                                            sendReply(msg, langs[msg.lang].sendPermissionsPvt)
                                        end
                                        sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', msg.chat.id), 'X', tostring(obj_user.id)) .. '\n' .. langs[msg.lang].permissionsIntro, keyboard_permissions_list(msg.chat.id, obj_user.id))
                                        return
                                    end
                                else
                                    return langs[msg.lang].noObject
                                end
                            end
                        else
                            local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    if msg.chat.type ~= 'private' then
                                        sendReply(msg, langs[msg.lang].sendPermissionsPvt)
                                    end
                                    sendKeyboard(msg.from.id, string.gsub(string.gsub(langs[msg.lang].permissionsOf, 'Y', msg.chat.id), 'X', tostring(obj_user.id)) .. '\n' .. langs[msg.lang].permissionsIntro, keyboard_permissions_list(msg.chat.id, obj_user.id))
                                    return
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
                    if matches[2]:lower() == 'modlist' then
                        if next(data[tostring(msg.chat.id)].moderators) == nil then
                            -- fix way
                            return langs[msg.lang].noGroupMods
                        end
                        mystat('/clean modlist')
                        local message = langs[msg.lang].modListStart .. string.gsub(msg.chat.print_name, '_', ' ') .. ':\n'
                        for k, v in pairs(data[tostring(msg.chat.id)].moderators) do
                            data[tostring(msg.chat.id)].moderators[tostring(k)] = nil
                            save_data(config.moderation.data, data)
                        end
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned modlist")
                    end
                    if matches[2]:lower() == 'rules' then
                        mystat('/clean rules')
                        data[tostring(msg.chat.id)].rules = nil
                        save_data(config.moderation.data, data)
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned rules")
                    end
                    return
                else
                    return langs[msg.lang].require_owner
                end
            end
        end
    end
end

return {
    description = "GROUP_MANAGEMENT",
    patterns =
    {
        "^(###cbgroup_management)(DELETE)$",
        "^(###cbgroup_management)(BACKSETTINGS)(%-%d+)$",
        "^(###cbgroup_management)(BACKMUTES)(%-%d+)$",
        "^(###cbgroup_management)(BACKPERMISSIONS)(%d+)(%-%d+)$",
        "^(###cbgroup_management)(LOCK)(.*)(%-%d+)$",
        "^(###cbgroup_management)(UNLOCK)(.*)(%-%d+)$",
        "^(###cbgroup_management)(MUTE)(.*)(%-%d+)$",
        "^(###cbgroup_management)(UNMUTE)(.*)(%-%d+)$",
        "^(###cbgroup_management)(FLOODPLUS)(%d+)(%-%d+)$",
        "^(###cbgroup_management)(FLOODMINUS)(%d+)(%-%d+)$",
        "^(###cbgroup_management)(GRANT)(%d+)(.*)(%-%d+)$",
        "^(###cbgroup_management)(DENY)(%d+)(.*)(%-%d+)$",

        "!!tgservice chat_add_user_link",
        "!!tgservice chat_add_users",
        "!!tgservice chat_add_user",
        "!!tgservice chat_del_user",
        "!!tgservice chat_change_photo",
        "!!tgservice delete_chat_photo",
        "!!tgservice chat_rename",

        -- INREALM
        "^[#!/]([Rr][Ee][Mm]) (%-?%d+)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Pp][Oo][Ww][Nn][Ee][Rr]) (%-?%d+) (%d+)$",-- (group id) (owner id)
        "^[#!/]([Mm][Uu][Tt][Ee]) (%-?%d+) ([^%s]+)",
        "^[#!/]([Uu][Nn][Mm][Uu][Tt][Ee]) (%-?%d+) ([^%s]+)",
        "^[#!/]([Mm][Uu][Tt][Ee][Ss][Ll][Ii][Ss][Tt]) (%-?%d+)",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Mm][Uu][Tt][Ee][Ss][Ll][Ii][Ss][Tt]) (%-?%d+)$",
        "^[#!/]([Ll][Oo][Cc][Kk]) (%-?%d+) ([^%s]+)$",
        "^[#!/]([Uu][Nn][Ll][Oo][Cc][Kk]) (%-?%d+) ([^%s]+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss]) (%-?%d+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss]) (%-?%d+)$",
        "^[#!/]([Ss][Uu][Pp][Ee][Rr][Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss]) (%-?%d+)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Pp][Rr][Uu][Ll][Ee][Ss]) (%-?%d+) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Pp][Aa][Bb][Oo][Uu][Tt]) (%-?%d+) (.*)$",

        -- INGROUP
        "^[#!/]([Aa][Dd][Dd]) ([Rr][Ee][Aa][Ll][Mm])$",
        "^[#!/]([Rr][Ee][Mm]) ([Rr][Ee][Aa][Ll][Mm])$",

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
        "^[#!/]([Tt][Yy][Pp][Ee])$",
        "^[#!/]([Ll][Oo][Gg])$",
        "^[#!/@]([Aa][Dd][Mm][Ii][Nn][Ss])",
        "^[#!/]([Aa][Dd][Dd])$",
        "^[#!/]([Rr][Ee][Mm])$",
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
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#getwarn",
        "#rules",
        "#modlist",
        "#owner",
        "#admins [<reply>|<text>]",
        "#link",
        "#settings",
        "#textualsettings",
        "MOD",
        "#type",
        "#updategroupinfo",
        "#setrules <text>",
        "#setwarn <value>",
        "#setflood <value>",
        "#newlink",
        "#muteslist",
        "#textualmuteslist",
        "#lock arabic|bots|flood|grouplink|leave|link|member|rtl|spam|strict",
        "#unlock arabic|bots|flood|grouplink|leave|link|member|rtl|spam|strict",
        "#pin <reply>",
        "#silentpin <reply>",
        "#unpin",
        "#settitle <text>",
        "#setdescription <text>",
        "#setphoto <reply>",
        "#unsetphoto",
        "OWNER",
        "#syncmodlist",
        "#log",
        "#getadmins",
        "#setlink <link>",
        "#unsetlink",
        "#promote <id>|<username>|<reply>|from",
        "#demote <id>|<username>|<reply>|from",
        "#promoteadmin <id>|<username>|<reply>|from [change_info] [delete_messages] [invite_users] [restrict_members] [pin_messages] [promote_members]",
        "#demoteadmin <id>|<username>|<reply>|from",
        "#setowner <id>|<username>|<reply>",
        "#mute all|audio|contact|document|gif|location|photo|sticker|text|tgservice|video|video_note|voice_note",
        "#unmute all|audio|contact|document|gif|location|photo|sticker|text|tgservice|video|video_note|voice_note",
        "#clean modlist|rules",
        "ADMIN",
        "#add",
        "#rem",
        "ex INGROUP.LUA",
        "#add realm",
        "#rem realm",
        "REALM",
        "#setgpowner <group_id> <user_id>",
        "#setgprules <group_id> <text>",
        "#mute <group_id> all|audio|contact|document|gif|location|photo|sticker|text|tgservice|video|video_note|voice_note",
        "#unmute <group_id> all|audio|contact|document|gif|location|photo|sticker|text|tgservice|video|video_note|voice_note",
        "#muteslist <group_id>",
        "#textualmuteslist <group_id>",
        "#lock <group_id> arabic|bots|flood|grouplink|leave|link|member|rtl|spam|strict",
        "#unlock <group_id> arabic|bots|flood|grouplink|leave|link|member|rtl|spam|strict",
        "#settings <group_id>",
        "#textualsettings <group_id>",
        "#type",
        "#rem <group_id>",
    },
}