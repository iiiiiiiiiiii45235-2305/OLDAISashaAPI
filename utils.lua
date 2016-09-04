URL = require "socket.url"
http = require "socket.http"
HTTPS = require "ssl.https"
ltn12 = require "ltn12"

serpent =(loadfile "./libs/serpent.lua")()
json =(loadfile "./libs/JSON.lua")()
mimetype =(loadfile "./libs/mimetype.lua")()
redis =(loadfile "./libs/redis.lua")()
JSON =(loadfile "./libs/dkjson.lua")()
langs = dofile("languages.lua")
db = Redis.connect('127.0.0.1', 6379)

http.TIMEOUT = 10

-- custom add
function load_data(filename)
    local f = io.open(filename)
    if not f then
        return { }
    end
    local s = f:read('*all')
    f:close()
    local data = JSON.decode(s)

    return data
end

function save_data(filename, data)
    local s = json:encode_pretty(data)
    local f = io.open(filename, 'w')
    f:write(s)
    f:close()
end

function fix_group_id(chat_id)
    return tonumber(tostring('-' .. tostring(chat_id)))
end

function fix_supergroup_channel_id(chat_id)
    return tonumber(tostring('-100' .. tostring(chat_id)))
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

function set_owner(chat_id, user_id, nick)
    redis:hset('chat:' .. chat_id .. ':mod', user_id, nick)
    -- mod
    redis:hset('chat:' .. chat_id .. ':owner', user_id, nick)
    -- owner
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

function res_user(username)
    local hash = 'bot:usernames'
    local stored = redis:hget(hash, username)
    if not stored then
        return false
    else
        return stored
    end
end

function res_user_group(username, chat_id)
    username = username:lower()
    local hash = 'bot:usernames:' .. chat_id
    local stored = redis:hget(hash, username)
    if stored then
        return stored
    else
        hash = 'bot:usernames'
        stored = redis:hget(hash, username)
        if stored then
            return stored
        else
            return false
        end
    end
end

function get_media_type(msg)
    if msg.photo then
        return 'photo'
    elseif msg.video then
        return 'video'
    elseif msg.audio then
        return 'audio'
    elseif msg.voice then
        return 'voice'
    elseif msg.document then
        if msg.document.mime_type == 'video/mp4' then
            return 'gif'
        else
            return 'document'
        end
    elseif msg.sticker then
        return 'sticker'
    elseif msg.contact then
        return 'contact'
    elseif msg.location then
        return 'geo'
    end
    return false
end

function group_table(chat_id)
    local group = {
        id = chat_id
    }

    local redis = {
        hgetall =
        {
            mods = 'chat:' .. chat_id .. ':mod',
            owner = 'chat:' .. chat_id .. ':owner',
            settings = 'chat:' .. chat_id .. ':settings',
            mediasettings = 'chat:' .. chat_id .. ':media',
            flood = 'chat:' .. chat_id .. ':flood',
            extra = 'chat:' .. chat_id .. ':extra',
            welcome = 'chat:' .. chat_id .. ':welcome'
        },
        get =
        {
            about = 'chat:' .. chat_id .. ':about',
            rules = 'chat:' .. chat_id .. ':rules'
        },
        smembers =
        {
            admblock = 'chat:' .. chat_id .. ':reportblocked'
        }
    }

    for k, v in pairs(redis.hgetall) do
        local tab = redis:hgetall(v)
        group[k] = tab
    end
    for k, v in pairs(redis.get) do
        local tab = redis:get(v)
        group[k] = tab
    end
    for k, v in pairs(redis.smembers) do
        local tab = redis:smembers(v)
        group[k] = tab
    end

    return group
end

voice_updated = 0
voice_succ = 0

function give_result(res)
    -- doesn't handle a nil "res"
    if res == 1 then
        voice_succ = voice_succ + 1
        return ' done (res: 1)'
    else
        voice_updated = voice_updated + 1
        return ' updated (res: 0)'
    end
end

function migrate_table(t, hash)
    if not next(t) then
        return '[empty table]\n'
    end
    local txt = ''
    for k, v in pairs(t) do
        txt = txt .. k .. ' (' .. v .. ') [migration:'
        local res = redis:hset(hash, k, v)
        txt = txt .. give_result(res) .. ']\n'
    end
    return txt
end

function div()
    print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
    print('XXXXXXXXXXXXXXXXXX BREAK XXXXXXXXXXXXXXXXXXX')
    print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
end

function getname(msg)
    local name = msg.from.first_name
    if msg.from.username then name = name .. ' (@' .. msg.from.username .. ')' end
    return name
end

function bash(str)
    local cmd = io.popen(str)
    local result = cmd:read('*all')
    cmd:close()
    return result
end

