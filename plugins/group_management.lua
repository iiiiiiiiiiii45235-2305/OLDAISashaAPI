-- REFACTORING OF INPM.LUA INREALM.LUA INGROUP.LUA AND SUPERGROUP.LUA

group_type = ''

-- INPM
local function all_chats(msg)
    i = 1
    local data = load_data(config.moderation.data)
    local groups = 'groups'
    if not data[tostring(groups)] then
        return langs[msg.lang].noGroups
    end
    local message = langs[msg.lang].groupsJoin
    for k, v in pairsByKeys(data[tostring(groups)]) do
        local group_id = v
        if data[tostring(group_id)] then
            settings = data[tostring(group_id)]['settings']
        end
        for m, n in pairsByKeys(settings) do
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
        message = message .. group_info
    end

    i = 1
    local realms = 'realms'
    if not data[tostring(realms)] then
        return langs[msg.lang].noRealms
    end
    message = message .. '\n\n' .. langs[msg.lang].realmsJoin
    for k, v in pairsByKeys(data[tostring(realms)]) do
        local realm_id = v
        if data[tostring(realm_id)] then
            settings = data[tostring(realm_id)]['settings']
        end
        for m, n in pairsByKeys(settings) do
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
        message = message .. realm_info
    end
    local file = io.open("./groups/lists/all_listed_groups.txt", "w")
    file:write(message)
    file:flush()
    file:close()
    return message
end

-- INREALM
local function admin_promote(user, chat_id)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    if not data.admins then
        data.admins = { }
        save_data(config.moderation.data, data)
    end
    if data.admins[tostring(user.id)] then
        return sendMessage(chat_id,(user.username or user.print_name) .. langs[lang].alreadyAdmin)
    end
    data.admins[tostring(user.id)] =(user.username or user.print_name)
    save_data(config.moderation.data, data)
    return sendMessage(chat_id,(user.username or user.print_name) .. langs[lang].promoteAdmin)
end

local function admin_demote(user, chat_id)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    if not data.admins then
        data.admins = { }
        save_data(config.moderation.data, data)
    end
    if not data.admins[tostring(user.id)] then
        return sendMessage(chat_id,(user.username or user.print_name) .. langs[lang].notAdmin)
    end
    data.admins[tostring(user.id)] = nil
    save_data(config.moderation.data, data)
    return sendMessage(chat_id,(user.username or user.print_name) .. langs[lang].demoteAdmin)
end

local function admin_list(chat_id)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    if not data.admins then
        data.admins = { }
        save_data(config.moderation.data, data)
    end
    local message = langs[lang].adminListStart
    for k, v in pairs(data.admins) do
        message = message .. v .. ' - ' .. k .. '\n'
    end
    return sendMessage(chat_id, message)
end

local function groups_list(msg)
    local data = load_data(config.moderation.data)
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

-- locks/unlocks from realm
local function realm_lock_group_member(data, target, lang)
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
    if group_member_lock == 'yes' then
        return langs[lang].membersAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_member'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].membersLocked
    end
end

local function realm_unlock_group_member(data, target, lang)
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
    if group_member_lock == 'no' then
        return langs[lang].membersAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_member'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].membersUnlocked
    end
end

local function realm_lock_group_flood(data, target, lang)
    local group_flood_lock = data[tostring(target)]['settings']['flood']
    if group_flood_lock == 'yes' then
        return langs[lang].floodAlreadyLocked
    else
        data[tostring(target)]['settings']['flood'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].floodLocked
    end
end

local function realm_unlock_group_flood(data, target, lang)
    local group_flood_lock = data[tostring(target)]['settings']['flood']
    if group_flood_lock == 'no' then
        return langs[lang].floodAlreadyUnlocked
    else
        data[tostring(target)]['settings']['flood'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].floodUnlocked
    end
end

local function realm_lock_group_arabic(data, target, lang)
    local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
    if group_arabic_lock == 'yes' then
        return langs[lang].arabicAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_arabic'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].arabicLocked
    end
end

local function realm_unlock_group_arabic(data, target, lang)
    local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
    if group_arabic_lock == 'no' then
        return langs[lang].arabicAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_arabic'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].arabicUnlocked
    end
end

local function realm_lock_group_rtl(data, target, lang)
    local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
    if group_rtl_lock == 'yes' then
        return langs[lang].rtlAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_rtl'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].rtlLocked
    end
end

local function realm_unlock_group_rtl(data, target, lang)
    local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
    if group_rtl_lock == 'no' then
        return langs[lang].rtlAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_rtl'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].rtlUnlocked
    end
end

local function realm_lock_group_links(data, target, lang)
    local group_link_lock = data[tostring(target)]['settings']['lock_link']
    if group_link_lock == 'yes' then
        return langs[lang].linksAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_link'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].linksLocked
    end
end

local function realm_unlock_group_links(data, target, lang)
    local group_link_lock = data[tostring(target)]['settings']['lock_link']
    if group_link_lock == 'no' then
        return langs[lang].linksAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_link'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].linksUnlocked
    end
end

local function realm_lock_group_spam(data, target, lang)
    local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
    if group_spam_lock == 'yes' then
        return langs[lang].spamAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_spam'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].spamLocked
    end
end

local function realm_unlock_group_spam(data, target, lang)
    local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
    if group_spam_lock == 'no' then
        return langs[lang].spamAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_spam'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].spamUnlocked
    end
end

local function realm_lock_group_sticker(data, target, lang)
    local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
    if group_sticker_lock == 'yes' then
        return langs[lang].stickersAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_sticker'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].stickersLocked
    end
end

local function realm_unlock_group_sticker(data, target, lang)
    local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
    if group_sticker_lock == 'no' then
        return langs[lang].stickersAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_sticker'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].stickersUnlocked
    end
end

-- show group settings
local function realm_group_settings(target, lang)
    local data = load_data(config.moderation.data)
    local settings = data[tostring(target)]['settings']
    local text = langs[lang].groupSettings .. target .. ":" ..
    langs[lang].nameLock .. settings.lock_name ..
    langs[lang].photoLock .. settings.lock_photo ..
    langs[lang].membersLock .. settings.lock_member
    return text
end

-- show SuperGroup settings
local function realm_supergroup_settings(target, lang)
    local data = load_data(config.moderation.data)
    if data[tostring(target)]['settings'] then
        if not data[tostring(target)]['settings']['lock_rtl'] then
            data[tostring(target)]['settings']['lock_rtl'] = 'no'
        end
    end
    if data[tostring(target)]['settings'] then
        if not data[tostring(target)]['settings']['lock_member'] then
            data[tostring(target)]['settings']['lock_member'] = 'no'
        end
    end
    local settings = data[tostring(target)]['settings']
    local text = langs[lang].supergroupSettings .. target .. ":" ..
    langs[lang].linksLock .. settings.lock_link ..
    langs[lang].floodLock .. settings.flood ..
    langs[lang].spamLock .. settings.lock_spam ..
    langs[lang].arabic_lock .. settings.lock_arabic ..
    langs[lang].membersLock .. settings.lock_member ..
    langs[lang].rtlLock .. settings.lock_rtl ..
    langs[lang].stickersLock .. settings.lock_sticker ..
    langs[lang].strictrules .. settings.strict
    return text
end

local function realms_list(msg)
    local data = load_data(config.moderation.data)
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

