local function db_user(user, chat_id)
    if not user.print_name then
        user.print_name = user.first_name .. ' ' ..(user.last_name or '')
    end
    if database[tostring(user.id)] then
        if database[tostring(user.id)]['groups'] then
            if not database[tostring(user.id)]['groups'][tostring(chat_id)] then
                database[tostring(user.id)]['groups'][tostring(chat_id)] = tonumber(chat_id)
            end
        else
            database[tostring(user.id)]['groups'] = { [tostring(chat_id)] = tonumber(chat_id) }
        end
        if database[tostring(user.id)]['print_name'] ~= user.print_name:gsub("_", " ") then
            database[tostring(user.id)]['print_name'] = user.print_name:gsub("_", " ")
            database[tostring(user.id)]['old_print_names'] = database[tostring(user.id)]['old_print_names'] .. ' ### ' .. user.print_name:gsub("_", " ")
        end
        local username = 'NOUSER'
        if user.username then
            username = '@' .. user.username
        end
        if database[tostring(user.id)]['username'] ~= username then
            database[tostring(user.id)]['username'] = username
            database[tostring(user.id)]['old_usernames'] = database[tostring(user.id)]['old_usernames'] .. ' ### ' .. username
        end
        if user.type then
            database[tostring(user.id)].type = user.type
        elseif user.is_bot then
            database[tostring(user.id)].type = 'bot'
        else
            database[tostring(user.id)].type = 'private'
        end
    else
        print('new user')
        local username = 'NOUSER'
        if user.username then
            username = '@' .. user.username
        end
        database[tostring(user.id)] = {
            print_name = user.print_name:gsub("_"," "),
            old_print_names = user.print_name:gsub("_"," "),
            type = user.type,
            username = username,
            old_usernames = username,
            groups = { [tostring(chat_id)] = tonumber(chat_id) },
        }
    end
end

local function db_group(group)
    if database[tostring(group.id)] then
        if database[tostring(group.id)]['print_name'] ~= group.print_name:gsub("_", " ") then
            database[tostring(group.id)]['print_name'] = group.print_name:gsub("_", " ")
            database[tostring(group.id)]['old_print_names'] = database[tostring(group.id)]['old_print_names'] .. ' ### ' .. group.print_name:gsub("_", " ")
        end
    else
        print('new group')
        database[tostring(group.id)] = {
            print_name = group.print_name:gsub("_"," "),
            old_print_names = group.print_name:gsub("_"," "),
            lang = get_lang(group.id),
            type = group.type,
        }
    end
end

local function db_supergroup(supergroup)
    if database[tostring(supergroup.id)] then
        if database[tostring(supergroup.id)]['print_name'] ~= supergroup.print_name:gsub("_", " ") then
            database[tostring(supergroup.id)]['print_name'] = supergroup.print_name:gsub("_", " ")
            database[tostring(supergroup.id)]['old_print_names'] = database[tostring(supergroup.id)]['old_print_names'] .. ' ### ' .. supergroup.print_name:gsub("_", " ")
        end
        if database[tostring(supergroup.id)]['username'] and database[tostring(supergroup.id)]['old_usernames'] then
            local username = 'NOUSER'
            if supergroup.username then
                username = '@' .. supergroup.username
            end
            if database[tostring(supergroup.id)]['username'] ~= username then
                database[tostring(supergroup.id)]['username'] = username
                database[tostring(supergroup.id)]['old_usernames'] = database[tostring(supergroup.id)]['old_usernames'] .. ' ### ' .. username
            end
        end
    else
        print('new supergroup')
        local username = 'NOUSER'
        if supergroup.username then
            username = '@' .. supergroup.username
        end
        database[tostring(supergroup.id)] = {
            print_name = supergroup.print_name:gsub("_"," "),
            old_print_names = supergroup.print_name:gsub("_"," "),
            lang = get_lang(supergroup.id),
            type = supergroup.type,
            username = username,
            old_usernames = username,
        }
    end
end

