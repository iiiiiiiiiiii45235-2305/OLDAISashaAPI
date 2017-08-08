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

local function groupsList(msg)
    if not data.groups then
        return langs[msg.lang].noGroups
    end
    local message = langs[msg.lang].groupListStart
    for k, v in pairs(data.groups) do
        if data[tostring(v)] then
            if data[tostring(v)]['settings'] then
                local name = ''
                local grp = data[tostring(v)]
                for m, n in pairs(grp) do
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
                message = message .. name .. ' [' .. v .. '] - [' .. group_owner .. ']\n{' .. group_link .. "}\n"
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
        if data[tostring(v)] then
            if data[tostring(v)]['settings'] then
                local grp = data[tostring(v)]
                local name = ''
                for m, n in pairs(grp) do
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
                message = message .. name .. ' [' .. v .. '] - [' .. group_owner .. ']\n{' .. group_link .. "}\n"
            end
        end
    end
    local file = io.open("./groups/lists/realms.txt", "w")
    file:write(message)
    file:flush()
    file:close()
    return message
end

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
        if matches[1]:lower() == "pm" then
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
        if matches[1]:lower() == "pmblock" then
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
        if matches[1]:lower() == "pmunblock" then
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
        if matches[1]:lower() == 'list' then
            if matches[2]:lower() == 'admins' then
                mystat('/list admins')
                return botAdminsList(msg.chat.id)
            elseif matches[2]:lower() == 'groups' then
                mystat('/list groups')
                -- groupsList(msg)
                -- sendDocument(msg.from.id, "./groups/lists/groups.txt")
                return groupsList(msg)
            elseif matches[2]:lower() == 'realms' then
                mystat('/list realms')
                -- realmsList(msg)
                -- sendDocument(msg.from.id, "./groups/lists/realms.txt")
                return realmsList(msg)
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
        else
            return langs[msg.lang].require_sudo
        end
    else
        return langs[msg.lang].require_admin
    end
end

local function pre_process(msg)
    if msg then
        if msg.service then
            if msg.service_type == 'chat_add_user' or msg.service_type == 'chat_add_users' then
                for k, v in pairs(msg.added) do
                    if tostring(v.id) == tostring(bot.id) then
                        if not is_admin(msg) then
                            sendMessage(msg.chat.id, langs[msg.lang].notMyGroup)
                            leaveChat(msg.chat.id)
                        end
                    end
                end
            end
        end
        return msg
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
        "^[#!/]([Aa][Dd][Dd][Aa][Dd][Mm][Ii][Nn]) ([^%s]+)$",
        "^[#!/]([Rr][Ee][Mm][Oo][Vv][Ee][Aa][Dd][Mm][Ii][Nn]) ([^%s]+)$",
        "^[#!/]([Ll][Ii][Ss][Tt]) ([^%s]+)$",
        "^[#!/]([Bb][Aa][Cc][Kk][Uu][Pp])$",
        "^[#!/]([Uu][Pp][Dd][Aa][Tt][Ee])$",
        "^[#!/]([Vv][Aa][Rr][Dd][Uu][Mm][Pp])$",
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
    },
    pre_process = pre_process,
    run = run,
    min_rank = 3,
    syntax =
    {
        "ADMIN",
        "#pm <id> <msg>",
        "#pmblock <id>|<username>|<reply>|from",
        "#pmunblock <id>|<username>|<reply>|from",
        "#list admins|groups|realms",
        "#checkspeed",
        "#vardump [<reply>]",
        "#commandsstats",
        "#ping",
        "#laststart",
        "#leave [<group_id>]",
        "SUDO",
        "#addadmin <user_id>|<username>",
        "#removeadmin <user_id>|<username>",
        "#botrestart",
        "#redissave",
        "#update",
        "#backup",
        "#rebootcli",
        "#reloaddata",
        "#broadcast <text>",
    },
}
-- By @imandaneshi :)
-- https://github.com/SEEDTEAM/TeleSeed/blob/test/plugins/admin.lua
-- Modified by @Rondoozle for supergroups
-- Modified by @EricSolinas for API