function change_one_header(id)
    voice_succ = 0
    voice_updated = 0
    logtxt = ''
    logtxt = logtxt .. '\n-----------------------------------------------------\nGROUP ID: ' .. id .. '\n'
    print('Group:', id)
    -- first: print this, once the for is done, print logtxt

    logtxt = logtxt .. '---> PORTING MODS...\n'
    local mods = redis:hgetall('bot:' .. id .. ':mod')
    logtxt = logtxt .. migrate_table(mods, 'chat:' .. id .. ':mod')

    logtxt = logtxt .. '---> PORTING OWNER...\n'
    local owner_id = redis:hkeys('bot:' .. id .. ':owner')
    local owner_name = redis:hvals('bot:' .. id .. ':owner')
    if not next(owner_id) or not next(owner_name) then
        logtxt = logtxt .. 'No owner!\n'
    else
        logtxt = logtxt .. 'Owner info: ' .. owner_id[1] .. ', ' .. owner_name[1] .. ' [migration:'
        local res = redis:hset('chat:' .. id .. ':owner', owner_id[1], owner_name[1])
        logtxt = logtxt .. give_result(res) .. '\n'
    end

    logtxt = logtxt .. '---> PORTING MEDIA SETTINGS...\n'
    local media = redis:hgetall('media:' .. id)
    logtxt = logtxt .. migrate_table(media, 'chat:' .. id .. ':media')

    logtxt = logtxt .. '---> PORTING ABOUT...\n'
    local about = redis:get('bot:' .. id .. ':about')
    if not about then
        logtxt = logtxt .. 'No about!\n'
    else
        logtxt = logtxt .. 'About found! [migration:'
        local res = redis:set('chat:' .. id .. ':about', about)
        logtxt = logtxt .. give_result(res) .. ']\n'
    end

    logtxt = logtxt .. '---> PORTING RULES...\n'
    local rules = redis:get('bot:' .. id .. ':rules')
    if not rules then
        logtxt = logtxt .. 'No rules!\n'
    else
        logtxt = logtxt .. 'Rules found!  [migration:'
        local res = redis:set('chat:' .. id .. ':rules', rules)
        logtxt = logtxt .. give_result(res) .. ']\n'
    end

    logtxt = logtxt .. '---> PORTING EXTRA...\n'
    local extra = redis:hgetall('extra:' .. id)
    logtxt = logtxt .. migrate_table(extra, 'chat:' .. id .. ':extra')
    print('\n\n\n')
    logtxt = 'Successful: ' .. voice_succ .. '\nUpdated: ' .. voice_updated .. '\n\n' .. logtxt
    print(logtxt)
    local log_path = "./logs/changehashes" .. id .. ".txt"
    file = io.open(log_path, "w")
    file:write(logtxt)
    file:close()
    for v, user in pairs(config.sudo_users) do
        if user ~= bot.id then
            -- print(text)
            sendDocument(user, log_path)
        end
    end
end

function change_extra_header(id)
    voice_succ = 0
    voice_updated = 0
    logtxt = ''
    logtxt = logtxt .. '\n-----------------------------------------------------\nGROUP ID: ' .. id .. '\n'
    print('Group:', id)
    -- first: print this, once the for is done, print logtxt

    logtxt = logtxt .. '---> PORTING EXTRA...\n'
    local extra = redis:hgetall('extra:' .. id)
    logtxt = logtxt .. migrate_table(extra, 'chat:' .. id .. ':extra')

    print('\n\n\n')

    logtxt = 'Successful: ' .. voice_succ .. '\nUpdated: ' .. voice_updated .. '\n\n' .. logtxt
    print(logtxt)
    local log_path = "./logs/changehashesEXTRA" .. id .. ".txt"
    file = io.open(log_path, "w")
    file:write(logtxt)
    file:close()
    for v, user in pairs(config.sudo_users) do
        if user ~= bot.id then
            -- print(text)
            sendDocument(user, log_path)
        end
    end
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

