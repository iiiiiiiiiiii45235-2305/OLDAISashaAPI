clr = require "term.colors"

last_cron = os.date('%M')
last_db_cron = os.date('%H')
last_administrator_cron = os.date('%d')

-- Save the content of config to config.lua
function save_config()
    serialize_to_file(config, './data/config.lua', false)
    print(clr.white .. 'saved config into ./data/config.lua' .. clr.reset)
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config()
    local f = io.open('./config.lua', "r")
    -- If config.lua doesn't exist
    if not f then
        print(clr.white .. "Created new config file: config.lua" .. clr.reset)
        create_config()
    else
        f:close()
    end
    local config = loadfile("./config.lua")()
    for v, user in pairs(config.sudo_users) do
        print(clr.green .. "Sudo user: " .. user .. clr.reset)
    end
    return config
end

-- Create a basic config.json file and saves it.
function create_config()
    -- A simple config with basic plugins and ourselves as privileged user
    config = {
        bot_api_key = '',
        enabled_plugins =
        {
            'anti_spam',
            'msg_checks',
            'onservice',
            -- THIS HAVE TO BE THE FIRST THREE: IF AN USER IS SPAMMING/IS BLOCKED, THE BOT WON'T GO THROUGH PLUGINS
            'administrator',
            'banhammer',
            'bot',
            'broadcast',
            'check_tag',
            'database',
            'fakecommand',
            'feedback',
            'filemanager',
            'flame',
            'get',
            'goodbyewelcome',
            'group_management',
            'help',
            'info',
            'interact',
            'leave_ban',
            'likecounter',
            'lua_exec',
            'me',
            'plugins',
            'reactions',
            'set',
            'stats',
            'strings',
            'tgcli_to_api_migration',
            'unset',
            'warn',
            'whitelist',
        },
        disabled_plugin_on_chat = { },
        sudo_users = { 41400331, },
        moderation = { data = 'data/moderation.json' },
        likecounter = { db = 'data/likecounterdb.json' },
        database = { db = 'data/database.json' },
        about_text = "AISashaAPI by @EricSolinas based on @GroupButler_bot and @TeleSeed supergroup branch with something taken from @DBTeam.\nThanks guys.",
        log_chat = - 1001043389864,
        vardump_chat = - 167065200,
        api_errors =
        {
            [101] = 'Not enough rights to kick participant',
            -- SUPERGROUP: bot is not admin
            [102] = 'USER_ADMIN_INVALID',
            -- SUPERGROUP: trying to kick an admin
            [103] = 'method is available for supergroup chats only',
            -- NORMAL: trying to unban
            [104] = 'Only creator of the group can kick administrators from the group',
            -- NORMAL: trying to kick an admin
            [105] = 'Bad Request: Need to be inviter of the user to kick it from the group',
            -- NORMAL: bot is not an admin or everyone is an admin
            [106] = 'USER_NOT_PARTICIPANT',
            -- NORMAL: trying to kick an user that is not in the group
            [107] = 'CHAT_ADMIN_REQUIRED',
            -- NORMAL: bot is not an admin or everyone is an admin
            [108] = 'there is no administrators in the private chat',
            -- something asked in a private chat with the api methods 2.1

            [110] = 'PEER_ID_INVALID',
            -- user never started the bot
            [111] = 'message is not modified',
            -- the edit message method hasn't modified the message
            [112] = 'Can\'t parse message text: Can\'t find end of the entity starting at byte offset %d+',
            -- the markdown is wrong and breaks the delivery
            [113] = 'group chat is migrated to a supergroup chat',
            -- group updated to supergroup
            [114] = 'Message can\'t be forwarded',
            -- unknown
            [115] = 'Message text is empty',
            -- empty message
            [116] = 'message not found',
            -- message id invalid, I guess
            [117] = 'chat not found',
            -- I don't know
            [118] = 'Message is too long',
            -- over 4096 char
            [119] = 'User not found',
            -- unknown user_id

            [120] = 'Can\'t parse reply keyboard markup JSON object',
            -- keyboard table invalid
            [121] = 'Field \\\"inline_keyboard\\\" of the InlineKeyboardMarkup should be an Array of Arrays',
            -- inline keyboard is not an array of array
            [122] = 'Can\'t parse inline keyboard button: InlineKeyboardButton should be an Object',
            [123] = 'Bad Request: Object expected as reply markup',
            -- empty inline keyboard table
            [124] = 'QUERY_ID_INVALID',
            -- callback query id invalid
            [125] = 'CHANNEL_PRIVATE',
            -- I don't know
            [126] = 'MESSAGE_TOO_LONG',
            -- text of an inline callback answer is too long
            [127] = 'wrong user_id specified',
            -- invalid user_id
            [128] = 'Too big total timeout [%d%.]+',
            -- something about spam an inline keyboards
            [129] = 'BUTTON_DATA_INVALID',
            -- callback_data string invalid

            [130] = 'Type of file to send mismatch',
            -- trying to send a media with the wrong method
            [131] = 'MESSAGE_ID_INVALID',
            -- I don't know
            [132] = 'Can\'t parse inline keyboard button: Can\'t find field "text"',
            -- the text of a button could be nil

            [403] = 'Bot was blocked by the user',
            -- user blocked the bot
            [429] = 'Too many requests: retry later',
            -- the bot is hitting api limits
            [430] = 'Too big total timeout',
            -- too many callback_data requests
        }
    }
    serialize_to_file(config, './config.lua', false)
    print(clr.white .. 'saved config into ./config.lua' .. clr.reset)
