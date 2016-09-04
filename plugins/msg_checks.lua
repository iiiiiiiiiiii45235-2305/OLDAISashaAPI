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
    if msg.forward then
        if msg.forward_from then
            msg.forward_from = clean_msg(msg.forward_from)
        elseif msg.forward_from_chat then
            msg.forward_from_chat = clean_msg(msg.forward_from_chat)
        end
    end
    return msg
end

local function check_msg(msg)
    if msg.text then
        -- msg.text checks
        local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
        local _nl, real_digits = string.gsub(msg.text, '%d', '')
        if lock_spam == "yes" and string.len(msg.text) > 2049 or ctrl_chars > 40 or real_digits > 2000 then
            if strict == "yes" then
                kickUser(bot.id, msg.from.id, msg.chat.id)
            end
            if msg.chat.type == 'group' then
                banUser(bot.id, msg.from.id, msg.chat.id)
            end
            return
        end
        local is_link_msg = msg.text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/")
        -- or msg.text:match("[Aa][Dd][Ff]%.[Ll][Yy]/") or msg.text:match("[Bb][Ii][Tt]%.[Ll][Yy]/") or msg.text:match("[Gg][Oo][Oo]%.[Gg][Ll]/")
        local is_bot = msg.text:match("?[Ss][Tt][Aa][Rr][Tt]=")
        if is_link_msg and lock_link == "yes" and not is_bot then
            if strict == "yes" then
                kickUser(bot.id, msg.from.id, msg.chat.id)
            end
            if msg.chat.type == 'group' then
                banUser(bot.id, msg.from.id, msg.chat.id)
            end
            return
        end
        if msg.service then
            if lock_tgservice == "yes" then
                return
            end
        end
        local is_squig_msg = msg.text:match("[\216-\219][\128-\191]")
        if is_squig_msg and lock_arabic == "yes" then
            if strict == "yes" then
                kickUser(bot.id, msg.from.id, msg.chat.id)
            end
            if msg.chat.type == 'group' then
                banUser(bot.id, msg.from.id, msg.chat.id)
            end
            return
        end
        local print_name = msg.from.print_name
        local is_rtl = print_name:match("‮") or msg.text:match("‮")
        if is_rtl and lock_rtl == "yes" then
            if strict == "yes" then
                kickUser(bot.id, msg.from.id, msg.chat.id)
            end
            if msg.chat.type == 'group' then
                banUser(bot.id, msg.from.id, msg.chat.id)
            end
            return
        end
    end
    if msg.media then
        -- msg.media checks
        if msg.caption then
            -- msg.caption checks
            local is_link_caption = msg.caption:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.caption:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/")
            -- or msg.caption:match("[Aa][Dd][Ff]%.[Ll][Yy]/") or msg.caption:match("[Bb][Ii][Tt]%.[Ll][Yy]/") or msg.caption:match("[Gg][Oo][Oo]%.[Gg][Ll]/")
            if is_link_caption and lock_link == "yes" then
                if strict == "yes" then
                    kickUser(bot.id, msg.from.id, msg.chat.id)
                end
                if msg.chat.type == 'group' then
                    banUser(bot.id, msg.from.id, msg.chat.id)
                end
                return
            end
            local is_squig_caption = msg.caption:match("[\216-\219][\128-\191]")
            if is_squig_caption and lock_arabic == "yes" then
                if strict == "yes" then
                    kickUser(bot.id, msg.from.id, msg.chat.id)
                end
                if msg.chat.type == 'group' then
                    banUser(bot.id, msg.from.id, msg.chat.id)
                end
                return
            end
            if lock_sticker == "yes" and msg.caption:match("sticker.webp") then
                if strict == "yes" then
                    kickUser(bot.id, msg.from.id, msg.chat.id)
                end
                if msg.chat.type == 'group' then
                    banUser(bot.id, msg.from.id, msg.chat.id)
                end
                return
            end
        end
        if msg.contact and lock_contacts == "yes" then
            if strict == "yes" then
                kickUser(bot.id, msg.from.id, msg.chat.id)
            end
            if msg.chat.type == 'group' then
                banUser(bot.id, msg.from.id, msg.chat.id)
            end
            return
        end
    end
    if msg.forward then
        if msg.forward_from then
            msg.forward_from = check_msg(msg.forward_from)
        elseif msg.forward_from_chat then
            msg.forward_from_chat = check_msg(msg.forward_from_chat)
        end
    end
    if msg.service then
        -- msg.service checks
        if msg.adder and msg.added then
            if msg.adder.id == msg.added.id then
                local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
                if string.len(msg.from.print_name) > 70 or ctrl_chars > 40 and lock_group_spam == 'yes' then
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] joined and Service Msg deleted (#spam name)")
                    if strict == "yes" then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] joined and kicked (#spam name)")
                        kickUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    if msg.chat.type == 'group' then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] joined and kicked (#spam name)")
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                end
                local print_name = msg.from.print_name
                local is_rtl_name = print_name:match("‮")
                if is_rtl_name and lock_rtl == "yes" then
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and kicked (#RTL char in name)")
                    kickUser(bot.id, msg.from.id, msg.chat.id)
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                end
                if lock_member == 'yes' then
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and kicked (#lockmember)")
                    kickUser(bot.id, msg.from.id, msg.chat.id)
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                end
            elseif msg.adder.id ~= msg.added.id then
                if string.len(msg.added.print_name) > 70 and lock_group_spam == 'yes' then
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: Service Msg deleted (#spam name)")
                    if strict == "yes" then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked (#spam name) ")
                        kickUser(bot.id, msg.added.id, msg.chat.id)
                    end
                    if msg.chat.type == 'group' then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked (#spam name) ")
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                end
                local print_name = msg.added.print_name
                local is_rtl_name = print_name:match("‮")
                if is_rtl_name and lock_rtl == "yes" then
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked (#RTL char in name)")
                    kickUser(bot.id, msg.added.id, msg.chat.id)
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                end
                if msg.chat.type == 'supergroup' and lock_member == 'yes' then
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked  (#lockmember)")
                    kickUser(bot.id, msg.added.id, msg.chat.id)
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                end
            end
        end
    end
    return msg
end

-- Begin pre_process function
local function pre_process(msg)
    -- Begin 'RondoMsgChecks' text checks by @rondoozle
    if msg.chat then
        if msg.chat.type == 'group' or msg.chat.type == 'supergroup' then
            if msg and not redis:sismember('whitelist', msg.from.id) then
                -- if regular user
                local data = load_data(config.moderation.data)
                if data[tostring(msg.chat.id)] and data[tostring(msg.chat.id)]['settings'] then
                    settings = data[tostring(msg.chat.id)]['settings']
                else
                    return msg
                end
                if settings.lock_arabic then
                    lock_arabic = settings.lock_arabic
                else
                    lock_arabic = 'no'
                end
                if settings.lock_rtl then
                    lock_rtl = settings.lock_rtl
                else
                    lock_rtl = 'no'
                end
                if settings.lock_tgservice then
                    lock_tgservice = settings.lock_tgservice
                else
                    lock_tgservice = 'no'
                end
                if settings.lock_link then
                    lock_link = settings.lock_link
                else
                    lock_link = 'no'
                end
                if settings.lock_member then
                    lock_member = settings.lock_member
                else
                    lock_member = 'no'
                end
                if settings.lock_spam then
                    lock_spam = settings.lock_spam
                else
                    lock_spam = 'no'
                end
                if settings.lock_sticker then
                    lock_sticker = settings.lock_sticker
                else
                    lock_sticker = 'no'
                end
                if settings.lock_contacts then
                    lock_contacts = settings.lock_contacts
                else
                    lock_contacts = 'no'
                end
                if settings.strict then
                    strict = settings.strict
                else
                    strict = 'no'
                end
                if not is_mod(msg) then
                    local tmp = check_msg(msg)
                    if tmp then
                        msg = tmp
                    else
                        return
                    end
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