local function cli_get_hash(msg)
    if msg.chat.type == 'private' then
        return 'user:' .. id_to_cli(msg.chat.id) .. ':variables'
    end
    if msg.chat.type == 'group' then
        return 'chat:' .. id_to_cli(msg.chat.id) .. ':variables'
    end
    if msg.chat.type == 'supergroup' then
        return 'channel:' .. id_to_cli(msg.chat.id) .. ':variables'
    end
    if msg.chat.type == 'channel' then
        return 'channel:' .. id_to_cli(msg.chat.id) .. ':variables'
    end
    return false
end
local function cli_get_value(msg, var_name)
    var_name = var_name:gsub(' ', '_')
    if cli_get_hash(msg) then
        local value = redis:hget(cli_get_hash(msg), var_name)
        if value then
            return value
        end
    end
end
local function cli_list_variables(msg)
    if cli_get_hash(msg) then
        local names = redis:hkeys(cli_get_hash(msg))
        local text = ''
        for i = 1, #names do
            text = text .. names[i]:gsub('_', ' ') .. '\n'
        end
        return text
    end
end
local function api_get_hash(msg)
    if msg.chat.type == 'private' then
        return 'user:' .. msg.chat.id .. ':variables'
    end
    if msg.chat.type == 'group' then
        return 'group:' .. msg.chat.id .. ':variables'
    end
    if msg.chat.type == 'supergroup' then
        return 'supergroup:' .. msg.chat.id .. ':variables'
    end
    if msg.chat.type == 'channel' then
        return 'channel:' .. msg.chat.id .. ':variables'
    end
    return false
end
local function api_set_value(msg, name, value)
    if (not name or not value) then
        return langs[msg.lang].errorTryAgain
    end

    if api_get_hash(msg) then
        redis:hset(api_get_hash(msg), name:gsub(' ', '_'), value)
        return name .. langs[msg.lang].saved
    end
end
local function cli_get_censorships_hash(msg)
    if msg.chat.type == 'chat' then
        return 'chat:' .. msg.chat.id .. ':censorships'
    end
    if msg.chat.type == 'channel' then
        return 'channel:' .. msg.chat.id .. ':censorships'
    end
    return false
end
local function cli_list_censorships(msg)
    local hash = cli_get_censorships_hash(msg)

    if hash then
        local names = redis:hkeys(hash)
        local text = ''
        for i = 1, #names do
            text = text .. names[i] .. '\n'
        end
        return text
    end
end
local function api_get_censorships_hash(msg)
    if msg.chat.type == 'group' then
        return 'group:' .. msg.chat.id .. ':censorships'
    end
    if msg.chat.type == 'supergroup' then
        return 'supergroup:' .. msg.chat.id .. ':censorships'
    end
    return false
end
local function api_setunset_delword(msg, var_name)
    local hash = api_get_censorships_hash(msg)
    if hash then
        if redis:hget(hash, var_name) then
            redis:hdel(hash, var_name)
            return langs[msg.lang].delwordRemoved .. var_name
        else
            redis:hset(hash, var_name, true)
            return langs[msg.lang].delwordAdded .. var_name
        end
    end
end
-- not used
local function convert_yes_no_true_false(value)
    if value then
        if value == 'yes' then
            return true
        elseif value == 'no' then
            return false
        else
            return false
        end
    else
        return false
    end
end

