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
    -- deleteMessage(msg)
    warnUser(bot.id, msg.from.id, msg.chat.id)
    if strict then
        banUser(bot.id, msg.from.id, msg.chat.id)
    end
    if msg.chat.type == 'group' then
        banUser(bot.id, msg.from.id, msg.chat.id)
    end
end

local function check_msg(msg, settings)
    local lock_arabic = settings.lock_arabic
    local lock_link = settings.lock_link
    local group_link = nil
    if settings.set_link then
        group_link = settings.set_link
    end
    local lock_member = settings.lock_member
    local lock_rtl = settings.lock_rtl
    local lock_spam = settings.lock_spam
    local strict = settings.strict

    local mute_all = isMuted(msg.chat.id, 'all')
    local mute_audio = isMuted(msg.chat.id, 'audio')
    local mute_contact = isMuted(msg.chat.id, 'contact')
    local mute_document = isMuted(msg.chat.id, 'document')
    local mute_gif = isMuted(msg.chat.id, 'gif')
    local mute_location = isMuted(msg.chat.id, 'location')
    local mute_photo = isMuted(msg.chat.id, 'photo')
    local mute_sticker = isMuted(msg.chat.id, 'sticker')
    local mute_text = isMuted(msg.chat.id, 'text')
    local mute_tgservice = isMuted(msg.chat.id, 'tgservice')
    local mute_video = isMuted(msg.chat.id, 'video')
    local mute_voice = isMuted(msg.chat.id, 'voice')

    if not msg.service then
        if isMutedUser(msg.chat.id, msg.from.id) then
            -- deleteMessage(msg)
            if msg.chat.type == 'group' then
                banUser(bot.id, msg.from.id, msg.chat.id)
            end
            msg = clean_msg(msg)
            return msg
        end
        if mute_all then
            -- deleteMessage(msg)
            if msg.chat.type == 'group' then
                banUser(bot.id, msg.from.id, msg.chat.id)
            end
            msg = clean_msg(msg)
            return msg
        end
        if msg.text then
            if mute_text then
                action(msg, strict)
                msg = clean_msg(msg)
                return msg
            end
            -- msg.text checks
            local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
            local _nl, real_digits = string.gsub(msg.text, '%d', '')
            if lock_spam and string.len(msg.text) > 2049 or ctrl_chars > 40 or real_digits > 2000 then
                action(msg, strict)
                msg = clean_msg(msg)
                return msg
            end
            local is_link_msg = msg.text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/")
            -- or msg.text:match("[Aa][Dd][Ff]%.[Ll][Yy]/") or msg.text:match("[Bb][Ii][Tt]%.[Ll][Yy]/") or msg.text:match("[Gg][Oo][Oo]%.[Gg][Ll]/")
            local is_bot = msg.text:match("?[Ss][Tt][Aa][Rr][Tt]=")
            if is_link_msg and lock_link and not is_bot then
                if group_link then
                    if not string.find(msg.text, data[tostring(msg.chat.id)].settings.set_link) then
                        action(msg, strict)
                        msg = clean_msg(msg)
                        return msg
                    end
                else
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return msg
                end
            end
            local is_squig_msg = msg.text:match("[\216-\219][\128-\191]")
            if is_squig_msg and lock_arabic then
                action(msg, strict)
                msg = clean_msg(msg)
                return msg
            end
            local print_name = msg.from.print_name
            local is_rtl = print_name:match("‮") or msg.text:match("‮")
            if is_rtl and lock_rtl then
                action(msg, strict)
                msg = clean_msg(msg)
                return msg
            end
        end
        -- msg.media checks
        if msg.caption then
            -- msg.caption checks
            local is_link_caption = msg.caption:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.caption:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/")
            -- or msg.caption:match("[Aa][Dd][Ff]%.[Ll][Yy]/") or msg.caption:match("[Bb][Ii][Tt]%.[Ll][Yy]/") or msg.caption:match("[Gg][Oo][Oo]%.[Gg][Ll]/")
            if is_link_caption and lock_link then
                if group_link then
                    if not string.find(msg.caption, data[tostring(msg.chat.id)].settings.set_link) then
                        action(msg, strict)
                        msg = clean_msg(msg)
                        return msg
                    end
                else
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return msg
                end
            end
            local is_squig_caption = msg.caption:match("[\216-\219][\128-\191]")
            if is_squig_caption and lock_arabic then
                action(msg, strict)
                msg = clean_msg(msg)
                return msg
            end
            local print_name = msg.from.print_name
            local is_rtl = print_name:match("‮") or msg.caption:match("‮")
            if is_rtl and lock_rtl then
                action(msg, strict)
                msg = clean_msg(msg)
                return msg
            end
        end
        if msg.media_type then
            if msg.media_type == 'audio' then
                if mute_audio then
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return msg
                end
            elseif msg.media_type == 'contact' then
                if mute_contact then
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return msg
                end
            elseif msg.media_type == 'document' then
                if mute_document then
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return msg
                end
            elseif msg.media_type == 'gif' then
                if mute_gif then
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return msg
                end
            elseif msg.media_type == 'location' then
                if mute_location then
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return msg
                end
            elseif msg.media_type == 'photo' then
                if mute_photo then
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return msg
                end
            elseif msg.media_type == 'sticker' then
                if mute_sticker then
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return msg
                end
            elseif msg.media_type == 'video' then
                if mute_video then
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return msg
                end
            elseif msg.media_type == 'voice' then
                if mute_voice then
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return msg
                end
            end
        end
    else
        if mute_tgservice then
            -- deleteMessage(msg)
            msg = clean_msg(msg)
            return msg
        end
        if msg.adder and msg.added then
            if msg.adder.id == msg.added.id then
                local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
                if string.len(msg.from.print_name) > 70 or ctrl_chars > 40 and lock_spam then
                    -- deleteMessage(msg)
                    if strict then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] joined and kicked (#spam name)")
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    if msg.chat.type == 'group' then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] joined and kicked (#spam name)")
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                    return msg
                end
                local print_name = msg.from.print_name
                local is_rtl_name = print_name:match("‮")
                if is_rtl_name and lock_rtl then
                    -- deleteMessage(msg)
                    if strict then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and kicked (#RTL char in name)")
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                    return msg
                end
                if lock_member then
                    -- deleteMessage(msg)
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and kicked (#lockmember)")
                    banUser(bot.id, msg.from.id, msg.chat.id)
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.from.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                    return msg
                end
            elseif msg.adder.id ~= msg.added.id then
                if string.len(msg.added.print_name) > 70 or ctrl_chars > 40 and lock_spam then
                    -- deleteMessage(msg)
                    if strict then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked (#spam name) ")
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                    if msg.chat.type == 'group' then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked (#spam name) ")
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                    return msg
                end
                local print_name = msg.added.print_name
                local is_rtl_name = print_name:match("‮")
                if is_rtl_name and lock_rtl then
                    -- deleteMessage(msg)
                    if strict then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked (#RTL char in name)")
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                    return msg
                end
                if msg.chat.type == 'supergroup' and lock_member then
                    -- deleteMessage(msg)
                    warnUser(bot.id, msg.adder.id, msg.chat.id)
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user kicked  (#lockmember)")
                    banUser(bot.id, msg.added.id, msg.chat.id)
                    if msg.chat.type == 'group' then
                        banUser(bot.id, msg.added.id, msg.chat.id)
                    end
                    msg = clean_msg(msg)
                    return msg
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
        if msg and not isWhitelisted(msg.from.id) and not msg.from.is_mod then
            -- if regular user
            local settings = nil
            if data[tostring(msg.chat.id)] then
                if data[tostring(msg.chat.id)].settings then
                    settings = data[tostring(msg.chat.id)].settings
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
-- Modified by @EricSolinas for API