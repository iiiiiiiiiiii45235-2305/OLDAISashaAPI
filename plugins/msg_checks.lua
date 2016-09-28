local function get_warn(chat_id)
    local data = load_data(config.moderation.data)
    local lang = get_lang(chat_id)
    local warn_max = data[tostring(chat_id)]['settings']['warn_max']
    if not warn_max then
        return langs[lang].noWarnSet
    end
    return langs[lang].warnSet .. warn_max
end

local function warn_user(executer, target, chat_id)
    if compare_ranks(executer, target, chat_id) then
        local lang = get_lang(chat_id)
        local warn_chat = string.match(get_warn(chat_id), "%d+") or 3
        redis:incr(chat_id .. ':warn:' .. target)
        local hashonredis = redis:get(chat_id .. ':warn:' .. target)
        if not hashonredis then
            redis:set(chat_id .. ':warn:' .. target, 1)
            sendMessage(chat_id, string.gsub(langs[lang].warned, 'X', '1'))
            hashonredis = 1
        end
        if tonumber(warn_chat) ~= 0 then
            if tonumber(hashonredis) >= tonumber(warn_chat) then
                redis:getset(chat_id .. ':warn:' .. target, 0)
                banUser(executer, target, chat_id)
            end
            sendMessage(chat_id, string.gsub(langs[lang].warned, 'X', tostring(hashonredis)))
        end
        savelog(chat_id, "[" .. executer .. "] warned user " .. target .. " Y")
    else
        sendMessage(chat_id, langs[lang].require_rank)
        savelog(chat_id, "[" .. executer .. "] warned user " .. target .. " N")
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

local function action(msg, strict)
    warn_user(bot.id, msg.from.id, msg.chat.id)
    if strict == "yes" then
        banUser(bot.id, msg.from.id, msg.chat.id)
    end
    if msg.chat.type == 'group' then
        banUser(bot.id, msg.from.id, msg.chat.id)
    end
end

