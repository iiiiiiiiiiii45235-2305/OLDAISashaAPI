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
    file = io.open(path, mode)
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
    options.redirect = false
    response = { HTTPS.request(options) }
    local code = response[2]
    local headers = response[3]
    local status = response[4]
    if code ~= 200 then return false, code end

    print("Saved to: " .. file_path)

    file = io.open(file_path, "w+")
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
    file = io.open(file, 'w+')
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
        redis:set('lang:' .. chat_id, 'it')
        lang = 'it'
    end
    return lang
end

function id_to_cli(obj_or_id)
    printvardump(obj_or_id)
    if type(obj_or_id) == 'table' then
        print('table')
        local obj = obj_or_id
        if obj.type then
            if obj.type == 'bot' or obj.type == 'private' or obj.type == 'user' then
                return tonumber(obj.id)
            elseif obj.type == 'group' then
                return tonumber(tostring(obj.id:gsub('-', '')))
            elseif obj.type == 'supergroup' or obj.type == 'channel' then
                return tonumber(tostring(obj.id:gsub('-100', '')))
            end
        end
    else
        print('number or string')
        local id = tostring(obj_or_id)
        local temp = tostring(id:gsub('-100', ''))
        if id == temp then
            temp = tostring(id:gsub('-', ''))
            if id == temp then
                return tonumber(id)
            else
                return tonumber(temp)
            end
        else
            return tonumber(temp)
        end
    end
end