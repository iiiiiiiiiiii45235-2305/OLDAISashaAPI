-- REFACTORING OF INPM.LUA INREALM.LUA INGROUP.LUA AND SUPERGROUP.LUA

group_type = ''

-- INPM
local function allChats(msg)
    i = 1
    if not data['groups'] then
        return langs[msg.lang].noGroups
    end
    local message = langs[msg.lang].groupsJoin
    for k, v in pairsByKeys(data['groups']) do
        local group_id = v
        if data[tostring(group_id)] then
            for m, n in pairsByKeys(data[tostring(group_id)]) do
                if type(m) == 'string' then
                    if m == 'set_name' then
                        name = n:gsub("", "")
                        chat_name = name:gsub("?", "")
                        group_name_id = name .. '\n(ID: ' .. group_id .. ')\n'
                        if name:match("[\216-\219][\128-\191]") then
                            group_info = i .. '. \n' .. group_name_id
                        else
                            group_info = i .. '. ' .. group_name_id
                        end
                        i = i + 1
                    end
                end
            end
        end
        message = message .. group_info
    end

    i = 1
    if not data['realms'] then
        return langs[msg.lang].noRealms
    end
    message = message .. '\n\n' .. langs[msg.lang].realmsJoin
    for k, v in pairsByKeys(data['realms']) do
        local realm_id = v
        if data[tostring(realm_id)] then
            for m, n in pairsByKeys(data[tostring(realm_id)]) do
                if type(m) == 'string' then
                    if m == 'set_name' then
                        name = n:gsub("", "")
                        chat_name = name:gsub("?", "")
                        realm_name_id = name .. '\n(ID: ' .. realm_id .. ')\n'
                        if name:match("[\216-\219][\128-\191]") then
                            realm_info = i .. '. \n' .. realm_name_id
                        else
                            realm_info = i .. '. ' .. realm_name_id
                        end
                        i = i + 1
                    end
                end
            end
        end
        message = message .. realm_info
    end
    local file = io.open("./groups/lists/all_listed_groups.txt", "w")
    file:write(message)
    file:flush()
    file:close()
    return message
end

-- INREALM
local function groupsList(msg)
    if not data.groups then
        return langs[msg.lang].noGroups
    end
    local message = langs[msg.lang].groupListStart
    for k, v in pairs(data.groups) do
        if data[tostring(v)] then
            if data[tostring(v)]['settings'] then
                local settings = data[tostring(v)]['settings']
                for m, n in pairs(settings) do
                    if m == 'set_name' then
                        name = n
                    end
                end
                local group_owner = "No owner"
                if data[tostring(v)]['set_owner'] then
                    group_owner = tostring(data[tostring(v)]['set_owner'])
                end
                local group_link = "No link"
                if data[tostring(v)]['settings']['set_link'] then
                    group_link = data[tostring(v)]['settings']['set_link']
                end
                message = message .. name .. ' ' .. v .. ' - ' .. group_owner .. '\n{' .. group_link .. "}\n"
            end
        end
    end
    local file = io.open("./groups/lists/groups.txt", "w")
    file:write(message)
    file:flush()
    file:close()
    return message
end

local function realmsList(msg)
    if not data.realms then
        return langs[msg.lang].noRealms
    end
    local message = langs[msg.lang].realmListStart
    for k, v in pairs(data.realms) do
        local settings = data[tostring(v)]['settings']
        for m, n in pairs(settings) do
            if m == 'set_name' then
                name = n
            end
        end
        local group_owner = "No owner"
        if data[tostring(v)]['admins_in'] then
            group_owner = tostring(data[tostring(v)]['admins_in'])
        end
        local group_link = "No link"
        if data[tostring(v)]['settings']['set_link'] then
            group_link = data[tostring(v)]['settings']['set_link']
        end
        message = message .. name .. ' ' .. v .. ' - ' .. group_owner .. '\n{' .. group_link .. "}\n"
    end
    local file = io.open("./groups/lists/realms.txt", "w")
    file:write(message)
    file:flush()
    file:close()
    return message
