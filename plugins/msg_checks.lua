-- Empty tables for solving multiple problems(thanks to @topkecleon)
local cronTable = {
    resolveUsernamesTable =
    {
        -- chat_id = { valMsg, valTot }
    }
}

local test_data = {
    link = nil,
    settings =
    {
        locks =
        {
            arabic = 7,
            bots = 7,
            forward = 7,
            gbanned = 7,
            leave = 7,
            links = 7,
            members = 7,
            rtl = 7,
            spam = 7,
        },
        mutes =
        {
            all = 7,
            audios = 7,
            contacts = 7,
            documents = 7,
            games = 7,
            gifs = 7,
            locations = 7,
            photos = 7,
            stickers = 7,
            text = 7,
            tgservices = 7,
            videos = 7,
            video_notes = 7,
            voice_notes = 7,
        },
    },
    whitelist = { links = { "@username", }, },
}

local function pre_process_links(text)
    if text then
        -- make all the telegram's links t.me
        text = links_to_tdotme(text)
        -- remove http(s)
        text = text:gsub("[Hh][Tt][Tt][Pp][Ss]?://", '')
        -- remove www.
        text = text:gsub("[Ww][Ww][Ww]%.", '')
        return text:lower()
    end
end

local function remove_whitelisted_links(text, links_whitelist, group_link)
    if links_whitelist then
        for k, v in pairs(links_whitelist) do
            if string.starts(v, '@') then
                for word in string.gmatch(text, '(@[%w_]+)') do
                    if word == v then
                        text = text:gsub(word:gsub('@', ''), '')
                    end
                end
            else
                text = text:gsub(v, '')
            end
        end
    end
    if group_link then
        text = text:gsub(group_link, '')
    end
    return text
end

local function test_bot_link(text)
    -- remove all possible bot's links and test if link again
    text = text:gsub("[Tt]%.[Mm][Ee]/[%w_]+%?[Ss][Tt][Aa][Rr][Tt]=", '')

    local is_now_link = text:match("[Tt]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Cc][Hh][Aa][Tt]%.[Ww][Hh][Aa][Tt][Ss][Aa][Pp][Pp]%.[Cc][Oo][Mm]/")
    return is_now_link
end

