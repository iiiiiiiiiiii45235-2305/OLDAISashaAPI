local fake_user_chat = { first_name = 'FAKE', last_name = 'USER CHAT', title = 'FAKE USER CHAT', id = 'FAKE ID' }
clr = require "term.colors"

last_cron = os.date('%M')
last_administrator_cron = os.date('%d')
last_redis_cron = ''
last_redis_administrator_cron = ''

tmp_msg = { }

-- Save the content of config to config.lua
function save_config()
    serialize_to_file(config, './config.lua', false)
    print(clr.white .. 'saved config into ./config.lua' .. clr.reset)
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config()
    local f = io.open('./config.lua', "r")
    -- If config.lua doesn't exist
    if not f then
        create_config()
        print(clr.white .. "Created new config file: config.lua" .. clr.reset)
    else
        f:close()
    end
    local config = loadfile("./config.lua")()
    for k, v in pairs(config.sudo_users) do
        print(clr.green .. "Sudo user: " .. k .. clr.reset)
    end
    return config
end

-- Create a basic config.lua file and saves it.
function create_config()
    -- A simple config with basic plugins and ourselves as privileged user
    local config = {
        bot_api_key = '',
        enabled_plugins =
        {
            'anti_spam',
            'alternatives',
            'msg_checks',
            'administrator',
            'banhammer',
            'bot',
            'check_tag',
            'database',
            'fakecommand',
            'feedback',
            'filemanager',
            'flame',
            'getsetunset',
            'goodbyewelcome',
            'group_management',
            'help',
            'info',
            'interact',
            'likecounter',
            'lua_exec',
            'me',
            'multiple_commands',
            'plugins',
            'stats',
            'strings',
            'tgcli_to_api_migration',
            'whitelist',
        },
        disabled_plugin_on_chat = { },
        sudo_users = { 41400331, },
        alternatives = { db = 'data/alternatives.json' },
        moderation = { data = 'data/moderation.json' },
        likecounter = { db = 'data/likecounterdb.json' },
        database = { db = 'data/database.json' },
        about_text = "AISashaAPI by @EricSolinas based on @GroupButler_bot and @TeleSeed supergroup branch with something taken from @DBTeam.\nThanks guys.",
        log_chat = - 1001043389864,
        vardump_chat = - 167065200,
        channel = '@AISashaChannel',
        -- channel username with the '@'
        help_group = '',
        -- group link, not username!
    }
    serialize_to_file(config, './config.lua', false)
    print(clr.white .. 'saved config into ./config.lua' .. clr.reset)
end

function bot_init()
    config = { }
    bot = nil

    loadfile("./utils.lua")()
    config = load_config()
    local file_bot_api_key = io.open('bot_api_key.txt', "r")
    if file_bot_api_key then
        -- read all contents of file into a string
        config.bot_api_key = file_bot_api_key:read()
        file_bot_api_key:close()
    end
    if config.bot_api_key == '' then
        print(clr.red .. 'API KEY MISSING!' .. clr.reset)
        return
    end
    loadfile("./methods.lua")()
    loadfile("./ranks.lua")()
    loadfile("./keyboards.lua")()

    bot = {
        first_name = "Sasha A.I. BOT",
        id = 283058260,
        is_bot = true,
        link = "t.me/AISashaBot",
        print_name = "Sasha A.I. BOT",
        type = "bot",
        userVersion =
        {
            first_name = "Sasha",
            id = 149998353,
            last_name = "A.I.",
            photo =
            {
                big_file_id = "AQADBAAD-KgxGxHL8AgACBWlRBkABL0Kzoc82qQS8woAAgI",
                small_file_id = "AQADBAAD-KgxGxHL8AgACBWlRBkABKD2Z-Gkcg4f8QoAAgI"
            },
            type = "private",
            username = "AISasha"
        },
        username = "AISashaBot"
    }

    last_update = last_update or 0
    -- Set loop variables: Update offset,
    last_cron = last_cron or os.time()
    -- the time of the last cron job,
    is_started = true
    -- whether the bot should be running or not.
    start_time = os.date('%c')
    langs = dofile('languages.lua')
