-- An empty table for solving multiple kicking problem(thanks to @topkecleon)
kicktable = { }

local TIME_CHECK = 2
-- seconds
-- Save stats, ban user
local function pre_process(msg)
    if msg then
        -- Ignore service msg
        if msg.service then
            for k, v in pairs(msg.added) do
                kicktable[v.id] = false
            end
            return msg
        end

        -- Save chat's total messages
        local hash = 'chatmsgs:' .. msg.chat.id
        if not redis:get(hash) then
            redis:set(hash, 0)
        end
        redis:incr(hash)

        -- Save user on Redis
        if msg.from.type == 'user' then
            local hash = 'user:' .. msg.from.id
            print('Saving user', hash)
            if msg.from.print_name then
                redis:hset(hash, 'print_name', msg.from.print_name)
            end
            if msg.from.first_name then
                redis:hset(hash, 'first_name', msg.from.first_name)
            end
            if msg.from.last_name then
                redis:hset(hash, 'last_name', msg.from.last_name)
            end
        end

        -- Save stats on Redis
        local hash = 'chat:' .. msg.chat.id .. ':users'
        if msg.chat.type == 'private' then
            hash = 'chat:' .. msg.from.id
        end
        redis:sadd(hash, msg.from.id)

        -- Total user msgs
        local hash = 'msgs:' .. msg.from.id .. ':' .. msg.chat.id
        redis:incr(hash)

        if data[tostring(msg.chat.id)] then
            -- Check if flood is on or off
            if not data[tostring(msg.chat.id)].settings.flood then
                return msg
            end
        end

        if not msg.edited then
            -- Check flood
            local hash = 'api:user:' .. msg.from.id .. ':msgs'
            local msgs = tonumber(redis:get(hash) or 0)

            if msg.chat.type == 'private' then
                local max_msg = 7 * 1
                print(msgs)
                if msgs >= max_msg then
                    print("Pass2")
                    -- Block user if spammed in private
                    blockUser(msg.from.id, msg.lang)
                    sendMessage(msg.from.id, langs[msg.lang].user .. "[" .. msg.from.id .. "]" .. langs[msg.lang].blockedForSpam)
                    sendLog(langs[msg.lang].user .. "[" .. msg.from.id .. "]" .. langs[msg.lang].blockedForSpam)
                    savelog(msg.from.id .. " PM", "User [" .. msg.from.id .. "] blocked for spam.")
                end
            else
                local NUM_MSG_MAX = 5
                local strict = false
                if data[tostring(msg.chat.id)] then
                    if data[tostring(msg.chat.id)].settings then
                        if data[tostring(msg.chat.id)].settings.flood_max then
                            NUM_MSG_MAX = tonumber(data[tostring(msg.chat.id)].settings.flood_max)
                            -- Obtain group flood sensitivity
                        end
                        if data[tostring(msg.chat.id)].settings.strict then
                            strict = data[tostring(msg.chat.id)].settings.strict
                        end
                    end
                end
                local max_msg = NUM_MSG_MAX * 1
                if msgs >= max_msg then
                    local user = msg.from.id
                    -- Ignore mods,owner and admins
                    if msg.from.is_mod then
                        return msg
                    end
                    -- Ignore whitelisted
                    if isWhitelisted(msg.chat.tg_cli_id, msg.from.id) then
                        return msg
                    end
                    if kicktable[msg.from.id] == true then
                        local member = getChatMember(msg.chat.id, msg.from.id)
                        if type(member) == 'table' then
                            if member.ok and member.result then
                                if member.result.status == 'left' or member.result.status == 'kicked' then
                                    return
                                else
                                    kicktable[msg.from.id] = false
                                end
                            end
                        end
                    end
                    local text = ''
                    if string.match(getWarn(msg.chat.id), "%d+") then
                        text = warnUser(bot.id, msg.from.id, msg.chat.id)
                        text = text .. '\n' .. kickUser(bot.id, msg.from.id, msg.chat.id)
                    elseif not strict then
                        text = kickUser(bot.id, msg.from.id, msg.chat.id)
                    else
                        text = banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    local username = msg.from.username
                    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
                        if msg.from.username then
                            savelog(msg.chat.id, msg.from.print_name .. " @" .. msg.from.username .. " [" .. msg.from.id .. "] kicked for #spam")
                            sendMessage(msg.chat.id, langs[msg.lang].floodNotAdmitted .. "@" .. msg.from.username .. " [" .. msg.from.id .. "]\n" .. langs[msg.lang].statusRemoved .. " (SPAM)\n" .. text)
                        else
                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] kicked for #spam")
                            sendMessage(msg.chat.id, langs[msg.lang].floodNotAdmitted .. langs[msg.lang].name .. msg.from.print_name .. " [" .. msg.from.id .. "]\n" .. langs[msg.lang].statusRemoved .. " (SPAM)\n" .. text)
                        end
                    end
                    -- incr it on redis
                    local gbanspam = 'gban:spam' .. msg.from.id
                    redis:incr(gbanspam)
                    local gbanspam = 'gban:spam' .. msg.from.id
                    local gbanspamonredis = redis:get(gbanspam)
                    -- Check if user has spammed is group more than 4 times
                    if gbanspamonredis then
                        if tonumber(gbanspamonredis) == 4 and not msg.from.is_owner then
                            -- Global ban that user
                            gbanUser(msg.from.id)
                            local gbanspam = 'gban:spam' .. msg.from.id
                            -- reset the counter
                            redis:set(gbanspam, 0)
                            if msg.from.username ~= nil then
                                username = msg.from.username
                            else
                                username = "---"
                            end
                            -- Send this to that chat
                            sendMessage(msg.chat.id, langs[msg.lang].user .. " [ " .. msg.from.print_name .. " ] " .. msg.from.id .. langs[msg.lang].gbanned .. " (SPAM)")
                            gban_text = langs[msg.lang].user .. " [ " .. msg.from.print_name .. " ] ( @" .. username .. " ) " .. msg.from.id .. langs[msg.lang].gbannedFrom .. " ( " .. msg.chat.print_name .. " ) [ " .. msg.chat.id .. " ] (SPAM)"
                            -- send it to log group/channel
                            sendLog(gban_text)
                        end
                    end
                    kicktable[msg.from.id] = true
                    msg = nil
                end
            end
            redis:setex(hash, TIME_CHECK, msgs + 1)
        end
        return msg
    end
end

local function cron()
    -- clear that table on the top of the plugins
    kicktable = { }
end

return {
    description = "ANTI_SPAM",
    cron = cron,
    patterns = { },
    pre_process = pre_process,
    min_rank = 5,
}