-- INGROUP
local function modadd(msg)
    local data = load_data(config.moderation.data)
    if is_group(msg) then
        return langs[msg.lang].groupAlreadyAdded
    end
    local list = getChatAdministrators(msg.chat.id)
    if list then
        for i, admin in pairs(list.result) do
            if admin.status == 'creator' then
                -- Group configuration
                data[tostring(msg.chat.id)] = {
                    group_type = 'Group',
                    moderators = { },
                    set_owner = tostring(admin.user.id),
                    settings =
                    {
                        set_name = string.gsub(msg.chat.print_name,'_',' '),
                        lock_name = 'yes',
                        lock_photo = 'no',
                        lock_member = 'no',
                        flood = 'yes',
                    }
                }
                save_data(config.moderation.data, data)
                if not data[tostring('groups')] then
                    data[tostring('groups')] = { }
                    save_data(config.moderation.data, data)
                end
                data[tostring('groups')][tostring(msg.chat.id)] = msg.chat.id
                save_data(config.moderation.data, data)
                return sendMessage(msg.chat.id, langs[msg.lang].groupAddedOwner)
            end
        end
    end
end

local function modrem(msg)
    local data = load_data(config.moderation.data)
    if not is_group(msg) then
        return langs[msg.lang].groupNotAdded
    end
    -- Group configuration removal
    data[tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    if not data[tostring('groups')] then
        data[tostring('groups')] = nil
        save_data(config.moderation.data, data)
    end
    data[tostring('groups')][tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    return sendMessage(msg.chat.id, langs[msg.lang].groupRemoved)
end

local function realmadd(msg)
    local data = load_data(config.moderation.data)
    if is_realm(msg) then
        return langs[msg.lang].realmAlreadyAdded
    end
    local list = getChatAdministrators(msg.chat.id)
    if list then
        for i, admin in pairs(list.result) do
            if admin.status == 'creator' then
                -- Group configuration
                data[tostring(msg.chat.id)] = {
                    group_type = 'Realm',
                    settings =
                    {
                        set_name = string.gsub(msg.chat.print_name,'_',' '),
                        lock_name = 'yes',
                        lock_photo = 'no',
                        lock_member = 'no',
                        flood = 'yes'
                    }
                }
                save_data(config.moderation.data, data)
                if not data[tostring('realms')] then
                    data[tostring('realms')] = { }
                    save_data(config.moderation.data, data)
                end
                data[tostring('realms')][tostring(msg.chat.id)] = msg.chat.id
                save_data(config.moderation.data, data)
                return sendMessage(msg.chat.id, langs[msg.lang].groupAddedOwner)
            end
        end
    end
end

local function realmrem(msg)
    local data = load_data(config.moderation.data)
    if not is_realm(msg) then
        return langs[msg.lang].realmNotAdded
    end
    -- Realm configuration removal
    data[tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    if not data[tostring('realms')] then
        data[tostring('realms')] = nil
        save_data(config.moderation.data, data)
    end
    data[tostring('realms')][tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    return sendMessage(msg.chat.it, langs[msg.lang].realmRemoved)
end

local function promote(chat_id, user)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    if not data[chat_id] then
        return sendMessage(chat_id, langs[lang].groupNotAdded)
    end
    if data[chat_id]['moderators'][tostring(member_id)] then
        return sendMessage(chat_id,(user.username or user.print_name) .. langs[lang].alreadyMod)
    end
    data[chat_id]['moderators'][tostring(member_id)] =(user.username or user.print_name)
    save_data(config.moderation.data, data)
    return sendMessage(chat_id,(user.username or user.print_name) .. langs[lang].promoteMod)
end

local function demote(chat_id, user)
    local lang = get_lang(chat_id)
    local data = load_data(config.moderation.data)
    if not data[chat_id] then
        return sendMessage(chat_id, langs[lang].groupNotAdded)
    end
    if not data[chat_id]['moderators'][tostring(member_id)] then
        return sendMessage(chat_id,(user.username or user.print_name) .. langs[lang].notMod)
    end
    data[chat_id]['moderators'][tostring(member_id)] = nil
    save_data(config.moderation.data, data)
    return sendMessage(chat_id,(user.username or user.print_name) .. langs[lang].demoteMod)
end

local function modlist(msg)
    local data = load_data(config.moderation.data)
    local groups = "groups"
    if not data[tostring(groups)][tostring(msg.chat.id)] then
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

local function show_group_settingsmod(target, lang)
    local data = load_data(config.moderation.data)
    if data[tostring(target)] then
        if data[tostring(target)]['settings']['flood_msg_max'] then
            NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
            print('custom' .. NUM_MSG_MAX)
        else
            NUM_MSG_MAX = 5
        end
    end
    local bots_protection = "yes"
    if data[tostring(target)]['settings']['lock_bots'] then
        bots_protection = data[tostring(target)]['settings']['lock_bots']
    end
    local leave_ban = "no"
    if data[tostring(target)]['settings']['leave_ban'] then
        leave_ban = data[tostring(target)]['settings']['leave_ban']
    end
    if data[tostring(target)]['settings'] then
        if not data[tostring(target)]['settings']['lock_link'] then
            data[tostring(target)]['settings']['lock_link'] = 'no'
        end
    end
    if data[tostring(target)]['settings'] then
        if not data[tostring(target)]['settings']['lock_sticker'] then
            data[tostring(target)]['settings']['lock_sticker'] = 'no'
        end
    end
    if data[tostring(target)]['settings'] then
        if not data[tostring(target)]['settings']['public'] then
            data[tostring(target)]['settings']['public'] = 'no'
        end
    end
    if data[tostring(target)]['settings'] then
        if not data[tostring(target)]['settings']['lock_rtl'] then
            data[tostring(target)]['settings']['lock_rtl'] = 'no'
        end
    end
    local settings = data[tostring(target)]['settings']
    local text = langs[lang].groupSettings ..
    langs[lang].nameLock .. settings.lock_name ..
    langs[lang].photoLock .. settings.lock_photo ..
    langs[lang].membersLock .. settings.lock_member ..
    langs[lang].leaveLock .. leave_ban ..
    langs[lang].floodSensibility .. NUM_MSG_MAX ..
    langs[lang].botsLock .. bots_protection ..
    langs[lang].linksLock .. settings.lock_link ..
    langs[lang].rtlLock .. settings.lock_rtl ..
    langs[lang].stickersLock .. settings.lock_sticker ..
    langs[lang].public .. settings.public
    return text
end

-- SUPERGROUP
local function superadd(msg)
    local data = load_data(config.moderation.data)
    if is_super_group(msg) then
        return langs[msg.lang].supergroupAlreadyAdded
    end
    local list = getChatAdministrators(msg.chat.id)
    if list then
        for i, admin in pairs(list.result) do
            if admin.status == 'creator' then
                -- Group configuration
                data[tostring(msg.chat.id)] = {
                    group_type = 'SuperGroup',
                    moderators = { },
                    set_owner = tostring(admin.user.id),
                    settings =
                    {
                        set_name = string.gsub(msg.chat.print_name,'_',' '),
                        lock_arabic = 'no',
                        lock_link = "no",
                        flood = 'yes',
                        lock_spam = 'yes',
                        lock_sticker = 'no',
                        member = 'no',
                        lock_rtl = 'no',
                        lock_contacts = 'no',
                        strict = 'no'
                    }
                }
                save_data(config.moderation.data, data)
                if not data[tostring('groups')] then
                    data[tostring('groups')] = { }
                    save_data(config.moderation.data, data)
                end
                data[tostring('groups')][tostring(msg.chat.id)] = msg.chat.id
                save_data(config.moderation.data, data)
                return sendMessage(msg.chat.id, langs[msg.lang].groupAddedOwner)
            end
        end
    end
end

local function superrem(msg)
    local data = load_data(config.moderation.data)
    if not is_group(msg) then
        return langs[msg.lang].groupNotAdded
    end
    -- Group configuration removal
    data[tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    if not data[tostring('groups')] then
        data[tostring('groups')] = nil
        save_data(config.moderation.data, data)
    end
    data[tostring('groups')][tostring(msg.chat.id)] = nil
    save_data(config.moderation.data, data)
    return sendMessage(msg.chat.id, langs[msg.lang].supergroupRemoved)
end

-- Show supergroup settings; function
local function show_supergroup_settings(target, lang)
    local data = load_data(config.moderation.data)
    if data[tostring(target)] then
        if data[tostring(target)]['settings']['flood_msg_max'] then
            NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
            print('custom' .. NUM_MSG_MAX)
        else
            NUM_MSG_MAX = 5
        end
    end
    if data[tostring(target)]['settings'] then
        if not data[tostring(target)]['settings']['public'] then
            data[tostring(target)]['settings']['public'] = 'no'
        end
    end
    if data[tostring(target)]['settings'] then
        if not data[tostring(target)]['settings']['lock_rtl'] then
            data[tostring(target)]['settings']['lock_rtl'] = 'no'
        end
    end
    if data[tostring(target)]['settings'] then
        if not data[tostring(target)]['settings']['lock_tgservice'] then
            data[tostring(target)]['settings']['lock_tgservice'] = 'no'
        end
    end
    if data[tostring(target)]['settings'] then
        if not data[tostring(target)]['settings']['lock_member'] then
            data[tostring(target)]['settings']['lock_member'] = 'no'
        end
    end
    local settings = data[tostring(target)]['settings']
    local text = langs[lang].supergroupSettings ..
    langs[lang].linksLock .. settings.lock_link ..
    langs[lang].floodLock .. settings.flood ..
    langs[lang].floodSensibility .. NUM_MSG_MAX ..
    langs[lang].spamLock .. settings.lock_spam ..
    langs[lang].arabicLock .. settings.lock_arabic ..
    langs[lang].membersLock .. settings.lock_member ..
    langs[lang].rtlLock .. settings.lock_rtl ..
    langs[lang].tgserviceLock .. settings.lock_tgservice ..
    langs[lang].stickersLock .. settings.lock_sticker ..
    langs[lang].public .. settings.public ..
    langs[lang].strictrules .. settings.strict
    return text
end

-- LOCKS UNLOCKS FUNCTIONS
local function lock_group_arabic(data, target, lang)
    local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
    if group_arabic_lock == 'yes' then
        return langs[lang].arabicAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_arabic'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].arabicLocked
    end
end

local function unlock_group_arabic(data, target, lang)
    local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
    if group_arabic_lock == 'no' then
        return langs[lang].arabicAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_arabic'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].arabicUnlocked
    end
end

local function lock_group_bots(data, target, lang)
    local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
    if group_bots_lock == 'yes' then
        return langs[lang].botsAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_bots'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].botsLocked
    end
end

local function unlock_group_bots(data, target, lang)
    local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
    if group_bots_lock == 'no' then
        return langs[lang].botsAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_bots'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].botsUnlocked
    end
end

local function lock_group_flood(data, target, lang)
    local group_flood_lock = data[tostring(target)]['settings']['flood']
    if group_flood_lock == 'yes' then
        return langs[lang].floodAlreadyLocked
    else
        data[tostring(target)]['settings']['flood'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].floodLocked
    end
end

local function unlock_group_flood(data, target, lang)
    local group_flood_lock = data[tostring(target)]['settings']['flood']
    if group_flood_lock == 'no' then
        return langs[lang].floodAlreadyUnlocked
    else
        data[tostring(target)]['settings']['flood'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].floodUnlocked
    end
end

local function lock_group_member(data, target, lang)
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
    if group_member_lock == 'yes' then
        return langs[lang].membersAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_member'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].membersLocked
    end
end

local function unlock_group_member(data, target, lang)
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
    if group_member_lock == 'no' then
        return langs[lang].membersAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_member'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].membersUnlocked
    end
end

local function lock_group_leave(data, target, lang)
    local leave_ban = data[tostring(target)]['settings']['leave_ban']
    if leave_ban == 'yes' then
        return langs[lang].leaveAlreadyLocked
    else
        data[tostring(target)]['settings']['leave_ban'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].leaveLocked
    end
end

local function unlock_group_leave(data, target, lang)
    local leave_ban = data[tostring(msg.chat.id)]['settings']['leave_ban']
    if leave_ban == 'no' then
        return langs[lang].leaveAlreadyUnlocked
    else
        data[tostring(target)]['settings']['leave_ban'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].leaveUnlocked
    end
end

local function lock_group_links(data, target, lang)
    local group_link_lock = data[tostring(target)]['settings']['lock_link']
    if group_link_lock == 'yes' then
        return langs[lang].linksAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_link'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].linksLocked
    end
end

local function unlock_group_links(data, target, lang)
    local group_link_lock = data[tostring(target)]['settings']['lock_link']
    if group_link_lock == 'no' then
        return langs[lang].linksAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_link'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].linksUnlocked
    end
end

local function lock_group_spam(data, target, lang)
    local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
    if group_spam_lock == 'yes' then
        return langs[lang].spamAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_spam'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].spamLocked
    end
end

local function unlock_group_spam(data, target, lang)
    local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
    if group_spam_lock == 'no' then
        return langs[lang].spamAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_spam'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].spamUnlocked
    end
end

local function lock_group_rtl(data, target, lang)
    local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
    if group_rtl_lock == 'yes' then
        return langs[lang].rtlAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_rtl'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].rtlLocked
    end
end

local function unlock_group_rtl(data, target, lang)
    local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
    if group_rtl_lock == 'no' then
        return langs[lang].rtlAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_rtl'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].rtlUnlocked
    end
end

local function lock_group_sticker(data, target, lang)
    local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
    if group_sticker_lock == 'yes' then
        return langs[lang].stickersAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_sticker'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].stickersLocked
    end
end

local function unlock_group_sticker(data, target, lang)
    local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
    if group_sticker_lock == 'no' then
        return langs[lang].stickersAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_sticker'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].stickersUnlocked
    end
end

local function lock_group_contacts(data, target, lang)
    local group_rtl_lock = data[tostring(target)]['settings']['lock_contacts']
    if group_contacts_lock == 'yes' then
        return langs[lang].contactsAlreadyLocked
    else
        data[tostring(target)]['settings']['lock_contacts'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].contactsLocked
    end
end

local function unlock_group_contacts(data, target, lang)
    local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
    if group_contacts_lock == 'no' then
        return langs[lang].contactsAlreadyUnlocked
    else
        data[tostring(target)]['settings']['lock_contacts'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].contactsUnlocked
    end
end

local function enable_strict_rules(data, target, lang)
    local group_rtl_lock = data[tostring(target)]['settings']['strict']
    if strict == 'yes' then
        return langs[lang].strictrulesAlreadyLocked
    else
        data[tostring(target)]['settings']['strict'] = 'yes'
        save_data(config.moderation.data, data)
        return langs[lang].strictrulesLocked
    end
end

local function disable_strict_rules(data, target, lang)
    local group_contacts_lock = data[tostring(target)]['settings']['strict']
    if strict == 'no' then
        return langs[lang].strictrulesAlreadyUnlocked
    else
        data[tostring(target)]['settings']['strict'] = 'no'
        save_data(config.moderation.data, data)
        return langs[lang].strictrulesUnlocked
    end
end

local function chat_set_owner(user, chat_id)
    local data = load_data(config.moderation.data)
    local lang = get_lang(chat_id)
    data[tostring(chat_id)]['set_owner'] = tostring(user.id)
    save_data(config.moderation.data, data)
    return(user.username or user.print_name) .. ' [' .. user.id .. ']' .. langs[lang].setOwner
end

local function get_admins(chat_id)
    local list = getChatAdministrators(chat_id)
    if list then
        local text = ''
        for i, admin in pairs(list.result) do
            text = text ..(admin.user.username or admin.user.first_name) .. ' [' .. admin.user.id .. ']\n'
        end
    end
end

local function contact_mods(msg)
    local text = langs[msg.lang].receiver .. msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']\n' .. langs[msg.lang].sender
    if msg.from.username then
        text = text .. '@' .. msg.from.username .. ' [' .. msg.from.id .. ']\n'
    else
        text = text .. msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']\n'
    end
    text = text .. langs[msg.lang].msgText ..(msg.text or msg.caption) .. '\n'
    if msg.reply then
        text = text .. langs[msg.lang].replyText ..(msg.reply_to_message.text or msg.reply_to_message.caption)
    end


    local already_contacted = { }
    local list = getChatAdministrators(msg.chat.id)
    if list then
        for i, admin in pairs(list.result) do
            already_contacted[tonumber(admin.user.id)] = admin.user.id
            sendMessage(admin.user.id, text)
        end
    end

    local data = load_data(config.moderation.data)

    -- owner
    local owner = data[tostring(msg.chat.id)]['set_owner']
    if owner then
        if not already_contacted[tonumber(owner)] then
            already_contacted[tonumber(owner)] = owner
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
            sendMessage(k, text)
        end
    end
end

local function run(msg, matches)
    local data = load_data(config.moderation.data)
    if matches[1]:lower() == 'type' then
        if is_mod(msg) then
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
        if is_owner(msg) then
            savelog(msg.chat.id, "log file created by owner/admin")
            return sendDocument(msg.chat.id, "./groups/logs/" .. msg.chat.id .. "log.txt")
        else
            return langs[msg.lang].require_owner
        end
    end
    if matches[1]:lower() == 'admins' then
        return contact_mods(msg)
    end

    -- INPM
    -- TODO: add lock and unlock join
    if is_sudo(msg) or msg.chat.type == 'private' then
        if matches[1]:lower() == 'allchats' then
            if is_admin(msg) then
                return all_chats(msg)
            else
                return langs[msg.lang].require_admin
            end
        end

        if matches[1]:lower() == 'allchatslist' then
            if is_admin(msg) then
                all_chats(msg)
                return sendDocument(msg.chat.id, "./groups/lists/all_listed_groups.txt")
            else
                return langs[msg.lang].require_admin
            end
        end
    end

    -- INREALM
    if is_realm(msg) then
        if matches[1]:lower() == 'rem' and matches[2] then
            if is_admin(msg) then
                -- Group configuration removal
                data[tostring(matches[2])] = nil
                save_data(config.moderation.data, data)
                if not data[tostring('groups')] then
                    data[tostring('groups')] = nil
                    save_data(config.moderation.data, data)
                end
                data[tostring('groups')][tostring(matches[2])] = nil
                save_data(config.moderation.data, data)
                return sendMessage(msg.chat.id, langs[msg.lang].chat .. matches[2] .. langs[msg.lang].removed)
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'addadmin' then
            if is_sudo(msg) then
                if msg.reply then
                    return admin_promote(msg.reply_to_message.from, msg.chat.id)
                elseif string.match(matches[2], '^%d+$') then
                    local obj_user = getChat(matches[2]).result
                    if obj_user then
                        if obj_user.type == 'private' then
                            return admin_promote(obj_user, msg.chat.id)
                        end
                    end
                else
                    local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                    if obj_user then
                        if obj_user.type == 'private' then
                            return admin_promote(obj_user, msg.chat.id)
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
                if msg.reply then
                    return admin_demote(msg.reply_to_message.from, msg.chat.id)
                elseif string.match(matches[2], '^%d+$') then
                    local obj_user = getChat(matches[2]).result
                    if obj_user then
                        if obj_user.type == 'private' then
                            return admin_demote(obj_user, msg.chat.id)
                        end
                    end
                else
                    local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                    if obj_user then
                        if obj_user.type == 'private' then
                            return admin_demote(obj_user, msg.chat.id)
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_sudo
            end
        end
        if matches[1]:lower() == 'setgpowner' and matches[2] and matches[3] then
            if is_admin(msg) then
                data[tostring(matches[2])]['set_owner'] = matches[3]
                save_data(config.moderation.data, data)
                return sendMessage(matches[2], matches[3] .. langs[lang].setOwner)
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'list' then
            if is_admin(msg) then
                if matches[2]:lower() == 'admins' then
                    return admin_list(msg.chat.id)
                elseif matches[2]:lower() == 'groups' then
                    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
                        groups_list(msg)
                        sendDocument(msg.chat.id, "./groups/lists/groups.txt")
                        sendDocument(msg.chat.id, "./groups/lists/groups.txt")
                        -- return group_list(msg)
                    elseif msg.chat.type == 'private' then
                        groups_list(msg)
                        sendDocument(msg.from.id, "./groups/lists/groups.txt")
                        -- return group_list(msg)
                    end
                    return langs[msg.lang].groupListCreated
                elseif matches[2]:lower() == 'realms' then
                    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
                        realms_list(msg)
                        sendDocument(msg.chat.id, "./groups/lists/realms.txt")
                        sendDocument(msg.chat.id, "./groups/lists/realms.txt")
                        -- return realms_list(msg)
                    elseif msg.chat.type == 'private' then
                        realms_list(msg)
                        sendDocument(msg.from.id, "./groups/lists/realms.txt")
                        -- return realms_list(msg)
                    end
                    return langs[msg.lang].realmListCreated
                end
            else
                return langs[msg.lang].require_admin
            end
        end
        if msg.service then
            if msg.service_type == 'chat_add_user' then
                if msg.added then
                    if msg.added.id ~= 149998353 then
                        -- if not admin and not bot then
                        if not is_admin(msg) then
                            return kickUser(bot.id, msg.added.id, msg.chat.id)
                        end
                    end
                end
            end
        end
        if (matches[1]:lower() == 'lock' or matches[1]:lower() == 'sasha blocca' or matches[1]:lower() == 'blocca') and matches[2] and matches[3] then
            if is_admin(msg) then
                if matches[3]:lower() == 'member' then
                    return realm_lock_group_member(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'flood' then
                    return realm_lock_group_flood(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'arabic' then
                    return realm_lock_group_arabic(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'links' then
                    return realm_lock_group_links(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'spam' then
                    return realm_lock_group_spam(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'rtl' then
                    return realm_lock_group_rtl(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'sticker' then
                    return realm_lock_group_sticker(data, matches[2], msg.lang)
                end
            else
                return langs[msg.lang].require_admin
            end
        end
        if (matches[1]:lower() == 'unlock' or matches[1]:lower() == 'sasha sblocca' or matches[1]:lower() == 'sblocca') and matches[2] and matches[3] then
            if is_admin(msg) then
                if matches[3]:lower() == 'member' then
                    return realm_unlock_group_member(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'flood' then
                    return realm_unlock_group_flood(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'arabic' then
                    return realm_unlock_group_arabic(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'links' then
                    return realm_unlock_group_links(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'spam' then
                    return realm_unlock_group_spam(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'rtl' then
                    return realm_unlock_group_rtl(data, matches[2], msg.lang)
                end
                if matches[3]:lower() == 'sticker' then
                    return realm_unlock_group_sticker(data, matches[2], msg.lang)
                end
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'settings' and data[tostring(matches[2])]['settings'] then
            if is_admin(msg) then
                return realm_group_settings(matches[2], msg.lang)
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'supersettings' and data[tostring(matches[2])]['settings'] then
            if is_admin(msg) then
                return realm_supergroup_settings(matches[2], msg.lang)
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'setgprules' then
            if is_admin(msg) then
                data[tostring(matches[2])]['rules'] = matches[3]
                save_data(config.moderation.data, data)
                return langs[msg.lang].newRules .. matches[3]
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'setgroupabout' and matches[2] and matches[3] then
            if is_admin(msg) then
                data[tostring(matches[2])]['description'] = matches[3]
                save_data(config.moderation.data, data)
                return langs[msg.lang].newDescription .. matches[3]
            else
                return langs[msg.lang].require_admin
            end
        end
    end

    -- INGROUP
    if msg.chat.type == 'group' then
        if matches[1]:lower() == 'add' and not matches[2] then
            if is_admin(msg) then
                if is_realm(msg) then
                    return langs[msg.lang].errorAlreadyRealm
                end
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added group [ " .. msg.chat.id .. " ]")
                print("group " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") added")
                return modadd(msg)
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
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added realm [ " .. msg.chat.id .. " ]")
                print("group " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") added as a realm")
                return realmadd(msg)
            else
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] attempted to add realm [ " .. msg.chat.id .. " ]")
                return langs[msg.lang].require_sudo
            end
        end
        if matches[1]:lower() == 'rem' and not matches[2] then
            if not is_admin(msg) then
                if not is_group(msg) then
                    return langs[msg.lang].errorNotGroup
                end
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed group [ " .. msg.chat.id .. " ]")
                print("group " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") removed")
                return modrem(msg)
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
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed realm [ " .. msg.chat.id .. " ]")
                print("group " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") removed as a realm")
                return realmrem(msg)
            else
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] attempted to remove realm [ " .. msg.chat.id .. " ]")
                return langs[msg.lang].require_sudo
            end
        end
        if data[tostring(msg.chat.id)] then
            local settings = data[tostring(msg.chat.id)]['settings']
            if msg.service then
                if msg.service_type == 'chat_add_user' then
                    if settings.lock_member == 'yes' and not is_owner2(msg.action.user.id, msg.chat.id) then
                        return kickUser(bot.id, msg.added.id, msg.chat.id)
                    elseif settings.lock_member == 'yes' and tonumber(msg.from.id) == tonumber(bot.id) then
                        return
                    elseif settings.lock_member == 'no' then
                        return
                    end
                end
                if msg.service_type == 'chat_del_user' then
                    return savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] deleted user  " .. 'user#id' .. msg.action.user.id)
                end
            end
            if matches[1]:lower() == 'promote' or matches[1]:lower() == 'sasha promuovi' or matches[1]:lower() == 'promuovi' then
                if is_owner(msg) then
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return promote(msg.chat.id, msg.reply_to_message.forward_from)
                                    else
                                        -- return error cant kick chat
                                    end
                                else
                                    -- return error no forward
                                end
                            end
                        else
                            return promote(msg.chat.id, msg.reply_to_message.from)
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2]).result
                        if obj_user then
                            if obj_user.type == 'private' then
                                return promote(msg.chat.id, obj_user)
                            end
                        end
                    else
                        local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                        if obj_user then
                            if obj_user.type == 'private' then
                                return promote(msg.chat.id, obj_user)
                            end
                        end
                    end
                    return
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == 'demote' or matches[1]:lower() == 'sasha degrada' or matches[1]:lower() == 'degrada' then
                if is_owner(msg) then
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return demote(msg.chat.id, msg.reply_to_message.forward_from)
                                    else
                                        -- return error cant kick chat
                                    end
                                else
                                    -- return error no forward
                                end
                            end
                        else
                            return demote(msg.chat.id, msg.reply_to_message.from)
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2]).result
                        if obj_user then
                            if obj_user.type == 'private' then
                                return demote(msg.chat.id, obj_user)
                            end
                        end
                    else
                        local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                        if obj_user then
                            if obj_user.type == 'private' then
                                return demote(msg.chat.id, obj_user)
                            end
                        end
                    end
                    return
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == 'modlist' or matches[1]:lower() == 'sasha lista mod' or matches[1]:lower() == 'lista mod' then
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group modlist")
                return modlist(msg)
            end
            if matches[1]:lower() == 'about' or matches[1]:lower() == 'sasha descrizione' then
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group description")
                if not data[tostring(msg.chat.id)]['description'] then
                    return langs[msg.lang].noDescription
                end
                return langs[msg.lang].description .. string.gsub(msg.chat.print_name, "_", " ") .. ':\n\n' .. data[tostring(msg.chat.id)]['description']
            end
            if matches[1]:lower() == 'rules' or matches[1]:lower() == 'sasha regole' then
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group rules")
                if not data[tostring(msg.chat.id)]['rules'] then
                    return langs[msg.lang].noRules
                end
                return langs[msg.lang].rules .. data[tostring(msg.chat.id)]['rules']
            end
            if matches[1]:lower() == 'setrules' or matches[1]:lower() == 'sasha imposta regole' then
                if is_mod(msg) then
                    data[tostring(msg.chat.id)]['rules'] = matches[2]
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] has changed group rules to [" .. matches[2] .. "]")
                    return langs[msg.lang].newRules .. matches[2]
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'setabout' or matches[1]:lower() == 'sasha imposta descrizione' then
                if is_mod(msg) then
                    data[tostring(msg.chat.id)]['description'] = matches[2]
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] has changed group description to [" .. matches[2] .. "]")
                    return langs[msg.lang].newDescription .. matches[2]
                else
                    return langs[msg.lang].require_mod
                end
            end
        end
        if matches[1]:lower() == 'lock' or matches[1]:lower() == 'sasha blocca' or matches[1]:lower() == 'blocca' then
            if is_mod(msg) then
                if matches[2]:lower() == 'member' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked member ")
                    return lock_group_member(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'flood' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked flood ")
                    return lock_group_flood(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'arabic' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked arabic ")
                    return lock_group_arabic(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'bots' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked bots ")
                    return lock_group_bots(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'leave' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked leaving ")
                    return lock_group_leave(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'links' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked link posting ")
                    return lock_group_links(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'rtl' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked rtl chars. in names")
                    return lock_group_rtl(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'sticker' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked sticker posting")
                    return lock_group_sticker(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'contacts' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked contact posting")
                    return lock_group_contacts(data, msg.chat.id, msg.lang)
                end
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'unlock' or matches[1]:lower() == 'sasha sblocca' or matches[1]:lower() == 'sblocca' then
            if is_mod(msg) then
                if matches[2]:lower() == 'member' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked member ")
                    return unlock_group_member(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'flood' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked flood ")
                    return unlock_group_flood(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'arabic' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked arabic ")
                    return unlock_group_arabic(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'bots' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked bots ")
                    return unlock_group_bots(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'leave' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked leaving ")
                    return unlock_group_leave(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'links' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked link posting")
                    return unlock_group_links(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'rtl' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked RTL chars. in names")
                    return unlock_group_rtl(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'sticker' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked sticker posting")
                    return unlock_group_sticker(data, msg.chat.id, msg.lang)
                end
                if matches[2]:lower() == 'contacts' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked contact posting")
                    return unlock_group_contacts(data, msg.chat.id, msg.lang)
                end
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'settings' then
            if is_mod(msg) then
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group settings ")
                return show_group_settingsmod(msg.chat.id, msg.lang)
            else
                return langs[msg.lang].require_mod
            end
        end
        if (matches[1]:lower() == 'setlink' or matches[1]:lower() == "sasha imposta link") and matches[2] then
            if is_owner(msg) then
                data[tostring(msg.chat.id)]['settings']['set_link'] = matches[2]
                save_data(config.moderation.data, data)
                return langs[msg.lang].linkSaved
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'unsetlink' or matches[1]:lower() == "sasha elimina link" then
            if is_owner(msg) then
                data[tostring(msg.chat.id)]['settings']['set_link'] = nil
                save_data(config.moderation.data, data)
                return langs[msg.lang].linkDeleted
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'link' or matches[1]:lower() == 'sasha link' then
            if is_mod(msg) then
                local group_link = data[tostring(msg.chat.id)]['settings']['set_link']
                if not group_link then
                    return langs[msg.lang].createLinkInfo
                end
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group link [" .. group_link .. "]")
                return msg.chat.title .. '\n' .. group_link
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'owner' then
            local group_owner = data[tostring(msg.chat.id)]['set_owner']
            if not group_owner then
                return langs[msg.lang].noOwnerCallAdmin
            end
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] used /owner")
            return langs[msg.lang].ownerIs .. group_owner
        end
        if matches[1]:lower() == 'setowner' then
            if is_owner(msg) then
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return chat_set_owner(msg.reply_to_message.forward_from, msg.chat.id)
                                else
                                    -- return error cant setowner chat
                                end
                            else
                                -- return error no forward
                            end
                        end
                    else
                        return chat_set_owner(msg.reply_to_message.from, msg.chat.id)
                    end
                end
                if string.match(matches[2], '^%d+$') then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set [" .. matches[2] .. "] as owner")
                    local obj_user = getChat(matches[2]).result
                    if obj_user then
                        if obj_user.type == 'private' then
                            return chat_set_owner(obj_user, msg.chat.id)
                        end
                    end
                else
                    local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                    if obj_user then
                        if obj_user.type == 'private' then
                            return chat_set_owner(obj_user, msg.chat.id)
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_owner
            end
        end
        if matches[1]:lower() == 'setflood' then
            if is_mod(msg) then
                if tonumber(matches[2]) < 3 or tonumber(matches[2]) > 200 then
                    return langs[msg.lang].errorFloodRange
                end
                data[tostring(msg.chat.id)]['settings']['flood_msg_max'] = matches[2]
                save_data(config.moderation.data, data)
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set flood to [" .. matches[2] .. "]")
                return langs[msg.lang].floodSet .. matches[2]
            else
                return langs[msg.lang].require_mod
            end
        end
        if matches[1]:lower() == 'clean' then
            if is_owner(msg) then
                if matches[2]:lower() == 'modlist' then
                    if next(data[tostring(msg.chat.id)]['moderators']) == nil then
                        -- fix way
                        return langs[msg.lang].noGroupMods
                    end
                    local message = langs[msg.lang].modListStart .. string.gsub(msg.chat.print_name, '_', ' ') .. ':\n'
                    for k, v in pairs(data[tostring(msg.chat.id)]['moderators']) do
                        data[tostring(msg.chat.id)]['moderators'][tostring(k)] = nil
                        save_data(config.moderation.data, data)
                    end
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned modlist")
                end
                if matches[2]:lower() == 'rules' then
                    data[tostring(msg.chat.id)]['rules'] = nil
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned rules")
                end
                if matches[2]:lower() == 'about' then
                    data[tostring(msg.chat.id)]['description'] = nil
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned about")
                end
            else
                return langs[msg.lang].require_owner
            end
        end
    end

    -- SUPERGROUP
    if msg.chat.type == 'supergroup' then
        if matches[1]:lower() == 'add' and not matches[2] then
            if is_admin(msg) then
                if is_super_group(msg) then
                    return reply_msg(msg.id, langs[msg.lang].supergroupAlreadyAdded, ok_cb, false)
                end
                print("SuperGroup " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") added")
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added SuperGroup")
                superadd(msg)
                set_mutes(msg.chat.id)
                channel_set_admin(get_receiver(msg), 'user#id' .. msg.from.id, ok_cb, false)
            else
                return langs[msg.lang].require_admin
            end
        end
        if matches[1]:lower() == 'rem' and is_admin(msg) and not matches[2] then
            if is_admin(msg) then
                if not is_super_group(msg) then
                    return reply_msg(msg.id, langs[msg.lang].supergroupRemoved, ok_cb, false)
                end
                print("SuperGroup " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") removed")
                superrem(msg)
                rem_mutes(msg.chat.id)
            else
                return langs[msg.lang].require_admin
            end
        end
        if data[tostring(msg.chat.id)] then
            if matches[1]:lower() == "getadmins" or matches[1]:lower() == "sasha lista admin" or matches[1]:lower() == "lista admin" then
                if is_owner(msg) then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup Admins list")
                    return get_admins(msg.chat.id)
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == "owner" then
                if not data[tostring(msg.chat.id)]['set_owner'] then
                    return langs[msg.lang].noOwnerCallAdmin
                end
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] used /owner")
                return langs[msg.lang].ownerIs .. data[tostring(msg.chat.id)]['set_owner']
            end
            if matches[1]:lower() == "modlist" or matches[1]:lower() == "sasha lista mod" or matches[1]:lower() == "lista mod" then
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group modlist")
                return modlist(msg)
            end
            if (matches[1]:lower() == 'setlink' or matches[1]:lower() == "sasha imposta link") and matches[2] then
                if is_owner(msg) then
                    data[tostring(msg.chat.id)]['settings']['set_link'] = matches[2]
                    save_data(config.moderation.data, data)
                    return langs[msg.lang].linkSaved
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == 'unsetlink' or matches[1]:lower() == "sasha elimina link" then
                if is_owner(msg) then
                    data[tostring(msg.chat.id)]['settings']['set_link'] = nil
                    save_data(config.moderation.data, data)
                    return langs[msg.lang].linkDeleted
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == 'link' or matches[1]:lower() == "sasha link" then
                if is_mod(msg) then
                    local group_link = data[tostring(msg.chat.id)]['settings']['set_link']
                    if not group_link then
                        return langs[msg.lang].createLinkInfo
                    end
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group link [" .. group_link .. "]")
                    return msg.chat.title .. '\n' .. group_link
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'setowner' then
                if is_owner(msg) then
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return chat_set_owner(msg.reply_to_message.forward_from, msg.chat.id)
                                    else
                                        -- return error cant setowner chat
                                    end
                                else
                                    -- return error no forward
                                end
                            end
                        else
                            return chat_set_owner(msg.reply_to_message.from, msg.chat.id)
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set [" .. matches[2] .. "] as owner")
                        local obj_user = getChat(matches[2]).result
                        if obj_user then
                            if obj_user.type == 'private' then
                                return chat_set_owner(obj_user, msg.chat.id)
                            end
                        end
                    else
                        local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                        if obj_user then
                            if obj_user.type == 'private' then
                                return chat_set_owner(obj_user, msg.chat.id)
                            end
                        end
                    end
                    return
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == 'promote' or matches[1]:lower() == "sasha promuovi" or matches[1]:lower() == "promuovi" then
                if is_owner(msg) then
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return promote(msg.chat.id, msg.reply_to_message.forward_from)
                                    else
                                        -- return error cant kick chat
                                    end
                                else
                                    -- return error no forward
                                end
                            end
                        else
                            return promote(msg.chat.id, msg.reply_to_message.from)
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2]).result
                        if obj_user then
                            if obj_user.type == 'private' then
                                return promote(msg.chat.id, obj_user)
                            end
                        end
                    else
                        local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                        if obj_user then
                            if obj_user.type == 'private' then
                                return promote(msg.chat.id, obj_user)
                            end
                        end
                    end
                    return
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == 'demote' or matches[1]:lower() == "sasha degrada" or matches[1]:lower() == "degrada" then
                if is_owner(msg) then
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        return demote(msg.chat.id, msg.reply_to_message.forward_from)
                                    else
                                        -- return error cant kick chat
                                    end
                                else
                                    -- return error no forward
                                end
                            end
                        else
                            return demote(msg.chat.id, msg.reply_to_message.from)
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        local obj_user = getChat(matches[2]).result
                        if obj_user then
                            if obj_user.type == 'private' then
                                return demote(msg.chat.id, obj_user)
                            end
                        end
                    else
                        local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                        if obj_user then
                            if obj_user.type == 'private' then
                                return demote(msg.chat.id, obj_user)
                            end
                        end
                    end
                    return
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == "setabout" or matches[1]:lower() == "sasha imposta descrizione" then
                if is_mod(msg) then
                    data[tostring(msg.chat.id)]['description'] = matches[2]
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set SuperGroup description to: " .. matches[2])
                    return langs[msg.lang].newDescription .. matches[2]
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'setrules' or matches[1]:lower() == "sasha imposta regole" then
                if is_mod(msg) then
                    data[tostring(msg.chat.id)]['rules'] = matches[2]
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] has changed group rules to [" .. matches[2] .. "]")
                    return langs[msg.lang].newRules .. matches[2]
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'clean' then
                if is_owner(msg) then
                    if matches[2]:lower() == 'modlist' then
                        if next(data[tostring(msg.chat.id)]['moderators']) == nil then
                            return langs[msg.lang].noGroupMods
                        end
                        for k, v in pairs(data[tostring(msg.chat.id)]['moderators']) do
                            data[tostring(msg.chat.id)]['moderators'][tostring(k)] = nil
                            save_data(config.moderation.data, data)
                        end
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned modlist")
                        return langs[msg.lang].modlistCleaned
                    end
                    if matches[2]:lower() == 'rules' then
                        local data_cat = 'rules'
                        if data[tostring(msg.chat.id)][data_cat] == nil then
                            return langs[msg.lang].noRules
                        end
                        data[tostring(msg.chat.id)][data_cat] = nil
                        save_data(config.moderation.data, data)
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned rules")
                        return langs[msg.lang].rulesCleaned
                    end
                    if matches[2]:lower() == 'about' then
                        local receiver = get_receiver(msg)
                        local about_text = ' '
                        local data_cat = 'description'
                        if data[tostring(msg.chat.id)][data_cat] == nil then
                            return langs[msg.lang].noDescription
                        end
                        data[tostring(msg.chat.id)][data_cat] = nil
                        save_data(config.moderation.data, data)
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned about")
                        return langs[msg.lang].descriptionCleaned
                    end
                    if matches[2]:lower() == 'mutelist' then
                        chat_id = msg.chat.id
                        local hash = 'mute_user:' .. chat_id
                        redis:del(hash)
                        return langs[msg.lang].mutelistCleaned
                    end
                else
                    return langs[msg.lang].require_owner
                end
            end
            if matches[1]:lower() == 'lock' or matches[1]:lower() == "sasha blocca" or matches[1]:lower() == "blocca" then
                if is_mod(msg) then
                    if matches[2]:lower() == 'links' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked link posting ")
                        return lock_group_links(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'spam' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked spam ")
                        return lock_group_spam(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'flood' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked flood ")
                        return lock_group_flood(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'arabic' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked arabic ")
                        return lock_group_arabic(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'member' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked member ")
                        return lock_group_member(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'rtl' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked rtl chars. in names")
                        return lock_group_rtl(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'tgservice' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked Tgservice Actions")
                        return lock_group_tgservice(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'sticker' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked sticker posting")
                        return lock_group_sticker(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'contacts' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked contact posting")
                        return lock_group_contacts(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'strict' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked enabled strict settings")
                        return enable_strict_rules(data, msg.chat.id, msg.lang)
                    end
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'unlock' or matches[1]:lower() == "sasha sblocca" or matches[1]:lower() == "sblocca" then
                if is_mod(msg) then
                    if matches[2]:lower() == 'links' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked link posting")
                        return unlock_group_links(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'spam' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked spam")
                        return unlock_group_spam(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'flood' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked flood")
                        return unlock_group_flood(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'arabic' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked Arabic")
                        return unlock_group_arabic(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'member' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked member ")
                        return unlock_group_member(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'rtl' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked RTL chars. in names")
                        return unlock_group_rtl(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'tgservice' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked tgservice actions")
                        return unlock_group_tgservice(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'sticker' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked sticker posting")
                        return unlock_group_sticker(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'contacts' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] unlocked contact posting")
                        return unlock_group_contacts(data, msg.chat.id, msg.lang)
                    end
                    if matches[2]:lower() == 'strict' then
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] locked disabled strict settings")
                        return disable_strict_rules(data, msg.chat.id, msg.lang)
                    end
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'setflood' then
                if is_mod(msg) then
                    if tonumber(matches[2]) < 3 or tonumber(matches[2]) > 200 then
                        return langs[msg.lang].errorFloodRange
                    end
                    data[tostring(msg.chat.id)]['settings']['flood_msg_max'] = matches[2]
                    save_data(config.moderation.data, data)
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] set flood to [" .. matches[2] .. "]")
                    return langs[msg.lang].floodSet .. matches[2]
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'settings' then
                if is_mod(msg) then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup settings ")
                    return show_supergroup_settings(msg.chat.id, msg.lang)
                else
                    return langs[msg.lang].require_mod
                end
            end
            if matches[1]:lower() == 'rules' or matches[1]:lower() == "sasha regole" then
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group rules")
                if not data[tostring(msg.chat.id)]['rules'] then
                    return langs[msg.lang].noRules
                end
                return data[tostring(msg.chat.id)]['settings']['set_name'] .. ' ' .. langs[msg.lang].rules .. '\n\n' .. data[tostring(msg.chat.id)]['rules']
            end
        end
    end
end

return {
    description = "GROUP_MANAGEMENT",
    patterns =
    {
        -- INPM
        "^[#!/]([Aa][Ll][Ll][Cc][Hh][Aa][Tt][Ss])$",
        "^[#!/]([Aa][Ll][Ll][Cc][Hh][Aa][Tt][Ss][Ll][Ii][Ss][Tt])$",

        -- INREALM
        "^[#!/]([Rr][Ee][Mm]) (%-?%d+)$",
        "^[#!/]([Aa][Dd][Dd][Aa][Dd][Mm][Ii][Nn]) (.*)$",
        "^[#!/]([Rr][Ee][Mm][Oo][Vv][Ee][Aa][Dd][Mm][Ii][Nn]) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Pp][Oo][Ww][Nn][Ee][Rr]) (%d+) (%d+)$",-- (group id) (owner id)
        "^[#!/]([Ll][Ii][Ss][Tt]) (.*)$",
        "^[#!/]([Ll][Oo][Cc][Kk]) (%-?%d+) (.*)$",
        "^[#!/]([Uu][Nn][Ll][Oo][Cc][Kk]) (%-?%d+) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss]) (%-?%d+)$",
        "^[#!/]([Ss][Uu][Pp][Ee][Rr][Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss]) (%-?%d+)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Pp][Rr][Uu][Ll][Ee][Ss]) (%-?%d+) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Ss][Uu][Pp][Ee][Rr][Gg][Rr][Oo][Uu][Pp][Aa][Bb][Oo][Uu][Tt]) (%-?%d+) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Rr][Oo][Uu][Pp][Aa][Bb][Oo][Uu][Tt]) (%-?%d+) (.*)$",
        -- lock
        "^([Ss][Aa][Ss][Hh][Aa] [Bb][Ll][Oo][Cc][Cc][Aa]) (%-?%d+) (.*)$",
        "^([Bb][Ll][Oo][Cc][Cc][Aa]) (%-?%d+) (.*)$",
        -- unlock
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Bb][Ll][Oo][Cc][Cc][Aa]) (%-?%d+) (.*)$",
        "^([Ss][Bb][Ll][Oo][Cc][Cc][Aa]) (%-?%d+) (.*)$",

        -- INGROUP
        "^[#!/]([Aa][Dd][Dd]) ([Rr][Ee][Aa][Ll][Mm])$",
        "^[#!/]([Rr][Ee][Mm]) ([Rr][Ee][Aa][Ll][Mm])$",

        -- SUPERGROUP
        "^[#!/]([Gg][Ee][Tt][Aa][Dd][Mm][Ii][Nn][Ss])$",
        -- getadmins
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Ss][Tt][Aa] [Aa][Dd][Mm][Ii][Nn])$",
        "^([Ll][Ii][Ss][Tt][Aa] [Aa][Dd][Mm][Ii][Nn])$",

        -- COMMON
        "^[#!/]([Tt][Yy][Pp][Ee])$",
        "^[#!/]([Ll][Oo][Gg])$",
        "^[#!/]([Aa][Dd][Mm][Ii][Nn][Ss])",
        "^[#!/]([Aa][Dd][Dd])$",
        "^[#!/]([Rr][Ee][Mm])$",
        "^[#!/]([Rr][Uu][Ll][Ee][Ss])$",
        "^[#!/]([Aa][Bb][Oo][Uu][Tt])$",
        "^[#!/]([Ss][Ee][Tt][Ff][Ll][Oo][Oo][Dd]) (%d+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss])$",
        "^[#!/]([Pp][Rr][Oo][Mm][Oo][Tt][Ee]) (.*)$",
        "^[#!/]([Pp][Rr][Oo][Mm][Oo][Tt][Ee])",
        "^[#!/]([Dd][Ee][Mm][Oo][Tt][Ee]) (.*)$",
        "^[#!/]([Dd][Ee][Mm][Oo][Tt][Ee])",
        "^[#!/]([Ss][Ee][Tt][Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        "^[#!/]([Ss][Ee][Tt][Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Ll][Ii][Nn][Kk])$",
        "^[#!/]([Ll][Ii][Nn][Kk])$",
        "^[#!/]([Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss]) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Aa][Bb][Oo][Uu][Tt]) (.*)$",
        "^[#!/]([Oo][Ww][Nn][Ee][Rr])$",
        "^[#!/]([Ll][Oo][Cc][Kk]) (.*)$",
        "^[#!/]([Uu][Nn][Ll][Oo][Cc][Kk]) (.*)$",
        "^[#!/]([Mm][Oo][Dd][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Cc][Ll][Ee][Aa][Nn]) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr])$",
        "^!!tgservice (.+)$",
        -- rules
        "^([Ss][Aa][Ss][Hh][Aa] [Rr][Ee][Gg][Oo][Ll][Ee])$",
        -- about
        "^([Ss][Aa][Ss][Hh][Aa] [Dd][Ee][Ss][Cc][Rr][Ii][Zz][Ii][Oo][Nn][Ee])$",
        -- promote
        "^([Ss][Aa][Ss][Hh][Aa] [Pp][Rr][Oo][Mm][Uu][Oo][Vv][Ii]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Pp][Rr][Oo][Mm][Uu][Oo][Vv][Ii])$",
        "^([Pp][Rr][Oo][Mm][Uu][Oo][Vv][Ii]) (.*)$",
        "^([Pp][Rr][Oo][Mm][Uu][Oo][Vv][Ii])$",
        -- demote
        "^([Ss][Aa][Ss][Hh][Aa] [Dd][Ee][Gg][Rr][Aa][Dd][Aa]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Dd][Ee][Gg][Rr][Aa][Dd][Aa])$",
        "^([Dd][Ee][Gg][Rr][Aa][Dd][Aa]) (.*)$",
        "^([Dd][Ee][Gg][Rr][Aa][Dd][Aa])$",
        -- setrules
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Mm][Pp][Oo][Ss][Tt][Aa] [Rr][Ee][Gg][Oo][Ll][Ee]) (.*)$",
        -- setabout
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Mm][Pp][Oo][Ss][Tt][Aa] [Dd][Ee][Ss][Cc][Rr][Ii][Zz][Ii][Oo][Nn][Ee]) (.*)$",
        -- lock
        "^([Ss][Aa][Ss][Hh][Aa] [Bb][Ll][Oo][Cc][Cc][Aa]) (.*)$",
        "^([Bb][Ll][Oo][Cc][Cc][Aa]) (.*)$",
        -- unlock
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Bb][Ll][Oo][Cc][Cc][Aa]) (.*)$",
        "^([Ss][Bb][Ll][Oo][Cc][Cc][Aa]) (.*)$",
        -- modlist
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Ss][Tt][Aa] [Mm][Oo][Dd])$",
        "^([Ll][Ii][Ss][Tt][Aa] [Mm][Oo][Dd])$",
        -- link
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Nn][Kk])$",
        -- setlink
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Mm][Pp][Oo][Ss][Tt][Aa] [Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Mm][Pp][Oo][Ss][Tt][Aa] [Ll][Ii][Nn][Kk]) ([Hh][Tt][Tt][Pp][Ss]://[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/%S+)$",
        -- unsetlink
        "^([Ss][Aa][Ss][Hh][Aa] [Ee][Ll][Ii][Mm][Ii][Nn][Aa] [Ll][Ii][Nn][Kk])$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "(#rules|sasha regole)",
        "(#about|sasha descrizione)",
        "(#modlist|[sasha] lista mod)",
        "#owner",
        "#admins [<reply>|<text>]",
        "MOD",
        "#type",
        "(#setrules|sasha imposta regole) <text>",
        "(#setabout|sasha imposta descrizione) <text>",
        "#settings",
        "(#link|sasha link)",
        "#setflood <value>",
        "GROUPS",
        "(#lock|[sasha] blocca) name|member|photo|flood|arabic|bots|leave|links|rtl|sticker|contacts",
        "(#unlock|[sasha] sblocca) name|member|photo|flood|arabic|bots|leave|links|rtl|sticker|contacts",
        "SUPERGROUPS",
        "(#lock|[sasha] blocca) links|spam|flood|arabic|member|rtl|tgservice|sticker|contacts|strict",
        "(#unlock|[sasha] sblocca) links|spam|flood|arabic|member|rtl|tgservice|sticker|contacts|strict",
        "OWNER",
        "#log",
        "(#setlink|sasha imposta link) <link>",
        "(#unsetlink|sasha elimina link)",
        "(#promote|[sasha] promuovi) <username>|<reply>",
        "(#demote|[sasha] degrada) <username>|<reply>",
        "#setowner <id>|<username>|<reply>",
        "#clean modlist|rules|about",
        "SUPERGROUPS",
        "(#getadmins|[sasha] lista admin)",
        "ADMIN",
        "#add",
        "#rem",
        "ex INGROUP.LUA",
        "#add realm",
        "#rem realm",
        "ex INPM.LUA",
        "#allchats",
        "#allchatlist",
        "SUPERGROUPS",
        "REALMS",
        "#setgpowner <group_id> <user_id>",
        "(#setabout|sasha imposta descrizione) <group_id> <text>",
        "(#setrules|sasha imposta regole) <group_id> <text>",
        "(#lock|[sasha] blocca) <group_id> name|member|photo|flood|arabic|links|spam|rtl|sticker",
        "(#unlock|[sasha] sblocca) <group_id> name|member|photo|flood|arabic|links|spam|rtl|sticker",
        "#settings <group_id>",
        "#type",
        "#rem <group_id>",
        "#list admins|groups|realms",
        "SUDO",
        "#addadmin <user_id>|<username>",
        "#removeadmin <user_id>|<username>",
    },
}