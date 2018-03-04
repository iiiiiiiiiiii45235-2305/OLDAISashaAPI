local default_group_data = {
    goodbye = false,
    welcome = false,
    welcomemembers = 0,
    lang = 'en',
    link = false,
    name = 'TITLE',
    owner = '41400331',
    photo = false,
    rules = false,
    type = false,
    moderators =
    {
        -- user_id = username or printname
        -- #todo
        -- user_id = {
        -- username or printname
        -- various permissions
        -- }
    },
    settings =
    {
        lock_grouplink = true,
        lock_groupname = false,
        lock_groupphoto = false,
        groupnotices = true,
        pmnotices = false,
        tagalert = false,
        -- punishments
        -- 0/false = allowed
        -- 1 = delete
        -- 2 = warn
        -- 3 = temprestrict
        -- 4 = restrict
        -- 5 = kick
        -- 6 = tempban
        -- 7 = ban
        -- 24h default
        time_ban = 86400,
        time_restrict = 86400,
        -- locks
        locks =
        {
            -- lock = punishment
            arabic = false,
            bots = 3,
            delword = 1,
            flood = 4,
            forward = false,
            gbanned = 4,
            leave = false,
            links = 2,
            members = false,
            rtl = false,
            spam = false,
            username = false,
        },
        max_flood = 5,
        max_warns = 3,
        -- mutes
        mutes =
        {
            -- mute = punishment
            all = false,
            audios = false,
            contacts = false,
            documents = false,
            games = false,
            gifs = false,
            locations = false,
            photos = false,
            stickers = false,
            text = false,
            tgservices = false,
            videos = false,
            video_notes = false,
            voice_notes = false,
        },
        strict = false,
        warns_punishment = 7,
    },
    whitelist =
    {
        gbanned =
        {
            -- user_id
        },
        links =
        {
            -- links, usernames, channel ids
            "@username",
        },
        users =
        {
            -- user_id
        },
    },
}

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
                    data[tostring(msg.chat.id)] = clone_table(default_group_data)
                    data[tostring(msg.chat.id)].type = 'Group'
                    data[tostring(msg.chat.id)].name = string.gsub(msg.chat.print_name, '_', ' ')
                    data[tostring(msg.chat.id)].owner = tostring(admin.user.id)
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
                    data[tostring(msg.chat.id)] = clone_table(default_group_data)
                    data[tostring(msg.chat.id)].type = 'Realm'
                    data[tostring(msg.chat.id)].name = string.gsub(msg.chat.print_name, '_', ' ')
                    data[tostring(msg.chat.id)].owner = tostring(admin.user.id)
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
                    data[tostring(msg.chat.id)] = clone_table(default_group_data)
                    data[tostring(msg.chat.id)].type = 'SuperGroup'
                    data[tostring(msg.chat.id)].name = string.gsub(msg.chat.print_name, '_', ' ')
                    data[tostring(msg.chat.id)].owner = tostring(admin.user.id)
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

local function groupsList(msg, get_links)
    local message = langs[msg.lang].groupListStart
    for k, v in pairsByGroupName(data) do
        if data[tostring(k)] then
            if data[tostring(k)].settings then
                local name = ''
                local grp = data[tostring(k)]
                for m, n in pairs(grp) do
                    if m == 'name' then
                        name = n
                    end
                end
                local group_owner = "No owner"
                if data[tostring(k)].owner then
                    group_owner = tostring(data[tostring(k)].owner)
                end
                local group_link = nil
                if data[tostring(k)].link then
                    group_link = data[tostring(k)].link
                elseif get_links and data[tostring(k)].type:lower() == 'supergroup' then
                    local link = exportChatInviteLink(k, true)
                    if link then
                        data[tostring(k)].link = link
                        save_data(config.moderation.data, data)
                        group_link = link
                    end
                end
                if group_link then
                    message = message .. '<a href="' .. group_link .. '">' .. html_escape(name) .. '</a>' .. ' ' .. k .. ' ' .. group_owner .. '\n'
                else
                    message = message .. html_escape(name) .. ' ' .. k .. ' ' .. group_owner .. '\n'
                end
            end
        end
    end
    local file_groups = io.open("./groups/lists/groups.txt", "w")
    file_groups:write(message)
    file_groups:flush()
    file_groups:close()
    return message
