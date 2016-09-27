local function user_msgs(user_id, chat_id)
    local user_info
    local uhash = 'user:' .. user_id
    local user = redis:hgetall(uhash)
    local um_hash = 'msgs:' .. user_id .. ':' .. chat_id
    user_info = tonumber(redis:get(um_hash) or 0)
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

local function kickinactive(chat_id, num, lang)
    local kicked = 0
    local hash = 'chat:' .. chat_id .. ':users'
    local users = redis:smembers(hash)

    for i = 1, #users do
        if tonumber(users[i]) ~= tonumber(bot.id) and not is_momod2(users[i], chat_id) then
            local msgs = user_msgs(users[i], chat_id)
            if tonumber(msgs) < tonumber(num) then
                kickUser(bot.id, users[i], chat_id)
                kicked = kicked + 1
            end
        end
    end
    sendMessage(chat_id, langs[lang].massacre:gsub('X', kicked))
end

local function run(msg, matches)
    if msg.service then
        return
    end
    if matches[1]:lower() == 'kickme' or matches[1]:lower() == 'sasha uccidimi' or matches[1]:lower() == 'sasha esplodimi' or matches[1]:lower() == 'sasha sparami' or matches[1]:lower() == 'sasha decompilami' or matches[1]:lower() == 'sasha bannami' then
        mystat('/kickme')
        -- /kickme
        if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] left using kickme ")
            -- Save to logs
            return kickUser(bot.id, msg.from.id, msg.chat.id)
        else
            return langs[msg.lang].useYourGroups
        end
    end
    if is_mod(msg) then
        if matches[1]:lower() == 'kick' or matches[1]:lower() == 'sasha uccidi' or matches[1]:lower() == 'uccidi' or matches[1]:lower() == 'spara' then
            mystat('/kick')
            if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
                -- /kick
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return kickUser(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        if msg.reply_to_message.service then
                            if msg.reply_to_message.service_type == 'chat_add_user' then
                                return kickUser(msg.from.id, msg.reply_to_message.added.id, msg.chat.id)
                            elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                return kickUser(msg.from.id, msg.reply_to_message.removed.id, msg.chat.id)
                            else
                                return kickUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id)
                            end
                        else
                            return kickUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id)
                        end
                    end
                end
                if string.match(matches[2], '^%d+$') then
                    return kickUser(msg.from.id, matches[2], msg.chat.id)
                else
                    local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                    if obj_user then
                        if obj_user.type == 'private' then
                            return kickUser(msg.from.id, obj_user.id, msg.chat.id)
                        end
                    end
                end
                return
            else
                return langs[msg.lang].useYourGroups
            end
        end
        if matches[1]:lower() == 'ban' or matches[1]:lower() == 'sasha banna' or matches[1]:lower() == 'sasha decompila' or matches[1]:lower() == 'banna' or matches[1]:lower() == 'decompila' or matches[1]:lower() == 'esplodi' or matches[1]:lower() == 'kaboom' then
            mystat('/ban')
            if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
                -- /ban
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return banUser(msg.from.id, msg.reply_to_message.forward_from.id, msg.chat.id)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        if msg.reply_to_message.service then
                            if msg.reply_to_message.service_type == 'chat_add_user' then
                                return banUser(msg.from.id, msg.reply_to_message.added.id, msg.chat.id)
                            elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                return banUser(msg.from.id, msg.reply_to_message.removed.id, msg.chat.id)
                            else
                                return banUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id)
                            end
                        else
                            return banUser(msg.from.id, msg.reply_to_message.from.id, msg.chat.id)
                        end
                    end
                end
                if string.match(matches[2], '^%d+$') then
                    return banUser(msg.from.id, matches[2], msg.chat.id)
                else
                    local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                    if obj_user then
                        if obj_user.type == 'private' then
                            return banUser(msg.from.id, obj_user.id, msg.chat.id)
                        end
                    end
                end
                return
            else
                return langs[msg.lang].useYourGroups
            end
        end
        if matches[1]:lower() == 'unban' or matches[1]:lower() == 'sasha sbanna' or matches[1]:lower() == 'sasha ricompila' or matches[1]:lower() == 'sasha compila' or matches[1]:lower() == 'sbanna' or matches[1]:lower() == 'ricompila' or matches[1]:lower() == 'compila' then
            mystat('/unban')
            if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
                -- /unban
                if msg.reply then
                    if matches[2] then
                        if matches[2]:lower() == 'from' then
                            if msg.reply_to_message.forward then
                                if msg.reply_to_message.forward_from then
                                    return unbanUser(msg.reply_to_message.forward_from.id, msg.chat.id)
                                else
                                    return langs[msg.lang].cantDoThisToChat
                                end
                            else
                                return langs[msg.lang].errorNoForward
                            end
                        end
                    else
                        if msg.reply_to_message.service then
                            if msg.reply_to_message.service_type == 'chat_add_user' then
                                return unbanUser(msg.reply_to_message.added.id, msg.chat.id)
                            elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                return unbanUser(msg.reply_to_message.removed.id, msg.chat.id)
                            else
                                return unbanUser(msg.reply_to_message.from.id, msg.chat.id)
                            end
                        else
                            return unbanUser(msg.reply_to_message.from.id, msg.chat.id)
                        end
                    end
                end
                if string.match(matches[2], '^%d+$') then
                    return unbanUser(matches[2], msg.chat.id)
                else
                    local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                    if obj_user then
                        if obj_user.type == 'private' then
                            return unbanUser(obj_user.id, msg.chat.id)
                        end
                    end
                end
                return
            else
                return langs[msg.lang].useYourGroups
            end
        end
        if matches[1]:lower() == "banlist" or matches[1]:lower() == "sasha lista ban" or matches[1]:lower() == "lista ban" then
            mystat('/banlist')
            -- /banlist
            if matches[2] and is_admin(msg) then
                return banList(matches[2])
            else
                if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
                    return banList(msg.chat.id)
                else
                    return langs[msg.lang].useYourGroups
                end
            end
        end
        if is_owner(msg) then
            if matches[1]:lower() == 'kickinactive' then
                mystat('/kickinactive')
                -- /kickinactive
                local num = matches[2] or 0
                return kickinactive(msg.chat.id, tonumber(num), msg.lang)
            end
            if is_admin(msg) then
                if matches[1]:lower() == 'gban' or matches[1]:lower() == 'sasha superbanna' or matches[1]:lower() == 'superbanna' then
                    mystat('/gban')
                    -- /gban
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        gbanUser(msg.reply_to_message.forward_from.id)
                                        return langs[msg.lang].user .. msg.reply_to_message.forward_from.id .. langs[msg.lang].gbanned
                                    else
                                        return langs[msg.lang].cantDoThisToChat
                                    end
                                else
                                    return langs[msg.lang].errorNoForward
                                end
                            end
                        else
                            if msg.reply_to_message.service then
                                if msg.reply_to_message.service_type == 'chat_add_user' then
                                    gbanUser(msg.reply_to_message.added.id)
                                    return langs[msg.lang].user .. msg.reply_to_message.added.id .. langs[msg.lang].gbanned
                                elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                    gbanUser(msg.reply_to_message.removed.id)
                                    return langs[msg.lang].user .. msg.reply_to_message.removed.id .. langs[msg.lang].gbanned
                                else
                                    gbanUser(msg.reply_to_message.from.id)
                                    return langs[msg.lang].user .. msg.reply_to_message.from.id .. langs[msg.lang].gbanned
                                end
                            else
                                gbanUser(msg.reply_to_message.from.id)
                                return langs[msg.lang].user .. msg.reply_to_message.from.id .. langs[msg.lang].gbanned
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        gbanUser(matches[2])
                        return langs[msg.lang].user .. matches[2] .. langs[msg.lang].gbanned
                    else
                        local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                        if obj_user then
                            if obj_user.type == 'private' then
                                gbanUser(obj_user.id)
                                return langs[msg.lang].user .. obj_user.id .. langs[msg.lang].gbanned
                            end
                        end
                    end
                    return
                end
                if matches[1]:lower() == 'ungban' or matches[1]:lower() == 'sasha supersbanna' or matches[1]:lower() == 'supersbanna' then
                    mystat('/ungban')
                    -- /ungban
                    if msg.reply then
                        if matches[2] then
                            if matches[2]:lower() == 'from' then
                                if msg.reply_to_message.forward then
                                    if msg.reply_to_message.forward_from then
                                        ungbanUser(msg.reply_to_message.forward_from.id)
                                        return langs[msg.lang].user .. msg.reply_to_message.forward_from.id .. langs[msg.lang].ungbanned
                                    else
                                        return langs[msg.lang].cantDoThisToChat
                                    end
                                else
                                    return langs[msg.lang].errorNoForward
                                end
                            end
                        else
                            if msg.reply_to_message.service then
                                if msg.reply_to_message.service_type == 'chat_add_user' then
                                    ungbanUser(msg.reply_to_message.added.id)
                                    return langs[msg.lang].user .. msg.reply_to_message.added.id .. langs[msg.lang].ungbanned
                                elseif msg.reply_to_message.service_type == 'chat_del_user' then
                                    ungbanUser(msg.reply_to_message.removed.id)
                                    return langs[msg.lang].user .. msg.reply_to_message.removed.id .. langs[msg.lang].ungbanned
                                else
                                    ungbanUser(msg.reply_to_message.from.id)
                                    return langs[msg.lang].user .. msg.reply_to_message.from.id .. langs[msg.lang].ungbanned
                                end
                            else
                                ungbanUser(msg.reply_to_message.from.id)
                                return langs[msg.lang].user .. msg.reply_to_message.from.id .. langs[msg.lang].ungbanned
                            end
                        end
                    end
                    if string.match(matches[2], '^%d+$') then
                        ungbanUser(matches[2])
                        return langs[msg.lang].user .. matches[2] .. langs[msg.lang].ungbanned
                    else
                        local obj_user = resolveUsername(matches[2]:gsub('@', ''))
                        if obj_user then
                            if obj_user.type == 'private' then
                                ungbanUser(obj_user.id)
                                return langs[msg.lang].user .. obj_user.id .. langs[msg.lang].ungbanned
                            end
                        end
                    end
                    return
                end
                if matches[1]:lower() == 'gbanlist' or matches[1]:lower() == 'sasha lista superban' or matches[1]:lower() == 'lista superban' then
                    mystat('/gbanlist')
                    -- /gbanlist
                    local hash = 'gbanned'
                    local list = redis:smembers(hash)
                    local gbanlist = langs[get_lang(msg.chat.id)].gbanListStart
                    for k, v in pairs(list) do
                        local user_info = redis:hgetall('user:' .. v)
                        if user_info and user_info.print_name then
                            local print_name = string.gsub(user_info.print_name, "_", " ")
                            local print_name = string.gsub(print_name, "?", "")
                            gbanlist = gbanlist .. k .. " - " .. print_name .. " [" .. v .. "]\n"
                        else
                            gbanlist = gbanlist .. k .. " - " .. v .. "\n"
                        end
                    end
                    local file = io.open("./groups/gbanlist.txt", "w")
                    file:write(gbanlist)
                    file:flush()
                    file:close()
                    return sendDocument(msg.chat.id, "./groups/gbanlist.txt")
                    -- return sendMessage(msg.chat.id, gbanlist)
                end
                return
            else
                return langs[msg.lang].require_admin
            end
        else
            return langs[msg.lang].require_owner
        end
    else
        return langs[msg.lang].require_mod
    end
