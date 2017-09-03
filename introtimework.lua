clr = require "term.colors"

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
    for v, user in pairs(config.sudo_users) do
        print(clr.green .. "Sudo user: " .. user .. clr.reset)
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

    require("utils")
    config = load_config()
    local file = io.open('bot_api_key.txt', "r")
    if file then
        -- read all contents of file into a string
        config.bot_api_key = file:read()
        file:close()
    end
    if config.bot_api_key == '' then
        print(clr.red .. 'API KEY MISSING!' .. clr.reset)
        return
    end
    require("methods")
    require("ranks")

    last_update = last_update or 0
    -- Set loop variables: Update offset,
    last_cron = last_cron or os.time()
    -- the time of the last cron job,
    is_started = true
    -- whether the bot should be running or not.
    start_time = os.date('%c')
end

---------WHEN THE BOT IS STARTED FROM THE TERMINAL, THIS IS THE FIRST FUNCTION HE FOUNDS

bot_init() -- Actually start the script. Run the bot_init function.

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