local function check_msg(msg, settings)
    local lock_arabic = 'no'
    local lock_rtl = 'no'
    local lock_tgservice = 'no'
    local lock_link = 'no'
    local lock_member = 'no'
    local lock_spam = 'no'
    local lock_sticker = 'no'
    local lock_contacts = 'no'
    local strict = 'no'
    local group_link = nil
    if settings.lock_arabic then
        lock_arabic = settings.lock_arabic
    end
    if settings.lock_rtl then
        lock_rtl = settings.lock_rtl
    end
    if settings.lock_tgservice then
        lock_tgservice = settings.lock_tgservice
    end
    if settings.lock_link then
        lock_link = settings.lock_link
    end
    if settings.lock_member then
        lock_member = settings.lock_member
    end
    if settings.lock_spam then
        lock_spam = settings.lock_spam
    end
    if settings.lock_sticker then
        lock_sticker = settings.lock_sticker
    end
    if settings.lock_contacts then
        lock_contacts = settings.lock_contacts
    end
    if settings.strict then
        strict = settings.strict
    end
    if settings.set_link then
        group_link = settings.set_link
    end
    if msg.text then
        -- msg.text checks
        local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
        local _nl, real_digits = string.gsub(msg.text, '%d', '')
        if lock_spam == "yes" and string.len(msg.text) > 2049 or ctrl_chars > 40 or real_digits > 2000 then
            action(msg, strict)
            msg = clean_msg(msg)
        end
        local is_link_msg = msg.text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/")
        -- or msg.text:match("[Aa][Dd][Ff]%.[Ll][Yy]/") or msg.text:match("[Bb][Ii][Tt]%.[Ll][Yy]/") or msg.text:match("[Gg][Oo][Oo]%.[Gg][Ll]/")
        local is_bot = msg.text:match("?[Ss][Tt][Aa][Rr][Tt]=")
        if is_link_msg and lock_link == "yes" and not is_bot then
            if group_link then
                if not string.find(msg.text, data[tostring(msg.chat.id)].settings.set_link) then
                    action(msg, strict)
                    msg = clean_msg(msg)
                end
            else
                action(msg, strict)
                msg = clean_msg(msg)
            end
        end
        local is_squig_msg = msg.text:match("[\216-\219][\128-\191]")
        if is_squig_msg and lock_arabic == "yes" then
            action(msg, strict)
            msg = clean_msg(msg)
        end
        local print_name = msg.from.print_name
        local is_rtl = print_name:match("‮") or msg.text:match("‮")
        if is_rtl and lock_rtl == "yes" then
            action(msg, strict)
            msg = clean_msg(msg)
        end
    end
    if msg.media then
        -- msg.media checks
        if msg.caption then
            -- msg.caption checks
            local is_link_caption = msg.caption:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.caption:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/")
            -- or msg.caption:match("[Aa][Dd][Ff]%.[Ll][Yy]/") or msg.caption:match("[Bb][Ii][Tt]%.[Ll][Yy]/") or msg.caption:match("[Gg][Oo][Oo]%.[Gg][Ll]/")
            if is_link_caption and lock_link == "yes" then
                if group_link then
                    if not string.find(msg.caption, data[tostring(msg.chat.id)].settings.set_link) then
                        action(msg, strict)
                        msg = clean_msg(msg)
                    end
                else
                    action(msg, strict)
                    msg = clean_msg(msg)
                end
            end
            local is_squig_caption = msg.caption:match("[\216-\219][\128-\191]")
            if is_squig_caption and lock_arabic == "yes" then
                action(msg, strict)
                msg = clean_msg(msg)
            end
        end
        if lock_sticker == "yes" and msg.sticker then
            action(msg, strict)
            msg = clean_msg(msg)
        end
        if lock_contacts == "yes" and msg.contact then
            action(msg, strict)
            msg = clean_msg(msg)
        end
    end
    if msg.service then
        -- msg.service checks
        if msg.adder and msg.added then
            if msg.adder.id == msg.added.id then
                local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
                if string.len(msg.from.print_name) > 70 or ctrl_chars > 40 and lock_group_spam == 'yes' then
                    if strict == "yes" then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] joined and kicked (#spam name)")
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    if msg.chat.type == 'group' then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] joined and kicked (#spam name)")
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                end
                local print_name = msg.from.print_name
                local is_rtl_name = print_name:match("‮")
                if is_rtl_name and lock_rtl == "yes" then
                    if strict == "yes" then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and kicked (#RTL char in name)")
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                end
                if lock_member == 'yes' then
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and kicked (#lockmember)")
                    banUser(bot.id, msg.from.id, msg.chat.id)
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                end
            elseif msg.adder.id ~= msg.added.id then
                if string.len(msg.added.print_name) > 70 and lock_group_spam == 'yes' then
                    if strict == "yes" then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked (#spam name) ")
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                    if msg.chat.type == 'group' then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked (#spam name) ")
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                end
                local print_name = msg.added.print_name
                local is_rtl_name = print_name:match("‮")
                if is_rtl_name and lock_rtl == "yes" then
                    if strict == "yes" then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked (#RTL char in name)")
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                end
                if msg.chat.type == 'supergroup' and lock_member == 'yes' then
                    warn_user(bot.id, msg.adder.id, msg.chat.id)
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked  (#lockmember)")
                    banUser(bot.id, msg.added.id, msg.chat.id)
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                end
            end
        end
    end
    return msg
end

-- Begin pre_process function
local function pre_process(msg)
    -- Begin 'RondoMsgChecks' text checks by @rondoozle
    if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
        if msg and not isWhitelisted(msg.from.id) and not is_mod(msg) then
            -- if regular user
            local data = load_data(config.moderation.data)
            local settings = nil
            if data[tostring(msg.chat.id)] then
                if data[tostring(msg.chat.id)]['settings'] then
                    settings = data[tostring(msg.chat.id)]['settings']
                end
            end
            if not settings then
                return msg
            else
                local tmp = check_msg(msg, settings)
                if tmp then
                    msg = tmp
                end
            end
        end
    end
    -- End 'RondoMsgChecks' text checks by @Rondoozle
    return msg
end
-- End pre_process function

return {
    description = "MSG_CHECKS",
    patterns = { },
    pre_process = pre_process,
    min_rank = 5
}
-- End msg_checks.lua
-- By @Rondoozle