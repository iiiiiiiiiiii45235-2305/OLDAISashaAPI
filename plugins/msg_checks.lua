local test_settings = {
    flood = true,
    flood_max = 5,
    lock_arabic = true,
    lock_bots = true,
    lock_group_link = true,
    lock_leave = true,
    lock_link = true,
    lock_member = true,
    lock_name = true,
    lock_photo = true,
    lock_rtl = true,
    lock_spam = true,
    mutes =
    {
        all = true,
        audio = true,
        contact = true,
        document = true,
        gif = true,
        location = true,
        photo = true,
        sticker = true,
        text = true,
        tgservice = true,
        video = true,
        video_note = true,
        voice_note = true,
    },
    set_link = nil,
    strict = true,
    warn_max = 3,
}

local function links_to_tdotme(text)
    text = text:gsub("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Mm][Ee]/", '[Tt]%.[Mm][Ee]/')
    text = text:gsub("[Tt][Ll][Gg][Rr][Mm]%.[Mm][Ee]/", '[Tt]%.[Mm][Ee]/')
    text = text:gsub("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm]%.[Dd][Oo][Gg]/", '[Tt]%.[Mm][Ee]/')
    return text
end

local function test_text_link(text, group_link)
    -- remove group_link and test if link again
    text = text:gsub(links_to_tdotme(group_link:lower()), '')

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