local function db_channel(channel)
    if database[tostring(channel.id)] then
        if database[tostring(channel.id)]['print_name'] ~= channel.print_name:gsub("_", " ") then
            database[tostring(channel.id)]['print_name'] = channel.print_name:gsub("_", " ")
            database[tostring(channel.id)]['old_print_names'] = database[tostring(channel.id)]['old_print_names'] .. ' ### ' .. channel.print_name:gsub("_", " ")
        end
        if database[tostring(channel.id)]['username'] and database[tostring(channel.id)]['old_usernames'] then
            local username = 'NOUSER'
            if channel.username then
                username = '@' .. channel.username
            end
            if database[tostring(channel.id)]['username'] ~= username then
                database[tostring(channel.id)]['username'] = username
                database[tostring(channel.id)]['old_usernames'] = database[tostring(channel.id)]['old_usernames'] .. ' ### ' .. username
            end
        end
    else
        print('new channel')
        local username = 'NOUSER'
        if channel.username then
            username = '@' .. channel.username
        end
        database[tostring(channel.id)] = {
            print_name = channel.print_name:gsub("_"," "),
            old_print_names = channel.print_name:gsub("_"," "),
            lang = get_lang(channel.id),
            type = channel.type,
            username = username,
            old_usernames = username,
        }
    end
end

