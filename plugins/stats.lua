-- Returns a table with `name` and `msgs`
local function get_msgs_user_chat(user_id, chat_id)
    local user_info = { }
    local uhash = 'user:' .. user_id
    local user = redis:hgetall(uhash)
    local um_hash = 'msgs:' .. user_id .. ':' .. chat_id
    user_info.msgs = tonumber(redis:get(um_hash) or 0)
    user_info.name =(user.print_name or '') .. ' [' .. user_id .. ']'
    user_info.id = user_id
    return user_info
end

-- Returns chat's total messages
local function get_msgs_chat(chat_id)
    local hash = 'chatmsgs:' .. chat_id
    local msgs = redis:get(hash)
    if not msgs then
        return 0
    end
    return msgs
end

local function clean_chat_stats(chat_id)
    local hash = 'chat:' .. chat_id .. ':users'
    local users = redis:smembers(hash)

    for i = 1, #users do
        local user_id = users[i]
        redis:set('msgs:' .. user_id .. ':' .. chat_id, 0)
    end

    local hash = 'chatmsgs:' .. chat_id
    redis:set(hash, 0)
end

local function real_chat_stats(chat_id)
    local lang = get_lang(chat_id)
    local chattotal = 0
    local hash = 'chat:' .. chat_id .. ':users'
    local users = redis:smembers(hash)
    local users_info = { }
    local participants = getChatParticipants(chat_id)

    -- Get total messages
    for k, v in pairs(participants) do
        if v.user then
            v = v.user
            chattotal = chattotal + tonumber(redis:get('msgs:' .. v.id .. ':' .. chat_id) or 0)
        end
    end

    -- Get user info
    for k, v in pairs(participants) do
        if v.user then
            v = v.user
            if tonumber(v.id) ~= tonumber(bot.id) then
                local user_id = v.id
                local user_info = get_msgs_user_chat(user_id, chat_id)
                local percentage =(user_info.msgs * 100) / chattotal
                user_info.percentage = string.format('%d', percentage)
                table.insert(users_info, user_info)
            end
        end
    end

    -- Sort users by msgs number
    table.sort(users_info, function(a, b)
        if a.msgs and b.msgs then
            return a.msgs > b.msgs
        end
    end )

    local text = langs[lang].usersInChat .. langs[lang].totalChatMessages .. chattotal .. '\n'
    for kuser, user in pairs(users_info) do
        text = text .. user.name .. ' = ' .. user.msgs .. ' (' .. user.percentage .. '%)\n'
    end
    -- remove rtl
    text = text:gsub("?", "")
    return text
end

local function chat_stats(chat_id, lang)
    -- Users on chat
    local hash = 'chat:' .. chat_id .. ':users'
    local users = redis:smembers(hash)
    local users_info = { }

    -- Get total messages
    local chattotal = get_msgs_chat(chat_id)

    -- Get user info
    for i = 1, #users do
        if tonumber(users[i]) ~= tonumber(bot.id) then
            local user_id = users[i]
            local user_info = get_msgs_user_chat(user_id, chat_id)
            local percentage =(user_info.msgs * 100) / chattotal
            user_info.percentage = string.format('%d', percentage)
            table.insert(users_info, user_info)
        end
    end
    -- Sort users by msgs number
    table.sort(users_info, function(a, b)
        if a.msgs and b.msgs then
            return a.msgs > b.msgs
        end
    end )
    local text = langs[lang].usersInChat .. langs[lang].totalChatMessages .. chattotal .. '\n'
    for k, user in pairs(users_info) do
        text = text .. user.name .. ' = ' .. user.msgs .. ' (' .. user.percentage .. '%)\n'
    end
    local file = io.open("./groups/lists/" .. chat_id .. "stats.txt", "w")
    file:write(text)
    file:flush()
    file:close()
    return
    -- text
end

local function chat_stats2(chat_id, lang)
    -- Users on chat
    local hash = 'chat:' .. chat_id .. ':users'
    local users = redis:smembers(hash)
    local users_info = { }

    -- Get total messages
    local chattotal = get_msgs_chat(chat_id)

    -- Get user info
    for i = 1, #users do
        if tonumber(users[i]) ~= tonumber(bot.id) then
            local user_id = users[i]
            local user_info = get_msgs_user_chat(user_id, chat_id)
            local percentage =(user_info.msgs * 100) / chattotal
            user_info.percentage = string.format('%d', percentage)
            table.insert(users_info, user_info)
        end
    end

    -- Sort users by msgs number
    table.sort(users_info, function(a, b)
        if a.msgs and b.msgs then
            return a.msgs > b.msgs
        end
    end )

    local text = langs[lang].usersInChat .. langs[lang].totalChatMessages .. chattotal .. '\n'
    for k, user in pairs(users_info) do
        text = text .. user.name .. ' = ' .. user.msgs .. ' (' .. user.percentage .. '%)\n'
    end
    return text
end