end

local max_groups = 10
local function groupsPages(page)
    local message = ""
    if not page then
        page = 1
    end
    page = tonumber(page)
    local tot_groups = 0
    for k, v in pairsByGroupName(data) do
        if data[tostring(k)] then
            if data[tostring(k)].settings then
                tot_groups = tot_groups + 1
            end
        end
    end
    local max_pages = math.floor(tot_groups / max_groups)
    if (tot_groups / max_groups) > math.floor(tot_groups / max_groups) then
        max_pages = max_pages + 1
    end
    if page > max_pages then
        page = max_pages
    end
    tot_groups = 0
    for k, v in pairsByGroupName(data) do
        if data[tostring(k)] then
            if data[tostring(k)].settings then
                tot_groups = tot_groups + 1
                if tot_groups >=(((page - 1) * max_groups) + 1) and tot_groups <=(max_groups * page) then
                    local name = ''
                    local grp = data[tostring(k)]
                    for m, n in pairs(grp) do
                        if m == 'name' then
                            name = n
                        end
                    end
                    local group_owner = "No owner"
                    if data[tostring(k)].owner then
                        group_owner = tostring(data[tostring(k)].owner)
                    end
                    local group_link = nil
                    if data[tostring(k)].link then
                        group_link = data[tostring(k)].link
                    end
                    if group_link then
                        message = message .. '<a href="' .. group_link .. '">' .. html_escape(name) .. '</a>' .. ' ' .. k .. ' ' .. group_owner .. '\n'
                    else
                        message = message .. html_escape(name) .. ' ' .. k .. ' ' .. group_owner .. '\n'
                    end
                end
            end
        end
    end
    return message
end

local max_lines = 40
local function requestsPages(page)
    local message = ""
    if not page then
        page = 1
    end
    page = tonumber(page)
    local tot_lines = 0
    local f = assert(io.open("./groups/logs/requestslog.txt", "rb"))
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
                message = message .. v .. '\n'
            end
        end
    end
    return message
end

