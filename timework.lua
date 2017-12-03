loadfile("./introtimework.lua")()
local action, chat_id, sleep_time = ...
if sleep_time then
    if tonumber(sleep_time) then
        if tonumber(sleep_time) > 0 then
            os.execute('sleep ' .. sleep_time)
        end
    end
end
if action == 'sendmessage' then
    action, chat_id, sleep_time, text = ...
    text = text:gsub('\\"', '"')
    sendMessage(chat_id, text)
elseif action == 'forwardmessage' then
    action, chat_id, sleep_time, message_id = ...
    forwardMessage(chat_id, chat_id, message_id)
elseif action == 'deletemessage' then
    action, chat_id, sleep_time, message_id = ...
    if not deleteMessage(chat_id, message_id, true) then
        sendMessage(chat_id, langs[get_lang(chat_id)].cantDeleteMessage, false, message_id)
    end
elseif action == 'cronbackup' then
    -- deletes all previous backups (they're in telegram so no problem)
    io.popen('sudo rm -f /home/pi/BACKUPS/*'):read("*all")

    sendMessage_SUDOERS(langs['en'].autoSendBackupDb, 'markdown')
    -- AISASHAAPI
    -- send database
    if io.popen('find /home/pi/AISashaAPI/data/database.json'):read("*all") ~= '' then
        sendDocument_SUDOERS('/home/pi/AISashaAPI/data/database.json')
    end
    -- AISASHA
    -- send database
    if io.popen('find /home/pi/AISasha/data/database.json'):read("*all") ~= '' then
        sendDocument_SUDOERS('/home/pi/AISasha/data/database.json')
    end
    -- send the whole backup
    doSendBackup()
    -- deletes all files in log folder
    io.popen('rm -f /home/pi/AISasha/groups/logs/*'):read("*all")
    io.popen('rm -f /home/pi/AISashaAPI/groups/logs/*'):read("*all")
end