end

local function clean_msg(msg)
    -- clean msg but returns it
    if msg.text then
        msg.text = ''
    end
    if msg.media then
        if msg.caption then
            msg.caption = ''
        end
    end
    return msg
end

local function pre_process(msg)
    local data = load_data(config.moderation.data)
    -- SERVICE MESSAGE
    if msg.service then
        if msg.service_type then
            -- Check if banned user joins chat by link
            if msg.service_type == 'chat_add_user_link' then
                print('Checking invited user ' .. msg.from.id)
                if isBanned(msg.from.id, msg.chat.id) or isGbanned(msg.from.id) then
                    -- Check it with redis
                    print('User is banned!')
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] is banned and kicked ! ")
                    -- Save to logs
                    banUser(bot.id, msg.from.id, msg.chat.id)
                end
            end
            -- Check if banned user joins chat
            if msg.service_type == 'chat_add_user' then
                print('Checking invited user ' .. msg.added.id)
                if isBanned(msg.added.id, msg.chat.id) and not is_mod2(msg.from.id, msg.chat.id) or isGbanned(msg.added.id) and not is_admin2(msg.from.id) then
                    -- Check it with redis
                    print('User is banned!')
                    savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added a banned user >" .. msg.added.id)
                    -- Save to logs
                    kickUser(bot.id, user_id, msg.chat.id)
                    local banhash = 'addedbanuser:' .. msg.chat.id .. ':' .. msg.from.id
                    redis:incr(banhash)
                    local banhash = 'addedbanuser:' .. msg.chat.id .. ':' .. msg.from.id
                    local banaddredis = redis:get(banhash)
                    if banaddredis then
                        if tonumber(banaddredis) >= 4 and not is_owner(msg) then
                            kickUser(bot.id, msg.from.id, msg.chat.id)
                            -- Kick user who adds ban ppl more than 3 times
                        end
                        if tonumber(banaddredis) >= 8 and not is_owner(msg) then
                            banUser(bot.id, msg.from.id, msg.chat.id)
                            -- Ban user who adds ban ppl more than 7 times
                            local banhash = 'addedbanuser:' .. msg.chat.id .. ':' .. msg.from.id
                            redis:set(banhash, 0)
                            -- Reset the Counter
                        end
                    end
                end
                if data[tostring(msg.chat.id)] then
                    if data[tostring(msg.chat.id)]['settings'] then
                        if data[tostring(msg.chat.id)]['settings']['lock_bots'] then
                            bots_protection = data[tostring(msg.chat.id)]['settings']['lock_bots']
                        end
                    end
                end
                if msg.added.username then
                    if string.sub(msg.added.username:lower(), -3) == 'bot' and not is_mod(msg) and bots_protection == "yes" then
                        --- Will kick bots added by normal users
                        savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added a bot > @" .. msg.added.username)
                        -- Save to logs
                        kickUser(bot.id, msg.added.id, msg.chat.id)
                    end
                end
            end
            -- No further checks
            return msg
        end
    end
    -- banned user is talking !
    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
        if isBanned(msg.from.id, msg.chat.id) or isGbanned(msg.from.id) then
            -- Check it with redis
            print('Banned user talking!')
            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] banned user is talking !")
            -- Save to logs
            kickUser(bot.id, msg.from.id, msg.chat.id)
            msg = clean_msg(msg)
        end
    end
    return msg