local function run(msg, matches)
    if matches[1]:lower() == 'migrate' then
        if msg.from.is_owner then
            local text = ''
            mystat('/migrate')
            local migrated = false
            -- migrate group from moderation.json
            local old_moderation_path = '/home/pi/AISasha/data/moderation.json'
            -- local new_moderation_path = config.moderation.data
            local old_moderation_data = load_data(old_moderation_path)
            -- local new_moderation_data = load_data(config.moderation.data)
            if old_moderation_data['groups'] then
                if not data['groups'] then
                    data['groups'] = { }
                end
                for id_string in pairs(old_moderation_data['groups']) do
                    if id_string == tostring(id_to_cli(msg.chat.id)) then
                        if old_moderation_data[id_string] then
                            if old_moderation_data[id_string].group_type == 'SuperGroup' then
                                data['groups'][tostring(msg.chat.id)] = tonumber(msg.chat.id)
                                data[tostring(msg.chat.id)] = { }
                                data[tostring(msg.chat.id)].goodbye = old_moderation_data[id_string].goodbye or ''
                                data[tostring(msg.chat.id)].type = old_moderation_data[id_string].group_type
                                data[tostring(msg.chat.id)].moderators = old_moderation_data[id_string].moderators
                                data[tostring(msg.chat.id)].photo = nil
                                data[tostring(msg.chat.id)].rules = old_moderation_data[id_string].rules
                                data[tostring(msg.chat.id)].name = msg.chat.print_name
                                data[tostring(msg.chat.id)].owner = old_moderation_data[id_string].set_owner
                                data[tostring(msg.chat.id)].settings = {
                                    flood = false,
                                    max_flood = 5,
                                    links_whitelist = { "@username", },
                                    lock_arabic = false,
                                    lock_bots = false,
                                    lock_group_link = false,
                                    lock_leave = false,
                                    lock_link = false,
                                    lock_member = false,
                                    lock_name = false,
                                    lock_photo = false,
                                    lock_rtl = false,
                                    lock_spam = false,
                                    mutes =
                                    {
                                        all = false,
                                        audio = false,
                                        contact = false,
                                        document = false,
                                        game = false,
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
                                    max_warns = 3,
                                }
                                data[tostring(msg.chat.id)].welcome = old_moderation_data[id_string].welcome or ''
                                data[tostring(msg.chat.id)].welcomemembers = old_moderation_data[id_string].welcomemembers or 0
                                migrated = true
                            end
                            if old_moderation_data[id_string].group_type == 'Group' then
                                data['groups'][tostring(msg.chat.id)] = tonumber(msg.chat.id)
                                data[tostring(msg.chat.id)] = { }
                                data[tostring(msg.chat.id)].goodbye = old_moderation_data[id_string].goodbye or ''
                                data[tostring(msg.chat.id)].type = old_moderation_data[id_string].group_type
                                data[tostring(msg.chat.id)].moderators = old_moderation_data[id_string].moderators
                                data[tostring(msg.chat.id)].photo = nil
                                data[tostring(msg.chat.id)].rules = old_moderation_data[id_string].rules
                                data[tostring(msg.chat.id)].name = msg.chat.print_name
                                data[tostring(msg.chat.id)].owner = old_moderation_data[id_string].set_owner
                                data[tostring(msg.chat.id)].settings = {
                                    flood = false,
                                    max_flood = 5,
                                    links_whitelist = { "@username", },
                                    lock_arabic = false,
                                    lock_bots = false,
                                    lock_group_link = false,
                                    lock_leave = false,
                                    lock_link = false,
                                    lock_member = false,
                                    lock_name = false,
                                    lock_photo = false,
                                    lock_rtl = false,
                                    lock_spam = false,
                                    mutes =
                                    {
                                        all = false,
                                        audio = false,
                                        contact = false,
                                        document = false,
                                        game = false,
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
                                    max_warns = 3,
                                }
                                data[tostring(msg.chat.id)].welcome = old_moderation_data[id_string].welcome or ''
                                data[tostring(msg.chat.id)].welcomemembers = old_moderation_data[id_string].welcomemembers or 0
                                migrated = true
                            end
                            if not migrated then
                                text = langs[msg.lang].unknownGroupType .. id_string .. '\n'
                            end
                        else
                            text = langs[msg.lang].noGroupDataAvailable .. '\n'
                        end
                    end
                end
            end
            if old_moderation_data['realms'] then
                if not data['realms'] then
                    data['realms'] = { }
                end
                for id_string in pairs(old_moderation_data['realms']) do
                    if old_moderation_data[id_string] then
                        if id_string == tostring(id_to_cli(msg.chat.id)) then
                            if old_moderation_data[id_string].group_type == 'Realm' then
                                data['realms'][tostring(msg.chat.id)] = tonumber(msg.chat.id)
                                data[tostring(msg.chat.id)] = { }
                                data[tostring(msg.chat.id)].type = old_moderation_data[id_string].group_type
                                data[tostring(msg.chat.id)].name = msg.chat.print_name
                                data[tostring(msg.chat.id)].settings = old_moderation_data[id_string].settings
                                migrated = true
                            end
                            if not migrated then
                                text = langs[msg.lang].unknownGroupType .. id_string .. '\n'
                            end
                        end
                    else
                        text = langs[msg.lang].noGroupDataAvailable .. ' json \n'
                    end
                end
            end
            save_data(config.moderation.data, data)

            -- migrate set, get, unset things
            local vars = cli_list_variables(msg)
            if vars ~= nil then
                local t = vars:split('\n')
                local i = 0
                for k, word in pairs(t) do
                    i = i + 1
                    local answer = cli_get_value(msg, word:lower())
                    if answer then
                        if string.match(answer, '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                            text = langs[msg.lang].crossexecDenial .. '\n'
                        end
                        api_set_value(msg, word:lower(), answer)
                    end
                end
            end

            -- migrate censorships
            local vars = cli_list_censorships(msg)
            if vars ~= nil then
                local t = vars:split('\n')
                local i = 0
                for k, word in pairs(t) do
                    i = i + 1
                    api_setunset_delword(msg, word:lower())
                end
            end

            -- migrate ban
            local banned = redis:smembers('banned:' .. id_to_cli(msg.chat.id))
            if next(banned) then
                for i = 1, #banned do
                    preBanUser(bot.id, banned[i], msg.chat.id)
                end
            end

            -- migrate likes from likecounterdb.json
            local old_likecounter_path = '/home/pi/AISasha/data/likecounterdb.json'
            local new_likecounter_path = config.likecounter.db
            local old_likecounter_data = load_data(old_likecounter_path)
            local new_likecounter_data = load_data(new_likecounter_path)
            if old_likecounter_data then
                for id_string in pairs(old_likecounter_data) do
                    -- if there are any groups check for everyone of them to find the one requesting migration, if found migrate
                    if id_string == tostring(id_to_cli(msg.chat.id)) then
                        if old_likecounter_data[id_string] then
                            new_likecounter_data[tostring(msg.chat.id)] = old_likecounter_data[id_string]
                        else
                            text = langs[msg.lang].noGroupDataAvailable .. ' likecounter\n'
                        end
                    end
                end
            end
            save_data(new_likecounter_path, new_likecounter_data)
            database = load_data(config.database.db)
            text = langs[msg.lang].migrationCompleted
            return text
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'copysettings' then
        if msg.from.is_owner then
            mystat('/copysettings')
            local found = false
            local old_moderation_path = '/home/pi/AISasha/data/moderation.json'
            -- local new_moderation_path = config.moderation.data
            local old_moderation_data = load_data(old_moderation_path)
            -- local new_moderation_data = load_data(config.moderation.data)
            if old_moderation_data['groups'] then
                for id_string in pairs(old_moderation_data['groups']) do
                    if id_string == tostring(id_to_cli(msg.chat.id)) then
                        if old_moderation_data[id_string] then
                            if old_moderation_data[id_string].group_type == 'SuperGroup' or old_moderation_data[id_string].group_type == 'Group' then
                                local lock_name = old_moderation_data[tostring(id_to_cli(msg.chat.id))].settings.lock_name
                                local lock_photo = old_moderation_data[tostring(id_to_cli(msg.chat.id))].settings.lock_photo
                                local set_photo = old_moderation_data[tostring(id_to_cli(msg.chat.id))].set_photo
                                local long_id = old_moderation_data[tostring(id_to_cli(msg.chat.id))].long_id
                                old_moderation_data[tostring(id_to_cli(msg.chat.id))] = data[tostring(msg.chat.id)]
                                old_moderation_data[tostring(id_to_cli(msg.chat.id))].settings.lock_name = lock_name
                                old_moderation_data[tostring(id_to_cli(msg.chat.id))].settings.lock_photo = lock_photo
                                old_moderation_data[tostring(id_to_cli(msg.chat.id))].set_photo = set_photo
                                old_moderation_data[tostring(id_to_cli(msg.chat.id))].long_id = long_id
                                found = true
                            end
                        end
                    end
                end
            end
            if old_moderation_data['realms'] then
                for id_string in pairs(old_moderation_data['realms']) do
                    if id_string == tostring(id_to_cli(msg.chat.id)) then
                        if old_moderation_data[id_string] then
                            if old_moderation_data[id_string].group_type == 'Realm' then
                                local lock_name = old_moderation_data[tostring(id_to_cli(msg.chat.id))].settings.lock_name
                                local lock_photo = old_moderation_data[tostring(id_to_cli(msg.chat.id))].settings.lock_photo
                                local set_photo = old_moderation_data[tostring(id_to_cli(msg.chat.id))].set_photo
                                local long_id = old_moderation_data[tostring(id_to_cli(msg.chat.id))].long_id
                                old_moderation_data[tostring(id_to_cli(msg.chat.id))] = data[tostring(msg.chat.id)]
                                old_moderation_data[tostring(id_to_cli(msg.chat.id))].settings.lock_name = lock_name
                                old_moderation_data[tostring(id_to_cli(msg.chat.id))].settings.lock_photo = lock_photo
                                old_moderation_data[tostring(id_to_cli(msg.chat.id))].set_photo = set_photo
                                old_moderation_data[tostring(id_to_cli(msg.chat.id))].long_id = long_id
                                found = true
                            end
                        end
                    end
                end
            end
            if found then
                save_data(old_moderation_path, old_moderation_data)
                sendMessage(bot.userVersion.id, '/reloaddata')
                return langs[msg.lang].settingsCopied
            else
                return langs[msg.lang].noGroupDataAvailable
            end
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'sudomigrate' then
        if is_sudo(msg) then
            mystat('/sudomigrate')
            -- migrate database from database.json
            local old_database_path = '/home/pi/AISasha/data/database.json'
            local new_database_path = config.database.db
            local old_database_data = load_data(old_database_path)
            local new_database_data = load_data(new_database_path)
            if old_database_data['groups'] then
                for id_string in pairs(old_database_data['groups']) do
                    -- if there are any groups move their data from cli to api db
                    if id_string == tostring(id_to_cli(msg.chat.id)) then
                        if old_database_data['groups'][id_string] then
                            if old_database_data['groups'][id_string].username and old_database_data['groups'][id_string].old_usernames then
                                -- supergroups
                                new_database_data[tostring('-100' .. id_string)] = { }
                                new_database_data[tostring('-100' .. id_string)].old_print_names = old_database_data['groups'][id_string].old_print_names
                                new_database_data[tostring('-100' .. id_string)].print_name = old_database_data['groups'][id_string].print_name
                                new_database_data[tostring('-100' .. id_string)].old_usernames = old_database_data['groups'][id_string].old_usernames
                                new_database_data[tostring('-100' .. id_string)].username = old_database_data['groups'][id_string].username
                                new_database_data[tostring('-100' .. id_string)].lang = old_database_data['groups'][id_string].lang
                            else
                                -- groups
                                new_database_data[tostring('-' .. id_string)] = { }
                                new_database_data[tostring('-' .. id_string)].old_print_names = old_database_data['groups'][id_string].old_print_names
                                new_database_data[tostring('-' .. id_string)].print_name = old_database_data['groups'][id_string].print_name
                                new_database_data[tostring('-' .. id_string)].lang = old_database_data['groups'][id_string].lang
                            end
                        else
                            return langs[msg.lang].noGroupDataAvailable
                        end
                    end
                end
            end
            if old_database_data['users'] then
                for id_string in pairs(old_database_data['users']) do
                    if old_database_data['users'][id_string] then
                        new_database_data[id_string] = { }
                        new_database_data[id_string].old_print_names = old_database_data['users'][id_string].old_print_names
                        new_database_data[id_string].print_name = old_database_data['users'][id_string].print_name
                        new_database_data[id_string].old_usernames = old_database_data['users'][id_string].old_usernames
                        new_database_data[id_string].username = old_database_data['users'][id_string].username
                    else
                        return langs[msg.lang].noUserDataAvailable
                    end
                end
            end
            save_data(new_database_path, new_database_data)
        else
            return langs[msg.lang].require_sudo
        end
    end
    return langs[msg.lang].migrationCompleted
end

return {
    description = "TGCLI_TO_API_MIGRATION",
    patterns =
    {
        "^[#!/]([Mm][Ii][Gg][Rr][Aa][Tt][Ee])$",
        "^[#!/]([Cc][Oo][Pp][Yy][Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss])$",
        "^[#!/]([Ss][Uu][Dd][Oo][Mm][Ii][Gg][Rr][Aa][Tt][Ee])$",
    },
    run = run,
    min_rank = 3,
    syntax =
    {
        "OWNER",
        "/migrate",
        "/copysettings",
        "SUDO",
        "/sudomigrate",
    },
}