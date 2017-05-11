local function run(msg, matches)
    if is_admin(msg) then
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
        if matches[1]:lower() == "pm" or matches[1]:lower() == "sasha messaggia" then
            mystat('/pm')
            sendMessage(matches[2], matches[3])
            return langs[msg.lang].pmSent
        end
        if matches[1]:lower() == "ping" then
            mystat('/ping')
            return 'Pong'
        end
        if matches[1]:lower() == "laststart" then
            mystat('/laststart')
            return start_time
        end
        if matches[1]:lower() == "pmblock" or matches[1]:lower() == "sasha blocca pm" then
            mystat('/block')
            if msg.reply then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                return blockUser(msg.reply_to_message.forward_from.id, msg.lang)
                            else
                                return langs[msg.lang].cantDoThisToChat
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    else
                        return blockUser(msg.reply_to_message.from.id, msg.lang)
                    end
                else
                    return blockUser(msg.reply_to_message.from.id, msg.lang)
                end
            elseif matches[2] and matches[2] ~= '' then
                if string.match(matches[2], '^%d+$') then
                    return blockUser(matches[2], msg.lang)
                else
                    local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            return blockUser(obj_user.id, msg.lang)
                        end
                    else
                        return langs[msg.lang].noObject
                    end
                end
            end
            return
        end
        if matches[1]:lower() == "pmunblock" or matches[1]:lower() == "sasha sblocca pm" then
            mystat('/unblock')
            if msg.reply then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                return unblockUser(msg.reply_to_message.forward_from.id, msg.lang)
                            else
                                return langs[msg.lang].cantDoThisToChat
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    else
                        return unblockUser(msg.reply_to_message.from.id, msg.lang)
                    end
                else
                    return unblockUser(msg.reply_to_message.from.id, msg.lang)
                end
            elseif matches[2] and matches[2] ~= '' then
                if string.match(matches[2], '^%d+$') then
                    return unblockUser(matches[2], msg.lang)
                else
                    local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            return unblockUser(obj_user.id, msg.lang)
                        end
                    else
                        return langs[msg.lang].noObject
                    end
                end
            end
            return
        end
        if matches[1]:lower() == 'vardump' then
            mystat('/vardump')
            return 'VARDUMP (<msg>)\n' .. serpent.block(msg, { sortkeys = false, comment = false })
        end
        if matches[1]:lower() == 'checkspeed' then
            mystat('/checkspeed')
            return os.date('%S', os.difftime(tonumber(os.time()), tonumber(msg.date)))
        end
        if is_sudo(msg) then
            if matches[1]:lower() == "rebootcli" or matches[1]:lower() == "sasha riavvia cli" then
                mystat('/rebootcli')
                io.popen('kill -9 $(pgrep telegram-cli)'):read('*all')
                return langs[msg.lang].cliReboot
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

return {
    description = "ADMINISTRATOR",
    patterns =
    {
        "^[#!/]([Pp][Mm]) (%-?%d+) (.*)$",
        "^[#!/]([Pp][Mm][Uu][Nn][Bb][Ll][Oo][Cc][Kk])$",
        "^[#!/]([Pp][Mm][Bb][Ll][Oo][Cc][Kk])$",
        "^[#!/]([Pp][Mm][Uu][Nn][Bb][Ll][Oo][Cc][Kk]) ([^%s]+)$",
        "^[#!/]([Pp][Mm][Bb][Ll][Oo][Cc][Kk]) ([^%s]+)$",
        "^[#!/]([Bb][Aa][Cc][Kk][Uu][Pp])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd][Bb][Aa][Cc][Kk][Uu][Pp])$",
        "^[#!/]([Uu][Pp][Dd][Aa][Tt][Ee])$",
        "^[#!/]([Vv][Aa][Rr][Dd][Uu][Mm][Pp])$",
        "^[#!/]([Bb][Oo][Tt][Rr][Ee][Ss][Tt][Aa][Rr][Tt])$",
        "^[#!/]([Rr][Ee][Dd][Ii][Ss][Ss][Aa][Vv][Ee])$",
        "^[#!/]([Cc][Oo][Mm][Mm][Aa][Nn][Dd][Ss][Ss][Tt][Aa][Tt][Ss])$",
        "^[#!/]([Cc][Hh][Ee][Cc][Kk][Ss][Pp][Ee][Ee][Dd])$",
        "^[#!/]([Rr][Ee][Bb][Oo][Oo][Tt][Cc][Ll][Ii])$",
        "^[#!/]([Pp][Ii][Nn][Gg])$",
        "^[#!/]([Ll][Aa][Ss][Tt][Ss][Tt][Aa][Rr][Tt])$",
        -- pm
        "^([Ss][Aa][Ss][Hh][Aa] [Mm][Ee][Ss][Ss][Aa][Gg][Gg][Ii][Aa]) (%-?%d+) (.*)$",
        -- unblock
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Bb][Ll][Oo][Cc][Cc][Aa] [Pp][Mm])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Bb][Ll][Oo][Cc][Cc][Aa] [Pp][Mm]) ([^%s]+)$",
        -- block
        "^([Ss][Aa][Ss][Hh][Aa] [Bb][Ll][Oo][Cc][Cc][Aa] [Pp][Mm])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Bb][Ll][Oo][Cc][Cc][Aa] [Pp][Mm]) ([^%s]+)$",
        -- backup
        "^([Ss][Aa][Ss][Hh][Aa] [Ee][Ss][Ee][Gg][Uu][Ii] [Bb][Aa][Cc][Kk][Uu][Pp])$",
        -- uploadbackup
        "^([Ss][Aa][Ss][Hh][Aa] [Ii][Nn][Vv][Ii][Aa] [Bb][Aa][Cc][Kk][Uu][Pp])$",
        -- rebootapi
        "^([Ss][Aa][Ss][Hh][Aa] [Rr][Ii][Aa][Vv][Ii][Aa] [Cc][Ll][Ii])$",
    },
    run = run,
    min_rank = 3,
    syntax =
    {
        "ADMIN",
        "(#pm|sasha messaggia) <id> <msg>",
        "(#pmblock|sasha blocca pm) <id>|<username>|<reply>|from",
        "(#pmunblock|sasha sblocca pm) <id>|<username>|<reply>|from",
        "#checkspeed",
        "#vardump [<reply>]",
        "#commandsstats",
        "#ping",
        "#laststart",
        "SUDO",
        "#botrestart",
        "#redissave",
        "#update",
        "(#backup|sasha esegui backup)",
        "(#uploadbackup|sasha invia backup)",
        "(#rebootcli|sasha riavvia cli)",
    },
}
-- By @imandaneshi :)
-- https://github.com/SEEDTEAM/TeleSeed/blob/test/plugins/admin.lua
-- Modified by @Rondoozle for supergroups
-- Modified by @EricSolinas for API