local function run(msg, matches)
    if is_admin(msg) then
        if msg.cb then
            if matches[2] == 'REQUESTSDELETE' or matches[2] == 'GROUPSDELETE' then
                if not deleteMessage(msg.chat.id, msg.message_id, true) then
                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                end
            elseif matches[2] == 'REQUESTSPAGES' or matches[2] == 'GROUPSPAGES' then
                answerCallbackQuery(msg.cb_id, langs[msg.lang].uselessButton, false)
            elseif matches[2] == 'REQUESTSBACK' then
                answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                editMessage(msg.chat.id, msg.message_id, requestsPages(matches[3] or 1), keyboard_requests_pages(matches[3]))
            elseif matches[2]:gsub('%d', '') == 'REQUESTSPAGEMINUS' then
                answerCallbackQuery(msg.cb_id, langs[msg.lang].turningPage)
                editMessage(msg.chat.id, msg.message_id, requestsPages(tonumber(matches[3] or(tonumber(matches[2]:match('%d')) + 1)) - tonumber(matches[2]:match('%d'))), keyboard_requests_pages(tonumber(matches[3] or(tonumber(matches[2]:match('%d')) + 1)) - tonumber(matches[2]:match('%d'))))
            elseif matches[2]:gsub('%d', '') == 'REQUESTSPAGEPLUS' then
                answerCallbackQuery(msg.cb_id, langs[msg.lang].turningPage)
                editMessage(msg.chat.id, msg.message_id, requestsPages(tonumber(matches[3] or(tonumber(matches[2]:match('%d')) -1)) + tonumber(matches[2]:match('%d'))), keyboard_requests_pages(tonumber(matches[3] or(tonumber(matches[2]:match('%d')) -1)) + tonumber(matches[2]:match('%d'))))
            elseif matches[2] == 'GROUPSBACK' then
                answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                editMessage(msg.chat.id, msg.message_id, groupsPages(matches[3] or 1), keyboard_list_groups_pages(msg.chat.id, matches[3] or 1), 'html')
            elseif matches[2]:gsub('%d', '') == 'GROUPSPAGEMINUS' then
                answerCallbackQuery(msg.cb_id, langs[msg.lang].turningPage)
                editMessage(msg.chat.id, msg.message_id, groupsPages(tonumber(matches[3] or(tonumber(matches[2]:match('%d')) + 1)) - tonumber(matches[2]:match('%d'))), keyboard_list_groups_pages(msg.chat.id, tonumber(matches[3] or(tonumber(matches[2]:match('%d')) + 1)) - tonumber(matches[2]:match('%d'))), 'html')
            elseif matches[2]:gsub('%d', '') == 'GROUPSPAGEPLUS' then
                answerCallbackQuery(msg.cb_id, langs[msg.lang].turningPage)
                editMessage(msg.chat.id, msg.message_id, groupsPages(tonumber(matches[3] or(tonumber(matches[2]:match('%d')) -1)) + tonumber(matches[2]:match('%d'))), keyboard_list_groups_pages(msg.chat.id, tonumber(matches[3] or(tonumber(matches[2]:match('%d')) -1)) + tonumber(matches[2]:match('%d'))), 'html')
            end
            return
        end

        if is_realm(msg) then
            if matches[1]:lower() == 'rem' and matches[2] then
                mystat('/rem <group_id>')
                -- Group configuration removal
                data[tostring(matches[2])] = nil
                if not data[tostring('groups')] then
                    data[tostring('groups')] = nil
                end
                data[tostring('groups')][tostring(matches[2])] = nil
                save_data(config.moderation.data, data)
                return langs[msg.lang].chat .. matches[2] .. langs[msg.lang].removed
            end
            if matches[1]:lower() == 'settimerestrict' and matches[2] and matches[3] then
                if matches[4] and matches[5] and matches[6] and matches[7] then
                    local unix = dateToUnix(matches[7], matches[6], matches[5], matches[4], matches[3])
                    if unix > 30 and unix < dateToUnix(0, 0, 0, 366, 0) then
                        data[tostring(matches[2])].settings['time_restrict'] = unix
                        save_data(config.moderation.data, data)
                        return langs[msg.lang].done
                    else
                        return langs[msg.lang].errorTimeRangePunishments
                    end
                else
                    if tonumber(matches[3]) > 30 and tonumber(matches[3]) < dateToUnix(0, 0, 0, 366, 0) then
                        data[tostring(matches[2])].settings['time_restrict'] = tonumber(matches[3])
                        save_data(config.moderation.data, data)
                        return langs[msg.lang].done
                    else
                        return langs[msg.lang].errorTimeRangePunishments
                    end
                end
            end
            if matches[1]:lower() == 'settimeban' and matches[2] and matches[3] then
                if matches[4] and matches[5] and matches[6] and matches[7] then
                    local unix = dateToUnix(matches[7], matches[6], matches[5], matches[4], matches[3])
                    if unix > 30 and unix < dateToUnix(0, 0, 0, 366, 0) then
                        data[tostring(matches[2])].settings['time_ban'] = unix
                        save_data(config.moderation.data, data)
                        return langs[msg.lang].done
                    else
                        return langs[msg.lang].errorTimeRangePunishments
                    end
                else
                    if tonumber(matches[3]) > 30 and tonumber(matches[3]) < dateToUnix(0, 0, 0, 366, 0) then
                        data[tostring(matches[2])].settings['time_ban'] = tonumber(matches[3])
                        save_data(config.moderation.data, data)
                        return langs[msg.lang].done
                    else
                        return langs[msg.lang].errorTimeRangePunishments
                    end
                end
            end
            if matches[1]:lower() == 'lock' and matches[2] and matches[3] and matches[4] then
                if groupDataDictionary[matches[3]:lower()] then
                    mystat('/lock <group_id> ' .. matches[3]:lower() .. ' ' .. matches[4]:lower())
                    return lockSetting(matches[2], matches[3]:lower(), matches[4]:lower())
                end
                return
            end
            if matches[1]:lower() == 'unlock' and matches[2] and matches[3] then
                if groupDataDictionary[matches[3]:lower()] then
                    mystat('/unlock <group_id> ' .. matches[3]:lower())
                    return unlockSetting(matches[2], matches[3]:lower())
                end
                return
            end
            if matches[1]:lower() == 'mute' and matches[2] and matches[3] and matches[4] then
                if groupDataDictionary[matches[3]:lower()] then
                    mystat('/mute <group_id> ' .. matches[3]:lower() .. ' ' .. matches[4]:lower())
                    return lockSetting(msg.chat.id, matches[3]:lower(), matches[4]:lower())
                end
                return
            end
            if matches[1]:lower() == 'unmute' and matches[2] and matches[3] then
                if groupDataDictionary[matches[3]:lower()] then
                    mystat('/unmute <group_id> ' .. matches[3]:lower())
                    return unlockSetting(msg.chat.id, matches[3]:lower())
                end
                return
            end
            if matches[1]:lower() == 'muteslist' and matches[2] then
                mystat('/muteslist <group_id>')
                local chat_name = ''
                if data[tostring(matches[2])] then
                    chat_name = data[tostring(matches[2])].name or ''
                end
                if sendKeyboard(msg.from.id, langs[msg.lang].mutesOf .. '(' .. matches[2] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[2], 2)) then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist " .. matches[2])
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendMutesPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
            end
            if matches[1]:lower() == 'textualmuteslist' and matches[2] then
                mystat('/muteslist <group_id>')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested SuperGroup muteslist " .. matches[2])
                return showSettings(matches[2], msg.lang)
            end
            if matches[1]:lower() == 'settings' and matches[2] then
                mystat('/settings <group_id>')
                local chat_name = ''
                if data[tostring(matches[2])] then
                    chat_name = data[tostring(matches[2])].name or ''
                end
                if sendKeyboard(msg.from.id, langs[msg.lang].settingsOf .. '(' .. matches[2] .. ') ' .. chat_name .. '\n' .. langs[msg.lang].settingsIntro, keyboard_settings_list(matches[2], 1)) then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group settings " .. matches[2])
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendSettingsPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
            end
            if matches[1]:lower() == 'textualsettings' and matches[2] then
                mystat('/settings <group_id>')
                return showSettings(matches[2], msg.lang)
            end
            if matches[1]:lower() == 'setgprules' and matches[2] and matches[3] then
                mystat('/setgprules <group_id>')
                data[tostring(matches[2])].rules = matches[3]
                save_data(config.moderation.data, data)
                return langs[msg.lang].newRules .. matches[3]
            end
            if matches[1]:lower() == 'setgpowner' and matches[2] and matches[3] then
                if data[tostring(matches[2])] then
                    mystat('/setgpowner <group_id> <user_id>')
                    data[tostring(matches[2])].owner = matches[3]
                    save_data(config.moderation.data, data)
                    sendMessage(matches[2], matches[3] .. langs[get_lang(matches[2])].setOwner)
                    if arePMNoticesEnabled(matches[3], matches[2]) then
                        sendMessage(matches[3], langs[get_lang(matches[3])].youHaveBeenDemotedMod .. database[tostring(matches[2])].print_name)
                    end
                    return matches[3] .. langs[msg.lang].setOwner
                end
            end
        end

        if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
            if matches[1]:lower() == 'add' and not matches[2] then
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
            end
            if matches[1]:lower() == 'rem' and not matches[2] then
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
            end
        end

        if matches[1]:lower() == 'type' then
            mystat('/type')
            return msg.chat.type or langs[msg.lang].chatTypeNotFound
        end
        if matches[1]:lower() == 'msgid' then
            mystat('/msgid')
            if msg.reply then
                return msg.reply_to_message.message_id
            else
                return msg.message_id
            end
        end
        if matches[1] == 'todo' then
            mystat('/todo <text>')
            if msg.reply then
                forwardLog(msg.chat.id, msg.reply_to_message.message_id)
                sendLog('#todo ' ..(matches[2] or ''), false, true)
            elseif matches[2] then
                sendLog('#todo ' .. matches[2], false, true)
            end
            if msg.chat.type ~= 'private' then
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
            end
            return
        end
        if matches[1] == 'commandsstats' then
            mystat('/commandsstats')
            local text = langs[msg.lang].botStats
            local hash = 'commands:stats'
            local names = redis:hkeys(hash)
            local num = redis:hvals(hash)
            for i = 1, #names do
                text = text .. '- ' .. names[i] .. ': ' .. num[i] .. '\n'
            end
            return text
        end
        if matches[1]:lower() == "ping" then
            mystat('/ping')
            return 'Pong'
        end
        if matches[1]:lower() == "laststart" then
            mystat('/laststart')
            return io.popen('speedtest'):read('*all')
        end
        if matches[1]:lower() == "pm" then
            mystat('/pm')
            sendMessage(matches[2], matches[3])
            return langs[msg.lang].pmSent
        end
        if matches[1]:lower() == "pmblock" then
            mystat('/block')
            if msg.reply then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                return blockUser(msg.reply_to_message.forward_from.id)
                            else
                                return langs[msg.lang].cantDoThisToChat
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    else
                        return blockUser(msg.reply_to_message.from.id)
                    end
                else
                    return blockUser(msg.reply_to_message.from.id)
                end
            elseif matches[2] and matches[2] ~= '' then
                if msg.entities then
                    for k, v in pairs(msg.entities) do
                        -- check if there's a text_mention
                        if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                            if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                return blockUser(msg.entities[k].user.id)
                            end
                        end
                    end
                end
                matches[2] = tostring(matches[2]):gsub(' ', '')
                if string.match(matches[2], '^%d+$') then
                    return blockUser(matches[2])
                else
                    local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            return blockUser(obj_user.id)
                        end
                    else
                        return langs[msg.lang].noObject
                    end
                end
            end
            return
        end
        if matches[1]:lower() == "pmunblock" then
            mystat('/unblock')
            if msg.reply then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                return unblockUser(msg.reply_to_message.forward_from.id)
                            else
                                return langs[msg.lang].cantDoThisToChat
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    else
                        return unblockUser(msg.reply_to_message.from.id)
                    end
                else
                    return unblockUser(msg.reply_to_message.from.id)
                end
            elseif matches[2] and matches[2] ~= '' then
                if msg.entities then
                    for k, v in pairs(msg.entities) do
                        -- check if there's a text_mention
                        if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                            if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                return unblockUser(msg.entities[k].user.id)
                            end
                        end
                    end
                end
                matches[2] = tostring(matches[2]):gsub(' ', '')
                if string.match(matches[2], '^%d+$') then
                    return unblockUser(matches[2])
                else
                    local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            return unblockUser(obj_user.id)
                        end
                    else
                        return langs[msg.lang].noObject
                    end
                end
            end
            return
        end
        if matches[1]:lower() == 'requestslog' then
            mystat('/requestslog')
            if sendKeyboard(msg.from.id, requestsPages(msg.chat.id), keyboard_requests_pages(msg.chat.id)) then
                savelog(msg.chat.id, "requestslog keyboard requested by admin")
                if msg.chat.type ~= 'private' then
                    local message_id = sendReply(msg, langs[msg.lang].sendLogPvt, 'html').result.message_id
                    io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. message_id .. '"')
                    return
                end
            else
                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
            end
        end
        if matches[1]:lower() == 'sendrequestslog' then
            mystat('/requestslog')
            return sendDocument(msg.chat.id, "./groups/logs/requestslog.txt")
        end
        if matches[1]:lower() == 'vardump' then
            mystat('/vardump')
            return 'VARDUMP (<msg>)\n' .. serpent.block(msg, { sortkeys = false, comment = false })
        end
        if matches[1]:lower() == 'checkspeed' then
            mystat('/checkspeed')
            return os.date('%S', os.difftime(tonumber(os.time()), tonumber(msg.date)))
        end
        if matches[1]:lower() == 'textuallist' then
            if matches[2]:lower() == 'groups' then
                mystat('/list groups')
                -- groupsList(msg)
                -- sendDocument(msg.from.id, "./groups/lists/groups.txt")
                if matches[2]:lower() == 'groups' then
                    sendReply(msg, groupsList(msg, false), 'html')
                elseif matches[2]:lower() == 'groups createlinks' then
                    sendReply(msg, groupsList(msg, true), 'html')
                end
            end
            return
        end
        if matches[1]:lower() == 'list' then
            if matches[2]:lower() == 'admins' then
                mystat('/list admins')
                return botAdminsList(msg.chat.id)
            elseif matches[2]:lower() == 'groups' then
                mystat('/list groups')
                if matches[2]:lower() == 'groups' then
                    if sendKeyboard(msg.from.id, groupsPages(1), keyboard_list_groups_pages(msg.chat.id, 1), 'html') then
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
            return
        end
        if matches[1]:lower() == 'leave' then
            mystat('/leave')
            if not matches[2] then
                sendMessage(msg.chat.id, langs[msg.lang].notMyGroup)
                return leaveChat(msg.chat.id)
            else
                sendMessage(matches[2], langs[msg.lang].notMyGroup)
                return leaveChat(matches[2])
            end
        end
        if is_sudo(msg) then
            -- Reload the entire bot!
            if matches[1]:lower() == 'reloadbot' then
                mystat('/reloadbot')
                reload_bot()
                return langs[msg.lang].botReloaded
            end
            if matches[1] == 'broadcast' then
                mystat('/broadcast')
                for k, v in pairs(data['groups']) do
                    sendMessage(v, matches[2])
                end
                return
            end
            if matches[1]:lower() == 'addadmin' then
                mystat('/addadmin')
                if msg.reply then
                    return promoteAdmin(msg.reply_to_message.from, msg.chat.id)
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return promoteAdmin(msg.entities[k].user, msg.chat.id)
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
            end
            if matches[1]:lower() == 'removeadmin' then
                mystat('/removeadmin')
                if msg.reply then
                    return demoteAdmin(msg.reply_to_message.from, msg.chat.id)
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return demoteAdmin(msg.entities[k].user, msg.chat.id)
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
            end
            if matches[1]:lower() == "rebootcli" then
                mystat('/rebootcli')
                io.popen('kill -9 $(pgrep telegram-cli)'):read('*all')
                return langs[msg.lang].cliReboot
            end
            if matches[1]:lower() == "reloaddata" then
                mystat('/reloaddata')
                data = load_data(config.moderation.data)
                return langs[msg.lang].dataReloaded
            end
            if matches[1]:lower() == "update" then
                mystat('/update')
                return io.popen('git pull'):read('*all')
            end
            if matches[1] == 'botrestart' then
                mystat('/botrestart')
                redis:bgsave()
                bot_init(true)
                return langs[msg.lang].botRestarted
            end
            if matches[1] == 'redissave' then
                mystat('/redissave')
                redis:bgsave()
                return langs[msg.lang].redisDbSaved
            end
            if matches[1]:lower() == "backup" then
                mystat('/backup')
                doSendBackup()
                return langs[msg.lang].backupDone
            end
            if matches[1]:lower() == 'getip' then
                return io.popen("wget -qO- http://ipecho.net/plain"):read('*all')
            end
            if matches[1]:lower() == 'add' and matches[2]:lower() == 'realm' then
                if is_group(msg) then
                    return langs[msg.lang].errorAlreadyGroup
                end
                mystat('/add realm')
                if msg.chat.type == 'group' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added realm [ " .. msg.chat.id .. " ]")
                    print("group " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") added as a realm")
                    return addRealm(msg)
                end
            end
            if matches[1]:lower() == 'rem' and matches[2]:lower() == 'realm' then
                if not is_realm(msg) then
                    return langs[msg.lang].errorNotRealm
                end
                mystat('/rem realm')
                savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] removed realm [ " .. msg.chat.id .. " ]")
                print("group " .. msg.chat.print_name .. "(" .. msg.chat.id .. ") removed as a realm")
                return remRealm(msg)
            end
        else
            return langs[msg.lang].require_sudo
        end
    else
        return langs[msg.lang].require_admin
    end