end

return {
    description = "BANHAMMER",
    patterns =
    {
        "^[#!/]([Kk][Ii][Cc][Kk][Mm][Ee])",
        "^[#!/]([Kk][Ii][Cc][Kk]) (.*)$",
        "^[#!/]([Kk][Ii][Cc][Kk])$",
        "^[#!/]([Kk][Ii][Cc][Kk][Ii][Nn][Aa][Cc][Tt][Ii][Vv][Ee])$",
        "^[#!/]([Kk][Ii][Cc][Kk][Ii][Nn][Aa][Cc][Tt][Ii][Vv][Ee]) (%-?%d+)$",
        "^[#!/]([Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Bb][Aa][Nn])$",
        "^[#!/]([Uu][Nn][Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Uu][Nn][Bb][Aa][Nn])$",
        "^[#!/]([Bb][Aa][Nn][Ll][Ii][Ss][Tt]) (.*)$",
        "^[#!/]([Bb][Aa][Nn][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Gg][Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Gg][Bb][Aa][Nn])$",
        "^[#!/]([Uu][Nn][Gg][Bb][Aa][Nn]) (.*)$",
        "^[#!/]([Uu][Nn][Gg][Bb][Aa][Nn])$",
        "^[#!/]([Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt])$",
        -- kickme
        "^([Ss][Aa][Ss][Hh][Aa] [Uu][Cc][Cc][Ii][Dd][Ii][Mm][Ii])",
        "^([Ss][Aa][Ss][Hh][Aa] [Ee][Ss][Pp][Ll][Oo][Dd][Ii][Mm][Ii])",
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Pp][Aa][Rr][Aa][Mm][Ii])",
        "^([Ss][Aa][Ss][Hh][Aa] [Dd][Ee][Cc][Oo][Mm][Pp][Ii][Ll][Aa][Mm][Ii])",
        "^([Ss][Aa][Ss][Hh][Aa] [Bb][Aa][Nn][Nn][Aa][Mm][Ii])",
        -- kick
        "^([Ss][Aa][Ss][Hh][Aa] [Uu][Cc][Cc][Ii][Dd][Ii]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Uu][Cc][Cc][Ii][Dd][Ii])$",
        "^([Uu][Cc][Cc][Ii][Dd][Ii]) (.*)$",
        "^([Uu][Cc][Cc][Ii][Dd][Ii])$",
        "^([Ss][Pp][Aa][Rr][Aa]) (.*)$",
        "^([Ss][Pp][Aa][Rr][Aa])$",
        -- ban
        "^([Ss][Aa][Ss][Hh][Aa] [Bb][Aa][Nn][Nn][Aa]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Bb][Aa][Nn][Nn][Aa])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Dd][Ee][Cc][Oo][Mm][Pp][Ii][Ll][Aa]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Dd][Ee][Cc][Oo][Mm][Pp][Ii][Ll][Aa])$",
        "^([Bb][Aa][Nn][Nn][Aa]) (.*)$",
        "^([Bb][Aa][Nn][Nn][Aa])$",
        "^([Dd][Ee][Cc][Oo][Mm][Pp][Ii][Ll][Aa]) (.*)$",
        "^([Dd][Ee][Cc][Oo][Mm][Pp][Ii][Ll][Aa])$",
        "^([Ee][Ss][Pp][Ll][Oo][Dd][Ii]) (.*)$",
        "^([Ee][Ss][Pp][Ll][Oo][Dd][Ii])$",
        "^([Kk][Aa][Bb][Oo][Oo][Mm]) (.*)$",
        "^([Kk][Aa][Bb][Oo][Oo][Mm])$",
        -- unban
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Bb][Aa][Nn][Nn][Aa]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Bb][Aa][Nn][Nn][Aa])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Rr][Ii][Cc][Oo][Mm][Pp][Ii][Ll][Aa]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Rr][Ii][Cc][Oo][Mm][Pp][Ii][Ll][Aa])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Cc][Oo][Mm][Pp][Ii][Ll][Aa]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Cc][Oo][Mm][Pp][Ii][Ll][Aa])$",
        "^([Ss][Bb][Aa][Nn][Nn][Aa]) (.*)$",
        "^([Ss][Bb][Aa][Nn][Nn][Aa])$",
        "^([Rr][Ii][Cc][Oo][Mm][Pp][Ii][Ll][Aa]) (.*)$",
        "^([Rr][Ii][Cc][Oo][Mm][Pp][Ii][Ll][Aa])$",
        "^([Cc][Oo][Mm][Pp][Ii][Ll][Aa]) (.*)$",
        "^([Cc][Oo][Mm][Pp][Ii][Ll][Aa])$",
        -- banlist
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Ss][Tt][Aa] [Bb][Aa][Nn]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Ss][Tt][Aa] [Bb][Aa][Nn])$",
        "^([Ll][Ii][Ss][Tt][Aa] [Bb][Aa][Nn]) (.*)$",
        "^([Ll][Ii][Ss][Tt][Aa] [Bb][Aa][Nn])$",
        -- gban
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Uu][Pp][Ee][Rr][Bb][Aa][Nn][Nn][Aa]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Uu][Pp][Ee][Rr][Bb][Aa][Nn][Nn][Aa])$",
        "^([Ss][Uu][Pp][Ee][Rr][Bb][Aa][Nn][Nn][Aa]) (.*)$",
        "^([Ss][Uu][Pp][Ee][Rr][Bb][Aa][Nn][Nn][Aa])$",
        -- ungban
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Uu][Pp][Ee][Rr][Ss][Bb][Aa][Nn][Nn][Aa]) (.*)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Ss][Uu][Pp][Ee][Rr][Ss][Bb][Aa][Nn][Nn][Aa])$",
        "^([Ss][Uu][Pp][Ee][Rr][Ss][Bb][Aa][Nn][Nn][Aa]) (.*)$",
        "^([Ss][Uu][Pp][Ee][Rr][Ss][Bb][Aa][Nn][Nn][Aa])$",
        -- gbanlist
        "^([Ss][Aa][Ss][Hh][Aa] [Ll][Ii][Ss][Tt][Aa] [Ss][Uu][Pp][Ee][Rr][Bb][Aa][Nn])$",
        "^([Ll][Ii][Ss][Tt][Aa] [Ss][Uu][Pp][Ee][Rr][Bb][Aa][Nn])$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "(#kickme|sasha (uccidimi|esplodimi|sparami|decompilami|bannami))",
        "MOD",
        "(#kick|spara|[sasha] uccidi) <id>|<username>|<reply>|from",
        "(#ban|esplodi|kaboom|[sasha] banna|[sasha] decompila) <id>|<username>|<reply>|from",
        "(#unban|[sasha] sbanna|[sasha] [ri]compila) <id>|<username>|<reply>|from",
        "(#banlist|[sasha] lista ban)",
        "OWNER",
        "#kickinactive [<msgs>]",
        "ADMIN",
        "(#banlist|[sasha] lista ban) <group_id>",
        "(#gban|[sasha] superbanna) <id>|<username>|<reply>|from",
        "(#ungban|[sasha] supersbanna) <id>|<username>|<reply>|from",
        "(#gbanlist|[sasha] lista superban)",
    },
}