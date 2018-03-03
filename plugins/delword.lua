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
        if redis:hget(hash, var_name) then
            redis:hdel(hash, var_name)
            return langs[msg.lang].delwordRemoved .. var_name
        else
            if time then
                if tonumber(time) == 0 then
                    redis:hset(hash, var_name, true)
                else
                    redis:hset(hash, var_name, time)
                end
            else
                redis:hset(hash, var_name, true)
            end
            return langs[msg.lang].delwordAdded .. var_name
        end
    end
end

local function list_censorships(msg)
    local hash = get_censorships_hash(msg)

    if hash then
        local names = redis:hkeys(hash)
        local text = langs[msg.lang].delwordList
        for i = 1, #names do
            text = text .. names[i] .. '\n'
        end
        return text
    end
end

local function run(msg, matches)
    if matches[1]:lower() == 'dellist' then
        if msg.from.is_mod then
            return list_censorships(msg)
        else
            if not sendMessage(msg.from.id, list_censorships(msg)) then
                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
            end
            local tmp = sendReply(msg, langs[msg.lang].generalSendPvt, 'html').result.message_id
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
                        if msg.media then
                            if msg.caption then
                                if string.match(msg.caption:lower(), temp) then
                                    found = true
                                end
                            end
                        end
                        if found then
                            local hash = get_censorships_hash(msg)
                            local time = redis:hget(hash, temp)
                            local text = ''
                            if time == 'true' or time == '0' then
                                text = punishmentAction(bot.id, msg.from.id, msg.chat.id, data[tostring(msg.chat.id)].settings.locks.delword, langs[msg.lang].reasonLockDelword, msg.message_id)
                            else
                                io.popen('lua timework.lua "deletemessage" "' .. time .. '" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                                text = punishmentAction(bot.id, msg.from.id, msg.chat.id, data[tostring(msg.chat.id)].settings.locks.delword, langs[msg.lang].reasonLockDelword)
                            end
                            if text ~= '' then
                                sendMessage(msg.chat.id, text)
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