end

-- Enable plugins in config.lua
function load_plugins()
    local index = 0
    for k, v in pairs(config.enabled_plugins) do
        index = index + 1
        print(clr.white .. "Loading plugin", v .. clr.reset)

        local ok, err = pcall( function()
            local t = loadfile("plugins/" .. v .. '.lua')()
            plugins[v] = t
        end )

        if not ok then
            print(clr.red .. 'Error loading plugin ' .. v .. clr.reset)
            print(tostring(clr.red .. io.popen("lua plugins/" .. v .. ".lua"):read('*all') .. clr.reset))
            print(clr.red .. err .. clr.reset)
        end
    end
    print(clr.white .. 'Plugins loaded: ', index .. clr.reset)
    return index
end

function load_database()
    print(clr.white .. 'Loading database.json' .. clr.reset)
    database = load_data(config.database.db)
end

function bot_init()
    config = { }
    bot = nil
    plugins = { }
    database = nil

    config = load_config()
    if config.bot_api_key == '' then
        print(clr.red .. 'API KEY MISSING!' .. clr.reset)
        return
    end
    require("utils")
    require("methods")
    require("ranks")

    while not bot do
        -- Get bot info and retry if unable to connect.
        bot = getMe()
    end
    bot = bot.result

    local tot_plugins = load_plugins()
    load_database()

    print('\n' .. clr.green .. 'BOT RUNNING:\n@' .. bot.username .. '\n' .. bot.first_name .. '\n' .. bot.id .. clr.reset)
    redis:hincrby('bot:general', 'starts', 1)
    sendAdmin('*Bot started!*\n_' .. os.date('On %A, %d %B %Y\nAt %X') .. '_\n' .. tot_plugins .. ' plugins loaded', true)

    -- Generate a random seed and "pop" the first random number. :)
    math.randomseed(os.time())
    math.random()

    last_update = last_update or 0
    -- Set loop variables: Update offset,
    last_cron = last_cron or os.time()
    -- the time of the last cron job,
    is_started = true
    -- whether the bot should be running or not.
end

function adjust_bot(tab)
    tab.type = 'private'
    tab.tg_cli_id = tonumber(tab.id)
    tab.print_name = tab.first_name ..(tab.last_name or '')
    return tab
end

function adjust_user(tab)
    tab.type = 'private'
    tab.tg_cli_id = tonumber(tab.id)
    tab.print_name = tab.first_name ..(tab.last_name or '')
    return tab
end

function adjust_group(tab)
    tab.type = 'group'
    local id_without_minus = tostring(tab.id):gsub('-', '')
    tab.tg_cli_id = tonumber(id_without_minus)
    tab.print_name = tab.title
    return tab
end

