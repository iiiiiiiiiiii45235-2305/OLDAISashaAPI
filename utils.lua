URL = require "socket.url"
http = require "socket.http"
HTTPS = require "ssl.https"
ltn12 = require "ltn12"
curl = require('cURL')

serpent =(loadfile "./libs/serpent.lua")()
json =(loadfile "./libs/JSON.lua")()
mimetype =(loadfile "./libs/mimetype.lua")()
redis =(loadfile "./libs/redis.lua")()
JSON =(loadfile "./libs/dkjson.lua")()
langs = dofile("languages.lua")

http.TIMEOUT = 10

-- custom add
function load_data(filename)
    local f = io.open(filename)
    if not f then
        return { }
    end
    local s = f:read('*all')
    f:close()
    local decodeddata = JSON.decode(s)

    return decodeddata
end

function save_data(filename, data)
    local s = json:encode_pretty(data)
    local f = io.open(filename, 'w')
    f:write(s)
    f:close()
end

function get_word(s, i)
    -- get the indexed word in a string

    s = s or ''
    i = i or 1

    local t = { }
    for w in s:gmatch('%g+') do
        table.insert(t, w)
    end

    return t[i] or false

end

function string:input()
    -- Returns the string after the first space.
    if not self:find(' ') then
        return false
    end
    return self:sub(self:find(' ') + 1)
end

function string:mEscape()
    -- Remove the markdown.
    self = self:gsub('*', '\\*'):gsub('_', '\\_'):gsub('`', '\\`'):gsub('%]', '\\]'):gsub('%[', '\\[')
    return self
end

function string:mEscape_hard()
    -- Remove the markdown.
    self = self:gsub('*', ''):gsub('_', ''):gsub('`', ''):gsub('%[', ''):gsub('%]', '')
    return self
end

function string.random(length)
    local str = "";
    for i = 1, length do
        math.random(97, 122)
        str = str .. string.char(math.random(97, 122));
    end
    return str;
end

function string:split(sep)
    local sep, fields = sep or ":", { }
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

-- DEPRECATED
function string.trim(s)
    print("string.trim(s) is DEPRECATED use string:trim() instead")
    return s:gsub("^%s*(.-)%s*$", "%1")
end

-- Removes spaces
function string:trim()
    return self:gsub("^%s*(.-)%s*$", "%1")
end

-- Returns true if the string is empty
function string:isempty()
    return self == nil or self == ''
end

-- Returns true if the string is blank
function string:isblank()
    self = self:trim()
    return self:isempty()
end

-- DEPRECATED!!!!!
function string.starts(String, Start)
    print("string.starts(String, Start) is DEPRECATED use string:starts(text) instead")
    return Start == string.sub(String, 1, string.len(Start))
end

-- Returns true if String starts with Start
function string:starts(text)
    return text == string.sub(self, 1, string.len(text))
end

function mystat(cmd)
    redis:hincrby('commands:stats', cmd, 1)
end

function printvardump(value)
    print(serpent.block(value, { comment = false }))
end

function vardumptext(value)
    return serpent.block(value, { comment = false })
end

function per_away(text)
    local text = tostring(text):gsub('%%', '£&£')
    return text
end

function make_text(text, par1, par2, par3, par4, par5)
    if par1 then text = text:gsub('&&&1', per_away(par1)) end
    if par2 then text = text:gsub('&&&2', per_away(par2)) end
    if par3 then text = text:gsub('&&&3', per_away(par3)) end
    if par4 then text = text:gsub('&&&4', per_away(par4)) end
    if par5 then text = text:gsub('&&&5', per_away(par5)) end
    text = text:gsub('£&£', '%%')
    return text
end

function write_file(path, text, mode)
    if not mode then
        mode = "w"
    end
    local file = io.open(path, mode)
    if not file then
        create_folder('logs')
        file = io.open(path, mode)
        if not file then
            return false
        end
    end
    file:write(text)
    file:close()
    return true
end

function create_folder(name)
    local cmd = io.popen('sudo mkdir ' .. name)
    cmd:read('*all')
    cmd = io.popen('sudo chmod -R 777 ' .. name)
    cmd:read('*all')
    cmd:close()
