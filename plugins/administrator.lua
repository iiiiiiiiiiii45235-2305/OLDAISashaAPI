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
            if data[tostring(k)]['settings'] then
                local name = ''
                local grp = data[tostring(k)]
                for m, n in pairs(grp) do
                    if m == 'set_name' then
                        name = n
                    end
                end
                local group_owner = "No owner"
                if data[tostring(k)]['set_owner'] then
                    group_owner = tostring(data[tostring(k)]['set_owner'])
                end
                local group_link = nil
                if data[tostring(k)]['settings']['set_link'] then
                    group_link = data[tostring(k)]['settings']['set_link']
                elseif get_links and data[tostring(k)]['group_type']:lower() == 'supergroup' then
                    local link = exportChatInviteLink(k)
                    if link then
                        data[tostring(k)]['settings']['set_link'] = link
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
    local tot_groups = 0
    for k, v in pairsByGroupName(data) do
        if data[tostring(k)] then
            if data[tostring(k)]['settings'] then
                tot_groups = tot_groups + 1
            end
        end
    end
    local max_pages = math.floor(tot_groups / max_groups)
    if (tot_groups / max_groups) >= math.floor(tot_groups / max_groups) then
        max_pages = max_pages + 1
    end
    if tonumber(page) > max_pages then
        page = max_pages
    end
    tot_groups = 0
    for k, v in pairsByGroupName(data) do
        if data[tostring(k)] then
            if data[tostring(k)]['settings'] then
                tot_groups = tot_groups + 1
                if tot_groups >=(((tonumber(page) -1) * max_groups) + 1) and tot_groups <=(max_groups * tonumber(page)) then
                    local name = ''
                    local grp = data[tostring(k)]
                    for m, n in pairs(grp) do
                        if m == 'set_name' then
                            name = n
                        end
                    end
                    local group_owner = "No owner"
                    if data[tostring(k)]['set_owner'] then
                        group_owner = tostring(data[tostring(k)]['set_owner'])
                    end
                    local group_link = nil
                    if data[tostring(k)]['settings']['set_link'] then
                        group_link = data[tostring(k)]['settings']['set_link']
                    elseif get_links and data[tostring(k)]['group_type']:lower() == 'supergroup' then
                        local link = exportChatInviteLink(k)
                        if link then
                            data[tostring(k)]['settings']['set_link'] = link
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
    end
    return message
end

local function run(msg, matches)
    if is_admin(msg) then
        if msg.cb then
            if matches[1] == '###cbadministrator' then
                if matches[2] == 'DELETE' then
                    if not deleteMessage(msg.chat.id, msg.message_id, true) then
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                    end
                elseif matches[2] == 'BACK' then
                    editMessage(msg.chat.id, msg.message_id, groupsPages(matches[3] or 1), keyboard_list_groups_pages(msg.chat.id, matches[3] or 1), 'html')
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                elseif matches[2] == 'PAGEMINUS' then
                    editMessage(msg.chat.id, msg.message_id, groupsPages(tonumber(matches[3] or 2) -1), keyboard_list_groups_pages(msg.chat.id, tonumber(matches[3] or 2) -1), 'html')
                elseif matches[2] == 'PAGEPLUS' then
                    editMessage(msg.chat.id, msg.message_id, groupsPages(tonumber(matches[3] or 0) + 1), keyboard_list_groups_pages(msg.chat.id, tonumber(matches[3] or 0) + 1), 'html')
                end
                return
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
            return langs[msg.lang].ok
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
                if msg.entities then
                    for k, v in pairs(msg.entities) do
                        -- check if there's a text_mention
                        if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                            if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                return blockUser(msg.entities[k].user.id, msg.lang)
                            end
                        end
                    end
                end
                matches[2] = tostring(matches[2]):gsub(' ', '')
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
                if msg.entities then
                    for k, v in pairs(msg.entities) do
                        -- check if there's a text_mention
                        if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                            if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                return unblockUser(msg.entities[k].user.id, msg.lang)
                            end
                        end
                    end
                end
                matches[2] = tostring(matches[2]):gsub(' ', '')
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
        if matches[1]:lower() == 'requestslog' then
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
                            io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. message_id .. '"')
                            io.popen('lua timework.lua "deletemessage" "' .. msg.chat.id .. '" "60" "' .. msg.message_id .. '"')
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
        "^(###cbadministrator)(DELETE)$",
        "^(###cbadministrator)(BACK)(%d+)$",
        "^(###cbadministrator)(PAGEMINUS)(%d+)$",
        "^(###cbadministrator)(PAGEPLUS)(%d+)$",

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
    run = run,
    min_rank = 3,
    syntax =
    {
        "ADMIN",
        "/todo {reply} [{text}]",
        "/todo {text}",
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
        "SUDO",
        "/addadmin {user_id}|{username}",
        "/removeadmin {user_id}|{username}",
        "/botrestart",
        "/redissave",
        "/update",
        "/backup",
        "/rebootcli",
        "/reloaddata",
        "/broadcast {text}",
    },
}
-- By @imandaneshi :)
-- https://github.com/SEEDTEAM/TeleSeed/blob/test/plugins/admin.lua
-- Modified by @Rondoozle for supergroups
-- Modified by @EricSolinas for API