end

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
                    data[tostring(msg.chat.id)] = {
                        goodbye = nil,
                        group_type = 'Group',
                        moderators = { },
                        rules = nil,
                        set_name = string.gsub(msg.chat.print_name,'_',' '),
                        set_owner = tostring(admin.user.id),
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
                    data[tostring(msg.chat.id)] = {
                        goodbye = nil,
                        group_type = 'Realm',
                        moderators = { },
                        rules = nil,
                        set_name = string.gsub(msg.chat.print_name,'_',' '),
                        set_owner = tostring(admin.user.id),
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
                    data[tostring(msg.chat.id)] = {
                        goodbye = nil,
                        group_type = 'SuperGroup',
                        moderators = { },
                        rules = nil,
                        set_name = string.gsub(msg.chat.print_name,'_',' '),
                        set_owner = tostring(admin.user.id),
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
    return langs[msg.lang].supergroupRemoved
end
-- end ADD/REM GROUPS

-- begin RANKS MANAGEMENT
local function promoteAdmin(user, chat_id)
    local lang = get_lang(chat_id)
    if not data.admins then
        data.admins = { }
        save_data(config.moderation.data, data)
    end
    if data.admins[tostring(user.id)] then
        return(user.username or user.print_name or user.first_name) .. langs[lang].alreadyAdmin
    end
    data.admins[tostring(user.id)] =(user.username or user.print_name or user.first_name)
    save_data(config.moderation.data, data)
    return(user.username or user.print_name or user.first_name) .. langs[lang].promoteAdmin
end

local function demoteAdmin(user, chat_id)
    local lang = get_lang(chat_id)
    if not data.admins then
        data.admins = { }
        save_data(config.moderation.data, data)
    end
    if not data.admins[tostring(user.id)] then
        return(user.username or user.print_name or user.first_name) .. langs[lang].notAdmin
    end
    data.admins[tostring(user.id)] = nil
    save_data(config.moderation.data, data)
    return(user.username or user.print_name or user.first_name) .. langs[lang].demoteAdmin
end

local function botAdminsList(chat_id)
    local lang = get_lang(chat_id)
    if not data.admins then
        data.admins = { }
        save_data(config.moderation.data, data)
    end
    local message = langs[lang].adminListStart
    for k, v in pairs(data.admins) do
        message = message .. v .. ' - ' .. k .. '\n'
    end
    return message
end

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
    local text = langs[msg.lang].receiver .. msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']\n' .. langs[msg.lang].sender
    if msg.from.username then
        text = text .. '@' .. msg.from.username .. ' [' .. msg.from.id .. ']\n'
    else
        text = text .. msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']\n'
    end
    text = text .. langs[msg.lang].msgText ..(msg.text or msg.caption) .. '\n'

    local already_contacted = { }
    local list = getChatAdministrators(msg.chat.id)
    if list then
        for i, admin in pairs(list.result) do
            already_contacted[tonumber(admin.user.id)] = admin.user.id
            if msg.reply then
                forwardMessage(admin.user.id, msg.chat.id, msg.reply_to_message.message_id)
            end
            sendMessage(admin.user.id, text)
        end
    end

    -- owner
    local owner = data[tostring(msg.chat.id)]['set_owner']
    if owner then
        if not already_contacted[tonumber(owner)] then
            already_contacted[tonumber(owner)] = owner
            if msg.reply then
                forwardMessage(owner, msg.chat.id, msg.reply_to_message.message_id)
            end
            sendMessage(owner, text)
        end
    end

    -- determine if table is empty
    if next(data[tostring(msg.chat.id)]['moderators']) == nil then
        -- fix way
        return
    end
    for k, v in pairs(data[tostring(msg.chat.id)]['moderators']) do
        if not already_contacted[tonumber(k)] then
            already_contacted[tonumber(k)] = k
            if msg.reply then
                forwardMessage(k, msg.chat.id, msg.reply_to_message.message_id)
            end
            sendMessage(k, text)
        end
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

local function keyboard_settings_list(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local flag = false
    keyboard.inline_keyboard[row] = { }
    for var, value in pairs(data[tostring(chat_id)].settings) do
        if type(value) == 'boolean' then
            if flag then
                flag = false
                row = row + 1
                column = 1
                keyboard.inline_keyboard[row] = { }
            end
            if value then
                keyboard.inline_keyboard[row][column] = { text = '🔒' .. reverseAdjustSettingType(var), callback_data = 'group_managementUNLOCK' .. var .. chat_id }
            else
                keyboard.inline_keyboard[row][column] = { text = '🔓' .. reverseAdjustSettingType(var), callback_data = 'group_managementLOCK' .. var .. chat_id }
            end
            column = column + 1
            if column > 2 then
                flag = true
            end
        end
    end
    row = row + 1
    column = 1
    keyboard.inline_keyboard[row] = { }
    keyboard.inline_keyboard[row][column] = { text = langs[get_lang(chat_id)].updateKeyboard, callback_data = 'group_managementBACKSETTINGS' .. chat_id }
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
            keyboard.inline_keyboard[row][column] = { text = '🔇' .. var, callback_data = 'group_managementUNMUTE' .. var .. chat_id }
        else
            keyboard.inline_keyboard[row][column] = { text = '🔊' .. var, callback_data = 'group_managementMUTE' .. var .. chat_id }
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
    return keyboard
end

local function run(msg, matches)
    if msg.service then
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
    end
    if msg.cb then
        if matches[1] == '###cbgroup_management' then
            if matches[2] == 'BACKSETTINGS' then
                return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].settingsOf .. matches[3], keyboard_settings_list(matches[3]))
            elseif matches[2] == 'BACKMUTES' then
                return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].mutesOf .. matches[3], keyboard_mutes_list(matches[3]))
            elseif matches[4] then
                if matches[2] == 'LOCK' then
                    if is_mod2(msg.from.id, matches[4]) then
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4])
                        return editMessageText(msg.chat.id, msg.message_id, lockSetting(tonumber(matches[4]), matches[3]), { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'group_managementBACKSETTINGS' .. matches[4] } } } })
                    else
                        return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                    end
                elseif matches[2] == 'UNLOCK' then
                    if is_mod2(msg.from.id, matches[4]) then
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4])
                        return editMessageText(msg.chat.id, msg.message_id, unlockSetting(tonumber(matches[4]), matches[3]), { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'group_managementBACKSETTINGS' .. matches[4] } } } })
                    else
                        return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                    end
                end
                if matches[2] == 'UNMUTE' then
                    if is_owner2(msg.from.id, matches[4]) then
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4])
                        return editMessageText(msg.chat.id, msg.message_id, unmute(tonumber(matches[4]), matches[3]), { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'group_managementBACKMUTES' .. matches[4] } } } })
                    else
                        return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                    end
                elseif matches[2] == 'MUTE' then
                    if is_owner2(msg.from.id, matches[4]) then
                        mystat('###cbgroup_management' .. matches[2] .. matches[3] .. matches[4])
                        return editMessageText(msg.chat.id, msg.message_id, mute(tonumber(matches[4]), matches[3]), { inline_keyboard = { { { text = langs[msg.lang].goBack, callback_data = 'group_managementBACKMUTES' .. matches[4] } } } })
                    else
                        return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_owner)
                    end
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
        return contactMods(msg)
    end

    -- INPM
    if is_sudo(msg) or msg.chat.type == 'private' then
        if matches[1]:lower() == 'join' or matches[1]:lower() == 'inviteme' or matches[1]:lower() == 'sasha invitami' or matches[1]:lower() == 'invitami' then
            if is_admin(msg) then
                -- adjust chat_id
                if string.match(matches[2], '^-100') then
                    sendMessage('-100' .. matches[2], "@AISasha")
                    sendMessage(bot.userVersion.id, "/lua channel_invite('channel#id' .. " .. matches[2]:gsub('-100', '') .. ", 'user#id' .. " .. msg.from.id .. ", ok_cb, false)")
                elseif string.match(matches[2], '-') then
                    sendMessage('-' .. matches[2], "@AISasha")
                    sendMessage(bot.userVersion.id, "/lua chat_add_user('chat#id' .. " .. matches[2]:gsub('-', '') .. ", 'user#id' .. " .. msg.from.id .. ", ok_cb, false)")
                else
                    sendMessage('-100' .. matches[2], "@AISasha")
                    sendMessage('-' .. matches[2], "@AISasha")
                    sendMessage(bot.userVersion.id, "/lua chat_add_user('chat#id' .. " .. matches[2] .. ", 'user#id' .. " .. msg.from.id .. ", ok_cb, false) " ..
                    "channel_invite('channel#id' .. " .. matches[2] .. ", 'user#id' .. " .. msg.from.id .. ", ok_cb, false)")
                end
                return langs[msg.lang].ok
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'allchats' then
            if is_admin(msg) then
                mystat('/allchats')
                return allChats(msg)
            else
                return langs[msg.lang].require_admin
            end
        end

        if matches[1]:lower() == 'allchatslist' then
            if is_admin(msg) then
                mystat('/allchatslist')
                allChats(msg)
                return sendDocument(msg.chat.id, "./groups/lists/all_listed_groups.txt")
            else
                return langs[msg.lang].require_admin
            end
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
        if matches[1]:lower() == 'addadmin' then
            if is_sudo(msg) then
                mystat('/addadmin')
                if msg.reply then
                    return promoteAdmin(msg.reply_to_message.from, msg.chat.id)
                elseif matches[2] and matches[2] ~= '' then
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return promoteAdmin(obj_user, msg.chat.id)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return promoteAdmin(obj_user, msg.chat.id)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_sudo
            end
        end
        if matches[1]:lower() == 'removeadmin' then
            if is_sudo(msg) then
                mystat('/removeadmin')
                if msg.reply then
                    return demoteAdmin(msg.reply_to_message.from, msg.chat.id)
                elseif matches[2] and matches[2] ~= '' then
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2])
                        if type(obj_user) == 'table' then
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    return demoteAdmin(obj_user, msg.chat.id)
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return demoteAdmin(obj_user, msg.chat.id)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_sudo
            end
        end
        if matches[1]:lower() == 'list' then
            if is_admin(msg) then
                if matches[2]:lower() == 'admins' then
                    mystat('/list admins')
                    return botAdminsList(msg.chat.id)
                elseif matches[2]:lower() == 'groups' then
                    mystat('/list groups')
                    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
                        groupsList(msg)
                        sendDocument(msg.chat.id, "./groups/lists/groups.txt")
                        -- return group_list(msg)
                    elseif msg.chat.type == 'private' then
                        groupsList(msg)
                        sendDocument(msg.from.id, "./groups/lists/groups.txt")
                        -- return group_list(msg)
                    end
                    return langs[msg.lang].groupListCreated
                elseif matches[2]:lower() == 'realms' then
                    mystat('/list realms')
                    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
                        realmsList(msg)
                        sendDocument(msg.chat.id, "./groups/lists/realms.txt")
                        -- return realmsList(msg)
                    elseif msg.chat.type == 'private' then
                        realmsList(msg)
                        sendDocument(msg.from.id, "./groups/lists/realms.txt")
                        -- return realmsList(msg)
                    end
                    return langs[msg.lang].realmListCreated
                end
                return
            else
                return langs[msg.lang].require_admin
            end
        end
        if (matches[1]:lower() == 'lock' or matches[1]:lower() == 'sasha blocca' or matches[1]:lower() == 'blocca') and matches[2] and matches[3] then
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
        if (matches[1]:lower() == 'unlock' or matches[1]:lower() == 'sasha sblocca' or matches[1]:lower() == 'sblocca') and matches[2] and matches[3] then
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
        if (matches[1]:lower() == 'mute' or matches[1]:lower() == 'silenzia') and matches[2] and matches[3] then
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
        if (matches[1]:lower() == 'unmute' or matches[1]:lower() == 'ripristina') and matches[2] and matches[3] then
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
        if (matches[1]:lower() == "muteslist" or matches[1]:lower() == "lista muti") and matches[2] then
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
        if matches[1]:lower() == "textualmuteslist" and matches[2] then
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
                    sendMessage(msg.chat.id, langs[msg.lang].sendSettingsPvt)
                end
                mystat('/settings <group_id>')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group settings " .. matches[2])
                sendKeyboard(msg.from.id, langs[msg.lang].settingsOf .. matches[2], keyboard_settings_list(matches[2]))
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
                mystat('/setgpowner <group_id> <user_id>')
                data[tostring(matches[2])].set_owner = matches[3]
                save_data(config.moderation.data, data)
                sendMessage(matches[2], matches[3] .. langs[lang].setOwner)
                return matches[3] .. langs[lang].setOwner
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
            if matches[1]:lower() == 'rules' or matches[1]:lower() == 'sasha regole' then
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
            if matches[1]:lower() == 'setrules' or matches[1]:lower() == 'sasha imposta regole' then
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
                    if tonumber(matches[2]) < 3 or tonumber(matches[2]) > 200 then
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
            if matches[1]:lower() == 'lock' or matches[1]:lower() == 'sasha blocca' or matches[1]:lower() == 'blocca' then
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
            if matches[1]:lower() == 'unlock' or matches[1]:lower() == 'sasha sblocca' or matches[1]:lower() == 'sblocca' then
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
            if matches[1]:lower() == 'mute' or matches[1]:lower() == 'silenzia' then
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
            if matches[1]:lower() == 'unmute' or matches[1]:lower() == 'ripristina' then
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
            if matches[1]:lower() == "muteuser" or matches[1]:lower() == 'voce' then
                if msg.from.is_mod then
                    mystat('/muteuser')
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        -- ignore higher or same rank
                                        if compare_ranks(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id) then
                                            if isMutedUser(msg.chat.id, msg.reply_to_message.forward_from.id) then
                                                unmuteUser(msg.chat.id, msg.reply_to_message.forward_from.id)
                                                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed [" .. msg.reply_to_message.forward_from.id .. "] from the muted users list")
                                                return msg.reply_to_message.forward_from.id .. langs[msg.lang].muteUserRemove
                                            else
                                                muteUser(msg.chat.id, msg.reply_to_message.forward_from.id)
                                                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added [" .. msg.reply_to_message.forward_from.id .. "] to the muted users list")
                                                return msg.reply_to_message.forward_from.id .. langs[msg.lang].muteUserAdd
                                            end
                                        else
                                            return langs[msg.lang].require_rank
                                        end
                                    else
                                        return langs[msg.lang].cantDoThisToChat
                                    end
                                else
                                    return langs[msg.lang].errorNoForward
                                end
                            end
                        else
                            -- ignore higher or same rank
                            if compare_ranks(msg.from.id, msg.reply_to_message.from.id, msg.chat.id) then
                                if isMutedUser(msg.chat.id, msg.reply_to_message.from.id) then
                                    unmuteUser(msg.chat.id, msg.reply_to_message.from.id)
                                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed [" .. msg.reply_to_message.from.id .. "] from the muted users list")
                                    return msg.reply_to_message.from.id .. langs[msg.lang].muteUserRemove
                                else
                                    muteUser(msg.chat.id, msg.reply_to_message.from.id)
                                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added [" .. msg.reply_to_message.from.id .. "] to the muted users list")
                                    return msg.reply_to_message.from.id .. langs[msg.lang].muteUserAdd
                                end
                            else
                                return langs[msg.lang].require_rank
                            end
                        end
                    elseif matches[2] and matches[2] ~= '' then
                        if string.match(matches[2], '^%d+$') then
                            -- ignore higher or same rank
                            if compare_ranks(msg.from.id, matches[2], msg.chat.id) then
                                if isMutedUser(msg.chat.id, matches[2]) then
                                    unmuteUser(msg.chat.id, matches[2])
                                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed [" .. matches[2] .. "] from the muted users list")
                                    return matches[2] .. langs[msg.lang].muteUserRemove
                                else
                                    muteUser(msg.chat.id, matches[2])
                                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added [" .. matches[2] .. "] to the muted users list")
                                    return matches[2] .. langs[msg.lang].muteUserAdd
                                end
                            else
                                return langs[msg.lang].require_rank
                            end
                        else
                            local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                            if obj_user then
                                if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                    -- ignore higher or same rank
                                    if compare_ranks(msg.from.id, obj_user.id, msg.chat.id) then
                                        if isMutedUser(msg.chat.id, obj_user.id) then
                                            unmuteUser(msg.chat.id, obj_user.id)
                                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed [" .. obj_user.id .. "] from the muted users list")
                                            return obj_user.id .. langs[msg.lang].muteUserRemove
                                        else
                                            muteUser(msg.chat.id, obj_user.id)
                                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added [" .. obj_user.id .. "] to the muted users list")
                                            return obj_user.id .. langs[msg.lang].muteUserAdd
                                        end
                                    else
                                        return langs[msg.lang].require_rank
                                    end
                                end
                            else
                                return langs[msg.lang].noObject
                            end
                        end
                    end
                    return
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == "muteslist" or matches[1]:lower() == "lista muti" then
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
            if matches[1]:lower() == "textualmuteslist" then
                if msg.from.is_mod then
                    mystat('/muteslist')
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist")
                    return mutesList(msg.chat.id)
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == "del" then
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
            if matches[1]:lower() == "mutelist" or matches[1]:lower() == "lista utenti muti" then
                if msg.from.is_mod then
                    mystat('/mutelist')
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup mutelist")
                    return mutedUserList(msg.chat.id)
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'settings' then
                if msg.from.is_mod then
                    if msg.chat.type ~= 'private' then
                        sendMessage(msg.chat.id, langs[msg.lang].sendSettingsPvt)
                    end
                    mystat('/settings')
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group settings ")
                    sendKeyboard(msg.from.id, langs[msg.lang].settingsOf .. msg.chat.id, keyboard_settings_list(msg.chat.id))
                    return
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'textualsettings' then
                if msg.from.is_mod then
                    mystat('/settings')
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group settings ")
                    return showSettings(msg.chat.id, msg.lang)
                else
                    return langs[msg.lang].require_mod
                end
            end
            if (matches[1]:lower() == 'setlink' or matches[1]:lower() == "sasha imposta link") and matches[2] then
                if msg.from.is_owner then
                    mystat('/setlink')
                    data[tostring(msg.chat.id)].settings.set_link = matches[2]
                    save_data(config.moderation.data, data)
                    return langs[msg.lang].linkSaved
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == 'unsetlink' or matches[1]:lower() == "sasha elimina link" then
                if msg.from.is_owner then
                    mystat('/unsetlink')
                    data[tostring(msg.chat.id)].settings.set_link = nil
                    save_data(config.moderation.data, data)
                    return langs[msg.lang].linkDeleted
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == 'link' or matches[1]:lower() == 'sasha link' then
                mystat('/link')
                if data[tostring(msg.chat.id)].settings.set_link then
                    if data[tostring(msg.chat.id)].settings.lock_group_link then
                        if msg.from.is_mod then
                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group link [" .. data[tostring(msg.chat.id)].settings.set_link .. "]")
                            return msg.chat.title .. '\n' .. data[tostring(msg.chat.id)].settings.set_link
                        else
                            return langs[msg.lang].require_mod
                        end
                    else
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group link [" .. data[tostring(msg.chat.id)].settings.set_link .. "]")
                        return msg.chat.title .. '\n' .. data[tostring(msg.chat.id)].settings.set_link
                    end
                else
                    return langs[msg.lang].sendMeLink
                end
            end
            if matches[1]:lower() == "getadmins" or matches[1]:lower() == "sasha lista admin" or matches[1]:lower() == "lista admin" then
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
            if matches[1]:lower() == 'modlist' or matches[1]:lower() == 'sasha lista mod' or matches[1]:lower() == 'lista mod' then
                mystat('/modlist')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group modlist")
                return modList(msg)
            end
            if matches[1]:lower() == 'promote' or matches[1]:lower() == 'sasha promuovi' or matches[1]:lower() == 'promuovi' then
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
            if matches[1]:lower() == 'demote' or matches[1]:lower() == 'sasha degrada' or matches[1]:lower() == 'degrada' then
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
        "^(###cbgroup_management)(BACKSETTINGS)(%-%d+)$",
        "^(###cbgroup_management)(BACKMUTES)(%-%d+)$",
        "^(###cbgroup_management)(LOCK)(.*)(%-%d+)$",
        "^(###cbgroup_management)(UNLOCK)(.*)(%-%d+)$",
        "^(###cbgroup_management)(MUTE)(.*)(%-%d+)$",
        "^(###cbgroup_management)(UNMUTE)(.*)(%-%d+)$",

        "!!tgservice chat_add_user_link",
        "!!tgservice chat_add_users",
        "!!tgservice chat_add_user",
        "!!tgservice chat_del_user",

        -- INPM
        "^[#!/]([Jj][Oo][Ii][Nn]) (%-?%d+)$",
        "^[#!/]([Aa][Ll][Ll][Cc][Hh][Aa][Tt][Ss])$",
        "^[#!/]([Aa][Ll][Ll][Cc][Hh][Aa][Tt][Ss][Ll][Ii][Ss][Tt])$",
        -- join
        "^[#!/]([Ii][Nn][Vv][Ii][Tt][Ee][Mm][Ee]) (%-?%d+)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Nn][Vv][Ii][Tt][Aa][Mm][Ii]) (%-?%d+)$",
        "^([Ii][Nn][Vv][Ii][Tt][Aa][Mm][Ii]) (%-?%d+)$",

        -- INREALM
        "^[#!/]([Rr][Ee][Mm]) (%-?%d+)$",
        "^[#!/]([Aa][Dd][Dd][Aa][Dd][Mm][Ii][Nn]) ([^%s]+)$",
        "^[#!/]([Rr][Ee][Mm][Oo][Vv][Ee][Aa][Dd][Mm][Ii][Nn]) ([^%s]+)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Pp][Oo][Ww][Nn][Ee][Rr]) (%-?%d+) (%d+)$",-- (group id) (owner id)
        "^[#!/]([Ll][Ii][Ss][Tt]) ([^%s]+)$",
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
        -- lock
        "^([Ss][Aa][Ss][Hh][Aa] [Bb][Ll][Oo][Cc][Cc][Aa]) (%-?%d+) ([^%s]+)$",
        "^([Bb][Ll][Oo][Cc][Cc][Aa]) (%-?%d+) ([^%s]+)$",
        -- unlock
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Bb][Ll][Oo][Cc][Cc][Aa]) (%-?%d+) ([^%s]+)$",
        "^([Ss][Bb][Ll][Oo][Cc][Cc][Aa]) (%-?%d+) ([^%s]+)$",
        -- mute
        "^([Ss][Ii][Ll][Ee][Nn][Zz][Ii][Aa]) (%-?%d+) ([^%s]+)$",
        -- unmute
        "^([Rr][Ii][Pp][Rr][Ii][Ss][Tt][Ii][Nn][Aa]) (%-?%d+) ([^%s]+)$",
        -- muteslist
        "^([Ll][Ii][Ss][Tt][Aa] [Mm][Uu][Tt][Ii]) (%-?%d+)$",

        -- INGROUP
        "^[#!/]([Aa][Dd][Dd]) ([Rr][Ee][Aa][Ll][Mm])$",
        "^[#!/]([Rr][Ee][Mm]) ([Rr][Ee][Aa][Ll][Mm])$",

        -- SUPERGROUP
        "^[#!/]([Gg][Ee][Tt][Aa][Dd][Mm][Ii][Nn][Ss])$",
        -- getadmins
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Ss][Tt][Aa] [Aa][Dd][Mm][Ii][Nn])$",
        "^([Ll][Ii][Ss][Tt][Aa] [Aa][Dd][Mm][Ii][Nn])$",

        -- COMMON
        "^[#!/]([Dd][Ee][Ll])$",
        "^[#!/]([Tt][Yy][Pp][Ee])$",
        "^[#!/]([Ll][Oo][Gg])$",
        "^[#!/]([Aa][Dd][Mm][Ii][Nn][Ss])",
        "^[#!/]([Aa][Dd][Dd])$",
        "^[#!/]([Rr][Ee][Mm])$",
        "^[#!/]([Rr][Uu][Ll][Ee][Ss])$",
        "^[#!/]([Aa][Bb][Oo][Uu][Tt])$",
        "^[#!/]([Ss][Ee][Tt][Ff][Ll][Oo][Oo][Dd]) (%d+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss])$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss])$",
        "^[#!/]([Pp][Rr][Oo][Mm][Oo][Tt][Ee]) ([^%s]+)$",
        "^[#!/]([Pp][Rr][Oo][Mm][Oo][Tt][Ee])$",
        "^[#!/]([Dd][Ee][Mm][Oo][Tt][Ee]) ([^%s]+)$",
        "^[#!/]([Dd][Ee][Mm][Oo][Tt][Ee])$",
        "^[#!/]([Mm][Uu][Tt][Ee][Uu][Ss][Ee][Rr]) ([^%s]+)$",
        "^[#!/]([Mm][Uu][Tt][Ee][Uu][Ss][Ee][Rr])",
        "^[#!/]([Mm][Uu][Tt][Ee][Ll][Ii][Ss][Tt])",
        "^[#!/]([Mm][Uu][Tt][Ee][Ss][Ll][Ii][Ss][Tt])",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Mm][Uu][Tt][Ee][Ss][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Uu][Nn][Mm][Uu][Tt][Ee]) ([^%s]+)",
        "^[#!/]([Mm][Uu][Tt][Ee]) ([^%s]+)",
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
        -- rules
        "^([Ss][Aa][Ss][Hh][Aa] [Rr][Ee][Gg][Oo][Ll][Ee])$",
        -- promote
        "^([Ss][Aa][Ss][Hh][Aa] [Pp][Rr][Oo][Mm][Uu][Oo][Vv][Ii]) ([^%s]+)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Pp][Rr][Oo][Mm][Uu][Oo][Vv][Ii])$",
        "^([Pp][Rr][Oo][Mm][Uu][Oo][Vv][Ii]) ([^%s]+)$",
        "^([Pp][Rr][Oo][Mm][Uu][Oo][Vv][Ii])$",
        -- demote
        "^([Ss][Aa][Ss][Hh][Aa] [Dd][Ee][Gg][Rr][Aa][Dd][Aa]) ([^%s]+)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Dd][Ee][Gg][Rr][Aa][Dd][Aa])$",
        "^([Dd][Ee][Gg][Rr][Aa][Dd][Aa]) ([^%s]+)$",
        "^([Dd][Ee][Gg][Rr][Aa][Dd][Aa])$",
        -- setrules
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Mm][Pp][Oo][Ss][Tt][Aa] [Rr][Ee][Gg][Oo][Ll][Ee]) (.*)$",
        -- lock
        "^([Ss][Aa][Ss][Hh][Aa] [Bb][Ll][Oo][Cc][Cc][Aa]) ([^%s]+)$",
        "^([Bb][Ll][Oo][Cc][Cc][Aa]) ([^%s]+)$",
        -- unlock
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Bb][Ll][Oo][Cc][Cc][Aa]) ([^%s]+)$",
        "^([Ss][Bb][Ll][Oo][Cc][Cc][Aa]) ([^%s]+)$",
        -- modlist
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Ss][Tt][Aa] [Mm][Oo][Dd])$",
        "^([Ll][Ii][Ss][Tt][Aa] [Mm][Oo][Dd])$",
        -- link
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Nn][Kk])$",
        -- setlink
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Mm][Pp][Oo][Ss][Tt][Aa] [Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Mm][Pp][Oo][Ss][Tt][Aa] [Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Mm][Pp][Oo][Ss][Tt][Aa] [Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt].[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Mm][Pp][Oo][Ss][Tt][Aa] [Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Dd][Oo][Gg]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        -- unsetlink
        "^([Ss][Aa][Ss][Hh][Aa] [Ee][Ll][Ii][Mm][Ii][Nn][Aa] [Ll][Ii][Nn][Kk])$",
        -- mute
        "^([Ss][Ii][Ll][Ee][Nn][Zz][Ii][Aa]) ([^%s]+)$",
        -- unmute
        "^([Rr][Ii][Pp][Rr][Ii][Ss][Tt][Ii][Nn][Aa]) ([^%s]+)$",
        -- muteuser
        "^([Vv][Oo][Cc][Ee])$",
        "^([Vv][Oo][Cc][Ee]) ([^%s]+)$",
        -- muteslist
        "^([Ll][Ii][Ss][Tt][Aa] [Mm][Uu][Tt][Ii])$",
        -- mutelist
        "^([Ll][Ii][Ss][Tt][Aa] [Uu][Tt][Ee][Nn][Tt][Ii] [Mm][Uu][Tt][Ii])$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#getwarn",
        "(#rules|sasha regole)",
        "(#modlist|[sasha] lista mod)",
        "#owner",
        "#admins [<reply>|<text>]",
        "(#link|sasha link)",
        "MOD",
        "#type",
        "#updategroupinfo",
        "(#setrules|sasha imposta regole) <text>",
        "#setwarn <value>",
        "#setflood <value>",
        "#settings",
        "#textualsettings",
        "#muteuser|voce <id>|<username>|<reply>|from",
        "(#muteslist|lista muti)",
        "#textualmuteslist",
        "(#mutelist|lista utenti muti)",
        "(#lock|[sasha] blocca) arabic|bots|flood|grouplink|leave|link|member|rtl|spam|strict",
        "(#unlock|[sasha] sblocca) arabic|bots|flood|grouplink|leave|link|member|rtl|spam|strict",
        "OWNER",
        "#syncmodlist",
        "#log",
        "(#getadmins|[sasha] lista admin)",
        "(#setlink|sasha imposta link) <link>",
        "(#unsetlink|sasha elimina link)",
        "(#promote|[sasha] promuovi) <username>|<reply>",
        "(#demote|[sasha] degrada) <username>|<reply>",
        "#setowner <id>|<username>|<reply>",
        "#mute|silenzia all|audio|contact|document|gif|location|photo|sticker|text|tgservice|video|video_note|voice_note",
        "#unmute|ripristina all|audio|contact|document|gif|location|photo|sticker|text|tgservice|video|video_note|voice_note",
        "#clean modlist|rules",
        "ADMIN",
        "#add",
        "#rem",
        "ex INGROUP.LUA",
        "#add realm",
        "#rem realm",
        "ex INPM.LUA",
        "(#join|#inviteme|[sasha] invitami) <chat_id>",
        "#allchats",
        "#allchatlist",
        "REALM",
        "#setgpowner <group_id> <user_id>",
        "#setgprules <group_id> <text>",
        "#mute|silenzia <group_id> all|audio|contact|document|gif|location|photo|sticker|text|tgservice|video|video_note|voice_note",
        "#unmute|ripristina <group_id> all|audio|contact|document|gif|location|photo|sticker|text|tgservice|video|video_note|voice_note",
        "(#muteslist|lista muti) <group_id>",
        "#textualmuteslist <group_id>",
        "(#lock|[sasha] blocca) <group_id> arabic|bots|flood|grouplink|leave|link|member|rtl|spam|strict",
        "(#unlock|[sasha] sblocca) <group_id> arabic|bots|flood|grouplink|leave|link|member|rtl|spam|strict",
        "#settings <group_id>",
        "#textualsettings <group_id>",
        "#type",
        "#rem <group_id>",
        "#list admins|groups|realms",
        "SUDO",
        "#addadmin <user_id>|<username>",
        "#removeadmin <user_id>|<username>",
    },
}