local function check_msg(msg, settings, pre_process_function)
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

    local mute_all = settings.mutes['all']
    local mute_audio = settings.mutes['audio']
    local mute_contact = settings.mutes['contact']
    local mute_document = settings.mutes['document']
    local mute_gif = settings.mutes['gif']
    local mute_location = settings.mutes['location']
    local mute_photo = settings.mutes['photo']
    local mute_sticker = settings.mutes['sticker']
    local mute_text = settings.mutes['text']
    local mute_tgservice = settings.mutes['tgservice']
    local mute_video = settings.mutes['video']
    local mute_video_note = settings.mutes['video_note']
    local mute_voice_note = settings.mutes['voice_note']

    local text = langs[msg.lang].checkMsg
    if not msg.service then
        if isMutedUser(msg.chat.id, msg.from.id) then
            if pre_process_function then
                print('muted user')
                deleteMessage(msg.chat.id, msg.message_id)
                return nil
            else
                text = text .. langs[msg.lang].reasonMutedUser
            end
        end
        if mute_all then
            if pre_process_function then
                print('all muted')
                deleteMessage(msg.chat.id, msg.message_id)
                return nil
            else
                text = text .. langs[msg.lang].reasonMutedAll
            end
        end
        if msg.entities then
            for k, v in pairs(msg.entities) do
                if v.url then
                    if lock_link then
                        if check_if_link(v.url, group_link) then
                            if pre_process_function then
                                print('link found entities')
                                action(msg, strict, langs[msg.lang].reasonLockLinkEntities)
                                return nil
                            else
                                text = text .. langs[msg.lang].reasonLockLinkEntities
                            end
                        end
                    end
                end
            end
        end
        if msg.text then
            if mute_text then
                if pre_process_function then
                    print('text muted')
                    action(msg, strict, langs[msg.lang].reasonMutedText)
                    return nil
                else
                    text = text .. langs[msg.lang].reasonMutedText
                end
            end
            -- msg.text checks
            if lock_spam then
                local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
                local _nl, real_digits = string.gsub(msg.text, '%d', '')
                if string.len(msg.text) > 2049 or ctrl_chars > 40 or real_digits > 2000 then
                    if pre_process_function then
                        print('spam found')
                        action(msg, strict, langs[msg.lang].reasonLockSpam)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockSpam
                    end
                end
            end
            if lock_link then
                if check_if_link(msg.text, group_link) then
                    if pre_process_function then
                        print('link found')
                        action(msg, strict, langs[msg.lang].reasonLockLink)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockLink
                    end
                end
                local tmp = msg.text:lower()
                tmp = links_to_tdotme(tmp)
                tmp = tmp:gsub('http://t.me/joinchat/([^%s]+)', '')
                tmp = tmp:gsub('http://t.me/([%a][%w_]+)', '@')
                while string.match(tmp, '@[^%s]+') do
                    if APIgetChat(string.match(tmp, '@[^%s]+'), true) then
                        if pre_process_function then
                            print('link (public channel/supergroup username) found')
                            action(msg, strict, langs[msg.lang].reasonLockLink)
                            return nil
                        else
                            text = text .. langs[msg.lang].reasonLockLink
                            tmp = tmp:gsub(string.match(tmp, '@[^%s]+'), '')
                        end
                    else
                        tmp = tmp:gsub(string.match(tmp, '@[^%s]+'), '')
                    end
                end
            end
            if lock_arabic then
                local is_squig_msg = msg.text:match("[\216-\219][\128-\191]")
                if is_squig_msg then
                    if pre_process_function then
                        print('arabic found')
                        action(msg, strict, langs[msg.lang].reasonLockArabic)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockArabic
                    end
                end
            end
            if lock_rtl then
                local is_rtl = msg.from.print_name:match("‮") or msg.text:match("‮")
                if is_rtl then
                    if pre_process_function then
                        print('rtl found')
                        action(msg, strict, langs[msg.lang].reasonLockRTL)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockRTL
                    end
                end
            end
        end
        if msg.caption then
            if mute_text then
                if pre_process_function then
                    print('text muted')
                    action(msg, strict, langs[msg.lang].reasonMutedText)
                    return nil
                else
                    text = text .. langs[msg.lang].reasonMutedText
                end
            end
            if lock_link then
                if check_if_link(msg.caption, group_link) then
                    if pre_process_function then
                        print('link found')
                        action(msg, strict, langs[msg.lang].reasonLockLink)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockLink
                    end
                end
                local tmp = msg.caption
                tmp = links_to_tdotme(tmp)
                tmp = tmp:gsub('http://t.me/joinchat/([^%s]+)', '')
                tmp = tmp:gsub('http://t.me/([%a][%w_]+)', '@')
                while string.match(tmp, '@[^%s]+') do
                    if APIgetChat(string.match(tmp, '@[^%s]+'), true) then
                        if pre_process_function then
                            print('link (public channel/supergroup username) found')
                            action(msg, strict, langs[msg.lang].reasonLockLink)
                            return nil
                        else
                            text = text .. langs[msg.lang].reasonLockLink
                            tmp = tmp:gsub(string.match(tmp, '@[^%s]+'), '')
                        end
                    else
                        tmp = tmp:gsub(string.match(tmp, '@[^%s]+'), '')
                    end
                end
            end
            if lock_arabic then
                local is_squig_caption = msg.caption:match("[\216-\219][\128-\191]")
                if is_squig_caption then
                    if pre_process_function then
                        print('arabic found')
                        action(msg, strict, langs[msg.lang].reasonLockArabic)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockArabic
                    end
                end
            end
            if lock_rtl then
                local is_rtl = msg.from.print_name:match("‮") or msg.caption:match("‮")
                if is_rtl then
                    if pre_process_function then
                        print('rtl found')
                        action(msg, strict, langs[msg.lang].reasonLockRTL)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockRTL
                    end
                end
            end
        end
        -- msg.media checks
        if msg.media and msg.media_type then
            if msg.media_type == 'audio' then
                if mute_audio then
                    if pre_process_function then
                        print('audio muted')
                        action(msg, strict, langs[msg.lang].reasonMutedAudio)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedAudio
                    end
                end
            elseif msg.media_type == 'contact' then
                if mute_contact then
                    if pre_process_function then
                        print('contact muted')
                        action(msg, strict, langs[msg.lang].reasonMutedContacts)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedContacts
                    end
                end
            elseif msg.media_type == 'document' then
                if mute_document then
                    if pre_process_function then
                        print('document muted')
                        action(msg, strict, langs[msg.lang].reasonMutedDocuments)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedDocuments
                    end
                end
            elseif msg.media_type == 'gif' then
                if mute_gif then
                    if pre_process_function then
                        print('gif muted')
                        action(msg, strict, langs[msg.lang].reasonMutedGifs)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedGifs
                    end
                end
            elseif msg.media_type == 'location' then
                if mute_location then
                    if pre_process_function then
                        print('location muted')
                        action(msg, strict, langs[msg.lang].reasonMutedLocations)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedLocations
                    end
                end
            elseif msg.media_type == 'photo' then
                if mute_photo then
                    if pre_process_function then
                        print('photo muted')
                        action(msg, strict, langs[msg.lang].reasonMutedPhoto)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedPhoto
                    end
                end
            elseif msg.media_type == 'sticker' then
                if mute_sticker then
                    if pre_process_function then
                        print('sticker muted')
                        action(msg, strict, langs[msg.lang].reasonMutedStickers)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedStickers
                    end
                end
            elseif msg.media_type == 'video' then
                if mute_video then
                    if pre_process_function then
                        print('video muted')
                        action(msg, strict, langs[msg.lang].reasonMutedVideo)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedVideo
                    end
                end
            elseif msg.media_type == 'video_note' then
                if mute_video_note then
                    if pre_process_function then
                        print('video_note muted')
                        action(msg, strict, langs[msg.lang].reasonMutedVideonotes)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedVideonotes
                    end
                end
            elseif msg.media_type == 'voice_note' then
                if mute_voice_note then
                    if pre_process_function then
                        print('voice_note muted')
                        action(msg, strict, langs[msg.lang].reasonMutedVoicenotes)
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedVoicenotes
                    end
                end
            end
        end
    else
        if mute_tgservice then
            if pre_process_function then
                print('tgservice muted')
                deleteMessage(msg.chat.id, msg.message_id)
                return nil
            else
                text = text .. langs[msg.lang].reasonMutedTgservice
            end
        end
        if msg.service_type == 'chat_add_user_link' then
            if lock_spam then
                local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
                if string.len(msg.from.print_name) > 70 or ctrl_chars > 40 then
                    if pre_process_function then
                        print('name spam found')
                        deleteMessage(msg.chat.id, msg.message_id)
                        if strict then
                            savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] joined and banned (#spam name)")
                            sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonLockSpam))
                        end
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockSpam
                    end
                end
            end
            if lock_rtl then
                local is_rtl_name = msg.from.print_name:match("‮")
                if is_rtl_name then
                    if pre_process_function then
                        print('rtl name found')
                        deleteMessage(msg.chat.id, msg.message_id)
                        if strict then
                            savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and banned (#RTL char in name)")
                            sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonLockRTL))
                        end
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockRTL
                    end
                end
            end
            if lock_member then
                if pre_process_function then
                    print('member locked')
                    deleteMessage(msg.chat.id, msg.message_id)
                    savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] joined and banned (#lockmember)")
                    sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, langs[msg.lang].reasonLockMembers))
                    return nil
                else
                    text = text .. langs[msg.lang].reasonLockMembers
                end
            end
        elseif msg.service_type == 'chat_add_user' or msg.service_type == 'chat_add_users' then
            for k, v in pairs(msg.added) do
                if lock_spam then
                    local _nl, ctrl_chars = string.gsub(msg.text, '%c', '')
                    if string.len(v.print_name) > 70 or ctrl_chars > 40 then
                        if pre_process_function then
                            print('name spam found')
                            deleteMessage(msg.chat.id, msg.message_id)
                            if strict then
                                savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " [" .. msg.from.id .. "] added [" .. v.id .. "]: added user banned (#spam name) ")
                                sendMessage(msg.chat.id, banUser(bot.id, v.id, msg.chat.id, langs[msg.lang].reasonLockSpam))
                            end
                            return nil
                        else
                            text = text .. langs[msg.lang].reasonLockSpam
                        end
                    end
                end
                if lock_rtl then
                    local is_rtl_name = v.print_name:match("‮")
                    if is_rtl_name then
                        if pre_process_function then
                            print('rtl name found')
                            deleteMessage(msg.chat.id, msg.message_id)
                            if strict then
                                savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. v.id .. "]: added user banned (#RTL char in name)")
                                sendMessage(msg.chat.id, banUser(bot.id, v.id, msg.chat.id, langs[msg.lang].reasonLockRTL))
                            end
                            return nil
                        else
                            text = text .. langs[msg.lang].reasonLockRTL
                        end
                    end
                end
                if lock_member then
                    if pre_process_function then
                        print('member locked')
                        deleteMessage(msg.chat.id, msg.message_id)
                        sendMessage(msg.chat.id, warnUser(bot.id, msg.adder.id, msg.chat.id, langs[msg.lang].reasonLockMembers))
                        savelog(msg.chat.id, tostring(msg.from.print_name:gsub("‮", "")):gsub("_", " ") .. " User [" .. msg.from.id .. "] added [" .. v.id .. "]: added user banned  (#lockmember)")
                        sendMessage(msg.chat.id, banUser(bot.id, v.id, msg.chat.id, langs[msg.lang].reasonLockMembers))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockMembers
                    end
                end
                if lock_bots then
                    if v.is_bot then
                        if pre_process_function then
                            print('bots locked')
                            savelog(msg.chat.id, msg.from.print_name .. " [" .. msg.from.id .. "] added a bot > @" .. v.username)
                            sendMessage(msg.chat.id, banUser(bot.id, v.id, msg.chat.id, langs[msg.lang].reasonLockBots))
                            return nil
                        else
                            text = text .. langs[msg.lang].reasonLockBots
                        end
                    end
                end
            end
        end
        if msg.service_type == 'chat_del_user' or msg.service_type == 'chat_del_user_leave' then
            if lock_leave then
                if not is_mod2(msg.removed.id, msg.chat.id) then
                    if pre_process_function then
                        print('leave locked')
                        sendMessage(msg.chat.id, banUser(bot.id, msg.removed.id, msg.chat.id, langs[msg.lang].reasonLockLeave))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockLeave
                    end
                end
            end
        end
    end
    if pre_process_function then
        return msg
    else
        if text == langs[msg.lang].checkMsg then
            return langs[msg.lang].checkMsgClean
        else
            return text
        end
    end
end

local function run(msg, matches)
    if matches[1]:lower() == 'checkmsg' then
        local settings = clone_table(test_settings)
        if data[tostring(msg.chat.id)] then
            if data[tostring(msg.chat.id)].settings then
                settings = clone_table(data[tostring(msg.chat.id)].settings)
            end
        end
        if msg.reply then
            return sendReply(msg.reply_to_message, check_msg(msg.reply_to_message, settings), false)
        elseif matches[2] then
            return check_msg(msg, settings, false)
        end
    end
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
                        settings = clone_table(data[tostring(msg.chat.id)].settings)
                    end
                end
                if settings then
                    return check_msg(msg, settings, true)
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
    patterns =
    {
        "^[#!/]([Cc][Hh][Ee][Cc][Kk][Mm][Ss][Gg])$",
        "^[#!/]([Cc][Hh][Ee][Cc][Kk][Mm][Ss][Gg]) (.*)$",
    },
    pre_process = pre_process,
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#checkmsg <reply>|<text>",
    },
}
-- End msg_checks.lua
-- By @Rondoozle
-- Modified by @EricSolinas for API