end

return {
    description = "ADMINISTRATOR",
    patterns =
    {
        "^(###cbadministrator)(REQUESTSDELETE)$",
        "^(###cbadministrator)(GROUPSDELETE)$",
        "^(###cbadministrator)(REQUESTSPAGES)$",
        "^(###cbadministrator)(GROUPSPAGES)$",
        "^(###cbadministrator)(REQUESTSBACK)(%d+)$",
        "^(###cbadministrator)(REQUESTSPAGE%dMINUS)(%d+)$",
        "^(###cbadministrator)(REQUESTSPAGE%dPLUS)(%d+)$",
        "^(###cbadministrator)(GROUPSBACK)(%d+)$",
        "^(###cbadministrator)(GROUPSPAGE%dMINUS)(%d+)$",
        "^(###cbadministrator)(GROUPSPAGE%dPLUS)(%d+)$",

        -- INREALM
        "^[#!/]([Rr][Ee][Mm]) (%-%d+)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Pp][Oo][Ww][Nn][Ee][Rr]) (%-%d+) (%d+)$",-- (group id) (owner id)
        "^[#!/]([Mm][Uu][Tt][Ee]) (%-%d+) ([^%s]+) ([^%s]+)",
        "^[#!/]([Uu][Nn][Mm][Uu][Tt][Ee]) (%-%d+) ([^%s]+)",
        "^[#!/]([Mm][Uu][Tt][Ee][Ss][Ll][Ii][Ss][Tt]) (%-%d+)",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Mm][Uu][Tt][Ee][Ss][Ll][Ii][Ss][Tt]) (%-%d+)$",
        "^[#!/]([Ll][Oo][Cc][Kk]) (%-%d+) ([^%s]+) ([^%s]+)$",
        "^[#!/]([Uu][Nn][Ll][Oo][Cc][Kk]) (%-%d+) ([^%s]+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss]) (%-%d+)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss]) (%-%d+)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Pp][Rr][Uu][Ll][Ee][Ss]) (%-%d+) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Mm][Ee][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) (%-%d+) (%d+) (%d+) (%d+) (%d+) (%d+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Mm][Ee][Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt]) (%-%d+) (%d+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Mm][Ee][Bb][Aa][Nn]) (%-%d+) (%d+) (%d+) (%d+) (%d+) (%d+)$",
        "^[#!/]([Ss][Ee][Tt][Tt][Ii][Mm][Ee][Bb][Aa][Nn]) (%-%d+) (%d+)$",

        -- INGROUP
        "^[#!/]([Aa][Dd][Dd]) ([Rr][Ee][Aa][Ll][Mm])$",
        "^[#!/]([Rr][Ee][Mm]) ([Rr][Ee][Aa][Ll][Mm])$",

        "^[#!/]([Aa][Dd][Dd])$",
        "^[#!/]([Rr][Ee][Mm])$",
        "^[#!/]([Tt][Oo][Dd][Oo])$",
        "^[#!/]([Tt][Oo][Dd][Oo]) (.*)$",
        "^[#!/]([Pp][Mm]) (%-?%d+) (.*)$",
        "^[#!/]([Pp][Mm][Uu][Nn][Bb][Ll][Oo][Cc][Kk])$",
        "^[#!/]([Pp][Mm][Bb][Ll][Oo][Cc][Kk])$",
        "^[#!/]([Pp][Mm][Uu][Nn][Bb][Ll][Oo][Cc][Kk]) ([^%s]+)$",
        "^[#!/]([Pp][Mm][Bb][Ll][Oo][Cc][Kk]) ([^%s]+)$",
        "^[#!/]([Aa][Dd][Dd][Aa][Dd][Mm][Ii][Nn]) ([^%s]+)$",
        "^[#!/]([Rr][Ee][Mm][Oo][Vv][Ee][Aa][Dd][Mm][Ii][Nn]) ([^%s]+)$",
        "^[#!/]([Ll][Ii][Ss][Tt]) (.*)$",
        "^[#!/]([Tt][Ee][Xx][Tt][Uu][Aa][Ll][Ll][Ii][Ss][Tt]) (.*)$",
        "^[#!/]([Bb][Aa][Cc][Kk][Uu][Pp])$",
        "^[#!/]([Uu][Pp][Dd][Aa][Tt][Ee])$",
        "^[#!/]([Rr][Ee][Qq][Uu][Ee][Ss][Tt][Ss][Ll][Oo][Gg])$",
        "^[#!/]([Ss][Ee][Nn][Dd][Rr][Ee][Qq][Uu][Ee][Ss][Tt][Ss][Ll][Oo][Gg])$",
        "^[#!/]([Vv][Aa][Rr][Dd][Uu][Mm][Pp])$",
        "^[#!/]([Rr][Ee][Ll][Oo][Aa][Dd][Bb][Oo][Tt])$",
        "^[#!/]([Bb][Oo][Tt][Rr][Ee][Ss][Tt][Aa][Rr][Tt])$",
        "^[#!/]([Rr][Ee][Dd][Ii][Ss][Ss][Aa][Vv][Ee])$",
        "^[#!/]([Cc][Oo][Mm][Mm][Aa][Nn][Dd][Ss][Ss][Tt][Aa][Tt][Ss])$",
        "^[#!/]([Cc][Hh][Ee][Cc][Kk][Ss][Pp][Ee][Ee][Dd])$",
        "^[#!/]([Rr][Ee][Bb][Oo][Oo][Tt][Cc][Ll][Ii])$",
        "^[#!/]([Pp][Ii][Nn][Gg])$",
        "^[#!/]([Ll][Aa][Ss][Tt][Ss][Tt][Aa][Rr][Tt])$",
        "^[#!/]([Rr][Ee][Ll][Oo][Aa][Dd][Dd][Aa][Tt][Aa])$",
        "^[#!/]([Bb][Rr][Oo][Aa][Dd][Cc][Aa][Ss][Tt]) +(.+)$",
        "^[#!/]([Ll][Ee][Aa][Vv][Ee]) (%-?%d+)$",
        "^[#!/]([Ll][Ee][Aa][Vv][Ee])$",
        "^[#!/]([Gg][Ee][Tt][Ii][Pp])$",
        "^[#!/]([Mm][Ss][Gg][Ii][Dd])$",
        "^[#!/]([Tt][Yy][Pp][Ee])$",
    },
    run = run,
    min_rank = 4,
    syntax =
    {
        "ADMIN",
        "/todo {reply} [{text}]",
        "/todo {text}",
        "/type",
        "/msgid",
        "/pm {id} {msg}",
        "/pmblock {user}",
        "/pmunblock {user}",
        "/list admins|(groups [createlinks])",
        "/checkspeed",
        "/requestslog",
        "/vardump [{reply}]",
        "/commandsstats",
        "/ping",
        "/laststart",
        "/leave [{group_id}]",
        "/add",
        "/rem",
        "REALM",
        "/setgpowner {group_id} {user_id}",
        "/setgprules {group_id} {text}",
        "/settimerestrict {group_id} {seconds}",
        "/settimeban {group_id} {seconds}",
        "/settimerestrict {group_id} {weeks} {days} {hours} {minutes} {seconds}",
        "/settimeban {group_id} {weeks} {days} {hours} {minutes} {seconds}",
        "/lock|/mute {group_id} all|arabic|audios|bots|contacts|delword|documents|flood|forward|games|gbanned|gifs|grouplink|groupname|groupnotices|groupphoto|leave|links|locations|members|photos|pmnotices|rtl|spam|stickers|strict|tagalert|text|tgservices|username|videos|video_notes|voice_notes|warns_punishment {punishment}",
        "/unlock|/unmute {group_id} all|arabic|audios|bots|contacts|delword|documents|flood|forward|games|gbanned|gifs|grouplink|groupname|groupnotices|groupphoto|leave|links|locations|members|photos|pmnotices|rtl|spam|stickers|strict|tagalert|text|tgservices|username|videos|video_notes|voice_notes|warns_punishment",
        "/muteslist {group_id}",
        "/textualmuteslist {group_id}",
        "/settings {group_id}",
        "/textualsettings {group_id}",
        "/rem {group_id}",
        "SUDO",
        "/addadmin {user_id}|{username}",
        "/removeadmin {user_id}|{username}",
        "/reloadbot",
        "/botrestart",
        "/redissave",
        "/update",
        "/backup",
        "/rebootcli",
        "/reloaddata",
        "/broadcast {text}",
        "/getip",
        "REALM",
        "/add realm",
        "/rem realm",
    },
}
-- By @imandaneshi :)
-- https://github.com/SEEDTEAM/TeleSeed/blob/test/plugins/admin.lua
-- Modified by @Rondoozle for supergroups
-- Modified by @EricSolinas for API