function initGroup(chat_id)

    -- default settings
    hash = 'chat:' .. chat_id .. ':settings'
    -- disabled for users:yes / disabled for users:no
    redis:hset(hash, 'Rules', 'no')
    redis:hset(hash, 'About', 'no')
    redis:hset(hash, 'Modlist', 'no')
    redis:hset(hash, 'Report', 'yes')
    redis:hset(hash, 'Welcome', 'no')
    redis:hset(hash, 'Extra', 'no')
    redis:hset(hash, 'Flood', 'no')

    -- flood
    hash = 'chat:' .. chat_id .. ':flood'
    redis:hset(hash, 'MaxFlood', 5)
    redis:hset(hash, 'ActionFlood', 'kick')

    -- char
    hash = 'chat:' .. chat_id .. ':char'
    redis:hset(hash, 'Arab', 'allowed')
    redis:hset(hash, 'Rtl', 'allowed')

    -- warn
    redis:set('chat:' .. chat_id .. ':max', 3)
    redis:set('chat:' .. chat_id .. ':warntype', 'ban')

    -- set media values
    hash = 'chat:' .. chat_id .. ':media'
    for i = 1, #config.media_list do
        redis:hset(hash, config.media_list[i], 'allowed')
    end

    -- set the default welcome type
    hash = 'chat:' .. chat_id .. ':welcome'
    redis:hset(hash, 'type', 'composed')
    redis:hset(hash, 'content', 'no')

    -- save group id
    redis:sadd('bot:groupsid', chat_id)

    -- save stats
    hash = 'bot:general'
    local num = redis:hincrby(hash, 'groups', 1)
    print('Stats saved', 'Groups: ' .. num)
end

function addBanList(chat_id, user_id, nick, why)
    local hash = 'chat:' .. chat_id .. ':bannedlist'
    local res, is_id_added = set(hash, user_id, 'nick', nick)
    if why and not(why == '') then
        set(hash, user_id, 'why', why)
    end
    return is_id_added
end

function remBanList(chat_id, user_id)
    if not chat_id or not user_id then return false end
    local hash = 'chat:' .. chat_id .. ':bannedlist'
    local res, des = rem(hash, user_id)
    return res
end

function getUserStatus(chat_id, user_id)
    local res = getChatMember(chat_id, user_id)
    if res then
        return res.result.status
    else
        return false
    end
end

function saveBan(user_id, motivation)
    local hash = 'ban:' .. user_id
    return redis:hincrby(hash, motivation, 1)
end

function is_info_message_key(key)
    if key == 'Modlist' or key == 'Rules' or key == 'About' or key == 'Extra' then
        return true
    else
        return false
    end
end

function get_http_file_name(url, headers)
    -- Eg: foo.var
    local file_name = url:match("[^%w]+([%.%w]+)$")
    -- Any delimited alphanumeric on the url
    file_name = file_name or url:match("[^%w]+(%w+)[^%w]+$")
    -- Random name, hope content-type works
    file_name = file_name or str:random(5)

    local content_type = headers["content-type"]

    local extension = nil
    if content_type then
        extension = mimetype.get_mime_extension(content_type)
    end
    if extension then
        file_name = file_name .. "." .. extension
    end

    local disposition = headers["content-disposition"]
    if disposition then
        -- attachment; filename=CodeCogsEqn.png
        file_name = disposition:match('filename=([^;]+)') or file_name
    end

    return file_name
end

--  Saves file to /tmp/. If file_name isn't provided,
-- will get the text after the last "/" for filename
-- and content-type for extension
function download_to_file(url, file_name)
    print("url to download: " .. url)

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

    if code ~= 200 then return nil end

    file_name = file_name or get_http_file_name(url, headers)

    local file_path = "data/tmp/" .. file_name
    print("Saved to: " .. file_path)

    file = io.open(file_path, "w+")
    file:write(table.concat(respbody))
    file:close()

    return file_path
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

-- Send image to user and delete it when finished.
-- cb_function and extra are optionals callback
function _send_photo(receiver, file_path, cb_function, extra)
    local extra = {
        file_path = file_path,
        cb_function = cb_function,
        extra = extra
    }
    -- Call to remove with optional callback
    send_photo(receiver, file_path, cb_function, extra)
end

-- Download the image and send to receiver, it will be deleted.
-- cb_function and extra are optionals callback
function send_photo_from_url(receiver, url, cb_function, extra)
    local lang = get_lang(string.match(receiver, '%d+'))

    -- If callback not provided
    cb_function = cb_function or ok_cb
    extra = extra or false

    local file_path = download_to_file(url, false)
    if not file_path then
        -- Error
        send_msg(receiver, langs[lang].errorImageDownload, cb_function, extra)
    else
        print("File path: " .. file_path)
        _send_photo(receiver, file_path, cb_function, extra)
    end
end

-- Same as send_photo_from_url but as callback function
function send_photo_from_url_callback(extra, success, result)
    local receiver = extra.receiver
    local url = extra.url

    local lang = get_lang(string.match(receiver, '%d+'))

    local file_path = download_to_file(url, false)
    if not file_path then
        -- Error
        send_msg(receiver, langs[lang].errorImageDownload, ok_cb, false)
    else
        print("File path: " .. file_path)
        _send_photo(receiver, file_path, ok_cb, false)
    end
end

--  Send multiple images asynchronous.
-- param urls must be a table.
function send_photos_from_url(receiver, urls)
    local extra = {
        receiver = receiver,
        urls = urls,
        remove_path = nil
    }
    send_photos_from_url_callback(extra)