end

function adjust_user(tab)
    if tab then
        if tab.is_bot then
            tab.type = 'bot'
        else
            tab.type = 'private'
        end
        tab.print_name = tab.first_name
        if tab.last_name then
            tab.print_name = tab.print_name .. ' ' .. tab.last_name
        end
        return tab
    else
        return adjust_user(fake_user_chat)
    end
end

function adjust_group(tab)
    if tab then
        tab.type = 'group'
        tab.print_name = tab.title
        return tab
    else
        return adjust_group(fake_user_chat)
    end
end

function adjust_supergroup(tab)
    if tab then
        tab.type = 'supergroup'
        tab.print_name = tab.title
        return tab
    else
        return adjust_supergroup(fake_user_chat)
    end
end

function adjust_channel(tab)
    if tab then
        tab.type = 'channel'
        tab.print_name = tab.title
        return tab
    else
        return adjust_channel(fake_user_chat)
    end
end

-- adjust message for cli plugins
-- recursive to simplify code
function adjust_msg(msg)
    -- sender print_name
    msg.from = adjust_user(msg.from)
    if msg.adder then
        msg.adder = adjust_user(msg.adder)
    end
    if msg.added then
        for k, v in pairs(msg.added) do
            msg.added[k] = adjust_user(v)
        end
    end
    if msg.remover then
        msg.remover = adjust_user(msg.remover)
    end
    if msg.removed then
        msg.removed = adjust_user(msg.removed)
    end
    if msg.entities then
        for k, v in pairs(msg.entities) do
            if msg.entities[k].user then
                adjust_user(msg.entities[k].user)
            end
        end
    end

    if msg.chat.type then
        if msg.chat.type == 'private' then
            -- private chat
            msg.bot = adjust_user(bot)
            msg.chat = adjust_user(msg.chat)
        elseif msg.chat.type == 'group' then
            -- group
            msg.chat = adjust_group(msg.chat)
        elseif msg.chat.type == 'supergroup' then
            -- supergroup
            msg.chat = adjust_supergroup(msg.chat)
        elseif msg.chat.type == 'channel' then
            -- channel
            msg.chat = adjust_channel(msg.chat)
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

local function update_sudoers(msg)
    if config.sudo_users[tostring(msg.from.id)] then
        config.sudo_users[tostring(msg.from.id)] = clone_table(msg.from)
    end
end

function pre_process_reply(msg)
    if msg.reply_to_message then
        msg.reply = true
    end
    return msg
end

function pre_process_callback(msg)
    if msg.cb_id then
        msg.cb = true
        msg.text = "###cb" .. msg.data
        msg.target_id = msg.data:match('(-%d+)$')
    end
    if msg.reply then
        msg.reply_to_message = pre_process_callback(msg.reply_to_message)
    end
    return msg
end

-- recursive to simplify code
function pre_process_forward(msg)
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
    msg.media = false
    if msg.audio then
        msg.media = true
        msg.text = "%[audio%]"
        msg.media_type = 'audio'
    elseif msg.contact then
        msg.media = true
        msg.text = "%[contact%]"
        msg.media_type = 'contact'
    elseif msg.document then
        msg.media = true
        msg.text = "%[document%]"
        msg.media_type = 'document'
        if msg.document.mime_type == 'video/mp4' then
            msg.text = "%[gif%]"
            msg.media_type = 'gif'
        end
    elseif msg.location then
        msg.media = true
        msg.text = "%[location%]"
        msg.media_type = 'location'
    elseif msg.photo then
        msg.media = true
        msg.text = "%[photo%]"
        msg.media_type = 'photo'
    elseif msg.sticker then
        msg.media = true
        msg.text = "%[sticker%]"
        msg.media_type = 'sticker'
    elseif msg.video then
        msg.media = true
        msg.text = "%[video%]"
        msg.media_type = 'video'
    elseif msg.video_note then
        msg.media = true
        msg.text = "%[video_note%]"
        msg.media_type = 'video_note'
    elseif msg.voice then
        msg.media = true
        msg.text = "%[voice_note%]"
        msg.media_type = 'voice_note'
    end

    if msg.entities then
        for i, entity in pairs(msg.entities) do
            if entity.type == 'url' or entity.type == 'text_link' then
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
    if msg.reply then
        pre_process_media_msg(msg.reply_to_message)
    end
    return msg
