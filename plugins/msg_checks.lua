local function test_text_link(text, group_link)
    -- remove group_link and test if link again
    text = text:gsub(group_link:lower(), '')

    local is_now_link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Tt][Ll][Gg][Rr][Mm]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Tt]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Cc][Hh][Aa][Tt]%.[Ww][Hh][Aa][Tt][Ss][Aa][Pp][Pp]%.[Cc][Oo][Mm]/")
    return is_now_link
end

local function test_bot_link(text)
    -- remove all possible bot's links and test if link again
    text = text:gsub("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/[%w_]+%?[Ss][Tt][Aa][Rr][Tt]=", '')
    text = text:gsub("[Tt][Ll][Gg][Rr][Mm]%.[Mm][Ee]/[%w_]+%?[Ss][Tt][Aa][Rr][Tt]=", '')
    text = text:gsub("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/[%w_]+%?[Ss][Tt][Aa][Rr][Tt]=", '')
    text = text:gsub("[Tt]%.[Mm][Ee]/[%w_]+%?[Ss][Tt][Aa][Rr][Tt]=", '')

    local is_now_link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Tt][Ll][Gg][Rr][Mm]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Tt]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Cc][Hh][Aa][Tt]%.[Ww][Hh][Aa][Tt][Ss][Aa][Pp][Pp]%.[Cc][Oo][Mm]/")
    return is_now_link
end

local function check_if_link(text, group_link)
    local is_text_link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Tt][Ll][Gg][Rr][Mm]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Tt]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Cc][Hh][Aa][Tt]%.[Ww][Hh][Aa][Tt][Ss][Aa][Pp][Pp]%.[Cc][Oo][Mm]/")
    -- or text:match("[Aa][Dd][Ff]%.[Ll][Yy]/") or text:match("[Bb][Ii][Tt]%.[Ll][Yy]/") or text:match("[Gg][Oo][Oo]%.[Gg][Ll]/")

    if is_text_link then
        local test_more = false
        local is_bot = text:match("%?[Ss][Tt][Aa][Rr][Tt]=")
        if is_bot then
            -- if bot link test if removing that there are other links
            test_more = test_bot_link(text:lower())
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
                    return test_text_link(text:lower(), group_link:lower())
                end
            else
                -- if no group_link then link
                return true
            end
        end
    end
    return false
end

--[[local function check_if_username(text, chat_username)
    -- change all of these into t.me
    text = text:gsub("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/", '[Tt]%.[Mm][Ee]/')
    text = text:gsub("[Tt][Ll][Gg][Rr][Mm]%.[Mm][Ee]/", '[Tt]%.[Mm][Ee]/')
    text = text:gsub("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/", '[Tt]%.[Mm][Ee]/')

    local is_text_username = text:match("@(%w_)+") or
    text:match("[Tt]%.[Mm][Ee]/[%w_]+")
    local matches = { string.match(text, "@(%w_)+") }
    if not matches[1] then
        matches = { string.match(text, "[Tt]%.[Mm][Ee]/([%w_]+)") }
        if not matches[1] then
            return false
        end
    end
    if is_text_username then
        local test_more = false
        local is_bot = text:match("?[Ss][Tt][Aa][Rr][Tt]=")
        if is_bot then
            -- if bot link test if removing that there are other links
            test_more = test_bot_link(text:lower())
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
                    return test_text_link(text:lower(), group_link:lower())
                end
            else
                -- if no group_link then link
                return true
            end
        end
    end
    return false
end]]

local function action(msg, strict, reason)
    deleteMessage(msg.chat.id, msg.message_id)
    if strict then
        sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, reason))
    else
        sendMessage(msg.chat.id, warnUser(bot.id, msg.from.id, msg.chat.id, reason))
    end
end

