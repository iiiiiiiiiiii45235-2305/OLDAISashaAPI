local function like(likedata, chat, user)
    chat = tostring(chat)
    user = tostring(user)
    if user ~= tostring(bot.id) then
        if not likedata[chat] then
            likedata[chat] = { }
        end
        if not likedata[chat][user] then
            likedata[chat][user] = 0
        end
        likedata[chat][user] = tonumber(likedata[chat][user] + 1)
        save_data(config.likecounter.db, likedata)
    end
end

local function dislike(likedata, chat, user)
    chat = tostring(chat)
    user = tostring(user)
    if user ~= tostring(bot.id) then
        if not likedata[chat] then
            likedata[chat] = { }
        end
        if not likedata[chat][user] then
            likedata[chat][user] = 0
        end
        likedata[chat][user] = tonumber(likedata[chat][user] -1)
        save_data(config.likecounter.db, likedata)
    end
end

-- Returns a table with `name`
local function get_name(user_id)
    local user_info = { }
    local uhash = 'user:' .. user_id
    local user = redis:hgetall(uhash)
    user_info.name = user.print_name or ''
    return user_info
end

local function likes_leaderboard(users, lang)
    local users_info = { }

    -- Get user name and param
    for k, user in pairs(users) do
        if user then
            local user_info = get_name(k)
            user_info.param = tonumber(user)
            table.insert(users_info, user_info)
        end
    end

    -- Sort users by param
    table.sort(users_info, function(a, b)
        if a.param and b.param then
            return a.param > b.param
        end
    end )

    local text = langs[lang].likesLeaderboard
    local i = 0
    for k, user in pairs(users_info) do
        if user.name and user.param then
            i = i + 1
            text = text .. i .. '. ' .. user.name .. ' => ' .. user.param .. '\n'
        end
    end
    return text
end

local function run(msg, matches)
    if msg.chat.type ~= 'user' then
        if matches[1]:lower() == 'createlikesdb' then
            mystat('/createlikesdb')
            if is_sudo(msg) then
                local f = io.open(config.likecounter.db, 'w+')
                f:write('{}')
                f:close()
                return langs[msg.lang].likesdbCreated
            else
                return langs[msg.lang].require_sudo
            end
        end

        local likedata = load_data(config.likecounter.db)

        if not likedata[tostring(msg.chat.id)] then
            likedata[tostring(msg.chat.id)] = { }
            save_data(config.likecounter.db, likedata)
        end

        if matches[1]:lower() == 'addlikes' and matches[2] and matches[3] and is_sudo(msg) then
            mystat('/addlikes')
            likedata[tostring(msg.chat.id)][matches[2]] = tonumber(likedata[tostring(msg.chat.id)][matches[2]] + matches[3])
            save_data(config.likecounter.db, likedata)
            return langs[msg.lang].cheating
        end

        if matches[1]:lower() == 'remlikes' and matches[2] and matches[3] and is_sudo(msg) then
            mystat('/remlikes')
            likedata[tostring(msg.chat.id)][matches[2]] = tonumber(likedata[tostring(msg.chat.id)][matches[2]] - matches[3])
            save_data(config.likecounter.db, likedata)
            return langs[msg.lang].cheating
        end

        if (matches[1]:lower() == 'likes') then
            mystat('/likes')
            return likes_leaderboard(likedata[tostring(msg.chat.id)], msg.lang)
        end

        if msg.fwd_from then
            return langs[msg.lang].forwardingLike
        else
            if matches[1]:lower() == 'like' or matches[1]:lower() == '1up' then
                mystat('/like')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return like(likedata, msg.chat.id, msg.reply_to_message.forward_from.id)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return like(likedata, msg.chat.id, msg.reply_to_message.from.id)
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return like(likedata, msg.chat.id, msg.entities[k].user.id)
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        return like(likedata, msg.chat.id, matches[2])
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return like(likedata, msg.chat.id, obj_user.id)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            elseif matches[1]:lower() == 'dislike' or matches[1]:lower() == '1down' then
                mystat('/dislike')
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return dislike(likedata, msg.chat.id, msg.reply_to_message.forward_from.id)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        return dislike(likedata, msg.chat.id, msg.reply_to_message.from.id)
                    end
                elseif matches[2] and matches[2] ~= '' then
                    if msg.entities then
                        for k, v in pairs(msg.entities) do
                            -- check if there's a text_mention
                            if msg.entities[k].type == 'text_mention' and msg.entities[k].user then
                                if ((string.find(msg.text, matches[2]) or 0) -1) == msg.entities[k].offset then
                                    return dislike(likedata, msg.chat.id, msg.entities[k].user.id)
                                end
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        return dislike(likedata, msg.chat.id, matches[2])
                    else
                        local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                        if obj_user then
                            if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                                return dislike(likedata, msg.chat.id, obj_user.id)
                            end
                        else
                            return langs[msg.lang].noObject
                        end
                    end
                end
                return
            end
        end
    end
end

return {
    description = "LIKECOUNTER",
    patterns =
    {
        "^[#!/]([Cc][Rr][Ee][Aa][Tt][Ee][Ll][Ii][Kk][Ee][Ss][Dd][Bb])$",
        "^[#!/]([Ll][Ii][Kk][Ee]) ([^%s]+)$",
        "^[#!/]([Ll][Ii][Kk][Ee])$",
        "^[#!/]([Dd][Ii][Ss][Ll][Ii][Kk][Ee]) ([^%s]+)$",
        "^[#!/]([Dd][Ii][Ss][Ll][Ii][Kk][Ee])$",
        "^[#!/]([Ll][Ii][Kk][Ee][Ss])$",
        "^[#!/]([Aa][Dd][Dd][Ll][Ii][Kk][Ee][Ss]) (%d+) (%d+)$",
        "^[#!/]([Rr][Ee][Mm][Ll][Ii][Kk][Ee][Ss]) (%d+) (%d+)$",
        -- like
        "^[#!/](1[Uu][Pp]) ([^%s]+)$",
        "^[#!/](1[Uu][Pp])$",
        -- dislike
        "^[#!/](1[Dd][Oo][Ww][Nn]) ([^%s]+)$",
        "^[#!/](1[Dd][Oo][Ww][Nn])$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "(/like|/1up) <id>|<username>|<reply>|from",
        "(/dislike|/1down) <id>|<username>|<reply>|from",
        "/likes",
        "SUDO",
        "/createlikesdb",
        "/addlikes <id> <value>",
        "/remlikes <id> <value>",
    },
}