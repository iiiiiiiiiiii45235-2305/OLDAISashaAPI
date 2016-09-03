local function whitelist_user(user_id, lang)
    local is_whitelisted = redis:sismember('whitelist', user_id)
    if is_whitelisted then
        redis:srem('whitelist', user_id)
        return langs[lang].userBot .. user_id .. langs[lang].whitelistRemoved
    else
        redis:sadd('whitelist', user_id)
        return langs[lang].userBot .. user_id .. langs[lang].whitelistAdded
    end
end

local function run(msg, matches)
    if matches[1]:lower() == "whitelist" and is_admin(msg) then
        if msg.reply then
            if matches[2] then
                if matches[2]:lower() == 'from' then
                    if msg.reply_to_message.forward then
                        if msg.reply_to_message.forward_from then
                            return whitelist_user(msg.reply_to_message.forward_from.id, lang)
                        else
                            -- return error cant whitelist chat
                        end
                    else
                        -- return error no forward
                    end
                end
            else
                return whitelist_user(msg.reply_to_message.from.id, lang)
            end
        end
    elseif matches[2] then
        if string.match(matches[2], '^%d+$') then
            return whitelist_user(matches[2], lang)
        else
            -- not sure if it works
            local obj_user = resolveUsername(matches[2]:gsub('@', ''))
            if obj_user then
                if obj_user.type == 'private' then
                    return whitelist_user(obj_user.id, lang)
                end
            end
        end
        return
    else
        local list = redis:smembers('whitelist')
        local text = langs[msg.lang].whitelistStart
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

    if matches[1]:lower() == "clean whitelist" and is_admin(msg) then
        redis:del('whitelist')
        return langs[msg.lang].whitelistCleaned
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
    min_rank = 3,
    syntax =
    {
        "ADMIN",
        "#whitelist <id>|<username>|<reply>",
        "#clean whitelist",
    },
}