local function check_msg(msg, settings)
    local lock_arabic = settings.lock_arabic
    local lock_bots = settings.lock_bots
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
    local mute_video_note = isMuted(msg.chat.id, 'video_note')
    local mute_voice_note = isMuted(msg.chat.id, 'voice_note')

    if not msg.service then
        if isMutedUser(msg.chat.id, msg.from.id) then
            print('muted user')
            deleteMessage(msg.chat.id, msg.message_id)
            return nil
        end
        if mute_all then
            print('all muted')
            deleteMessage(msg.chat.id, msg.message_id)
            return nil
        end
        if msg.entities then
            for k, v in pairs(msg.entities) do
                if v.url then
                    if lock_link then
                        if check_if_link(v.url, group_link) then
                            print('link found entities')
                            action(msg, strict, langs[msg.lang].reasonLockLinkEntities)
                            return nil
                        end
                    end
                end
            end
        end
        if msg.text then
            if mute_text then
                print('text muted')
                action(msg, strict, langs[msg.lang].reasonMutedText)
                return nil
            end
            -- msg.text checks
            if lock_spam then
                local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
                local _nl, real_digits = string.gsub(msg.text, '%d', '')
                if string.len(msg.text) > 2049 or ctrl_chars > 40 or real_digits > 2000 then
                    print('spam found')
                    action(msg, strict, langs[msg.lang].reasonLockSpam)
                    return nil
                end
            end
            if lock_link then
                if check_if_link(msg.text, group_link) then
                    print('link found')
                    action(msg, strict, langs[msg.lang].reasonLockLink)
                    return nil
                end
            end
            if lock_arabic then
                local is_squig_msg = msg.text:match("[\216-\219][\128-\191]")
                if is_squig_msg then
                    print('arabic found')
                    action(msg, strict, langs[msg.lang].reasonLockArabic)
                    return nil
                end
            end
            if lock_rtl then
                local is_rtl = msg.from.print_name:match("‮") or msg.text:match("‮")
                if is_rtl then
                    print('rtl found')
                    action(msg, strict, langs[msg.lang].reasonLockRTL)
                    return nil
                end
            end
        end
        if msg.caption then
            if mute_text then
                print('text muted')
                action(msg, strict, langs[msg.lang].reasonMutedText)
                return nil
            end
            if lock_link then
                if check_if_link(msg.caption, group_link) then
                    print('link found')
                    action(msg, strict, langs[msg.lang].reasonLockLink)
                    return nil
                end
            end
            if lock_arabic then
                local is_squig_caption = msg.caption:match("[\216-\219][\128-\191]")
                if is_squig_caption then
                    print('arabic found')
                    action(msg, strict, langs[msg.lang].reasonLockArabic)
                    return nil
                end
            end
            if lock_rtl then
                local is_rtl = msg.from.print_name:match("‮") or msg.caption:match("‮")
                if is_rtl then
                    print('rtl found')
                    action(msg, strict, langs[msg.lang].reasonLockRTL)
                    return nil
                end
            end
        end
        -- msg.media checks
        if msg.media and msg.media_type then
            if msg.media_type == 'audio' then
                if mute_audio then
                    print('audio muted')
                    action(msg, strict, langs[msg.lang].reasonMutedAudio)
                    return nil
                end
            elseif msg.media_type == 'contact' then
                if mute_contact then
                    print('contact muted')
                    action(msg, strict, langs[msg.lang].reasonMutedContacts)
                    return nil
                end
            elseif msg.media_type == 'document' then
                if mute_document then
                    print('document muted')
                    action(msg, strict, langs[msg.lang].reasonMutedDocuments)
                    return nil
                end
            elseif msg.media_type == 'gif' then
                if mute_gif then
                    print('gif muted')
                    action(msg, strict, langs[msg.lang].reasonMutedGifs)
                    return nil
                end
            elseif msg.media_type == 'location' then
                if mute_location then
                    print('location muted')
                    action(msg, strict, langs[msg.lang].reasonMutedLocations)
                    return nil
                end
            elseif msg.media_type == 'photo' then
                if mute_photo then
                    print('photo muted')
                    action(msg, strict, langs[msg.lang].reasonMutedPhoto)
                    return nil
                end
            elseif msg.media_type == 'sticker' then
                if mute_sticker then
                    print('sticker muted')
                    action(msg, strict, langs[msg.lang].reasonMutedStickers)
                    return nil
                end
            elseif msg.media_type == 'video' then
                if mute_video then
                    print('video muted')
                    action(msg, strict, langs[msg.lang].reasonMutedVideo)
                    return nil
                end
            elseif msg.media_type == 'video_note' then
                if mute_video_note then
                    print('video_note muted')
                    action(msg, strict, langs[msg.lang].reasonMutedVideo)
                    return nil
                end
            elseif msg.media_type == 'voice_note' then
                if mute_voice_note then
                    print('voice_note muted')
                    action(msg, strict, langs[msg.lang].reasonMutedVoicenotes)
                    return nil
                end
            end
        end
    else
        if mute_tgservice then
            print('tgservice muted')
            deleteMessage(msg.chat.id, msg.message_id)
            return nil
        end
        if msg.service_type == 'chat_add_user_link' then
            if lock_spam then
                local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
                if string.len(msg.from.print_name) > 70 or ctrl_chars > 40 then
                    print('name spam found')
                    deleteMessage(msg.chat.id, msg.message_id)
                    if strict then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] joined and banned (#spam name)")
                        sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonLockSpam))
                    end
                    return nil
                end
            end
            if lock_rtl then
                local is_rtl_name = msg.from.print_name:match("‮")
                if is_rtl_name then
                    print('rtl name found')
                    deleteMessage(msg.chat.id, msg.message_id)
                    if strict then
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and banned (#RTL char in name)")
                        sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonLockRTL))
                    end
                    return nil
                end
            end
            if lock_member then
                print('member locked')
                deleteMessage(msg.chat.id, msg.message_id)
                savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and banned (#lockmember)")
                sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonLockMembers))
                return nil
            end
        elseif msg.service_type == 'chat_add_user' or msg.service_type == 'chat_add_users' then
            for k, v in pairs(msg.added) do
                if lock_spam then
                    local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
                    if string.len(v.print_name) > 70 or ctrl_chars > 40 then
                        print('name spam found')
                        deleteMessage(msg.chat.id, msg.message_id)
                        if strict then
                            savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] added [" .. v.id .. "]: added user banned (#spam name) ")
                            sendMessage(msg.chat.id, banUser(bot.id, v.id, msg.chat.id, langs[msg.lang].reasonLockSpam))
                        end
                        return nil
                    end
                end
                if lock_rtl then
                    local is_rtl_name = v.print_name:match("‮")
                    if is_rtl_name then
                        print('rtl name found')
                        deleteMessage(msg.chat.id, msg.message_id)
                        if strict then
                            savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. v.id .. "]: added user banned (#RTL char in name)")
                            sendMessage(msg.chat.id, banUser(bot.id, v.id, msg.chat.id, langs[msg.lang].reasonLockRTL))
                        end
                        return nil
                    end
                end
                if lock_member then
                    print('member locked')
                    deleteMessage(msg.chat.id, msg.message_id)
                    sendMessage(msg.chat.id, warnUser(bot.id, msg.adder.id, msg.chat.id, langs[msg.lang].reasonLockMembers))
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. v.id .. "]: added user banned  (#lockmember)")
                    sendMessage(msg.chat.id, banUser(bot.id, v.id, msg.chat.id, langs[msg.lang].reasonLockMembers))
                    return nil
                end
                if lock_bots then
                    if v.username then
                        if string.sub(v.username:lower(), -3) == 'bot' then
                            print('bots locked')
                            -- Will ban bots added by normal users
                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added a bot > @" .. v.username)
                            -- Save to logs
                            sendMessage(msg.chat.id, banUser(bot.id, v.id, msg.chat.id, langs[msg.lang].reasonLockBots))
                            return nil
                        end
                    end
                end
            end
        end
        if msg.service_type == 'chat_del_user' or msg.service_type == 'chat_del_user_leave' then
            if lock_leave then
                if not is_mod2(msg.removed.id, msg.chat.id) then
                    print('leave locked')
                    sendMessage(msg.chat.id, banUser(bot.id, msg.removed.id, msg.chat.id, langs[msg.lang].reasonLockLeave))
                    return nil
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
            if not isWhitelisted(msg.chat.tg_cli_id, msg.from.id) and not msg.from.is_mod then
                -- if regular user
                local settings = nil
                if data[tostring(msg.chat.id)] then
                    if data[tostring(msg.chat.id)].settings then
                        settings = data[tostring(msg.chat.id)].settings
                    end
                end
                if settings then
                    return check_msg(msg, settings)
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