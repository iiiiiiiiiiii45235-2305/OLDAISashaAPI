local function run(msg, matches)
    if is_admin(msg) then
        if matches[1] == 'botrestart' then
            mystat('/restart')
            redis:bgsave()
            bot_init(true)
            return sendReply(msg, langs[msg.lang].botRestarted)
        end
        if matches[1] == 'botstop' then
            mystat('/stop')
            redis:bgsave()
            is_started = false
            return sendReply(msg, langs[msg.lang].botStopped)
        end
        if matches[1] == 'redissave' then
            mystat('/save')
            redis:bgsave()
            return sendMessage(msg.chat.id, langs[msg.lang].redisDbSaved)
        end
        if matches[1] == 'commandsstats' then
            mystat('/commands')
            local text = langs[msg.lang].botStats
            local hash = 'commands:stats'
            local names = db:hkeys(hash)
            local num = db:hvals(hash)
            for i = 1, #names do
                text = text .. '- ' .. names[i] .. ': ' .. num[i] .. '\n'
            end
            return sendMessage(msg.chat.id, text)
        end
        --[[
        if matches[1] == 'log' then
            mystat('/log')
            if matches[2] then
                if matches[2] ~= 'del' then
                    local reply = 'I\' sent it in private'
                    if matches[2] == 'msg' then
                        api.sendDocument(msg.chat.id, './logs/msgs_errors.txt')
                    elseif matches[2] == 'dbswitch' then
                        api.sendDocument(msg.chat.id, './logs/dbswitch.txt')
                    elseif matches[2] == 'errors' then
                        api.sendDocument(msg.chat.id, './logs/errors.txt')
                    elseif matches[2] == 'starts' then
                        api.sendDocument(msg.chat.id, './logs/starts.txt')
                    elseif matches[2] == 'additions' then
                        api.sendDocument(msg.chat.id, './logs/additions.txt')
                    elseif matches[2] == 'usernames' then
                        api.sendDocument(msg.chat.id, './logs/usernames.txt')
                    else
                        reply = 'Invalid parameter: ' .. matches[2]
                    end
                    if reply:match('^Invalid parameter: .*') then
                        api.sendMessage(msg.chat.id, reply)
                    end
                else
                    if matches[3] then
                        local reply = 'Log deleted'
                        local cmd
                        if matches[3] == 'msg' then
                            cmd = io.popen('sudo rm -rf logs/msgs_errors.txt')
                        elseif matches[3] == 'dbswitch' then
                            cmd = io.popen('sudo rm -rf logs/dbswitch.txt')
                        elseif matches[3] == 'errors' then
                            cmd = io.popen('sudo rm -rf logs/errors.txt')
                        elseif matches[3] == 'starts' then
                            cmd = io.popen('sudo rm -rf logs/starts.txt')
                        elseif matches[3] == 'starts' then
                            cmd = io.popen('sudo rm -rf logs/additions.txt')
                        elseif matches[3] == 'usernames' then
                            cmd = io.popen('sudo rm -rf logs/usernames.txt')
                        else
                            reply = 'Invalid parameter: ' .. matches[3]
                        end
                        if msg.chat.type ~= 'private' then
                            if not string.match(reply, '^Invalid parameter: .*') then
                                cmd:read('*all')
                                cmd:close()
                                api.sendReply(msg, reply)
                            else
                                api.sendReply(msg, reply)
                            end
                        else
                            if string.match(reply, '^Invalid parameter: .*') then
                                api.sendMessage(msg.chat.id, reply)
                            else
                                cmd:read('*all')
                                cmd:close()
                                api.sendMessage(msg.chat.id, reply)
                            end
                        end
                    else
                        local cmd = io.popen('sudo rm -rf logs')
                        cmd:read('*all')
                        cmd:close()
                        if msg.chat.type == 'private' then
                            api.sendMessage(msg.chat.id, 'Logs folder deleted', true)
                        else
                            api.sendReply(msg, 'Logs folder deleted', true)
                        end
                    end
                end
            else
                local reply = '*Available logs*:\n\n`msg`: errors during the delivery of messages\n`errors`: errors during the execution\n`starts`: when the bot have been started\n`usernames`: all the usernames seen by the bot\n`additions`: when the bot have been added to a group\n\nUsage:\n`/log [argument]`\n`/log del [argument]`\n`/log del` (whole folder)'
                if msg.chat.type == 'private' then
                    api.sendMessage(msg.chat.id, reply, true)
                else
                    api.sendReply(msg, reply, true)
                end
            end
        end
        if matches[1] == 'redis backup' then
            local groups = db:smembers('bot:groupsid')
            printvardump(groups)
            div()
            local all_groups = { }
            for k, v in pairs(groups) do
                local current = { }
                current = group_table(v)
                printvardump(current)
                div()
                table.insert(all_groups, current)
            end
            div()
            printvardump(all_groups)
            save_data("./logs/redisbackup.json", all_groups)
            if not(msg.chat.type == 'private') then
                api.sendMessage(msg.chat.id, 'I\'ve sent you the .json file in private')
            end
            api.sendDocument(config.admin, "./logs/redisbackup.json")
        end
        if matches[1] == 'usernames' then
            local usernames = db:hkeys('bot:usernames')
            local file = io.open("./logs/usernames.txt", "w")
            file:write(vtext(usernames):gsub('"', ''))
            file:close()
            api.sendDocument(msg.from.id, './logs/usernames.txt')
            api.sendMessage(msg.chat.id, 'Instruction processed. Total number of usernames: ' .. #usernames)
            mystat('/usernames')
        end
        if matches[1] == 'api errors' then
            local errors = db:hkeys('bot:errors')
            local times = db:hvals('bot:errors')
            local text = 'Api errors:\n'
            for i = 1, #errors do
                text = text .. errors[i] .. ': ' .. times[i] .. '\n'
            end
            mystat('/apierrors')
            api.sendMessage(msg.from.id, text)
        end
        ]]
        if matches[1]:lower() == "pm" or matches[1]:lower() == "sasha messaggia" then
            sendMessage(matches[2], matches[3])
            mystat('/pm')
            return langs[msg.lang].pmSent
        end
        if matches[1]:lower() == "pmblock" or matches[1]:lower() == "sasha blocca" then
            mystat('/pmblock')
            if msg.reply then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                return blockUser(msg.reply_to_message.forward_from.id, msg.lang)
                            else
                                -- return error cant block chat
                            end
                        else
                            -- return error no forward
                        end
                    else
                        return blockUser(msg.reply_to_message.from.id, msg.lang)
                    end
                else
                    return blockUser(msg.reply_to_message.from.id, msg.lang)
                end
            elseif string.match(matches[2], '^%d+$') then
                return blockUser(matches[2], msg.lang)
            else
                -- not sure if it works
                local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                if obj_user then
                    if obj_user.type == 'private' then
                        return blockUser(obj_user.id, msg.lang)
                    end
                end
            end
            return
        end
        if matches[1]:lower() == "pmunblock" or matches[1]:lower() == "sasha sblocca" then
            mystat('/pmunblock')
            if msg.reply then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                return unblockUser(msg.reply_to_message.forward_from.id, msg.lang)
                            else
                                -- return error cant unblock chat
                            end
                        else
                            -- return error no forward
                        end
                    else
                        return unblockUser(msg.reply_to_message.from.id, msg.lang)
                    end
                else
                    return unblockUser(msg.reply_to_message.from.id, msg.lang)
                end
            elseif string.match(matches[2], '^%d+$') then
                return unblockUser(matches[2], msg.lang)
            else
                -- not sure if it works
                local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                if obj_user then
                    if obj_user.type == 'private' then
                        return unblockUser(obj_user.id, msg.lang)
                    end
                end
            end
            return
        end
        if matches[1]:lower() == 'vardump' then
            mystat('/vardump')
            return sendMessage(msg.chat.id, 'VARDUMP (<msg>)\n' .. serpent.block(msg, { sortkeys = false, comment = false }))
        end
        if matches[1]:lower() == 'checkspeed' then
            mystat('/checkspeed')
            return os.date('%S', os.difftime(tonumber(os.time()), tonumber(msg.date)))
        end
        if is_sudo(msg) then
            if matches[1]:lower() == "sync_gbans" or matches[1]:lower() == "sasha sincronizza lista superban" then
                mystat('/sync_gbans')
                local url = "http://seedteam.org/Teleseed/Global_bans.json"
                local SEED_gbans = http.request(url)
                local jdat = json:decode(SEED_gbans)
                for k, v in pairs(jdat) do
                    redis:hset('user:' .. v, 'print_name', k)
                    gbanUser(v)
                    print(k, v .. " Globally banned")
                end
                return langs[msg.lang].gbansSync
            end
            if matches[1]:lower() == "backup" or matches[1]:lower() == "sasha esegui backup" then
                mystat('/backup')
                local time = os.time()
                local log = io.popen('cd "/home/pi/BACKUPS/" && tar -zcvf backupAISashaBot' .. time .. '.tar.gz /home/pi/AISashaAPI --exclude=/home/pi/AISashaAPI/.git'):read('*all')
                local file = io.open("/home/pi/BACKUPS/backupLog" .. time .. ".txt", "w")
                file:write(log)
                file:flush()
                file:close()
                sendDocument_SUDOERS("/home/pi/BACKUPS/backupLog" .. time .. ".txt")
                return langs[msg.lang].backupDone
            end
            if matches[1]:lower() == "uploadbackup" or matches[1]:lower() == "sasha invia backup" then
                mystat('/uploadbackup')
                local files = io.popen('ls "/home/pi/BACKUPS/"'):read("*all"):split('\n')
                if files then
                    local backups = { }
                    for k, v in pairsByKeys(files) do
                        if string.match(v, '^backupAISashaBot%d+%.tar%.gz$') then
                            backups[string.match(v, '%d+')] = v
                        end
                    end
                    if backups then
                        local last_backup = ''
                        for k, v in pairsByKeys(backups) do
                            last_backup = v
                        end
                        sendDocument_SUDOERS('/home/pi/BACKUPS/' .. last_backup)
                        return langs[msg.lang].backupSent
                    else
                        return langs[msg.lang].backupMissing
                    end
                else
                    return langs[msg.lang].backupMissing
                end
            end
        else
            return langs[msg.lang].require_sudo
        end
    else
        return langs[msg.lang].require_admin
    end
end

local function cron()
    -- send database and last backup
    -- save database
    save_data(config.database.db, database)

    -- do backup
    local time = os.time()
    local log = io.popen('cd "/home/pi/BACKUPS/" && tar -zcvf backupAISashaBot' .. time .. '.tar.gz /home/pi/AISashaAPI --exclude=/home/pi/AISashaAPI/.git'):read('*all')
    local file = io.open("/home/pi/BACKUPS/backupLog" .. time .. ".txt", "w")
    file:write(log)
    file:flush()
    file:close()
    sendMessage_SUDOERS(langs[msg.lang].autoSendBackupDb)

    -- send database
    if io.popen('find /home/pi/AISashaAPI/data/database.json'):read("*all") ~= '' then
        sendDocument_SUDOERS('/home/pi/AISashaAPI/data/database.json')
    end

    -- send last backup
    local files = io.popen('ls "/home/pi/BACKUPS/"'):read("*all"):split('\n')
    local backups = { }
    if files then
        for k, v in pairsByKeys(files) do
            if string.match(v, '^backupAISashaBot%d+%.tar%.gz$') then
                backups[string.match(v, '%d+')] = v
            end
        end
        local last_backup = ''
        for k, v in pairsByKeys(backups) do
            last_backup = v
        end
        sendDocument_SUDOERS('/home/pi/BACKUPS/' .. last_backup)
    end
end

return {
    description = "ADMINISTRATOR",
    patterns =
    {
        "^[#!/]([Pp][Mm]) (%d+) (.*)$",
        "^[#!/]([Pp][Mm][Uu][Nn][Bb][Ll][Oo][Cc][Kk])$",
        "^[#!/]([Pp][Mm][Bb][Ll][Oo][Cc][Kk]) (.*)$",
        "^[#!/]([Pp][Mm][Uu][Nn][Bb][Ll][Oo][Cc][Kk])$",
        "^[#!/]([Pp][Mm][Bb][Ll][Oo][Cc][Kk]) (.*)$",
        "^[#!/]([Ss][Yy][Nn][Cc]_[Gg][Bb][Aa][Nn][Ss])$",
        -- sync your global bans with seed
        "^[#!/]([Bb][Aa][Cc][Kk][Uu][Pp])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd][Bb][Aa][Cc][Kk][Uu][Pp])$",
        "^[#!/]([Uu][Pp][Dd][Aa][Tt][Ee][Ii][Dd])$",
        "^[#!/]([Vv][Aa][Rr][Dd][Uu][Mm][Pp])$",
        "^[#!/]([Bb][Oo][Tt][Ss][Tt][Oo][Pp])$",
        "^[#!/]([Bb][Oo][Tt][Rr][Ee][Ss][Tt][Aa][Rr][Tt])$",
        "^[#!/]([Rr][Ee][Dd][Ii][Ss][Ss][Aa][Vv][Ee])$",
        "^[#!/]([Cc][Oo][Mm][Mm][Aa][Nn][Dd][Ss][Ss][Tt][Aa][Tt][Ss])$",
        -- pm
        "^([Ss][Aa][Ss][Hh][Aa] [Mm][Ee][Ss][Ss][Aa][Gg][Gg][Ii][Aa]) (%d+) (.*)$",
        -- pmunblock
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Bb][Ll][Oo][Cc][Cc][Aa])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Bb][Ll][Oo][Cc][Cc][Aa]) (.*)$",
        -- pmblock
        "^([Ss][Aa][Ss][Hh][Aa] [Bb][Ll][Oo][Cc][Cc][Aa])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Bb][Ll][Oo][Cc][Cc][Aa]) (.*)$",
        -- sync_gbans
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Ii][Nn][Cc][Rr][Oo][Nn][Ii][Zz][Zz][Aa] [Ss][Uu][Pp][Ee][Rr][Bb][Aa][Nn])$",
        -- backup
        "^([Ss][Aa][Ss][Hh][Aa] [Ee][Ss][Ee][Gg][Uu][Ii] [Bb][Aa][Cc][Kk][Uu][Pp])$",
        -- uploadbackup
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Nn][Vv][Ii][Aa] [Bb][Aa][Cc][Kk][Uu][Pp])$",
    },
    -- cron = cron,
    run = run,
    min_rank = 3,
    syntax =
    {
        "ADMIN",
        "(#pm|sasha messaggia) <user_id> <msg>",
        "(#block|sasha blocca) <user_id>",
        "(#unblock|sasha sblocca) <user_id>",
        "#checkspeed",
        "#vardump [<reply>]",
        "#commandsstats",
        "SUDO",
        "#botstop",
        "#botrestart",
        "#redissave",
        "(#sync_gbans|sasha sincronizza superban)",
        "(#backup|sasha esegui backup)",
        "(#uploadbackup|sasha invia backup)",
    },
}
-- By @imandaneshi :)
-- https://github.com/SEEDTEAM/TeleSeed/blob/test/plugins/admin.lua
-- Modified by @Rondoozle for supergroups
-- Modified by @EricSolinas for API