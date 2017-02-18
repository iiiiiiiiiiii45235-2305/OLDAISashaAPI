local function test_text(text, group_link)
    text = text:gsub(group_link:lower(), '')
    local is_now_link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/") or text:match("[Tt][Ll][Gg][Rr][Mm]%.[Mm][Ee]/") or
    text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/") or text:match("[Tt]%.[Mm][Ee]/")
    or text:match("[Cc][Hh][Aa][Tt]%.[Ww][Hh][Aa][Tt][Ss][Aa][Pp][Pp]%.[Cc][Oo][Mm]/")
    return is_now_link
end

local function test_bot(text)
    text = text:gsub("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/[%w_]+?[Ss][Tt][Aa][Rr][Tt]=", '')
    text = text:gsub("[Tt][Ll][Gg][Rr][Mm]%.[Mm][Ee]/[%w_]+?[Ss][Tt][Aa][Rr][Tt]=", '')
    text = text:gsub("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/[%w_]+?[Ss][Tt][Aa][Rr][Tt]=", '')
    text = text:gsub("[Tt]%.[Mm][Ee]/[%w_]+?[Ss][Tt][Aa][Rr][Tt]=", '')
    local is_now_link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/") or text:match("[Tt][Ll][Gg][Rr][Mm]%.[Mm][Ee]/") or
    text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/") or text:match("[Tt]%.[Mm][Ee]/")
    or text:match("[Cc][Hh][Aa][Tt]%.[Ww][Hh][Aa][Tt][Ss][Aa][Pp][Pp]%.[Cc][Oo][Mm]/")
    return is_now_link
end

local function check_if_link(text, group_link)
    local is_text_link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/") or text:match("[Tt][Ll][Gg][Rr][Mm]%.[Mm][Ee]/") or
    text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/") or text:match("[Tt]%.[Mm][Ee]/")
    or text:match("[Cc][Hh][Aa][Tt]%.[Ww][Hh][Aa][Tt][Ss][Aa][Pp][Pp]%.[Cc][Oo][Mm]/")
    -- or text:match("[Aa][Dd][Ff]%.[Ll][Yy]/") or text:match("[Bb][Ii][Tt]%.[Ll][Yy]/") or text:match("[Gg][Oo][Oo]%.[Gg][Ll]/")
    if is_text_link then
        local test_more = false
        local is_bot = text:match("?[Ss][Tt][Aa][Rr][Tt]=")
        if is_bot then
            -- if bot link test if removing that there are other links
            test_more = test_bot(text:lower())
        else
            -- if not bot link then test if there are links
            test_more = true
        end
        if test_more then
            -- if there could be other links check
            if group_link then
                if not string.find(text:lower(), group_link:lower()) then
                    -- if group link but not in text then link
                    return true
                else
                    -- test if removing group link there are other links
                    return test_text(text:lower(), group_link:lower())
                end
            else
                -- if no group_link then link
                return true
            end
        end
    end
    return false
end

local function clean_msg(msg)
    -- clean msg but returns it
    msg.cleaned = true
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
    deleteMessage(msg)
    sendMessage(msg.chat.id, warnUser(bot.id, msg.from.id, msg.chat.id))
    if strict then
        sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id))
    end
    if msg.chat.type == 'group' then
        sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id))
    end
end