end

function savelog(group, logtxt)
    local ok, err = pcall( function()
        local text =(os.date("[ %c ]=>  " .. logtxt .. "\n \n"))
        local file = io.open("./groups/logs/" .. group .. "log.txt", "a")

        file:write(text)
        file:close()
    end )
end

--[[
-- savelog of groupbutler
function savelog(action, arg1, arg2, arg3, arg4)
    if action == 'send_msg' then
        local text = os.date('[%A, %d %B %Y at %X]') .. '\n' .. arg1 .. '\n\n'
        local path = "./logs/msgs_errors.txt"
        local res = write_file(path, text, "a")
        if not res then
            create_folder('logs')
            write_file(path, text, "a")
        end
    elseif action == 'errors' then
        -- error, from, chat, text
        local path = "./logs/errors.txt"
        local text = os.date('[%A, %d %B %Y at %X]') .. '\nERROR: ' .. arg1
        if arg2 then
            text = text .. '\nFROM: ' .. arg2
        end
        if arg3 then
            text = text .. '\nCHAT: ' .. arg3
        end
        if arg4 then
            text = text .. '\nTEXT: ' .. arg4
        end
        text = text .. '\n\n'
        local res = write_file(path, text, "a")
        if not res then
            create_folder('logs')
            write_file(path, text, "a")
        end
    end
end
]]

function clone_table(t)
    -- doing "table1 = table2" in lua = create a pointer to table2
    local new_t = { }
    local i, v = next(t, nil)
    while i do
        new_t[i] = v
        i, v = next(t, i)
    end
    return new_t
end