end

-- recursive to simplify code
function pre_process_service_msg(msg)
    msg.service = false
    if msg.group_chat_created then
        msg.service = true
        msg.text = '!!tgservice chat_created ' ..(msg.text or '')
        msg.service_type = 'chat_created'
    elseif msg.new_chat_members then
        msg.adder = clone_table(msg.from)
        msg.added = { }
        for k, v in pairs(msg.new_chat_members) do
            if msg.from.id == v.id then
                msg.added[k] = clone_table(msg.from)
            else
                msg.added[k] = clone_table(v)
            end
        end
    elseif msg.new_chat_member then
        msg.adder = clone_table(msg.from)
        msg.added = { }
        if msg.from.id == msg.new_chat_member.id then
            msg.added[1] = clone_table(msg.from)
        else
            msg.added[1] = clone_table(msg.new_chat_member)
        end
    elseif msg.left_chat_member then
        msg.remover = clone_table(msg.from)
        if msg.from.id == msg.left_chat_member.id then
            msg.removed = clone_table(msg.from)
        else
            msg.removed = clone_table(msg.left_chat_member)
        end
    elseif msg.migrate_from_chat_id then
        msg.service = true
        msg.text = '!!tgservice migrated_from ' ..(msg.text or '')
        msg.service_type = 'migrated_from'
        migrate_to_supergroup(msg)
    elseif msg.pinned_message then
        msg.service = true
        msg.text = '!!tgservice pinned_message ' ..(msg.text or '')
        msg.service_type = 'pinned_message'
    elseif msg.delete_chat_photo then
        msg.service = true
        msg.text = '!!tgservice delete_chat_photo ' ..(msg.text or '')
        msg.service_type = 'delete_chat_photo'
    elseif msg.new_chat_photo then
        msg.service = true
        msg.text = '!!tgservice chat_change_photo ' ..(msg.text or '')
        msg.service_type = 'chat_change_photo'
    elseif msg.new_chat_title then
        msg.service = true
        msg.text = '!!tgservice chat_rename ' ..(msg.text or '')
        msg.service_type = 'chat_rename'
    end
    if msg.adder and msg.added then
        msg.service = true
        -- add_user
        if #msg.new_chat_members == 1 then
            if msg.adder.id == msg.added[1].id then
                msg.text = '!!tgservice chat_add_user_link ' ..(msg.text or '')
                msg.service_type = 'chat_add_user_link'
            else
                msg.text = '!!tgservice chat_add_user ' ..(msg.text or '')
                msg.service_type = 'chat_add_user'
            end
        else
            msg.text = '!!tgservice chat_add_users ' ..(msg.text or '')
            msg.service_type = 'chat_add_users'
        end
        msg.new_chat_member = nil
        msg.new_chat_members = nil
        msg.new_chat_participant = nil
    end
    if msg.remover and msg.removed then
        msg.service = true
        -- del_user
        if msg.remover.id == msg.removed.id then
            msg.text = '!!tgservice chat_del_user_leave ' ..(msg.text or '')
            msg.service_type = 'chat_del_user_leave'
        else
            msg.text = '!!tgservice chat_del_user ' ..(msg.text or '')
            msg.service_type = 'chat_del_user'
        end
        msg.left_chat_member = nil
        msg.left_chat_participant = nil
    end
    if msg.reply then
        pre_process_service_msg(msg.reply_to_message)
    end
    return msg
end

---------WHEN THE BOT IS STARTED FROM THE TERMINAL, THIS IS THE FIRST FUNCTION HE FOUNDS

bot_init() -- Actually start the script. Run the bot_init function.

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