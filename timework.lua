-- CALL IT LIKE THIS: io.popen('lua timework.lua "ACTION" "SLEEP_TIME" "OTHER" "PARAMETERS"')
loadfile("./introtimework.lua")()
local action, sleep_time = ...
if sleep_time then
    if tonumber(sleep_time) then
        if tonumber(sleep_time) > 0 then
            os.execute('sleep ' .. sleep_time)
        end
    end
end
if action == 'backup' then
    print('TIMEWORK BACKUP')
    -- deletes all previous backups (they're in telegram so no problem)
    print("Deleting old backups")
    io.popen('sudo rm -f /home/pi/BACKUPS/*'):read("*all")
    sendMessage_SUDOERS(langs['en'].autoSendBackupDb, 'markdown')
    -- send the backups
    doSendBackup()
    -- deletes all files in log folder
    io.popen('rm -f /home/pi/AISasha/groups/logs/*'):read("*all")
    io.popen('rm -f /home/pi/AISashaAPI/groups/logs/*'):read("*all")
elseif action == 'update' then
    print('TIMEWORK UPDATE')
    action, sleep_time, chat_id = ...
    sendMessage(chat_id, io.popen('git pull'):read('*all'))
elseif action == 'sendmessage' then
    print('TIMEWORK SENDMESSAGE')
    action, sleep_time, chat_id, parse_mode, text = ...
    text = text:gsub('\\"', '"')
    sendMessage(chat_id, text, parse_mode)
elseif action == 'forwardmessage' then
    print('TIMEWORK FORWARDMESSAGE')
    action, sleep_time, chat_id, message_id = ...
    forwardMessage(chat_id, chat_id, message_id)
elseif action == 'deletemessage' then
    print('TIMEWORK DELETEMESSAGE')
    action, sleep_time, chat_id, message_ids = ...
    local t = message_ids:split(',')
    for k, v in pairs(t) do
        if v then
            if v ~= '' then
                if not deleteMessage(chat_id, v, true) then
                    -- sendMessage(chat_id, langs[get_lang(chat_id)].cantDeleteMessage, false, v)
                end
            end
        end
    end
elseif action == 'restrictuser' then
    print('TIMEWORK RESTRICTUSER')
    action, sleep_time, chat_id, user_id, time = ...
    if time then
        restrictChatMember(chat_id, user_id, default_restrictions, time)
    else
        restrictChatMember(chat_id, user_id, default_restrictions)
    end
elseif action == 'kickuser' then
    print('TIMEWORK KICKUSER')
    action, sleep_time, chat_id, user_id = ...
    kickChatMember(user_id, chat_id, 45)
elseif action == 'banuser' then
    print('TIMEWORK BANUSER')
    action, sleep_time, chat_id, user_id, time = ...
    if time then
        kickChatMember(user_id, chat_id, time)
    else
        kickChatMember(user_id, chat_id)
    end
elseif action == 'fileconversion' then
    print('TIMEWORK FILECONVERSION')
    action, sleep_time, chat_id, file_id, file_path, from_type, to_type, text = ...
    local data = load_data(config.moderation.data)
    file_path = file_path:gsub('\\"', '"')
    text = text:gsub('\\"', '"')
    local res = getFile(file_id)
    if res then
        -- sync
        os.execute('python3 pyrogramFiles.py DOWNLOAD ' .. chat_id .. ' ' .. file_id .. ' "' .. file_path .. '" "' .. text .. '"')
        -- async
        pyrogramUpload(chat_id, to_type, file_path, nil, langs[get_lang(chat_id)].downloadAndRename)
        return
    end
elseif action == 'contactadmins' then
    print('TIMEWORK CONTACT ADMINS')
    action, sleep_time, chat_id, shitstorm, hashtag, text = ...
    local data = load_data(config.moderation.data)

    local already_contacted = { }
    already_contacted[tostring(bot.id)] = bot.id
    already_contacted[tostring(bot.userVersion.id)] = bot.userVersion.id
    local cant_contact = ''
    local shitstormFlag = false
    local fwd_msg = nil
    if tostring(shitstorm) == 'true' then
        shitstormFlag = true
    elseif tostring(shitstorm) ~= 'false' then
        fwd_msg = shitstorm
    end
    sendMessage(chat_id, hashtag)
    if shitstormFlag then
        for k, v in pairs(config.sudo_users) do
            if not already_contacted[tostring(v.id)] then
                already_contacted[tostring(v.id)] = v.id
                if sendChatAction(v.id, 'typing', true) then
                    sendMessage(v.id, text, 'html')
                    os.execute('sleep 0.4')
                else
                    cant_contact = cant_contact .. v.id .. ' ' ..(v.username or('NOUSER ' .. v.first_name .. ' ' ..(v.last_name or ''))) .. '\n'
                end
            end
        end
    end
    local list = getChatAdministrators(chat_id)
    if list then
        for i, admin in pairs(list.result) do
            if not already_contacted[tostring(admin.user.id)] then
                already_contacted[tostring(admin.user.id)] = admin.user.id
                if sendChatAction(admin.user.id, 'typing', true) then
                    if not shitstormFlag and fwd_msg then
                        -- @admins command
                        forwardMessage(admin.user.id, chat_id, fwd_msg)
                    end
                    sendMessage(admin.user.id, text, 'html')
                    os.execute('sleep 0.4')
                else
                    cant_contact = cant_contact .. admin.user.id .. ' ' ..(admin.user.username or('NOUSER ' .. admin.user.first_name .. ' ' ..(admin.user.last_name or ''))) .. '\n'
                end
            end
        end
    end
    -- owner
    local owner = data[tostring(chat_id)].owner
    if owner then
        if not already_contacted[tostring(owner)] then
            already_contacted[tostring(owner)] = owner
            if sendChatAction(owner, 'typing', true) then
                if not shitstormFlag and fwd_msg then
                    -- @admins command
                    forwardMessage(owner, chat_id, fwd_msg)
                end
                sendMessage(owner, text, 'html')
                os.execute('sleep 0.4')
            else
                cant_contact = cant_contact .. owner .. '\n'
            end
        end
    end
    -- determine if table is empty
    if next(data[tostring(chat_id)].moderators) ~= nil then
        for k, v in pairs(data[tostring(chat_id)].moderators) do
            if not already_contacted[tostring(k)] then
                already_contacted[tostring(k)] = k
                if sendChatAction(k, 'typing', true) then
                    if not shitstormFlag and fwd_msg then
                        -- @admins command
                        forwardMessage(k, chat_id, fwd_msg)
                    end
                    sendMessage(k, text, 'html')
                    os.execute('sleep 0.4')
                else
                    cant_contact = cant_contact .. k .. ' ' ..(v or '') .. '\n'
                end
            end
        end
    end
    if cant_contact ~= '' then
        sendMessage(chat_id, langs[get_lang(chat_id)].cantContact .. cant_contact)
    end
end