function remove_duplicates(t)
    if type(t) ~= 'table' then
        return false, 'Table expected, got ' .. type(t)
    else
        local kv_table = { }
        for i, element in pairs(t) do
            if not kv_table[element] then
                kv_table[element] = true
            end
        end

        local k_table = { }
        for key, boolean in pairs(kv_table) do
            k_table[#k_table + 1] = key
        end

        return k_table
    end
end

function get_date(timestamp)
    if not timestamp then
        timestamp = os.time()
    end
    return os.date('%d/%m/%y')
end

function download_to_file(url, file_path)
    -- https://github.com/yagop/telegram-bot/blob/master/bot/utils.lua
    -- print("url to download: "..url)

    local respbody = { }
    local options = {
        url = url,
        sink = ltn12.sink.table(respbody),
        redirect = true
    }
    -- nil, code, headers, status
    local response = nil
    if url:starts('https') then
        options.redirect = false
        response = { HTTPS.request(options) }
    else
        response = { http.request(options) }
    end
    local code = response[2]
    local headers = response[3]
    local status = response[4]
    if code ~= 200 then return false, code end

    print("Saved to: " .. file_path)

    local file = io.open(file_path, "w+")
    file:write(table.concat(respbody))
    file:close()
    return file_path, code
end

function telegram_file_link(res)
    -- res = table returned by getFile()
    return "https://api.telegram.org/file/bot" .. config.bot_api_key .. "/" .. res.result.file_path
end

----------------------- specific cross-plugins functions---------------------
function getUserStatus(chat_id, user_id)
    local res = getChatMember(chat_id, user_id)
    if res then
        return res.result.status
    else
        return false
    end
end

-- taken from http://stackoverflow.com/a/11130774/3163199
function scandir(directory)
    local i = 0
    local t = { }
    for filename in io.popen('ls -a "' .. directory .. '"'):lines() do
        i = i + 1
        t[i] = filename
    end
    return t
end

-- http://www.lua.org/manual/5.2/manual.html#pdf-io.popen
function run_command(str)
    local cmd = io.popen(str)
    local result = cmd:read('*all')
    cmd:close()
    return result
end

-- Returns at table of lua files inside plugins
function plugins_names()
    local files = { }
    for k, v in pairs(scandir("plugins")) do
        -- Ends with .lua
        if (v:match(".lua$")) then
            table.insert(files, v)
        end
    end
    return files
end
-- Returns the key (index) in the config.enabled_plugins table
function plugin_enabled(plugin_name)
    for k, v in pairs(config.enabled_plugins) do
        if plugin_name == v then
            return k
        end
    end
    return false
end
-- Returns true if it is a system plugin
function system_plugin(p)
    if p == 'administrator' or
        p == 'alternatives' or
        p == 'anti_spam' or
        p == 'banhammer' or
        p == 'bot' or
        p == 'check_tag' or
        p == 'database' or
        p == 'feedback' or
        p == 'filemanager' or
        p == 'goodbyewelcome' or
        p == 'group_management' or
        p == 'info' or
        p == 'lua_exec' or
        p == 'msg_checks' or
        p == 'multiple_commands' or
        p == 'plugins' or
        p == 'strings' or
        p == 'tgcli_to_api_migration' or
        p == 'whitelist' then
        return true
    end
    return false
end
function plugin_disabled_on_chat(plugin_name, chat_id)
    if not config.disabled_plugin_on_chat then
        return false
    end
    if not config.disabled_plugin_on_chat[chat_id] then
        return false
    end
    return config.disabled_plugin_on_chat[chat_id][plugin_name]
end

-- Function name explains what it does.
function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- Save into file the data serialized for lua.
-- Set uglify true to minify the file.
function serialize_to_file(data, file, uglify)
    local file = io.open(file, 'w+')
    local serialized
    if not uglify then
        serialized = serpent.block(data, {
            comment = false,
            name = '_'
        } )
    else
        serialized = serpent.dump(data)
    end
    file:write(serialized)
    file:close()
end

-- Parameters in ?a=1&b=2 style
function format_http_params(params, is_get)
    local str = ''
    -- If is get add ? to the beginning
    if is_get then str = '?' end
    local first = true
    -- Frist param
    for k, v in pairs(params) do
        if v then
            -- nil value
            if first then
                first = false
                str = str .. k .. "=" .. v
            else
                str = str .. "&" .. k .. "=" .. v
            end
        end
    end
    return str
end

function is_realm(msg)
    local var = false
    local chat = msg.chat.id
    if data['realms'] then
        if data['realms'][tostring(chat)] then
            var = true
        end
        return var
    end
end

-- Check if this chat is a group or not
function is_group(msg)
    local var = false
    local chat = msg.chat.id
    if data['groups'] then
        if data['groups'][tostring(chat)] then
            if msg.chat.type == 'group' then
                var = true
            end
        end
        return var
    end
end

function is_super_group(msg)
    local var = false
    local chat = msg.chat.id
    if data['groups'] then
        if data['groups'][tostring(chat)] then
            if msg.chat.type == 'supergroup' then
                var = true
            end
            return var
        end
    end
end

function isChatDisabled(chat_id)
    if not config.disabled_channels then
        return false
    end

    if config.disabled_channels[chat_id] == nil then
        return false
    end

    return config.disabled_channels[chat_id]
end

-- Returns a table with matches or nil
function match_pattern(pattern, text, lower_case)
    if text then
        local matches = { }
        if lower_case then
            matches = { string.match(text:lower(), pattern) }
        else
            matches = { string.match(text, pattern) }
        end
        if next(matches) then
            return matches
        end
    end
    -- nil
end

-- Function to read data from files
function load_from_file(file, default_data)
    local f = io.open(file, "r+")
    -- If file doesn't exists
    if f == nil then
        -- Create a new empty table
        default_data = default_data or { }
        serialize_to_file(default_data, file, false)
        print('Created file', file)
    else
        print('Data loaded from file', file)
        f:close()
    end
    return loadfile(file)()
end

-- See http://stackoverflow.com/a/14899740
function unescape_html(str)
    local map = {
        ["lt"] = "<",
        ["gt"] = ">",
        ["amp"] = "&",
        ["quot"] = '"',
        ["apos"] = "'"
    }
    new = string.gsub(str, '(&(#?x?)([%d%a]+);)', function(orig, n, s)
        var = map[s] or n == "#" and string.char(s)
        var = var or n == "#x" and string.char(tonumber(s, 16))
        var = var or orig
        return var
    end )
    return new
end

-- Table Sort
function pairsByKeys(t, f)
    local a = { }
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0
    -- iterator variable
    local iter = function()
        -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end
-- End Table Sort

function get_lang(chat_id)
    local lang = redis:get('lang:' .. chat_id)
    if not lang then
        redis:set('lang:' .. chat_id, 'en')
        lang = 'en'
    end
    return lang
end

function obj_id_to_cli(obj)
    if obj.type then
        if obj.type == 'bot' or obj.type == 'private' or obj.type == 'user' then
            return tostring(obj.id)
        elseif obj.type == 'group' then
            return tostring(obj.id):gsub('-', '')
        elseif obj.type == 'supergroup' or obj.type == 'channel' then
            return tostring(obj.id):gsub('-100', '')
        end
    end
end

function id_to_cli(id)
    local temp = tostring(id):gsub('-100', '')
    if id == temp then
        temp = tostring(id):gsub('-', '')
        if id == temp then
            return tostring(id)
        else
            return tostring(temp)
        end
    else
        return tostring(temp)
    end
end

function doSendBackup()
    local time = os.time()
    local tar_command = 'tar -zcvf backupRaspberryPi' .. time .. '.tar.gz ' ..
    -- desktop
    '/home/pi/Desktop ' ..
    -- sasha user
    '/home/pi/AISasha --exclude=/home/pi/AISasha/.git --exclude=/home/pi/AISasha/.luarocks --exclude=/home/pi/AISasha/patches --exclude=/home/pi/AISasha/tg ' ..
    -- sasha bot
    '/home/pi/AISashaAPI --exclude=/home/pi/AISashaAPI/.git ' ..
    -- bot for reported
    '/home/pi/MyBotForReported  --exclude=/home/pi/MyBotForReported/.git ' ..
    -- redis database
    '/var/lib/redis'
    -- save redis db
    redis:bgsave()
    local log = io.popen('cd "/home/pi/BACKUPS/" && ' .. tar_command):read('*all')
    local file = io.open("/home/pi/BACKUPS/backupLog" .. time .. ".txt", "w")
    file:write(log)
    file:flush()
    file:close()
    -- send last backup
    local files = io.popen('ls "/home/pi/BACKUPS/"'):read("*all"):split('\n')
    local backups = { }
    if files then
        for k, v in pairsByKeys(files) do
            if string.match(v, '^backupRaspberryPi%d+%.tar%.gz$') then
                backups[string.match(v, '%d+')] = v
            end
        end
        local last_backup = ''
        for k, v in pairsByKeys(backups) do
            last_backup = v
        end
        sendDocument_SUDOERS('/home/pi/BACKUPS/' .. last_backup)
    end
end

permissionsDictionary = {
    ["can_change_info"] = "can_change_info",
    ["change_info"] = "can_change_info",
    ["can_delete_messages"] = "can_delete_messages",
    ["delete_messages"] = "can_delete_messages",
    ["can_invite_users"] = "can_invite_users",
    ["invite_users"] = "can_invite_users",
    ["can_restrict_members"] = "can_restrict_members",
    ["restrict_members"] = "can_restrict_members",
    ["can_pin_messages"] = "can_pin_messages",
    ["pin_messages"] = "can_pin_messages",
    ["can_promote_members"] = "can_promote_members",
    ["promote_members"] = "can_promote_members",
}
reversePermissionsDictionary = {
    ["can_change_info"] = "change_info",
    ["change_info"] = "change_info",
    ["can_delete_messages"] = "delete_messages",
    ["delete_messages"] = "delete_messages",
    ["can_invite_users"] = "invite_users",
    ["invite_users"] = "invite_users",
    ["can_restrict_members"] = "restrict_members",
    ["restrict_members"] = "restrict_members",
    ["can_pin_messages"] = "pin_messages",
    ["pin_messages"] = "pin_messages",
    ["can_promote_members"] = "promote_members",
    ["promote_members"] = "promote_members",
}
function adjustPermissions(param_permissions)
    local permissions = {
        ['can_change_info'] = false,
        ['can_delete_messages'] = false,
        ['can_invite_users'] = false,
        ['can_restrict_members'] = false,
        ['can_pin_messages'] = false,
        ['can_promote_members'] = false,
    }
    if param_permissions then
        if type(param_permissions) == 'table' then
            for k, v in pairs(param_permissions) do
                if permissionsDictionary[k] then
                    permissions[tostring(permissionsDictionary[k])] = param_permissions[tostring(permissionsDictionary[k])]
                end
            end
        elseif type(param_permissions) == 'string' then
            param_permissions = param_permissions:lower()
            for k, v in pairs(param_permissions:split(' ')) do
                if permissionsDictionary[v] then
                    permissions[tostring(permissionsDictionary[v])] = true
                end
            end
        end
    end
    return permissions
end

function reverseAdjustSettingType(setting_type)
    if setting_type == 'lock_arabic' then
        setting_type = 'arabic'
    end
    if setting_type == 'lock_bots' then
        setting_type = 'bots'
    end
    if setting_type == 'flood' then
        setting_type = 'flood'
    end
    if setting_type == 'lock_group_link' then
        setting_type = 'grouplink'
    end
    if setting_type == 'lock_leave' then
        setting_type = 'leave'
    end
    if setting_type == 'lock_link' then
        setting_type = 'link'
    end
    if setting_type == 'lock_member' then
        setting_type = 'member'
    end
    if setting_type == 'lock_name' then
        setting_type = 'name'
    end
    if setting_type == 'lock_photo' then
        setting_type = 'photo'
    end
    if setting_type == 'lock_rtl' then
        setting_type = 'rtl'
    end
    if setting_type == 'lock_spam' then
        setting_type = 'spam'
    end
    if setting_type == 'strict' then
        setting_type = 'strict'
    end
    return setting_type
end

restrictionsDictionary = {
    ["can_send_messages"] = "can_send_messages",
    ["send_messages"] = "can_send_messages",
    ["can_send_media_messages"] = "can_send_media_messages",
    ["send_media_messages"] = "can_send_media_messages",
    ["can_send_other_messages"] = "can_send_other_messages",
    ["send_other_messages"] = "can_send_other_messages",
    ["can_add_web_page_previews"] = "can_add_web_page_previews",
    ["add_web_page_previews"] = "can_add_web_page_previews",
}
reverseRestrictionsDictionary = {
    ["can_send_messages"] = "send_messages",
    ["send_messages"] = "send_messages",
    ["can_send_media_messages"] = "send_media_messages",
    ["send_media_messages"] = "send_media_messages",
    ["can_send_other_messages"] = "send_other_messages",
    ["send_other_messages"] = "send_other_messages",
    ["can_add_web_page_previews"] = "add_web_page_previews",
    ["add_web_page_previews"] = "add_web_page_previews",
}
function adjustRestrictions(param_restrictions)
    local restrictions = {
        can_send_messages = true,
        can_send_media_messages = true,
        can_send_other_messages = true,
        can_add_web_page_previews = true
    }
    if param_restrictions then
        if type(param_restrictions) == 'table' then
            for k, v in pairs(param_restrictions) do
                if restrictionsDictionary[k] then
                    restrictions[tostring(restrictionsDictionary[k])] = param_restrictions[tostring(restrictionsDictionary[k])]
                end
            end
        elseif type(param_restrictions) == 'string' then
            param_restrictions = param_restrictions:lower()
            for k, v in pairs(param_restrictions:split(' ')) do
                if restrictionsDictionary[v] then
                    if restrictionsDictionary[v] == 'can_send_messages' then
                        restrictions[restrictionsDictionary[v]] = false
                        restrictions['can_send_media_messages'] = false
                        restrictions['can_send_other_messages'] = false
                        restrictions['can_add_web_page_previews'] = false
                    end
                    if restrictionsDictionary[v] == 'can_send_media_messages' then
                        restrictions[restrictionsDictionary[v]] = false
                        restrictions['can_send_other_messages'] = false
                        restrictions['can_add_web_page_previews'] = false
                    end
                    if restrictionsDictionary[v] == 'can_send_other_messages' then
                        restrictions[restrictionsDictionary[v]] = false
                    end
                    if restrictionsDictionary[v] == 'can_add_web_page_previews' then
                        restrictions[restrictionsDictionary[v]] = false
                    end
                end
            end
        end
    end
    return restrictions
end