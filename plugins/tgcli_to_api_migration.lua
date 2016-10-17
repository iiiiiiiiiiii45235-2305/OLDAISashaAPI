local function cli_get_hash(msg)
    if msg.chat.type == 'channel' then
        return 'channel:' .. msg.chat.tg_cli_id .. ':variables'
    end
    if msg.chat.type == 'supergroup' then
        return 'channel:' .. msg.chat.tg_cli_id .. ':variables'
    end
    if msg.chat.type == 'group' then
        return 'chat:' .. msg.chat.tg_cli_id .. ':variables'
    end
    if msg.chat.type == 'private' then
        return 'user:' .. msg.chat.tg_cli_id .. ':variables'
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
    if msg.chat.type == 'channel' then
        return 'channel:' .. msg.chat.id .. ':variables'
    end
    if msg.chat.type == 'supergroup' then
        return 'supergroup:' .. msg.chat.id .. ':variables'
    end
    if msg.chat.type == 'group' then
        return 'group:' .. msg.chat.id .. ':variables'
    end
    if msg.chat.type == 'private' then
        return 'user:' .. msg.chat.id .. ':variables'
    end
    return false
end
local function api_set_value(msg, name, value)
    if (not name or not value) then
        return langs[msg.lang].errorTryAgain
    end

    if api_get_hash(msg) then
        redis:hset(api_get_hash(msg), name:gsub('_', ' '), value)
        return name .. langs[msg.lang].saved
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
            mystat('/migrate')
            local migrated = false
            -- migrate group from moderation.json
            local old_moderation_path = '/home/pi/AISashaExp/data/moderation.json'
            local new_moderation_path = '/home/pi/AISashaAPI/data/moderation.json'
            local old_moderation_data = load_data(old_moderation_path)
            local new_moderation_data = load_data(new_moderation_path)
            if old_moderation_data['groups'] then
                if not new_moderation_data['groups'] then
                    new_moderation_data['groups'] = { }
                end
                for id_string in pairs(old_moderation_data['groups']) do
                    if id_string == msg.chat.tg_cli_id then
                        if old_moderation_data[id_string] then
                            if new_moderation_data[id_string] then
                                return langs[msg.lang].migrationAlreadyExecuted
                            else
                                if old_moderation_data[id_string].group_type == 'SuperGroup' then
                                    new_moderation_data['groups'][tostring('-100' .. id_string)] = tonumber('-100' .. id_string)
                                    new_moderation_data[tostring('-100' .. id_string)] = { }
                                    new_moderation_data[tostring('-100' .. id_string)].goodbye = old_moderation_data[id_string].goodbye or ''
                                    new_moderation_data[tostring('-100' .. id_string)].group_type = old_moderation_data[id_string].group_type
                                    new_moderation_data[tostring('-100' .. id_string)].moderators = old_moderation_data[id_string].moderators
                                    new_moderation_data[tostring('-100' .. id_string)].rules = old_moderation_data[id_string].rules
                                    new_moderation_data[tostring('-100' .. id_string)].set_name = msg.chat.print_name
                                    new_moderation_data[tostring('-100' .. id_string)].set_owner = old_moderation_data[id_string].set_owner
                                    new_moderation_data[tostring('-100' .. id_string)].settings = {
                                        flood = true,
                                        flood_max = 5,
                                        lock_arabic = false,
                                        lock_leave = false,
                                        lock_link = false,
                                        lock_member = false,
                                        lock_rtl = false,
                                        lock_spam = false,
                                        mutes =
                                        {
                                            all = false,
                                            audio = false,
                                            contact = false,
                                            document = false,
                                            gif = false,
                                            location = false,
                                            photo = false,
                                            sticker = false,
                                            text = false,
                                            tgservice = false,
                                            video = false,
                                            voice = false,
                                        },
                                        strict = false,
                                        warn_max = 3,
                                    }
                                    new_moderation_data[tostring('-100' .. id_string)].welcome = old_moderation_data[id_string].welcome or ''
                                    new_moderation_data[tostring('-100' .. id_string)].welcomemembers = old_moderation_data[id_string].welcomemembers or 0
                                    migrated = true
                                end
                                if old_moderation_data[id_string].group_type == 'Group' then
                                    new_moderation_data['groups'][tostring('-' .. id_string)] = tonumber('-' .. id_string)
                                    new_moderation_data[tostring('-' .. id_string)] = { }
                                    new_moderation_data[tostring('-' .. id_string)].goodbye = old_moderation_data[id_string].goodbye or ''
                                    new_moderation_data[tostring('-' .. id_string)].group_type = old_moderation_data[id_string].group_type
                                    new_moderation_data[tostring('-' .. id_string)].moderators = old_moderation_data[id_string].moderators
                                    new_moderation_data[tostring('-' .. id_string)].rules = old_moderation_data[id_string].rules
                                    new_moderation_data[tostring('-' .. id_string)].set_name = msg.chat.print_name
                                    new_moderation_data[tostring('-' .. id_string)].set_owner = old_moderation_data[id_string].set_owner
                                    new_moderation_data[tostring('-' .. id_string)].settings = {
                                        flood = true,
                                        flood_max = 5,
                                        lock_arabic = false,
                                        lock_leave = false,
                                        lock_link = false,
                                        lock_member = false,
                                        lock_rtl = false,
                                        lock_spam = false,
                                        mutes =
                                        {
                                            all = false,
                                            audio = false,
                                            contact = false,
                                            document = false,
                                            gif = false,
                                            location = false,
                                            photo = false,
                                            sticker = false,
                                            text = false,
                                            tgservice = false,
                                            video = false,
                                            voice = false,
                                        },
                                        strict = false,
                                        warn_max = 3,
                                    }
                                    new_moderation_data[tostring('-' .. id_string)].welcome = old_moderation_data[id_string].welcome or ''
                                    new_moderation_data[tostring('-' .. id_string)].welcomemembers = old_moderation_data[id_string].welcomemembers or 0
                                    migrated = true
                                end
                                if not migrated then
                                    return langs[msg.lang].unknownGroupType .. id_string
                                end
                            end
                        else
                            return langs[msg.lang].noGroupDataAvailable
                        end
                    end
                end
            end
            if old_moderation_data['realms'] then
                if not new_moderation_data['realms'] then
                    new_moderation_data['realms'] = { }
                end
                for id_string in pairs(old_moderation_data['realms']) do
                    if old_moderation_data[id_string] then
                        if id_string == msg.chat.tg_cli_id then
                            if old_moderation_data[id_string].group_type == 'Realm' then
                                new_moderation_data['realms'][tostring('-' .. id_string)] = tonumber('-' .. id_string)
                                new_moderation_data[tostring('-' .. id_string)] = { }
                                new_moderation_data[tostring('-' .. id_string)].group_type = old_moderation_data[id_string].group_type
                                new_moderation_data[tostring('-' .. id_string)].set_name = msg.chat.print_name
                                new_moderation_data[tostring('-' .. id_string)].settings = old_moderation_data[id_string].settings
                                migrated = true
                            else
                                if not migrated then
                                    return langs[msg.lang].unknownGroupType .. id_string
                                end
                            end
                        else
                            return langs[msg.lang].unknownGroupType .. id_string
                        end
                    else
                        return langs[msg.lang].noGroupDataAvailable
                    end
                end
            end
            save_data(new_moderation_path, new_moderation_data)

            -- migrate set, get, unset things
            local vars = cli_list_variables(msg)
            if vars ~= nil then
                local t = vars:split('\n')
                local i = 0
                for k, word in pairs(t) do
                    i = i + 1
                    local answer = cli_get_value(msg, word:lower())
                    if answer then
                        api_set_value(msg, word:lower(), answer)
                    end
                end
            end

            -- migrate ban
            local banned = redis:smembers('banned:' .. msg.chat.tg_cli_id)
            if next(banned) then
                for i = 1, #banned do
                    banUser(bot.id, banned[i], msg.chat.id)
                end
            end

            -- migrate likes from likecounterdb.json
            local old_likecounter_path = '/home/pi/AISashaExp/data/likecounterdb.json'
            local new_likecounter_path = '/home/pi/AISashaAPI/data/likecounterdb.json'
            local old_likecounter_data = load_data(old_likecounter_path)
            local new_likecounter_data = load_data(new_likecounter_path)
            if old_likecounter_data['groups'] then
                for id_string in pairs(old_likecounter_data) do
                    -- if there are any groups check for everyone of them to find the one requesting migration, if found migrate
                    if id_string == tostring(msg.chat.tg_cli_id) then
                        if old_likecounter_data[id_string] then
                            new_likecounter_data[tostring(msg.chat.id)] = old_likecounter_data[id_string]
                        else
                            return langs[msg.lang].noGroupDataAvailable
                        end
                    end
                end
            end
            save_data(new_likecounter_path, new_likecounter_data)
            return sendMessage(msg.chat.id, langs[msg.lang].migrationCompleted)
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'sudomigrate' then
        if is_sudo(msg) then
            mystat('/sudomigrate')
            -- migrate database from database.json
            local old_database_path = '/home/pi/AISashaExp/data/database.json'
            local new_database_path = '/home/pi/AISashaAPI/data/database.json'
            local old_database_data = load_data(old_database_path)
            local new_database_data = load_data(new_database_path)
            if old_database_data['groups'] then
                for id_string in pairs(old_database_data['groups']) do
                    -- if there are any groups move their data from cli to api db
                    if id_string == tostring(msg.chat.tg_cli_id) then
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
    return sendMessage(msg.chat.id, langs[msg.lang].migrationCompleted)
end

return {
    description = "TGCLI_TO_API_MIGRATION",
    patterns =
    {
        "^[#!/]([Mm][Ii][Gg][Rr][Aa][Tt][Ee])$",
        "^[#!/]([Ss][Uu][Dd][Oo][Mm][Ii][Gg][Rr][Aa][Tt][Ee])$",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "OWNER",
        "#migrate",
        "SUDO",
        "#sudomigrate",
    },
}