local function check_msg(msg, settings)
    local lock_arabic = settings.lock_arabic
    local lock_leave = settings.lock_leave
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
            print('muted user')
            deleteMessage(msg)
            if msg.chat.type == 'group' then
                sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id))
            end
            msg = clean_msg(msg)
            return nil
        end
        if mute_all then
            print('all muted')
            deleteMessage(msg)
            if msg.chat.type == 'group' then
                sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id))
            end
            msg = clean_msg(msg)
            return nil
        end
        if msg.text then
            if mute_text then
                print('text muted')
                action(msg, strict)
                msg = clean_msg(msg)
                return nil
            end
            -- msg.text checks
            if lock_spam then
                local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
                local _nl, real_digits = string.gsub(msg.text, '%d', '')
                if string.len(msg.text) > 2049 or ctrl_chars > 40 or real_digits > 2000 then
                    print('spam found')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            end
            if lock_link then
                if check_if_link(msg.text, group_link) then
                    print('link found')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            end
            if lock_arabic then
                local is_squig_msg = msg.text:match("[\216-\219][\128-\191]")
                if is_squig_msg then
                    print('arabic found')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            end
            if lock_rtl then
                local is_rtl = msg.from.print_name:match("‮") or msg.text:match("‮")
                if is_rtl then
                    print('rtl found')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            end
        end
        if msg.caption then
            if lock_link then
                if check_if_link(msg.caption, group_link) then
                    print('link found')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            end
            if lock_arabic then
                local is_squig_caption = msg.caption:match("[\216-\219][\128-\191]")
                if is_squig_caption then
                    print('arabic found')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            end
            if lock_rtl then
                local is_rtl = msg.from.print_name:match("‮") or msg.caption:match("‮")
                if is_rtl then
                    print('rtl found')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            end
        end
        -- msg.media checks
        if msg.media_type then
            if msg.media_type == 'audio' then
                if mute_audio then
                    print('audio muted')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            elseif msg.media_type == 'contact' then
                if mute_contact then
                    print('contact muted')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            elseif msg.media_type == 'document' then
                if mute_document then
                    print('document muted')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            elseif msg.media_type == 'gif' then
                if mute_gif then
                    print('gif muted')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            elseif msg.media_type == 'location' then
                if mute_location then
                    print('location muted')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            elseif msg.media_type == 'photo' then
                if mute_photo then
                    print('photo muted')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            elseif msg.media_type == 'sticker' then
                if mute_sticker then
                    print('sticker muted')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            elseif msg.media_type == 'video' then
                if mute_video then
                    print('video muted')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            elseif msg.media_type == 'voice' then
                if mute_voice then
                    print('voice muted')
                    action(msg, strict)
                    msg = clean_msg(msg)
                    return nil
                end
            end
        end
    else
        if mute_tgservice then
            print('tgservice muted')
            deleteMessage(msg)
            msg = clean_msg(msg)
            return nil
        end
        if msg.adder and msg.added then
            if msg.adder.id == msg.added.id then
                local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
                if lock_spam then
                    if string.len(msg.from.print_name) > 70 or ctrl_chars > 40 then
                        print('name spam found')
                        deleteMessage(msg)
                        if strict then
                            savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] joined and banned (#spam name)")
                            sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id))
                        end
                        if msg.chat.type == 'group' then
                            savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] joined and banned (#spam name)")
                            sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id))
                        end
                        msg = clean_msg(msg)
                        return nil
                    end
                end
                if lock_rtl then
                    local is_rtl_name = msg.from.print_name:match("‮")
                    if is_rtl_name then
                        print('rtl name found')
                        deleteMessage(msg)
                        if strict then
                            savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and banned (#RTL char in name)")
                            sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id))
                        end
                        if msg.chat.type == 'group' then
                            sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id))
                        end
                        msg = clean_msg(msg)
                        return nil
                    end
                end
                if lock_member then
                    print('member locked')
                    deleteMessage(msg)
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and banned (#lockmember)")
                    sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id))
                    msg = clean_msg(msg)
                    return nil
                end
            elseif msg.adder.id ~= msg.added.id then
                if lock_spam then
                    if string.len(msg.added.print_name) > 70 or ctrl_chars > 40 then
                        print('name spam found')
                        deleteMessage(msg)
                        if strict then
                            savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user banned (#spam name) ")
                            sendMessage(msg.chat.id, banUser(bot.id, msg.added.id, msg.chat.id))
                        end
                        if msg.chat.type == 'group' then
                            savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user banned (#spam name) ")
                            sendMessage(msg.chat.id, banUser(bot.id, msg.added.id, msg.chat.id))
                        end
                        msg = clean_msg(msg)
                        return nil
                    end
                end
                if lock_rtl then
                    local is_rtl_name = msg.added.print_name:match("‮")
                    if is_rtl_name then
                        print('rtl name found')
                        deleteMessage(msg)
                        if strict then
                            savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user banned (#RTL char in name)")
                            sendMessage(msg.chat.id, banUser(bot.id, msg.added.id, msg.chat.id))
                        end
                        if msg.chat.type == 'group' then
                            sendMessage(msg.chat.id, banUser(bot.id, msg.added.id, msg.chat.id))
                        end
                        msg = clean_msg(msg)
                        return nil
                    end
                end
                if lock_member then
                    print('member locked')
                    deleteMessage(msg)
                    sendMessage(msg.chat.id, warnUser(bot.id, msg.adder.id, msg.chat.id))
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. msg.added.id .. "]: added user banned  (#lockmember)")
                    sendMessage(msg.chat.id, banUser(bot.id, msg.added.id, msg.chat.id))
                    msg = clean_msg(msg)
                    return nil
                end
            end
        end
        if msg.remover and msg.removed then
            if lock_leave then
                if not is_mod2(msg.removed.id, msg.chat.id) then
                    return banUser(bot.id, msg.removed.id, msg.chat.id)
                end
            end
        end
    end
    return msg
end

-- Begin pre_process function
local function pre_process(msg)
    if msg then
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