local function run(msg, matches)
    if is_sudo(msg) then
        if matches[1]:lower() == 'createdatabase' then
            mystat('/createdatabase')
            local f = io.open(config.database.db, 'w+')
            f:write('{}')
            f:close()
            database = load_data(config.database.db)
            return langs[msg.lang].dbCreated
        end

        --[[if matches[1]:lower() == 'dodatabase' or matches[1]:lower() == 'sasha esegui database' then
            return langs[msg.lang].useAISasha
            mystat('/dodatabase')
            local participants = getChatParticipants(msg.chat.id)
            for k, v in pairs(participants) do
                if v.user then
                    v = v.user
                    if v.first_name then
                        v.print_name = v.first_name ..(v.last_name or '')
                        db_user(v, msg.chat.id)
                    end
                end
            end
            save_data(config.database.db, database)
            return langs[msg.lang].dataLeaked
        end]]

        if matches[1]:lower() == 'dbsearch' or matches[1]:lower() == 'sasha cerca db' or matches[1]:lower() == 'cerca db' then
            mystat('/dbsearch')
            if msg.reply then
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                if database[tostring(msg.reply_to_message.forward_from.id)] then
                                    return serpent.block(database[tostring(msg.reply_to_message.forward_from.id)], { sortkeys = false, comment = false })
                                else
                                    return matches[2] .. langs[msg.lang].notFound
                                end
                            elseif msg.reply_to_message.forward_from_chat then
                                if database[tostring(msg.reply_to_message.forward_from_chat.id)] then
                                    return serpent.block(database[tostring(msg.reply_to_message.forward_from_chat.id)], { sortkeys = false, comment = false })
                                else
                                    return matches[2] .. langs[msg.lang].notFound
                                end
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    end
                else
                    if database[tostring(msg.reply_to_message.from.id)] then
                        return serpent.block(database[tostring(msg.reply_to_message.from.id)], { sortkeys = false, comment = false })
                    else
                        return matches[2] .. langs[msg.lang].notFound
                    end
                end
            elseif matches[2] and matches[2] ~= '' then
                if msg.entities then
                    for k, v in pairs(msg.entities) do
                        -- check if there's a text_mention
                        if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                            if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                if database[tostring(msg.entities[k].user.id)] then
                                    return serpent.block(database[tostring(msg.entities[k].user.id)], { sortkeys = false, comment = false })
                                else
                                    return msg.entities[k].user.id .. langs[msg.lang].notFound
                                end
                            end
                        end
                    end
                end
                if string.match(matches[2], '^%d+$') then
                    if database[tostring(matches[2])] then
                        return serpent.block(database[tostring(matches[2])], { sortkeys = false, comment = false })
                    else
                        return matches[2] .. langs[msg.lang].notFound
                    end
                else
                    local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            if database[tostring(obj_user.id)] then
                                return serpent.block(database[tostring(obj_user.id)], { sortkeys = false, comment = false })
                            else
                                return matches[2] .. langs[msg.lang].notFound
                            end
                        end
                    else
                        return langs[msg.lang].noObject
                    end
                end
            end
            return
        end

        if matches[1]:lower() == 'addrecord' and matches[2] and matches[3] then
            mystat('/addrecord')
            local t = matches[3]:split('\n')
            if matches[2]:lower() == 'user' then
                local id = t[1]
                local print_name = t[2]
                local old_print_names = t[3]
                local type = matches[2]
                local username = t[4]
                local old_usernames = t[5]
                local groups = { }
                for k, v in pairs(t[6]:split(' ')) do
                    groups[tostring(v)] = tonumber(v)
                end
                print('new user')
                database[tostring(id)] = {
                    print_name = print_name:gsub("_"," "),
                    old_print_names = old_print_names:gsub("_"," "),
                    type = type,
                    username = username,
                    old_usernames = old_usernames,
                    groups = groups,
                }
                save_data(config.database.db, database)
                return langs[msg.lang].userManuallyAdded
            elseif matches[2]:lower() == 'group' then
                local id = t[1]
                local print_name = t[2]
                local old_print_names = t[3]
                local lang = t[4]
                local type = matches[2]
                print('new group')
                database[tostring(id)] = {
                    print_name = print_name:gsub("_"," "),
                    old_print_names = old_print_names:gsub("_"," "),
                    lang = lang,
                    type = type,
                }
                save_data(config.database.db, database)
                return langs[msg.lang].groupManuallyAdded
            elseif matches[2]:lower() == 'supergroup' then
                local id = t[1]
                local print_name = t[2]
                local old_print_names = t[3]
                local lang = t[4]
                local type = matches[2]
                local username = 'NOUSER'
                local old_usernames = username
                if t[5] then
                    username = t[5]
                    old_usernames = username
                    if t[6] then
                        old_usernames = t[6]
                    end
                end
                print('new supergroup')
                database[tostring(id)] = {
                    print_name = print_name:gsub("_"," "),
                    old_print_names = old_print_names:gsub("_"," "),
                    lang = lang,
                    type = type,
                    username = username,
                    old_usernames = old_usernames,
                }
                save_data(config.database.db, database)
                return langs[msg.lang].supergroupManuallyAdded
            elseif matches[2]:lower() == 'channel' then
                local id = t[1]
                local print_name = t[2]
                local old_print_names = t[3]
                local lang = t[4]
                local type = matches[2]
                local username = 'NOUSER'
                local old_usernames = username
                if t[5] then
                    username = t[5]
                    old_usernames = username
                    if t[6] then
                        old_usernames = t[6]
                    end
                end
                print('new supergroup')
                database[tostring(id)] = {
                    print_name = print_name:gsub("_"," "),
                    old_print_names = old_print_names:gsub("_"," "),
                    lang = lang,
                    type = type,
                    username = username,
                    old_usernames = old_usernames,
                }
                save_data(config.database.db, database)
                return langs[msg.lang].channelManuallyAdded
            end
        end

        if (matches[1]:lower() == 'dbdelete' or matches[1]:lower() == 'sasha elimina db' or matches[1]:lower() == 'elimina db') and matches[2] then
            mystat('/delete')
            if database[tostring(matches[2])] then
                database[tostring(matches[2])] = nil
                save_data(config.database.db, database)
                return langs[msg.lang].recordDeleted
            else
                return matches[2] .. langs[msg.lang].notFound
            end
        end

        if matches[1]:lower() == 'uploaddb' then
            mystat('/uploaddb')
            print('SAVING USERS/GROUPS DATABASE')
            save_data(config.database.db, database)
            if io.popen('find /home/pi/AISashaAPI/data/database.json'):read("*all") ~= '' then
                sendDocument_SUDOERS('/home/pi/AISashaAPI/data/database.json')
                return langs[msg.lang].databaseSent
            else
                return langs[msg.lang].databaseMissing
            end
        end

        if matches[1]:lower() == 'replacedb' then
            mystat('/replacedb')
            if msg.reply then
                if msg.reply_to_message.document then
                    if msg.reply_to_message.document.mime_type == 'application/json' then
                        local res = getFile(msg.reply_to_message.document.file_id)
                        local download_link = telegram_file_link(res)
                        download_to_file(download_link, '/home/pi/AISashaAPI/data/database.json')
                        database = load_data(config.database.db)
                        return langs[msg.lang].databaseDownloaded
                    else
                        return langs[msg.lang].needJson
                    end
                else
                    return langs[msg.lang].useQuoteOnFile
                end
            else
                return langs[msg.lang].useQuoteOnFile
            end
        end
    else
        return langs[msg.lang].require_sudo
    end
end

