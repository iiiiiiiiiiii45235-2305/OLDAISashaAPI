local function whitelist_user(group_id, user_id)
    local is_whitelisted = redis:sismember('whitelist:' .. group_id, user_id)
    if is_whitelisted then
        redis:srem('whitelist:' .. group_id, user_id)
        return false
    else
        redis:sadd('whitelist:' .. group_id, user_id)
        return true
    end
end

local function run(msg, matches)
    if matches[1]:lower() == "whitelist" then
        if msg.reply then
            if is_owner(msg) then
                mystat('/whitelist <user>')
                if matches[2] then
                    if matches[2]:lower() == 'from' then
                        if msg.reply_to_message.forward then
                            if msg.reply_to_message.forward_from then
                                if whitelist_user(msg.chat.id, msg.reply_to_message.forward_from.id) then
                                    return langs[msg.lang].userBot .. msg.reply_to_message.forward_from.id .. langs[msg.lang].whitelistRemoved
                                else
                                    return langs[msg.lang].userBot .. msg.reply_to_message.forward_from.id .. langs[msg.lang].whitelistAdded
                                end
                            else
                                return langs[msg.lang].cantDoThisToChat
                            end
                        else
                            return langs[msg.lang].errorNoForward
                        end
                    end
                else
                    if whitelist_user(msg.chat.id, msg.reply_to_message.from.id) then
                        return langs[msg.lang].userBot .. msg.reply_to_message.from.id .. langs[msg.lang].whitelistRemoved
                    else
                        return langs[msg.lang].userBot .. msg.reply_to_message.from.id .. langs[msg.lang].whitelistAdded
                    end
                end
            else
                return langs[msg.lang].require_owner
            end
        elseif matches[2] then
            if is_owner(msg) then
                mystat('/whitelist <user>')
                if string.match(matches[2], '^%d+$') then
                    if whitelist_user(msg.chat.id, matches[2]) then
                        return langs[msg.lang].userBot .. matches[2] .. langs[msg.lang].whitelistRemoved
                    else
                        return langs[msg.lang].userBot .. matches[2] .. langs[msg.lang].whitelistAdded
                    end
                else
                    local obj_user = getChat('@' .. string.match(matches[2], '^[^%s]+'):gsub('@', ''))
                    if obj_user then
                        if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                            if whitelist_user(msg.chat.id, obj_user.id) then
                                return langs[msg.lang].userBot .. obj_user.id .. langs[msg.lang].whitelistRemoved
                            else
                                return langs[msg.lang].userBot .. obj_user.id .. langs[msg.lang].whitelistAdded
                            end
                        end
                    end
                end
                return
            else
                return langs[msg.lang].require_owner
            end
        else
            mystat('/whitelist')
            local list = redis:smembers('whitelist:' .. msg.chat.id)
            local text = langs[msg.lang].whitelistStart .. msg.chat.id .. '\n'
            for k, v in pairs(list) do
                local user_info = redis:hgetall('user:' .. v)
                if user_info and user_info.print_name then
                    local print_name = string.gsub(user_info.print_name, "_", " ")
                    text = text .. k .. " - " .. print_name .. " [" .. v .. "]\n"
                else
                    text = text .. k .. " - " .. v .. "\n"
                end
            end
            return text
        end
    end

    if matches[1]:lower() == "clean whitelist" then
        if is_owner(msg) then
            mystat('/clean whitelist')
            redis:del('whitelist:' .. msg.chat.id)
            return langs[msg.lang].whitelistCleaned
        else
            return langs[msg.lang].require_owner
        end
    end
end

return {
    description = "WHITELIST",
    patterns =
    {
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt])$",
        "^[#!/]([Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt]) (.*)$",
        "^[#!/]([Cc][Ll][Ee][Aa][Nn] [Ww][Hh][Ii][Tt][Ee][Ll][Ii][Ss][Tt])$"
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#whitelist",
        "OWNER",
        "#whitelist <id>|<username>|<reply>",
        "#clean whitelist",
    },
}