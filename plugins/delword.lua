-- tables that contains 'group_id' = message_id to delete old commands responses
local oldResponses = {
    lastDellist = { },
}

local function get_censorships_hash(msg)
    if msg.chat.type == 'group' then
        return 'group:' .. msg.chat.id .. ':censorships'
    end
    if msg.chat.type == 'supergroup' then
        return 'supergroup:' .. msg.chat.id .. ':censorships'
    end
    return false
end

local function setunset_delword(msg, var_name, time)
    local hash = get_censorships_hash(msg)
    if hash then
        if redis_hget_something(hash, var_name) then
            redis_hdelsrem_something(hash, var_name)
            return langs[msg.lang].delwordRemoved .. var_name
        else
            if time then
                if tonumber(time) == 0 then
                    redis_hset_something(hash, var_name, true)
                else
                    redis_hset_something(hash, var_name, time)
                end
            else
                redis_hset_something(hash, var_name, true)
            end
            return langs[msg.lang].delwordAdded .. var_name
        end
    end
end

local function list_censorships(msg)
    local hash = get_censorships_hash(msg)

    if hash then
        local names = redis_get_something(hash)
        local text = langs[msg.lang].delwordList:gsub('X', msg.chat.print_name or msg.chat.title)
        if names then
            for k, v in pairs(names) do
                text = text .. '\n' .. k
            end
        end
        return text
    end
end

local function run(msg, matches)
    if matches[1]:lower() == 'dellist' then
        if msg.from.is_mod then
            local tmp = oldResponses.lastDellist[tostring(msg.chat.id)]
            oldResponses.lastDellist[tostring(msg.chat.id)] = getMessageId(sendReply(msg, list_censorships(msg)))
            if tmp then
                deleteMessage(msg.chat.id, tmp, true)
            end
            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
        else
            local tmp = ''
            if not sendMessage(msg.from.id, list_censorships(msg)) then
                tmp = getMessageId(sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id))
            else
                tmp = getMessageId(sendReply(msg, langs[msg.lang].generalSendPvt, 'html'))
            end
            io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. ',' .. tmp .. '"')
        end
        return
    end
    if matches[1]:lower() == 'delword' then
        if msg.from.is_mod then
            if pcall( function()
                    string.match(matches[2]:lower(), matches[2]:lower())
                end ) then
                return setunset_delword(msg, matches[2]:lower())
            else
                return langs[msg.lang].errorTryAgain
            end
        else
            return langs[msg.lang].require_mod
        end
    end
end

local function pre_process(msg)
    if msg then
        if data[tostring(msg.chat.id)].settings.locks.delword then
            if not msg.from.is_mod then
                local found = false
                local vars = list_censorships(msg)

                if vars ~= nil then
                    local t = vars:split('\n')
                    for i, word in pairs(t) do
                        local temp = word:lower()
                        if msg.text then
                            if string.match(msg.text:lower(), temp) then
                                found = true
                            end
                        end
                        if found then
                            local hash = get_censorships_hash(msg)
                            local time = redis_hget_something(hash, temp)
                            local text = ''
                            if time == 'true' or time == '0' then
                                deleteMessage(msg.chat.id, msg.message_id)
                            else
                                io.popen('lua timework.lua "deletemessage" "' .. time .. '" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                            end
                            local message_id = getMessageId(sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, data[tostring(msg.chat.id)].settings.locks.delword, langs[msg.lang].reasonLockDelword)))
                            if not data[tostring(msg.chat.id)].settings.groupnotices then
                                io.popen('lua timework.lua "deletemessage" "300" "' .. msg.chat.id .. '" "' ..(message_id or '') .. '"')
                            end
                            return nil
                        end
                    end
                end
            end
        end
        return msg
    end
end

return {
    description = "DELWORD",
    patterns =
    {
        "^[#!/]([Dd][Ee][Ll][Ww][Oo][Rr][Dd]) (.*)$",
        "^[#!/]([Dd][Ee][Ll][Ll][Ii][Ss][Tt])$",
    },
    pre_process = pre_process,
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/dellist",
        "MOD",
        "/delword {word}|{pattern}",
    },
}