local function run(msg, matches)
    if matches[1]:lower() == 'aisashabot' then
        mystat('/aisashabot')
        -- Put everything you like :)
        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] used /aisashabot ")
        return config.about_text
    end
    if matches[1]:lower() == "stats" or matches[1]:lower() == "messages" then
        if not matches[2] then
            mystat('/stats')
            if msg.from.is_mod then
                if msg.chat.type ~= 'private' and msg.chat.type ~= 'channel' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group stats ")
                    return langs[msg.lang].useAISasha
                    -- return real_chat_stats(msg.chat.id, msg.lang)
                end
            else
                return langs[msg.lang].require_mod
            end
        elseif matches[2]:lower() == "group" then
            mystat('/stats group <group_id>')
            if is_admin(msg) then
                if msg.chat.type ~= 'private' and msg.chat.type ~= 'channel' then
                    savelog(matches[3], msg.from.print_name .. " [" .. msg.from.id .. "] requested group stats ")
                    return chat_stats2(matches[3], msg.lang)
                end
            else
                return langs[msg.lang].require_admin
            end
        end
        return
    elseif matches[1]:lower() == "statslist" or matches[1]:lower() == "messageslist" then
        if not matches[2] then
            mystat('/statslist')
            if msg.from.is_mod then
                if msg.chat.type ~= 'private' and msg.chat.type ~= 'channel' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] requested group stats ")
                    return langs[msg.lang].useAISasha
                    -- chat_stats(msg.chat.id, msg.lang)
                    -- return sendDocument(msg.chat.id, "./groups/lists/" .. msg.chat.id .. "stats.txt")
                end
            else
                return langs[msg.lang].require_mod
            end
        elseif matches[2]:lower() == "group" then
            mystat('/statslist group <group_id>')
            if is_admin(msg) then
                if msg.chat.type ~= 'private' and msg.chat.type ~= 'channel' then
                    savelog(matches[3], msg.from.print_name .. " [" .. msg.from.id .. "] requested group stats ")
                    chat_stats(matches[3], msg.lang)
                    return sendDocument(msg.chat.id, "./groups/lists/" .. matches[3] .. "stats.txt")
                end
            else
                return langs[msg.lang].require_admin
            end
        end
        return
    elseif matches[1]:lower() == "cleanstats" or matches[1]:lower() == "cleanmessages" then
        if not matches[2] then
            mystat('/cleanstats')
            if msg.from.is_mod then
                if msg.chat.type ~= 'private' and msg.chat.type ~= 'channel' then
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] cleaned group stats ")
                    clean_chat_stats(msg.chat.id)
                    return langs[msg.lang].statsCleaned
                end
            else
                return langs[msg.lang].require_mod
            end
        elseif matches[2]:lower() == "group" then
            mystat('/cleanstats group <group_id>')
            if is_admin(msg) then
                if msg.chat.type ~= 'private' and msg.chat.type ~= 'channel' then
                    savelog(matches[3], msg.from.print_name .. " [" .. msg.from.id .. "] cleaned group stats ")
                    clean_chat_stats(matches[3])
                    return langs[msg.lang].statsCleaned
                end
            else
                return langs[msg.lang].require_admin
            end
        end
        return
    end
end

return {
    description = "STATS",
    patterns =
    {
        "^[#!/]([Ss][Tt][Aa][Tt][Ss])$",
        "^[#!/]([Cc][Ll][Ee][Aa][Nn][Ss][Tt][Aa][Tt][Ss])$",
        "^[#!/]([Ss][Tt][Aa][Tt][Ss][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Ss][Tt][Aa][Tt][Ss]) ([Gg][Rr][Oo][Uu][Pp]) (%-?%d+)$",
        "^[#!/]([Cc][Ll][Ee][Aa][Nn][Ss][Tt][Aa][Tt][Ss]) ([Gg][Rr][Oo][Uu][Pp]) (%-?%d+)$",
        "^[#!/]([Ss][Tt][Aa][Tt][Ss][Ll][Ii][Ss][Tt]) ([Gg][Rr][Oo][Uu][Pp]) (%-?%d+)$",
        "^[#!/]([Bb][Oo][Tt][Ss][Tt][Aa][Tt][Ss])$",
        "^[#!/]?([Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt])$",
        -- stats
        "^[#!/]([Mm][Ee][Ss][Ss][Aa][Gg][Ee][Ss])$",
        "^[#!/]([Mm][Ee][Ss][Ss][Aa][Gg][Ee][Ss]) ([Gg][Rr][Oo][Uu][Pp]) (%-?%d+)$",
        -- cleanstats
        "^[#!/]([Cc][Ll][Ee][Aa][Nn][Mm][Ee][Ss][Ss][Aa][Gg][Ee][Ss])$",
        "^[#!/]([Cc][Ll][Ee][Aa][Nn][Mm][Ee][Ss][Ss][Aa][Gg][Ee][Ss]) ([Gg][Rr][Oo][Uu][Pp]) (%-?%d+)$",
        -- statslist
        "^[#!/]([Mm][Ee][Ss][Ss][Aa][Gg][Ee][Ss][Ll][Ii][Ss][Tt])$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "[#]aisashabot",
        "MOD",
        "(#stats|#statslist|#messages)",
        "(#cleanstats|#cleanmessages)",
        "ADMIN",
        "(#stats|#statslist|#messages) group <group_id>",
        "(#cleanstats|#cleanmessages) group <group_id>",
        "(#stats|#statslist) aisasha",
    },
}