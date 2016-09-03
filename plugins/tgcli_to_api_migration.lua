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
        redis:hset(api_get_hash(msg), name, value)
        return name .. langs[msg.lang].saved
    end
end

local function run(msg, matches)
    if matches[1]:lower() == 'migrate' then
        if is_owner then
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
                        redis:hdel(cli_get_hash(msg), word:lower())
                    end
                end
                sendMessage(msg.chat.id, i .. langs[msg.lang].setsRestored)
            end

            -- migrate likes from likecounterdb.json
            local old_likecounter_path = '/home/pi/AISashaAPI/data/likecounterdb.json'
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
                            -- error no group data found
                        end
                    end
                end
            end
            save_data(new_likecounter_path, new_likecounter_data)
        else
            return langs[msg.lang].require_owner
        end
    end

    if matches[1]:lower() == 'sudomigrate' then
        if is_sudo(msg) then
            -- migrate group from moderation.json
            local old_moderation_path = '/home/pi/AISashaAPI/data/moderation.json'
            local new_moderation_path = '/home/pi/AISashaAPI/data/moderation.json'
            local old_moderation_data = load_data(old_moderation_path)
            local new_moderation_data = load_data(new_moderation_path)
            if old_moderation_data['groups'] then
                for id_string in pairs(old_moderation_data['groups']) do
                    if old_moderation_data[id_string] then
                        if old_moderation_data[id_string].group_type == 'SuperGroup' then
                            new_moderation_data['groups'][tostring('-100' .. id_string)] = '-100' .. id_string
                            new_moderation_data[tostring('-100' .. id_string)].group_type = old_moderation_data[id_string].group_type
                            new_moderation_data[tostring('-100' .. id_string)].moderators = old_moderation_data[id_string].moderators
                            new_moderation_data[tostring('-100' .. id_string)].rules = old_moderation_data[id_string].rules
                            new_moderation_data[tostring('-100' .. id_string)].description = old_moderation_data[id_string].description
                            new_moderation_data[tostring('-100' .. id_string)].set_owner = old_moderation_data[id_string].set_owner
                            new_moderation_data[tostring('-100' .. id_string)].settings = old_moderation_data[id_string].settings
                            new_moderation_data[tostring('-100' .. id_string)].welcome = old_moderation_data[id_string].welcome
                            new_moderation_data[tostring('-100' .. id_string)].welcomemembers = old_moderation_data[id_string].welcomemembers
                            new_moderation_data[tostring('-100' .. id_string)].goodbye = old_moderation_data[id_string].goodbye
                        elseif old_moderation_data[id_string].group_type == 'Group' then
                            new_moderation_data['groups'][tostring('-' .. id_string)] = '-' .. id_string
                            new_moderation_data[tostring('-' .. id_string)].group_type = old_moderation_data[id_string].group_type
                            new_moderation_data[tostring('-' .. id_string)].moderators = old_moderation_data[id_string].moderators
                            new_moderation_data[tostring('-' .. id_string)].rules = old_moderation_data[id_string].rules
                            new_moderation_data[tostring('-' .. id_string)].description = old_moderation_data[id_string].description
                            new_moderation_data[tostring('-' .. id_string)].set_owner = old_moderation_data[id_string].set_owner
                            new_moderation_data[tostring('-' .. id_string)].settings = old_moderation_data[id_string].settings
                            new_moderation_data[tostring('-' .. id_string)].welcome = old_moderation_data[id_string].welcome
                            new_moderation_data[tostring('-' .. id_string)].welcomemembers = old_moderation_data[id_string].welcomemembers
                            new_moderation_data[tostring('-' .. id_string)].goodbye = old_moderation_data[id_string].goodbye
                        else
                            -- error unknown group type .. id_string
                        end
                    else
                        -- error no group data found
                    end
                end
            end
            if old_moderation_data['realms'] then
                for id_string in pairs(old_moderation_data['realms']) do
                    if old_moderation_data[id_string] then
                        new_moderation_data['realms'][tostring('-' .. id_string)] = '-' .. id_string
                        new_moderation_data[tostring('-' .. id_string)].group_type = old_moderation_data[id_string].group_type
                        new_moderation_data[tostring('-' .. id_string)].settings = old_moderation_data[id_string].settings
                    else
                        -- error no group data found
                    end
                end
            end
            save_data(new_moderation_path, new_moderation_data)

            -- migrate database from database.json
            local old_database_path = '/home/pi/AISashaAPI/data/database.json'
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
                                new_database_data[tostring('-100' .. id_string)].old_print_names = old_database_data['groups'][id_string].old_print_names
                                new_database_data[tostring('-100' .. id_string)].print_name = old_database_data['groups'][id_string].print_name
                                new_database_data[tostring('-100' .. id_string)].old_usernames = old_database_data['groups'][id_string].old_usernames
                                new_database_data[tostring('-100' .. id_string)].username = old_database_data['groups'][id_string].username
                                new_database_data[tostring('-100' .. id_string)].lang = old_database_data['groups'][id_string].lang
                            else
                                -- groups
                                new_database_data[tostring('-' .. id_string)].old_print_names = old_database_data['groups'][id_string].old_print_names
                                new_database_data[tostring('-' .. id_string)].print_name = old_database_data['groups'][id_string].print_name
                                new_database_data[tostring('-' .. id_string)].lang = old_database_data['groups'][id_string].lang
                            end
                        else
                            -- error no group data found
                        end
                    end
                end
            end
            if old_database_data['users'] then
                for id_string in pairs(old_database_data['users']) do
                    if old_database_data['users'][id_string] then
                        new_database_data[id_string].old_print_names = old_database_data['users'][id_string].old_print_names
                        new_database_data[id_string].print_name = old_database_data['users'][id_string].print_name
                        new_database_data[id_string].old_usernames = old_database_data['users'][id_string].old_usernames
                        new_database_data[id_string].username = old_database_data['users'][id_string].username
                    else
                        -- error no user data found
                    end
                end
            end
            save_data(new_database_path, new_database_data)
        end
    end
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