local function save_to_db(msg)
    if database then
        if not string.match(msg.from.id, '^%*%d') then
            if msg.from.type == 'private' then
                db_user(msg.from, bot.id)
            end
            if msg.from.type == 'channel' then
                db_channel(msg.from)
            end
            if msg.chat.type == 'group' then
                db_group(msg.chat)
            end
            if msg.chat.type == 'supergroup' then
                db_supergroup(msg.chat)
            end
            if msg.chat.type == 'channel' then
                db_channel(msg.chat)
            end
            if msg.adder then
                db_user(msg.adder, msg.chat.id)
            end
            if msg.added then
                for k, v in pairs(msg.added) do
                    db_user(v, msg.chat.id)
                end
            end
            if msg.remover then
                db_user(msg.remover, msg.chat.id)
            end
            if msg.removed then
                db_user(msg.removed, msg.chat.id)
            end

            if msg.entities then
                for k, v in pairs(msg.entities) do
                    if msg.entities[k].user then
                        db_user(msg.entities[k].user, msg.chat.id)
                    end
                end
            end

            local tmp = ''
            if msg.text then
                tmp = msg.text:lower()
            end
            if msg.media then
                if msg.caption then
                    tmp = msg.caption:lower()
                end
            end
            -- make all the telegram's links t.me
            tmp = links_to_tdotme(tmp)
            -- remove http(s)
            tmp = tmp:gsub("[Hh][Tt][Tt][Pp][Ss]?://", '')
            -- remove joinchat links
            tmp = tmp:gsub('[Tt]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/([^%s]+)', '')
            -- remove ?start=blabla and things like that
            tmp = tmp:gsub('%?([^%s]+)', '')
            -- make links usernames
            tmp = tmp:gsub('[Tt]%.[Mm][Ee]/', '@')
            while string.match(tmp, '(@[^%s]+)') do
                local obj = getChat(string.match(tmp, '(@[^%s]+)'), true)
                if obj then
                    if obj.result then
                        obj = obj.result
                        if obj.type == 'private' then
                            if msg.bot then
                                db_user(obj, bot.id)
                            else
                                db_user(obj, msg.chat.id)
                            end
                        elseif obj.type == 'group' then
                            db_group(obj)
                        elseif obj.type == 'supergroup' then
                            db_supergroup(obj)
                        elseif obj.type == 'channel' then
                            db_channel(obj)
                        end
                    end
                end
                tmp = tmp:gsub(string.match(tmp, '(@[^%s]+)'), '')
            end

            -- if forward save forward
            if msg.forward then
                if msg.forward_from then
                    db_user(msg.forward_from, bot.id)
                elseif msg.forward_from_chat then
                    db_channel(msg.forward_from_chat)
                end
            end
        end

        -- if reply save reply
        if msg.reply then
            save_to_db(msg.reply_to_message)
        end
    else
        sendMessage_SUDOERS(langs[msg.lang].databaseFuckedUp, 'markdown')
        local f = io.open(config.database.db, 'w+')
        f:write('{}')
        f:close()
    end
end

local function pre_process(msg)
    if msg then
        save_to_db(msg)
        if msg.service then
            if msg.service_type == 'chat_rename' then
                return msg
            end
        end
        if data[tostring(msg.chat.id)] then
            if data[tostring(msg.chat.id)].set_name then
                -- update chat's names
                data[tostring(msg.chat.id)].set_name = string.gsub(msg.chat.print_name, '_', ' ')
            end
        end
        return msg
    end
end

return {
    description = "DATABASE",
    patterns =
    {
        "^[#!/]([Cc][Rr][Ee][Aa][Tt][Ee][Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee])$",
        "^[#!/]([Dd][Oo][Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee])$",
        "^[#!/]([Dd][Bb][Ss][Ee][Aa][Rr][Cc][Hh]) ([^%s]+)$",
        "^[#!/]([Aa][Dd][Dd][Rr][Ee][Cc][Oo][Rr][Dd]) ([^%s]+) (.*)$",
        "^[#!/]([Dd][Bb][Dd][Ee][Ll][Ee][Tt][Ee]) (%-?%d+)$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd][Dd][Bb])$",
        "^[#!/]([Rr][Ee][Pp][Ll][Aa][Cc][Ee][Dd][Bb])$",
        -- dodatabase
        "^([Ss][Aa][Ss][Hh][Aa] [Ee][Ss][Ee][Gg][Uu][Ii] [Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee])$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 4,
    syntax =
    {
        "SUDO",
        "#createdatabase",
        -- "(#dodatabase|sasha esegui database)",
        "#dbsearch <id>|<username>|<reply>|from",
        "#dbdelete <id>",
        "#addrecord user <id>\n<print_name>\n<old_print_names>\n<username>\n<old_usernames>\n<groups_ids_separated_by_space>",
        "#addrecord group <id>\n<print_name>\n<old_print_names>\n<lang>",
        "#addrecord supergroup <id>\n<print_name>\n<old_print_names>\n<lang>\n[<username>\n<old_usernames>]",
        "#addrecord channel <id>\n<print_name>\n<old_print_names>\n<lang>\n[<username>\n<old_usernames>]",
        "#uploaddb",
        "#replacedb",
    },
}