local function check_if_link(text, links_whitelist, group_link)
    text = pre_process_links(text)
    text = remove_whitelisted_links(text, links_whitelist, group_link)
    local is_text_link = text:match("[Tt]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or
    text:match("[Cc][Hh][Aa][Tt]%.[Ww][Hh][Aa][Tt][Ss][Aa][Pp][Pp]%.[Cc][Oo][Mm]/")
    -- or text:match("[Aa][Dd][Ff]%.[Ll][Yy]/") or text:match("[Bb][Ii][Tt]%.[Ll][Yy]/") or text:match("[Gg][Oo][Oo]%.[Gg][Ll]/")

    local tmp = text
    -- remove joinchat links
    tmp = tmp:gsub('[Tt]%.[Mm][Ee]/[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/([^%s]+)', '')
    -- remove ?start=blabla and things like that
    tmp = tmp:gsub('%?([^%s]+)', '')
    -- make links usernames
    tmp = tmp:gsub('[Tt]%.[Mm][Ee]/', '@')
    printvardump(cronTable.resolveUsernamesTable)
    if not cronTable.resolveUsernamesTable[tostring(msg.chat.id)] then
        print('in')
        cronTable.resolveUsernamesTable[tostring(msg.chat.id)] = { valMsg = 0, valTot = 0 }
    end
    print('1')
    cronTable.resolveUsernamesTable[tostring(msg.chat.id)].valMsg = 0
    print('2')
    cronTable.resolveUsernamesTable[tostring(msg.chat.id)].valTot = cronTable.resolveUsernamesTable[tostring(msg.chat.id)].valTot or 0
    print('postcron')
    while string.match(tmp, '@[%w_]+') and cronTable.resolveUsernamesTable[tostring(msg.chat.id)].valMsg < 5 and cronTable.resolveUsernamesTable[tostring(msg.chat.id)].valTot < 30 do
        print('incron')
        cronTable.resolveUsernamesTable[tostring(msg.chat.id)].valMsg = cronTable.resolveUsernamesTable[tostring(msg.chat.id)].valMsg + 1
        cronTable.resolveUsernamesTable[tostring(msg.chat.id)].valTot = cronTable.resolveUsernamesTable[tostring(msg.chat.id)].valTot + 1
        if APIgetChat(string.match(tmp, '@[%w_]+'), true) then
            return true
        else
            tmp = tmp:gsub(string.match(tmp, '@[%w_]+'), '')
        end
    end
    print('endcron')
    if is_text_link then
        local is_bot = text:match("%?[Ss][Tt][Aa][Rr][Tt]=")
        if is_bot then
            -- if bot link test if removing that there are other links
            return test_bot_link(text:lower())
        else
            -- if not bot link then test if there are links
            return true
        end
    end
    return false
end

local function oldAction(msg, strict, reason)
    deleteMessage(msg.chat.id, msg.message_id)
    if not globalCronTable.punishedTable[tostring(msg.chat.id)][tostring(msg.from.id)] then
        if not strict then
            sendMessage(msg.chat.id, warnUser(bot.id, msg.from.id, msg.chat.id, reason))
        else
            sendMessage(msg.chat.id, banUser(bot.id, msg.from.id, msg.chat.id, reason))
        end
    end
end

local function my_tonumber(field)
    return tonumber(field) or 0
end

local function check_msg(msg, group_data, pre_process_function)
    local group_link = nil
    if group_data.link then
        group_link = group_data.link
        group_link = links_to_tdotme(group_link)
        group_link = pre_process_links(group_link)
    end
    local links_whitelist = group_data.whitelist.links
    -- locks
    local lock_arabic = group_data.settings.locks.arabic
    local lock_bots = group_data.settings.locks.bots
    local lock_forward = group_data.settings.locks.forward
    local lock_gbanned = group_data.settings.locks.gbanned
    local lock_leave = group_data.settings.locks.leave
    local lock_links = group_data.settings.locks.links
    local lock_members = group_data.settings.locks.members
    local lock_rtl = group_data.settings.locks.rtl
    local lock_spam = group_data.settings.locks.spam
    -- mutes
    local mute_all = group_data.settings.mutes.all
    local mute_audio = group_data.settings.mutes.audios
    local mute_contacts = group_data.settings.mutes.contacts
    local mute_documents = group_data.settings.mutes.documents
    local mute_games = group_data.settings.mutes.games
    local mute_gifs = group_data.settings.mutes.gifs
    local mute_locations = group_data.settings.mutes.locations
    local mute_photos = group_data.settings.mutes.photos
    local mute_stickers = group_data.settings.mutes.stickers
    local mute_text = group_data.settings.mutes.text
    local mute_tgservices = group_data.settings.mutes.tgservices
    local mute_videos = group_data.settings.mutes.videos
    local mute_video_notes = group_data.settings.mutes.video_notes
    local mute_voice_notes = group_data.settings.mutes.voice_notes

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
        if my_tonumber(mute_all) > 0 then
            if pre_process_function then
                print('all muted')
                sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_all, langs[msg.lang].reasonMutedAll, msg.message_id))
                return nil
            else
                text = text .. langs[msg.lang].reasonMutedAll
            end
        end
        if msg.entities then
            for k, v in pairs(msg.entities) do
                if v.url then
                    if my_tonumber(lock_links) > 0 then
                        local tmp = v.url
                        if check_if_link(tmp, links_whitelist, group_link) then
                            if pre_process_function then
                                print('link found entities')
                                sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, lock_links, langs[msg.lang].reasonLockLinkEntities, msg.message_id))
                                return nil
                            else
                                text = text .. langs[msg.lang].reasonLockLinkEntities
                            end
                        end
                    end
                end
            end
        end
        if msg.forward then
            if msg.forward_from_chat then
                if my_tonumber(lock_forward) > 0 then
                    local whitelisted = false
                    for k, v in pairs(links_whitelist) do
                        if tostring(v) == tostring(msg.forward_from_chat.id) then
                            whitelisted = true
                        end
                    end
                    if not whitelisted then
                        if pre_process_function then
                            print('link (forward) found')
                            sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, lock_forward, langs[msg.lang].reasonLockLinkForward, msg.message_id))
                            return nil
                        else
                            text = text .. langs[msg.lang].reasonLockLinkForward
                        end
                    end
                end
            end
        end
        if msg.text then
            local textToUse = msg.text
            if msg.caption then
                textToUse = msg.caption
            end
            if my_tonumber(mute_text) > 0 and not msg.media then
                if pre_process_function then
                    print('text muted')
                    sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_text, langs[msg.lang].reasonMutedText, msg.message_id))
                    return nil
                else
                    text = text .. langs[msg.lang].reasonMutedText
                end
            end
            print('mutetext passed')
            -- textToUse checks
            if my_tonumber(lock_spam) > 0 then
                local _nl, ctrl_chars = string.gsub(textToUse, '%c', '')
                local _nl, real_digits = string.gsub(textToUse, '%d', '')
                if string.len(textToUse) > 2049 or ctrl_chars > 40 or real_digits > 2000 then
                    if pre_process_function then
                        print('spam found')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, lock_spam, langs[msg.lang].reasonLockSpam, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockSpam
                    end
                end
            end
            print('lockspam passed')
            if my_tonumber(lock_links) > 0 then
                local tmp = textToUse
                if check_if_link(tmp, links_whitelist, group_link) then
                    if pre_process_function then
                        print('link found')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, lock_links, langs[msg.lang].reasonLockLink, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockLink
                    end
                end
            end
            print('locklinks passed')
            if my_tonumber(lock_arabic) > 0 then
                local is_squig_msg = textToUse:match("[\216-\219][\128-\191]")
                if is_squig_msg then
                    if pre_process_function then
                        print('arabic found')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, lock_arabic, langs[msg.lang].reasonLockArabic, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockArabic
                    end
                end
            end
            print('lockarabic passed')
            if my_tonumber(lock_rtl) > 0 then
                local is_rtl = msg.from.print_name:match("‮") or textToUse:match("‮")
                if is_rtl then
                    if pre_process_function then
                        print('rtl found')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, lock_rtl, langs[msg.lang].reasonLockRTL, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockRTL
                    end
                end
            end
            print('lockrtl passed')
        end
        print('before media check')
        -- msg.media checks
        if msg.media and msg.media_type then
            print('media check')
            if msg.media_type == 'audio' then
                if my_tonumber(mute_audio) > 0 then
                    if pre_process_function then
                        print('audio muted')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_audio, langs[msg.lang].reasonMutedAudio, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedAudio
                    end
                end
            elseif msg.media_type == 'contact' then
                if my_tonumber(mute_contacts) > 0 then
                    if pre_process_function then
                        print('contact muted')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_contacts, langs[msg.lang].reasonMutedContacts, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedContacts
                    end
                end
            elseif msg.media_type == 'document' then
                if my_tonumber(mute_documents) > 0 then
                    if pre_process_function then
                        print('document muted')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_documents, langs[msg.lang].reasonMutedDocuments, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedDocuments
                    end
                end
            elseif msg.media_type == 'game' then
                if my_tonumber(mute_games) > 0 then
                    if pre_process_function then
                        print('game muted')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_games, langs[msg.lang].reasonMutedGame, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedGame
                    end
                end
            elseif msg.media_type == 'gif' then
                if my_tonumber(mute_gifs) > 0 then
                    if pre_process_function then
                        print('gif muted')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_gifs, langs[msg.lang].reasonMutedGifs, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedGifs
                    end
                end
            elseif msg.media_type == 'location' then
                if my_tonumber(mute_locations) > 0 then
                    if pre_process_function then
                        print('location muted')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_locations, langs[msg.lang].reasonMutedLocations, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedLocations
                    end
                end
            elseif msg.media_type == 'photo' then
                if my_tonumber(mute_photos) > 0 then
                    if pre_process_function then
                        print('photo muted')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_photos, langs[msg.lang].reasonMutedPhoto, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedPhoto
                    end
                end
            elseif msg.media_type == 'sticker' then
                if my_tonumber(mute_stickers) > 0 then
                    if pre_process_function then
                        print('sticker muted')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_stickers, langs[msg.lang].reasonMutedStickers, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedStickers
                    end
                end
            elseif msg.media_type == 'video' then
                if my_tonumber(mute_videos) > 0 then
                    if pre_process_function then
                        print('video muted')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_videos, langs[msg.lang].reasonMutedVideo, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedVideo
                    end
                end
            elseif msg.media_type == 'video_note' then
                print('video_note')
                print(mute_video_notes)
                print(my_tonumber(mute_video_notes))
                if my_tonumber(mute_video_notes) > 0 then
                    if pre_process_function then
                        print('video_note muted')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_video_notes, langs[msg.lang].reasonMutedVideonotes, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedVideonotes
                    end
                end
            elseif msg.media_type == 'voice_note' then
                if my_tonumber(mute_voice_notes) > 0 then
                    if pre_process_function then
                        print('voice_note muted')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, mute_voice_notes, langs[msg.lang].reasonMutedVoicenotes, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonMutedVoicenotes
                    end
                end
            end
        end
    else
        if my_tonumber(mute_tgservices) > 0 then
            if pre_process_function then
                print('tgservice muted')
                deleteMessage(msg.chat.id, msg.message_id)
                return nil
            else
                text = text .. langs[msg.lang].reasonMutedTgservice
            end
        end
        if msg.service_type == 'chat_add_user_link' then
            if my_tonumber(lock_spam) > 0 then
                local _nl, ctrl_chars = string.gsub(msg.from.print_name, '%c', '')
                if string.len(msg.from.print_name) > 70 or ctrl_chars > 40 then
                    if pre_process_function then
                        print('name spam found')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, lock_spam, langs[msg.lang].reasonLockSpam, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockSpam
                    end
                end
            end
            if my_tonumber(lock_rtl) > 0 then
                local is_rtl_name = msg.from.print_name:match("‮")
                if is_rtl_name then
                    if pre_process_function then
                        print('rtl name found')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, lock_rtl, langs[msg.lang].reasonLockRTL, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockRTL
                    end
                end
            end
            if my_tonumber(lock_members) > 0 then
                if pre_process_function then
                    print('members locked')
                    sendMessage(msg.chat.id, punishmentAction(bot.id, msg.from.id, msg.chat.id, lock_members, langs[msg.lang].reasonLockMembers, msg.message_id))
                    return nil
                else
                    text = text .. langs[msg.lang].reasonLockMembers
                end
            end
        elseif msg.service_type == 'chat_add_user' or msg.service_type == 'chat_add_users' then
            for k, v in pairs(msg.added) do
                if my_tonumber(lock_spam) > 0 then
                    local _nl, ctrl_chars = string.gsub(v.print_name, '%c', '')
                    if string.len(v.print_name) > 70 or ctrl_chars > 40 then
                        if pre_process_function then
                            print('name spam found')
                            sendMessage(msg.chat.id, punishmentAction(bot.id, v.id, msg.chat.id, lock_spam, langs[msg.lang].reasonLockSpam, msg.message_id))
                            return nil
                        else
                            text = text .. langs[msg.lang].reasonLockSpam
                        end
                    end
                end
                if my_tonumber(lock_rtl) > 0 then
                    local is_rtl_name = v.print_name:match("‮")
                    if is_rtl_name then
                        if pre_process_function then
                            print('rtl name found')
                            sendMessage(msg.chat.id, punishmentAction(bot.id, v.id, msg.chat.id, lock_rtl, langs[msg.lang].reasonLockRTL, msg.message_id))
                            return nil
                        else
                            text = text .. langs[msg.lang].reasonLockRTL
                        end
                    end
                end
                if my_tonumber(lock_members) > 0 then
                    if pre_process_function then
                        print('member locked')
                        deleteMessage(msg.chat.id, msg.message_id)
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.adder.id, msg.chat.id, lock_members, langs[msg.lang].reasonLockMembers, msg.message_id))
                        sendMessage(msg.chat.id, punishmentAction(bot.id, v.id, msg.chat.id, lock_members, langs[msg.lang].reasonLockMembers, msg.message_id))
                        return nil
                    else
                        text = text .. langs[msg.lang].reasonLockMembers
                    end
                end
                if my_tonumber(lock_bots) > 0 then
                    if v.is_bot then
                        if pre_process_function then
                            print('bots locked')
                            sendMessage(msg.chat.id, punishmentAction(bot.id, v.id, msg.chat.id, lock_bots, langs[msg.lang].reasonLockBots, msg.message_id))
                            return nil
                        else
                            text = text .. langs[msg.lang].reasonLockBots
                        end
                    end
                end
            end
        end
        if msg.service_type == 'chat_del_user' or msg.service_type == 'chat_del_user_leave' then
            if my_tonumber(lock_leave) > 0 then
                if not is_mod2(msg.removed.id, msg.chat.id) then
                    if pre_process_function then
                        print('leave locked')
                        sendMessage(msg.chat.id, punishmentAction(bot.id, msg.removed.id, msg.chat.id, lock_leave, langs[msg.lang].reasonLockLeave, msg.message_id))
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
        local settings = clone_table(test_data)
        if data[tostring(msg.chat.id)] then
            settings = clone_table(data[tostring(msg.chat.id)])
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
        cronTable.resolveUsernamesTable[tostring(msg.chat.id)] = cronTable.resolveUsernamesTable[tostring(msg.chat.id)] or { }
        -- Begin 'RondoMsgChecks' text checks by @rondoozle
        if data[tostring(msg.chat.id)] and not isWhitelisted(msg.chat.id, msg.from.id) and not msg.from.is_mod then
            -- if regular user
            msg = check_msg(msg, clone_table(data[tostring(msg.chat.id)]), true)
        end
        return msg
    end
    -- End 'RondoMsgChecks' text checks by @Rondoozle
end
-- End pre_process function

local function cron()
    -- clear that table on the top of the plugin
    cronTable = {
        resolveUsernamesTable = { }
    }
end

return {
    description = "MSG_CHECKS",
    cron = cron,
    patterns =
    {
        "^[#!/]([Cc][Hh][Ee][Cc][Kk][Mm][Ss][Gg])$",
        "^[#!/]([Cc][Hh][Ee][Cc][Kk][Mm][Ss][Gg]) (.*)$",
    },
    pre_process = pre_process,
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/checkmsg {reply}|{text}",
    },
}
-- End msg_checks.lua
-- By @Rondoozle
-- Modified by @EricSolinas for API