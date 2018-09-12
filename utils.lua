URL = require "socket.url"
http = require "socket.http"
HTTPS = require "ssl.https"
ltn12 = require "ltn12"
curl = require "cURL"

serpent =(loadfile "./libs/serpent.lua")()
json =(loadfile "./libs/JSON.lua")()
mimetype =(loadfile "./libs/mimetype.lua")()
redis =(loadfile "./libs/redis.lua")()
sha2 =(loadfile "./libs/sha2.lua")()

http.TIMEOUT = 10

-- custom add
function load_data(filename)
    local f = io.open(filename)
    if not f then
        return { }
    end
    local s = f:read('*all')
    f:close()
    local decodeddata = json:decode(s)

    return decodeddata
end

function save_data(filename, data, uglify)
    local s
    if not uglify then
        s = json:encode_pretty(data)
    else
        s = json:encode(data)
    end
    if s then
        local f = io.open(filename, 'w')
        f:write(s)
        f:close()
    end
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
    redis_hincr('commands:stats', cmd, 1)
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
    local file_to_write = io.open(path, mode)
    if not file then
        create_folder('logs')
        file_to_write = io.open(path, mode)
        if not file then
            return false
        end
    end
    file_to_write:write(text)
    file_to_write:close()
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
        local file_log = io.open("./groups/logs/" .. group .. "log.txt", "a")

        file_log:write(text)
        file_log:close()
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
    if type(t) ~= 'table' then
        return false, 'Table expected, got ' .. type(t)
    else
        local new_t = { }
        local i, v = next(t, nil)
        while i do
            if t then
                new_t[i] = v
                i, v = next(t, i)
            end
        end
        return new_t
    end
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

    local file_downloaded = io.open(file_path, "w+")
    file_downloaded:write(table.concat(respbody))
    file_downloaded:close()
    return file_path, code
end

function telegram_file_link(res)
    -- res = table returned by getFile()
    return "https://api.telegram.org/file/bot" .. config.bot_api_key .. "/" .. res.result.file_path
end

----------------------- specific cross-plugins functions---------------------
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
        p == 'filemanager' or
        p == 'goodbyewelcome' or
        p == 'group_management' or
        p == 'info' or
        p == 'lua_exec' or
        p == 'msg_checks' or
        p == 'multiple_commands' or
        p == 'plugins' or
        p == 'strings' or
        -- p == 'tgcli_to_api_migration' or
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
    local file_to_write = io.open(file, 'w+')
    local serialized
    if not uglify then
        serialized = serpent.block(data, {
            comment = false,
            name = '_'
        } )
    else
        serialized = serpent.dump(data)
    end
    file_to_write:write(serialized)
    file_to_write:close()
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