function adjust_supergroup(tab)
    local id_without_minus = tostring(tab.id):gsub('-100', '')
    tab.type = 'supergroup'
    tab.tg_cli_id = tonumber(id_without_minus)
    tab.print_name = tab.title
    return tab
end

function adjust_channel(tab)
    local id_without_minus = tostring(tab.id):gsub('-100', '')
    tab.type = 'channel'
    tab.tg_cli_id = tonumber(id_without_minus)
    tab.print_name = tab.title
    return tab
end

-- adjust message for cli plugins
-- recursive to simplify code
function adjust_msg(msg)
    -- sender print_name and tg_cli_id
    msg.from = adjust_user(msg.from)

    if msg.new_chat_participant then
        msg.new_chat_participant = adjust_user(msg.new_chat_participant)
    end
    if msg.new_chat_member then
        msg.new_chat_member = adjust_user(msg.new_chat_member)
    end
    if msg.adder then
        msg.adder = adjust_user(msg.adder)
    end
    if msg.added then
        msg.added = adjust_user(msg.added)
    end
    if msg.left_chat_participant then
        msg.left_chat_participant = adjust_user(msg.left_chat_participant)
    end
    if msg.left_chat_member then
        msg.left_chat_member = adjust_user(msg.left_chat_member)
    end
    if msg.remover then
        msg.remover = adjust_user(msg.remover)
    end
    if msg.removed then
        msg.removed = adjust_user(msg.removed)
    end

    if msg.chat.type then
        if msg.chat.type == 'private' then
            -- private chat
            msg.bot = adjust_bot(bot)
            msg.chat = adjust_user(msg.chat)
            msg.receiver = 'user#id' .. msg.chat.tg_cli_id
        elseif msg.chat.type == 'group' then
            -- group
            msg.chat = adjust_group(msg.chat)
            msg.receiver = 'chat#id' .. msg.chat.tg_cli_id
        elseif msg.chat.type == 'supergroup' then
            -- supergroup
            msg.chat = adjust_supergroup(msg.chat)
            msg.receiver = 'channel#id' .. msg.chat.tg_cli_id
        elseif msg.chat.type == 'channel' then
            -- channel
            msg.chat = adjust_channel(msg.chat)
            msg.receiver = 'channel#id' .. msg.chat.tg_cli_id
        end
    end

    -- if forward adjust forward
    if msg.forward then
        if msg.forward_from then
            msg.forward_from = adjust_user(msg.forward_from)
        elseif msg.forward_from_chat then
            msg.forward_from_chat = adjust_channel(msg.forward_from_chat)
        end
    end

    -- if reply adjust reply
    if msg.reply then
        msg.reply_to_message = adjust_msg(msg.reply_to_message)
    end

    -- group language
    msg.lang = get_lang(msg.chat.id)
    return msg
end

local function collect_stats(msg)
    -- count the number of messages
    redis:hincrby('bot:general', 'messages', 1)

    -- for resolve username
    if msg.from and msg.from.username then
        redis:hset('bot:usernames', '@' .. msg.from.username:lower(), msg.from.id)
        redis:hset('bot:usernames:' .. msg.chat.id, '@' .. msg.from.username:lower(), msg.from.id)
    end
    if msg.forward_from and msg.forward_from.username then
        redis:hset('bot:usernames', '@' .. msg.forward_from.username:lower(), msg.forward_from.id)
        redis:hset('bot:usernames:' .. msg.chat.id, '@' .. msg.forward_from.username:lower(), msg.forward_from.id)
    end

    -- group stats
    if not(msg.chat.type == 'private') then
        -- user in the group stats
        if msg.from.id then
            redis:hset('chat:' .. msg.chat.id .. ':userlast', msg.from.id, os.time())
            -- last message for each user
            redis:hincrby('chat:' .. msg.chat.id .. ':userstats', msg.from.id, 1)
            -- number of messages for each user
            if msg.media then
                redis:hincrby('chat:' .. msg.chat.id .. ':usermedia', msg.from.id, 1)
            end
        end
        redis:incrby('chat:' .. msg.chat.id .. ':totalmsgs', 1)
        -- total number of messages of the group
    end

    -- user stats
    if msg.from then
        redis:hincrby('user:' .. msg.from.id, 'msgs', 1)
        if msg.media then
            redis:hincrby('user:' .. msg.from.id, 'media', 1)
        end
    end

    if msg.cb and msg.from and msg.chat then
        redis:hincrby('chat:' .. msg.chat.id .. ':cb', msg.from.id, 1)
    end