end

-- Use send_photos_from_url.
-- This function might be difficult to understand.
function send_photos_from_url_callback(extra, success, result)
    -- extra is a table containing receiver, urls and remove_path
    local receiver = extra.receiver
    local urls = extra.urls
    local remove_path = extra.remove_path

    -- The previously image to remove
    if remove_path ~= nil then
        os.remove(remove_path)
        print("Deleted: " .. remove_path)
    end

    -- Nil or empty, exit case (no more urls)
    if urls == nil or #urls == 0 then
        return false
    end

    -- Take the head and remove from urls table
    local head = table.remove(urls, 1)

    local file_path = download_to_file(head, false)
    local extra = {
        receiver = receiver,
        urls = urls,
        remove_path = file_path
    }

    -- Send first and postpone the others as callback
    send_photo(receiver, file_path, send_photos_from_url_callback, extra)
end

-- Callback to remove a file
function rmtmp_cb(extra, success, result)
    local file_path = extra.file_path
    local cb_function = extra.cb_function or ok_cb
    local extra = extra.extra

    if file_path ~= nil then
        os.remove(file_path)
        print("Deleted: " .. file_path)
    end
    -- Finally call the callback
    cb_function(extra, success, result)
end

-- Send document to user and delete it when finished.
-- cb_function and extra are optionals callback
function _send_document(receiver, file_path, cb_function, extra)
    local extra = {
        file_path = file_path,
        cb_function = cb_function or ok_cb,
        extra = extra or false
    }
    -- Call to remove with optional callback
    send_document(receiver, file_path, rmtmp_cb, extra)
end

-- Download the image and send to receiver, it will be deleted.
-- cb_function and extra are optionals callback
function send_document_from_url(receiver, url, cb_function, extra)
    local file_path = download_to_file(url, false)
    print("File path: " .. file_path)
    _send_document(receiver, file_path, cb_function, extra)
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
    local realms = 'realms'
    local data = load_data(config.moderation.data)
    local chat = msg.chat.id
    if data[tostring(realms)] then
        if data[tostring(realms)][tostring(chat)] then
            var = true
        end
        return var
    end
end

-- Check if this chat is a group or not
function is_group(msg)
    local var = false
    local data = load_data(config.moderation.data)
    local groups = 'groups'
    local chat = msg.chat.id
    if data[tostring(groups)] then
        if data[tostring(groups)][tostring(chat)] then
            if msg.chat.type == 'group' then
                var = true
            end
        end
        return var
    end
end

function is_super_group(msg)
    local var = false
    local data = load_data(config.moderation.data)
    local groups = 'groups'
    local chat = msg.chat.id
    if data[tostring(groups)] then
        if data[tostring(groups)][tostring(chat)] then
            if msg.chat.type == 'supergroup' then
                var = true
            end
            return var
        end
    end
end

function is_channel_disabled(receiver)
    if not config.disabled_channels then
        return false
    end

    if config.disabled_channels[receiver] == nil then
        return false
    end

    return config.disabled_channels[receiver]
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
        if not next(matches) then
            if lower_case then
                matches = { string.match(text:lower(), "^@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt] " .. pattern:gsub('%^', '')) }
            else
                matches = { string.match(text, "^@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt] " .. pattern:gsub('%^', '')) }
            end
            if next(matches) then
                return matches
            end
        else
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

-- Check if this chat is a group or not
function is_our_group(msg)
    local var = false
    local data = load_data(config.moderation.data)
    local groups = 'groups'
    local chat = msg.chat.tg_cli_id
    if data[tostring(groups)] then
        if data[tostring(groups)][tostring(chat)] then
            if msg.chat.type == 'group' then
                var = true
            end
        end
        return var
    end
end

function is_our_super_group(msg)
    local var = false
    local data = load_data(config.moderation.data)
    local groups = 'groups'
    local chat = msg.chat.tg_cli_id
    if data[tostring(groups)] then
        if data[tostring(groups)][tostring(chat)] then
            if msg.chat.type == 'supergroup' then
                var = true
            end
            return var
        end
    end
end

function is_our_log_group(msg)
    local var = false
    local data = load_data(config.moderation.data)
    local GBan_log = 'GBan_log'
    if data[tostring(GBan_log)] then
        if data[tostring(GBan_log)][tostring(msg.chat.tg_cli_id)] then
            if msg.chat.type == 'supergroup' then
                var = true
            end
            return var
        end
    end
end

function get_lang(chat_id)
    local lang = redis:get('lang:' .. chat_id)
    if not lang then
        redis:set('lang:' .. chat_id, 'it')
        lang = 'it'
    end
    return lang
end