function html_escape(str)
    return string.gsub(str, "[}{\">/<'&]", {
        ["&"] = "&amp;",
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ['"'] = "&quot;",
        ["'"] = "&#39;",
        ["/"] = "&#47;"
    } )
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
    local new = string.gsub(str, '(&(#?x?)([%d%a]+);)', function(orig, n, s)
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

function pairsByGroupName(t)
    local list = { }
    for id, value in pairs(t) do
        if tonumber(id) then
            list[#list + 1] = id
        end
    end
    function byval(a, b)
        if t[a] and t[b] then
            if t[a].name and t[b].name then
                return t[a].name < t[b].name
            end
        end
        return false
    end
    table.sort(list, byval)
    local i = 0
    -- iterator variable
    local iter = function()
        -- iterator function
        i = i + 1
        if list[i] == nil then
            return nil
        else
            return list[i], t[list[i]]
        end
    end
    return iter
end
-- End Table Sort

function get_lang(chat_id)
    if not chat_id then
        return 'en'
    end
    if tonumber(chat_id) < 0 then
        if data then
            if data[tostring(chat_id)] then
                data[tostring(chat_id)].lang = data[tostring(chat_id)].lang or 'en'
                return data[tostring(chat_id)].lang
            else
                return 'en'
            end
        else
            return 'en'
        end
    else
        local lang = redis_get_something('lang:' .. chat_id)
        if not lang then
            redis_set_something('lang:' .. chat_id, 'en')
            lang = 'en'
        end
        return lang
    end
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

function executeBackupCommand(tar_command, time)
    print("Executing " .. tar_command)
    local backup_name = string.match(tar_command, 'backup(.*)%d+%.tar%.gz')
    local log = assert(io.popen('cd "/home/pi/BACKUPS/" && ' .. tar_command .. ' && cd "/home/pi/AISashaAPI/"'):read('*all'))
    local file_backup_log = io.open("/home/pi/BACKUPS/backupLog" .. time .. ".txt", "w")
    file_backup_log:write(log)
    file_backup_log:flush()
    file_backup_log:close()
    print("Finished")
    -- send last backup
    local files = io.popen('ls "/home/pi/BACKUPS/"'):read("*all")
    if files then
        files = files:split('\n')
    end
    local backups = { }
    if files then
        for k, v in pairsByKeys(files) do
            if string.match(v, '^backup' .. backup_name .. '%d+%.tar%.gz$') then
                backups[string.match(v, '%d+')] = v
            end
        end
        local last_backup = ''
        for k, v in pairsByKeys(backups) do
            last_backup = v
        end
        sendDocument_SUDOERS('/home/pi/BACKUPS/' .. last_backup)
    end
    return log
end

function doSendBackup()
    -- save redis db
    print("Saving Redis DB")
    redis:bgsave()
    -- save crontab
    print("Saving Crontab")
    io.popen('crontab -l > /home/pi/Desktop/crontab.txt'):read("*all")

    print("Synchronizing time")
    local log = io.popen('sudo ntpdate -s time.nist.gov'):read('*all')
    local time = os.time()

    -- AISASHA
    local AISasha_tar = 'sudo tar -zcvf backupAISasha' .. time .. '.tar.gz ' ..
    '/home/pi/AISasha ' ..
    '/home/pi/.telegram-cli'
    log = log .. '\n' .. executeBackupCommand(AISasha_tar, time)
    -- AISASHAAPI
    local AISashaAPI_tar = 'sudo tar -zcvf backupAISashaAPI' .. time .. '.tar.gz ' ..
    '/home/pi/AISashaAPI '
    log = log .. '\n' .. executeBackupCommand(AISashaAPI_tar, time)
    -- RASPBERRYPI
    local RaspberryPi_tar = 'sudo tar -zcvf backupRaspberryPi' .. time .. '.tar.gz ' ..
    '/home/pi/Desktop ' ..
    '/home/pi/tmux-mem-cpu-load ' ..
    '/home/pi/.tmux.conf ' ..
    '/home/pi/.tmux.conf.local ' ..
    '/home/pi/.vnc/config.d/vncserver-x11 ' ..
    '/etc/ssh/sshd_config ' ..
    '/etc/ssmtp/ssmtp.conf ' ..
    '/var/lib/redis '
    log = log .. '\n' .. executeBackupCommand(RaspberryPi_tar, time)
    -- GRABBER
    local Grabber_tar = 'sudo tar -zcvf backupGrabber' .. time .. '.tar.gz ' ..
    '/home/pi/Grabber '
    log = log .. '\n' .. executeBackupCommand(Grabber_tar, time)
    -- MYBOTFORREPORTED
    local MyBotForReported_tar = 'sudo tar -zcvf backupMyBotForReported' .. time .. '.tar.gz ' ..
    '/home/pi/MyBotForReported '
    log = log .. '\n' .. executeBackupCommand(MyBotForReported_tar, time)
    -- GLOBAL
    local tar = 'sudo tar -zcvf backupRPI' .. time .. '.tar.gz ' ..
    '/home/pi/AISasha ' ..
    '/home/pi/.telegram-cli ' ..
    '/home/pi/AISashaAPI ' ..
    '/home/pi/Desktop ' ..
    '/home/pi/tmux-mem-cpu-load ' ..
    '/home/pi/.tmux.conf ' ..
    '/home/pi/.tmux.conf.local ' ..
    '/home/pi/.vnc/config.d/vncserver-x11 ' ..
    '/etc/ssh/sshd_config ' ..
    '/etc/ssmtp/ssmtp.conf ' ..
    '/var/lib/redis ' ..
    '/home/pi/Grabber ' ..
    '/home/pi/MyBotForReported '
    log = log .. '\n' .. executeBackupCommand(tar, time)
end

function adjustPermissions(param_permissions)
    local permissions = {
        can_change_info = false,
        can_delete_messages = false,
        can_invite_users = false,
        can_restrict_members = false,
        can_pin_messages = false,
        can_promote_members = false,
    }
    if param_permissions then
        if type(param_permissions) == 'table' then
            for k, v in pairs(param_permissions) do
                if permissionsDictionary[k:lower()] then
                    permissions[tostring(permissionsDictionary[k:lower()])] = param_permissions[tostring(permissionsDictionary[k:lower()])]
                end
            end
        elseif type(param_permissions) == 'string' then
            param_permissions = param_permissions:lower()
            for k, v in pairs(param_permissions:split(' ')) do
                if permissionsDictionary[v:lower()] then
                    permissions[tostring(permissionsDictionary[v:lower()])] = true
                end
            end
        end
    end
    return permissions
end

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
                if restrictionsDictionary[k:lower()] then
                    restrictions[tostring(restrictionsDictionary[k:lower()])] = param_restrictions[tostring(restrictionsDictionary[k:lower()])]
                end
            end
        elseif type(param_restrictions) == 'string' then
            param_restrictions = param_restrictions:lower()
            for k, v in pairs(param_restrictions:split(' ')) do
                if restrictionsDictionary[v:lower()] then
                    if restrictionsDictionary[v:lower()] == 'can_send_messages' then
                        restrictions[restrictionsDictionary[v:lower()]] = false
                        restrictions['can_send_media_messages'] = false
                        restrictions['can_send_other_messages'] = false
                        restrictions['can_add_web_page_previews'] = false
                    end
                    if restrictionsDictionary[v:lower()] == 'can_send_media_messages' then
                        restrictions[restrictionsDictionary[v:lower()]] = false
                        restrictions['can_send_other_messages'] = false
                        restrictions['can_add_web_page_previews'] = false
                    end
                    if restrictionsDictionary[v:lower()] == 'can_send_other_messages' then
                        restrictions[restrictionsDictionary[v:lower()]] = false
                    end
                    if restrictionsDictionary[v:lower()] == 'can_add_web_page_previews' then
                        restrictions[restrictionsDictionary[v:lower()]] = false
                    end
                end
            end
        end
    end
    return restrictions
end

function links_to_tdotme(text)
    if text then
        text = text:gsub("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/", 't.me/')
        text = text:gsub("[Tt][Ll][Gg][Rr][Mm]%.[Mm][Ee]/", 't.me/')
        text = text:gsub("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/", 't.me/')
    end
    return text
end

function adjust_plugin_names(p, lang)
    if p == 'administrator' then
        return langs[lang].pluginAdministrator or p or 'ERR'
    elseif p == 'alternatives' then
        return langs[lang].pluginAlternatives or p or 'ERR'
    elseif p == 'anti_spam' then
        return langs[lang].pluginAnti_spam or p or 'ERR'
    elseif p == 'banhammer' then
        return langs[lang].pluginBanhammer or p or 'ERR'
    elseif p == 'bot' then
        return langs[lang].pluginBot or p or 'ERR'
    elseif p == 'check_tag' then
        return langs[lang].pluginCheck_tag or p or 'ERR'
    elseif p == 'database' then
        return langs[lang].pluginDatabase or p or 'ERR'
    elseif p == 'delword' then
        return langs[lang].pluginDelword or p or 'ERR'
    elseif p == 'dogify' then
        return langs[lang].pluginDogify or p or 'ERR'
    elseif p == 'fakecommand' then
        return langs[lang].pluginFakecommand or p or 'ERR'
    elseif p == 'feedback' then
        return langs[lang].pluginFeedback or p or 'ERR'
    elseif p == 'fileconversion' then
        return langs[lang].pluginFileconversion or p or 'ERR'
    elseif p == 'filemanager' then
        return langs[lang].pluginFilemanager or p or 'ERR'
    elseif p == 'flame' then
        return langs[lang].pluginFlame or p or 'ERR'
    elseif p == 'getsetunset' then
        return langs[lang].pluginGetsetunset or p or 'ERR'
    elseif p == 'goodbyewelcome' then
        return langs[lang].pluginGoodbyewelcome or p or 'ERR'
    elseif p == 'group_management' then
        return langs[lang].pluginGroup_management or p or 'ERR'
    elseif p == 'help' then
        return langs[lang].pluginHelp or p or 'ERR'
    elseif p == 'info' then
        return langs[lang].pluginInfo or p or 'ERR'
    elseif p == 'interact' then
        return langs[lang].pluginInteract or p or 'ERR'
    elseif p == 'likecounter' then
        return langs[lang].pluginLikecounter or p or 'ERR'
    elseif p == 'lua_exec' then
        return langs[lang].pluginLua_exec or p or 'ERR'
    elseif p == 'me' then
        return langs[lang].pluginMe or p or 'ERR'
    elseif p == 'msg_checks' then
        return langs[lang].pluginMsg_checks or p or 'ERR'
    elseif p == 'multiple_commands' then
        return langs[lang].pluginMultiple_commands or p or 'ERR'
    elseif p == 'news' then
        return langs[lang].pluginNews or p or 'ERR'
    elseif p == 'plugins' then
        return langs[lang].pluginPlugins or p or 'ERR'
    elseif p == 'pokedex' then
        return langs[lang].pluginPokedex or p or 'ERR'
    elseif p == 'qr' then
        return langs[lang].pluginQr or p or 'ERR'
    elseif p == 'scheduled_commands' then
        return langs[lang].pluginScheduled_commands or p or 'ERR'
    elseif p == 'shout' then
        return langs[lang].pluginShout or p or 'ERR'
    elseif p == 'spam' then
        return langs[lang].pluginSpam or p or 'ERR'
    elseif p == 'stats' then
        return langs[lang].pluginStats or p or 'ERR'
    elseif p == 'strings' then
        return langs[lang].pluginStrings or p or 'ERR'
    elseif p == 'tempmessage' then
        return langs[lang].pluginTempmessage or p or 'ERR'
    elseif p == 'test' then
        return 'TEST' or p or 'ERR'
    elseif p == 'tex' then
        return langs[lang].pluginTex or p or 'ERR'
    elseif p == 'tgcli_to_api_migration' then
        return langs[lang].pluginTgcli_to_api_migration or p or 'ERR'
    elseif p == 'urbandictionary' then
        return langs[lang].pluginUrbandictionary or p or 'ERR'
    elseif p == 'webshot' then
        return langs[lang].pluginWebshot or p or 'ERR'
    elseif p == 'whitelist' then
        return langs[lang].pluginWhitelist or p or 'ERR'
    end
    return 'ERR'
end

function check_chat_msgs(chat_id)
    -- Chat bot msgs in 60 seconds
    local hash = 'bot:' .. chat_id .. ':msgs'
    return tonumber(redis:get(hash) or 0)
end

function check_total_msgs()
    -- Total bot msgs in 1 second
    local hash = 'bot:msgs'
    return tonumber(redis:get(hash) or 0)
end

function msgs_plus_plus(chat_id)
    -- Chat bot msgs in 60 seconds
    local chat_hash = 'bot:' .. chat_id .. ':msgs'
    -- Total bot msgs in 1 second
    local hash = 'bot:msgs'
    local chat_msgs = tonumber(redis:get(chat_hash) or 0)
    local tot_msgs = tonumber(redis:get(hash) or 0)
    redis:setex(chat_hash, 60, chat_msgs + 1)
    redis:setex(hash, 1, tot_msgs + 1)
end

function arePMNoticesEnabled(user_id, chat_id)
    if is_admin2(user_id) then
        return true
    end
    local pm = false
    if redis_get_something('notice:' .. user_id) and sendChatAction(user_id, 'typing', true) then
        pm = true
    end
    if data[tostring(chat_id)] then
        return data[tostring(chat_id)].settings.pmnotices
    else
        return false
    end
    return pm
end

function profileLink(id, name)
    return "<a href=\"tg://user?id=" .. id .. "\">" .. html_escape(name) .. "</a>"
end

function punishmentAction(executer, target, chat_id, punishment, reason, message_id)
    print(executer, target, chat_id, punishment, reason, message_id)
    local lang = get_lang(chat_id)
    local text = ''
    if tonumber(punishment) >= 1 and message_id then
        -- delete
        deleteMessage(chat_id, message_id, true)
    end
    if tonumber(punishment) >= 2 and string.match(getWarn(chat_id), "%d+") then
        -- warn
        text = text .. tostring(warnUser(executer, target, chat_id, reason)) .. '\n'
    end
    if not globalCronTable.punishedTable[tostring(chat_id)][tostring(target)] then
        if tonumber(punishment) == 3 or tonumber(punishment) == 4 then
            if tostring(chat_id):starts('-100') then
                if tonumber(punishment) == 3 and not data[tostring(chat_id)].settings.strict then
                    -- temprestrict
                    text = text .. tostring(restrictUser(executer, target, chat_id, default_restrictions, data[tostring(chat_id)].settings.time_restrict)) .. '\n'
                else
                    -- restrict
                    text = text .. tostring(restrictUser(executer, target, chat_id, default_restrictions)) .. '\n'
                end
            else
                punishment = 7
            end
        end
        if tonumber(punishment) == 5 then
            -- kick
            text = text .. tostring(kickUser(executer, target, chat_id, reason)) .. '\n'
        end
        if tonumber(punishment) == 6 or tonumber(punishment) == 7 then
            if tonumber(punishment) == 6 and tostring(chat_id):starts('-100') and not data[tostring(chat_id)].settings.strict then
                -- tempban
                text = text .. tostring(banUser(executer, target, chat_id, reason, data[tostring(chat_id)].settings.time_ban)) .. '\n'
            else
                -- ban
                text = text .. tostring(banUser(executer, target, chat_id, reason)) .. '\n'
            end
        end
    end
    local chatTag = text:match('(#chat%d+)')
    local userTag = text:match('(#user%d+)')
    local executerTag = text:match('(#executer%d+)')
    text = text:gsub(chatTag .. ' ', '')
    text = text:gsub(userTag .. ' ', '')
    text = text:gsub(executerTag .. ' ', '')
    text = text .. '\n' .. chatTag .. ' ' .. userTag .. ' ' .. executerTag
    return text
end
function adjust_punishment(setting, punishment, change)
    punishment = tonumber(punishment) or 0
    local increment = false
    local decrement = false
    if tostring(change) == '+' then
        punishment = punishment + 1
        increment = true
    elseif tostring(change) == '-' then
        punishment = punishment - 1
        decrement = true
    end
    if punishment == 0 then
        -- if disable
        return false
    end

    if groupDataDictionary[setting] then
        local setting = groupDataDictionary[setting]
        if setting == 'warns_punishment' then
            if punishment < 3 then
                -- if not temprestrict or higher
                if decrement then
                    punishment = 0
                else
                    punishment = 3
                end
            elseif punishment == 5 then
                -- if kick move to tempban
                if decrement then
                    punishment = 4
                else
                    punishment = 6
                end
            end
        elseif setting == 'bots' then
            if punishment < 3 then
                -- if not temprestrict or higher
                if decrement then
                    punishment = 0
                else
                    punishment = 3
                end
            elseif punishment == 5 then
                -- if kick move to tempban
                if decrement then
                    punishment = 4
                else
                    punishment = 6
                end
            end
        elseif setting == 'flood' then
            if punishment < 2 then
                -- if not warn or higher move to warn
                if decrement then
                    punishment = 0
                else
                    punishment = 2
                end
            end
        elseif setting == 'gbanned' then
            if punishment < 4 then
                -- if not restrict or higher move to restrict
                if decrement then
                    punishment = 0
                else
                    punishment = 4
                end
            elseif punishment == 5 then
                -- if kick move to tempban
                if decrement then
                    punishment = 4
                else
                    punishment = 6
                end
            end
        elseif setting == 'leave' then
            if punishment < 3 then
                -- if not temprestrict or higher move to temprestrict
                if decrement then
                    punishment = 0
                else
                    punishment = 3
                end
            elseif punishment == 5 then
                -- if kick move to tempban
                if decrement then
                    punishment = 4
                else
                    punishment = 6
                end
            end
        elseif setting == 'members' then
            if punishment < 3 then
                -- if not temprestrict or higher move to temprestrict
                if decrement then
                    punishment = 0
                else
                    punishment = 3
                end
            elseif punishment == 5 then
                -- if kick move to tempban
                if decrement then
                    punishment = 4
                else
                    punishment = 6
                end
            end
        elseif setting == 'username' then
            if punishment == 5 then
                -- if kick move to tempban
                if decrement then
                    punishment = 4
                else
                    punishment = 6
                end
            end
        elseif setting == 'tgservices' then
            if punishment > 1 then
                -- if not delete disable
                if increment then
                    punishment = 0
                else
                    punishment = 1
                end
            end
        end
    else
        print('not a setting')
        return false
    end

    if tonumber(punishment) < 0 then
        -- if less than disable
        if decrement then
            return 7
        else
            return false
        end
    elseif tonumber(punishment) > 7 then
        -- if more than ban
        if increment then
            return false
        else
            return 7
        end
    end
    -- nothing else to check, return punishment
    return punishment
end
function setPunishment(target, setting_type, punishment)
    punishment = tonumber(punishment) or 0
    if punishment == 0 then
        punishment = false
    end
    local lang = get_lang(target)
    if not tostring(target):starts('-100') and(punishment == 3 or punishment == 4 or punishment == 6) then
        punishment = 7
    end
    if data[tostring(target)].settings[tostring(setting_type)] ~= nil then
        data[tostring(target)].settings[tostring(setting_type)] = punishment
    elseif data[tostring(target)].settings.locks[tostring(setting_type)] ~= nil then
        data[tostring(target)].settings.locks[tostring(setting_type)] = punishment
    elseif data[tostring(target)].settings.mutes[tostring(setting_type)] ~= nil then
        data[tostring(target)].settings.mutes[tostring(setting_type)] = punishment
    else
        return langs[lang].settingNotFound
    end
    save_data(config.moderation.data, data)
    if not punishment then
        return reverseGroupDataDictionary[setting_type] .. langs[lang].nowWillNotBePunished
    else
        return reverseGroupDataDictionary[setting_type] .. langs[lang].nowWillBePunishedWith .. reverse_punishments_table[punishment]
    end
end
function getPunishment(target, setting_type)
    local punishment = false
    if data[tostring(target)].settings[tostring(setting_type)] ~= nil then
        punishment = data[tostring(target)].settings[tostring(setting_type)]
    elseif data[tostring(target)].settings.locks[tostring(setting_type)] ~= nil then
        punishment = data[tostring(target)].settings.locks[tostring(setting_type)]
    elseif data[tostring(target)].settings.mutes[tostring(setting_type)] ~= nil then
        punishment = data[tostring(target)].settings.mutes[tostring(setting_type)]
    end
    return punishment
end

function unixToDate(unix)
    local remainder, weeks, days, hours, minutes, seconds = 0
    weeks = math.floor(unix / 604800)
    remainder = unix % 604800
    days = math.floor(remainder / 86400)
    remainder = remainder % 86400
    hours = math.floor(remainder / 3600)
    remainder = remainder % 3600
    minutes = math.floor(remainder / 60)
    seconds = remainder % 60
    return seconds, minutes, hours, days, weeks
end

function dateToUnix(seconds, minutes, hours, days, weeks)
    local time =((weeks or 0) * 7 * 24 * 60 * 60) +((days or 0) * 24 * 60 * 60) +((hours or 0) * 60 * 60) +((minutes or 0) * 60) +(seconds or 0)
    return time
end

function extractMediaDetails(message)
    if message.media then
        local file_id = ''
        local file_name = ''
        local file_size = ''
        if message.media_type == 'photo' then
            local bigger_pic_id = ''
            local size = 0
            for k, v in pairsByKeys(message.photo) do
                if v.file_size then
                    if v.file_size > size then
                        size = v.file_size
                        bigger_pic_id = v.file_id
                    end
                end
            end
            file_id = bigger_pic_id
            file_name = bigger_pic_id
            file_size = size
            -- document, sticker
        elseif message.media_type == 'audio' then
            file_id = message.audio.file_id
            file_name = message.audio.file_name or message.audio.file_id
            file_size = message.audio.file_size
            -- document, video, video_note, voice
        elseif message.media_type == 'document' then
            file_id = message.document.file_id
            file_name = message.document.file_name or message.document.file_id
            file_size = message.document.file_size
            -- audio, document, photo, sticker, video, video_note, voice
        elseif message.media_type == 'gif' then
            file_id = message.animation.file_id
            file_name = message.animation.file_name or message.animation.file_id
            file_size = message.animation.file_size
            -- document, video, video_note
        elseif message.media_type == 'sticker' then
            file_id = message.sticker.file_id
            file_name = message.sticker.file_name or message.sticker.file_id
            file_size = message.sticker.file_size
            -- document, photo
        elseif message.media_type == 'video' then
            file_id = message.video.file_id
            file_name = message.video.file_name or message.video.file_id
            file_size = message.video.file_size
            -- audio, document, video_note, voice
        elseif message.media_type == 'video_note' then
            file_id = message.video_note.file_id
            file_name = message.video_note.file_name or message.video_note.file_id
            file_size = message.video_note.file_size
            -- audio, document, video, voice
        elseif message.media_type == 'voice_note' then
            file_id = message.voice.file_id
            file_name = message.voice.file_name or message.voice.file_id
            file_size = message.voice.file_size
            -- audio, document, video, video_note
        end
        return file_id, file_name, file_size
    end
end

function getMessageId(object)
    if object.message_id then
        return object.message_id
    elseif object.result then
        if object.result.message_id then
            return object.result.message_id
        end
    end
    return nil
end