end

local function pre_process_reply(msg)
    if msg.reply_to_message then
        msg.reply = true
    end
    return msg
end

local function pre_process_forward(msg)
    if msg.forward_from or msg.forward_from_chat then
        msg.forward = true
    end
    if msg.reply then
        msg.reply_to_message = pre_process_forward(msg.reply_to_message)
    end
    return msg
end

-- recursive to simplify code
function pre_process_media_msg(msg)
    if msg.photo or msg.video or msg.audio or msg.voice or msg.document or msg.sticker or msg.contact or msg.location then
        msg.media = true
        if msg.photo then
            msg.text = "%[photo%]"
            msg.media_type = 'photo'
        elseif msg.video then
            msg.text = "%[video%]"
            msg.media_type = 'video'
        elseif msg.audio then
            msg.text = "%[audio%]"
            msg.media_type = 'audio'
        elseif msg.voice then
            msg.text = "%[voice%]"
            msg.media_type = 'voice'
        elseif msg.document then
            msg.text = "%[document%]"
            msg.media_type = 'document'
            if msg.document.mime_type == 'video/mp4' then
                msg.text = "%[gif%]"
                msg.media_type = 'gif'
            end
        elseif msg.sticker then
            msg.text = "%[sticker%]"
            msg.media_type = 'sticker'
        elseif msg.contact then
            msg.text = "%[contact%]"
            msg.media_type = 'contact'
        elseif msg.location then
            msg.text = "%[geo%]"
            msg.media_type = 'geo'
        end

        if msg.entities then
            for i, entity in pairs(msg.entities) do
                if entity.type == 'url' then
                    msg.url = true
                    msg.media = true
                    msg.media_type = 'link'
                    break
                end
            end
            if not msg.url then
                msg.media = false
            end
            -- if the entity it's not an url (username/bot command), set msg.media as false
        end
    end
    if msg.reply then
        pre_process_media_msg(msg.reply_to_message)
    end
    return msg
end

function migrate_to_supergroup(msg)
    local old = msg.chat.id
    local new = msg.migrate_to_chat_id
    if not old or not new then
        print('A group id is missing')
        return false
    end

    local data = load_data(config.moderation.data)
    data[tostring(new)] = data[tostring(old)]
    data[tostring(old)] = nil
    data['groups'][tostring(new)] = tonumber(new)
    data['groups'][tostring(old)] = nil

    -- migrate get
    local vars = redis:hgetall('group:' .. old .. ':variables')
    for name, value in pairs(vars) do
        redis:hset('supergroup:' .. new .. ':variables', name, value)
        redis:hdel('group:' .. old .. ':variables', name)
    end

    -- migrate ban
    local banned = redis:smembers('banned:' .. msg.chat.tg_cli_id)
    if next(banned) then
        for i = 1, #banned do
            banUser(msg.chat.id, banned[i])
        end
    end

    -- migrate likes from likecounterdb.json
    local data = load_data(config.likecounter.db)
    if data then
        for id_string in pairs(data) do
            -- if there are any groups check for everyone of them to find the one requesting migration, if found migrate
            if id_string == tostring(old) then
                data[tostring(new)] = data[id_string]
                data[id_string] = nil
            end
        end
    end
    save_data(config.likecounter.db, data)

    -- migrate database from database.json
    local data = load_data(config.database.db)
    if data then
        for id_string in pairs(data) do
            -- if there are any groups move their data from cli to api db
            if id_string == tostring(old) then
                data[tostring(new)] = data[tostring(old)]
                data[tostring(new)].old_usernames = 'NOUSER'
                data[tostring(new)].username = 'NOUSER'
                data[tostring(old)] = nil
            end
        end
    end
    save_data(config.database.db, data)
    sendMessage(new, langs[get_lang(old)].groupToSupergroup)
end

-- recursive to simplify code
function pre_process_service_msg(msg)
    if msg.service or msg.migrate_from_chat_id or msg.pinned_message or msg.new_chat_photo or msg.new_chat_title then
        if msg.service then
            if msg.group_chat_created then
                msg.text = '!!tgservice chat_created'
                msg.service_type = 'chat_created'
            elseif msg.adder and msg.added then
                if msg.adder.id == msg.added.id then
                    msg.text = '!!tgservice chat_add_user_link'
                    msg.service_type = 'chat_add_user_link'
                else
                    msg.text = '!!tgservice chat_add_user'
                    msg.service_type = 'chat_add_user'
                end
            elseif msg.remover and msg.removed then
                if msg.remover.id == msg.removed.id then
                    msg.text = '!!tgservice chat_del_user_leave'
                    msg.service_type = 'chat_del_user_leave'
                else
                    msg.text = '!!tgservice chat_del_user'
                    msg.service_type = 'chat_del_user'
                end
            end
        elseif msg.migrate_from_chat_id then
            msg.text = '!!tgservice migrated_from'
            msg.service_type = 'migrated_from'
            migrate_to_supergroup(msg)
        elseif msg.pinned_message then
            msg.text = '!!tgservice pinned_message'
            msg.service_type = 'pinned_message'
        elseif msg.new_chat_photo then
            msg.text = '!!tgservice chat_change_photo'
            msg.service_type = 'chat_change_photo'
        elseif msg.new_chat_title then
            msg.text = '!!tgservice chat_rename'
            msg.service_type = 'chat_rename'
        end
        msg.service = true
    end
    if msg.reply then
        pre_process_service_msg(msg.reply_to_message)
    end
    return msg
end

function msg_valid(msg)
    if tostring(msg.from.id) == '149998353' then
        print(clr.yellow .. 'Not valid: my user version' .. clr.reset)
        return false
    end

    -- Before bot was started more or less
    if msg.date < os.time() -5 then
        print(clr.yellow .. 'Not valid: old msg' .. clr.reset)
        return false
    end

    if is_channel_disabled(msg.chat.id) and not is_owner(msg) then
        print(clr.yellow .. 'Not valid: channel disabled' .. clr.reset)
        return false
    end

    if isBlocked(msg.from.id) and msg.chat.type == 'private' then
        print(clr.yellow .. 'Not valid: user blocked' .. clr.reset)
        return false
    end

    if msg.chat.id == config.vardump_chat then
        sendMessage(msg.chat.id, vardumptext(msg))
        print(clr.yellow .. 'Not valid: vardump chat' .. clr.reset)
        return false
    end

    return true
end

-- Apply plugin.pre_process function
function pre_process_msg(msg)
    for name, plugin in pairs(plugins) do
        if plugin.pre_process and msg then
            print(clr.white .. 'Preprocess', name)
            msg = plugin.pre_process(msg)
        end
    end
    return msg
end

-- Go over enabled plugins patterns.
function match_plugins(msg)
    for name, plugin in pairs(plugins) do
        match_plugin(plugin, name, msg)
    end
end

-- Check if plugin is on config.disabled_plugin_on_chat table
local function is_plugin_disabled_on_chat(plugin_name, receiver)
    local disabled_chats = config.disabled_plugin_on_chat
    -- Table exists and chat has disabled plugins
    if disabled_chats and disabled_chats[receiver] then
        -- Checks if plugin is disabled on this chat
        for disabled_plugin, disabled in pairs(disabled_chats[receiver]) do
            if disabled_plugin == plugin_name and disabled then
                local warning = 'Plugin ' .. disabled_plugin .. ' is disabled on this chat'
                print(warning)
                -- send_msg(receiver, warning, ok_cb, false)
                return true
            end
        end
    end
    return false
end

function match_plugin(plugin, plugin_name, msg)
    -- Go over patterns. If one matches it's enough.
    for k, pattern in pairs(plugin.patterns) do
        local matches = match_pattern(pattern, msg.text)
        if matches then
            print(clr.magenta .. "msg matches: ", plugin_name, " => ", pattern .. clr.reset)

            local disabled = is_plugin_disabled_on_chat(plugin_name, msg.receiver)

            if pattern ~= "([\216-\219][\128-\191])" and pattern ~= "!!tgservice (.*)" and pattern ~= "%[(document)%]" and pattern ~= "%[(photo)%]" and pattern ~= "%[(video)%]" and pattern ~= "%[(audio)%]" and pattern ~= "%[(contact)%]" and pattern ~= "%[(geo)%]" then
                if msg.chat.type == 'private' then
                    if disabled then
                        savelog(msg.chat.id .. ' PM', msg.chat.print_name:gsub('_', ' ') .. ' ID: ' .. '[' .. msg.chat.tg_cli_id .. ']' .. '\nCommand "' .. msg.text .. '" received but plugin is disabled on chat.')
                    else
                        savelog(msg.chat.id .. ' PM', msg.chat.print_name:gsub('_', ' ') .. ' ID: ' .. '[' .. msg.chat.tg_cli_id .. ']' .. '\nCommand "' .. msg.text .. '" executed.')
                    end
                else
                    if disabled then
                        savelog(msg.chat.id, msg.chat.print_name:gsub('_', ' ') .. ' ID: ' .. '[' .. msg.chat.tg_cli_id .. ']' .. ' Sender: ' .. msg.chat.print_name:gsub('_', ' ') .. ' [' .. msg.chat.tg_cli_id .. ']' .. '\nCommand "' .. msg.text .. '" received but plugin is disabled on chat.')
                    else
                        savelog(msg.chat.id, msg.chat.print_name:gsub('_', ' ') .. ' ID: ' .. '[' .. msg.chat.tg_cli_id .. ']' .. ' Sender: ' .. msg.chat.print_name:gsub('_', ' ') .. ' [' .. msg.chat.tg_cli_id .. ']' .. '\nCommand "' .. msg.text .. '" executed.')
                    end
                end
            end

            if disabled then
                return nil
            end
            -- Function exists
            if plugin.run then
                local result = plugin.run(msg, matches)
                if result then
                    sendMessage(msg.chat.id, result)
                end
            end
            -- One patterns matches
            return
        end
    end
end

function print_msg(msg)
    local hour = os.date('%H')
    local minute = os.date('%M')
    local second = os.date('%S')
    local chat_name = msg.chat.title or(msg.chat.first_name ..(msg.chat.last_name or ''))
    local sender_name = msg.from.title or(msg.from.first_name ..(msg.from.last_name or ''))
    local print_text = clr.cyan .. ' [' .. hour .. ':' .. minute .. ':' .. second .. ']  ' .. chat_name .. ' ' .. clr.reset .. clr.red .. sender_name .. clr.reset .. clr.blue .. ' >>> ' .. clr.reset
    if msg.forward then
        print_text = print_text .. clr.white .. '[forward] ' .. clr.reset
    end
    if msg.reply then
        print_text = print_text .. clr.white .. '[reply] ' .. clr.reset
    end
    if msg.media then
        print_text = print_text .. clr.white .. '[' ..(msg.media_type or 'unsupported') .. '] ' .. clr.reset
        if msg.caption then
            print_text = print_text .. clr.white .. msg.caption .. clr.reset
        end
    end
    if msg.service then
        -- white action reset red name reset
        if msg.service_type == 'chat_del_user' then
            print_text = print_text .. clr.red ..(msg.remover.first_name ..(msg.remover.last_name or '')) .. clr.reset .. clr.white .. ' deleted user ' .. clr.reset .. clr.red ..(msg.removed.first_name ..(msg.removed.last_name or '')) .. clr.reset
        elseif msg.service_type == 'chat_del_user_leave' then
            print_text = print_text .. clr.red ..(msg.remover.first_name ..(msg.remover.last_name or '')) .. clr.reset .. clr.white .. ' left the chat ' .. clr.reset
        elseif msg.service_type == 'chat_add_user' then
            print_text = print_text .. clr.red ..(msg.adder.first_name ..(msg.adder.last_name or '')) .. clr.reset .. clr.white .. ' added user ' .. clr.reset .. clr.red ..(msg.added.first_name ..(msg.added.last_name or '')) .. clr.reset
        elseif msg.service_type == 'chat_add_user_link' then
            print_text = print_text .. clr.red ..(msg.adder.first_name ..(msg.adder.last_name or '')) .. clr.reset .. clr.white .. ' joined chat by invite link ' .. clr.reset
        else
            print_text = print_text .. clr.white .. '[' ..(msg.service_type or 'unsupported') .. '] ' .. clr.reset
        end
    end
    if msg.text then
        print_text = print_text .. clr.blue .. msg.text .. clr.reset
    end
    print(print_text)
    print(msg.chat.id)
end

-- This function is called when tg receive a msg
function on_msg_receive(msg)
    if not is_started then
        return
    end
    if not msg then
        sendAdmin('A loop without msg!')
        return
    end
    collect_stats(msg)
    msg = pre_process_reply(msg)
    msg = pre_process_forward(msg)
    msg = pre_process_media_msg(msg)
    msg = pre_process_service_msg(msg)
    msg = adjust_msg(msg)
    print_msg(msg)
    if msg.text then
        if string.match(msg.text, "^@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt] ") then
            msg.text = msg.text:gsub("^@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt] ", "")
        end
    end
    if msg_valid(msg) then
        msg = pre_process_msg(msg)
        if msg then
            match_plugins(msg)
        end
    end
end

function ok_cb(extra, success, result)
end

-- Call and postpone execution for cron plugins
function cron_plugins()
    if last_cron ~= os.date('%M') then
        -- Run cron jobs every minute.
        last_cron = os.date('%M')
        for name, plugin in ipairs(plugins) do
            if name ~= 'database' and name ~= 'administrator' then
                if plugin.cron then
                    -- Call each plugin's cron function, if it has one.
                    local res, err = pcall( function() plugin.cron() end)
                    if not res then
                        sendLog('An #error occurred.\n' .. err)
                        return
                    end
                end
            end
        end
    end
end

function cron_administrator()
    if last_administrator_cron ~= os.date('%d') then
        -- Run cron jobs every minute.
        last_administrator_cron = os.date('%d')
        for name, plugin in pairs(plugins) do
            -- Only plugins with cron function
            if name == 'administrator' then
                plugin.cron()
            end
        end
    end
end

function cron_database()
    if last_db_cron ~= os.date('%H') then
        -- Run cron jobs every minute.
        last_db_cron = os.date('%H')
        for name, plugin in pairs(plugins) do
            -- Only plugins with cron function
            if name == 'database' then
                plugin.cron()
            end
        end
    end
end

---------WHEN THE BOT IS STARTED FROM THE TERMINAL, THIS IS THE FIRST FUNCTION HE FOUNDS

bot_init() -- Actually start the script. Run the bot_init function.

while is_started do
    -- Start a loop while the bot should be running.
    local res = getUpdates(last_update + 1)
    -- Get the latest updates!
    if res then
        -- printvardump(res)
        for i, msg in ipairs(res.result) do
            -- Go through every new message.
            last_update = msg.update_id
            if msg.message--[[ or msg.callback_query--[[ or msg.edited_message ]] then
                --[[if msg.edited_message then
					msg.message = msg.edited_message
					msg.edited_message = nil
				end]]
                on_msg_receive(msg.message)
            end
        end
    else
        print(clr.red .. 'Connection error' .. clr.reset)
    end
    cron_plugins()
    cron_database()
    cron_administrator()
end

print(clr.white .. 'Halted.' .. clr.reset)

--[[COLORS
  black = "\27[30m",
  blink = "\27[5m",
  blue = "\27[34m",
  bright = "\27[1m",
  clear = "\27[0m",
  cyan = "\27[36m",
  default = "\27[0m",
  dim = "\27[2m",
  green = "\27[32m",
  hidden = "\27[8m",
  magenta = "\27[35m",
  onblack = "\27[40m",
  onblue = "\27[44m",
  oncyan = "\27[46m",
  ongreen = "\27[42m",
  onmagenta = "\27[45m",
  onred = "\27[41m",
  onwhite = "\27[47m",
  onyellow = "\27[43m",
  red = "\27[31m",
  reset = "\27[0m",
  reverse = "\27[7m",
  underscore = "\27[4m",
  white = "\27[37m",
  yellow = "\27[33m"
]]