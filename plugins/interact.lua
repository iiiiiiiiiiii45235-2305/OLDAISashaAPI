local function run(msg, matches)
    if matches[1]:lower() == 'markdownecho' and matches[2] then
        if msg.from.is_mod then
            mystat('/markdownecho')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            if msg.reply then
                if not sendReply(msg.reply_to_message, matches[2], 'markdown') then
                    return langs[msg.lang].errorTryAgain
                end
            else
                if not sendMessage(msg.chat.id, matches[2], 'markdown') then
                    return langs[msg.lang].errorTryAgain
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'delmarkdownecho' and matches[2] then
        if msg.from.is_mod then
            mystat('/delmarkdownecho')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            deleteMessage(msg.chat.id, msg.message_id)
            if msg.reply then
                if not sendReply(msg.reply_to_message, matches[2], 'markdown') then
                    return langs[msg.lang].errorTryAgain
                end
            else
                if not sendMessage(msg.chat.id, matches[2], 'markdown') then
                    return langs[msg.lang].errorTryAgain
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'htmlecho' and matches[2] then
        if msg.from.is_mod then
            mystat('/htmlecho')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            if msg.reply then
                if not sendReply(msg.reply_to_message, matches[2], 'html') then
                    return langs[msg.lang].errorTryAgain
                end
            else
                if not sendMessage(msg.chat.id, matches[2], 'html') then
                    return langs[msg.lang].errorTryAgain
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'delhtmlecho' and matches[2] then
        if msg.from.is_mod then
            mystat('/delhtmlecho')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            deleteMessage(msg.chat.id, msg.message_id)
            if msg.reply then
                if not sendReply(msg.reply_to_message, matches[2], 'html') then
                    return langs[msg.lang].errorTryAgain
                end
            else
                if not sendMessage(msg.chat.id, matches[2], 'html') then
                    return langs[msg.lang].errorTryAgain
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'echo' and matches[2] then
        if msg.from.is_mod then
            mystat('/echo')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            if msg.reply then
                return sendReply(msg.reply_to_message, matches[2])
            else
                return sendMessage(msg.chat.id, matches[2])
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'delecho' and matches[2] then
        if msg.from.is_mod then
            mystat('/delecho')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            deleteMessage(msg.chat.id, msg.message_id)
            if msg.reply then
                return sendReply(msg.reply_to_message, matches[2])
            else
                return sendMessage(msg.chat.id, matches[2])
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'testuser' then
        mystat('/testuser')
        if msg.reply then
            if matches[2] then
                if matches[2]:lower() == 'from' then
                    if msg.reply_to_message.forward then
                        if msg.reply_to_message.forward_from then
                            if sendChatAction(msg.reply_to_message.forward_from.id, 'typing') then
                                return langs[msg.lang].userDidNotBlockBot
                            else
                                return langs[msg.lang].userBlockedBot
                            end
                        else
                            return langs[msg.lang].cantDoThisToChat
                        end
                    else
                        return langs[msg.lang].errorNoForward
                    end
                else
                    if sendChatAction(msg.reply_to_message.from.id, 'typing') then
                        return langs[msg.lang].userDidNotBlockBot
                    else
                        return langs[msg.lang].userBlockedBot
                    end
                end
            else
                if msg.reply_to_message.service then
                    if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                        local text = ''
                        if sendChatAction(msg.reply_to_message.adder.id, 'typing') then
                            text = text .. msg.reply_to_message.adder.id .. ' ' .. langs[msg.lang].userDidNotBlockBot .. '\n'
                        else
                            text = text .. msg.reply_to_message.adder.id .. ' ' .. langs[msg.lang].userBlockedBot .. '\n'
                        end
                        for k, v in pairs(msg.reply_to_message.added) do
                            if sendChatAction(msg.reply_to_message.from.id, 'typing') then
                                text = text .. v.id .. ' ' .. langs[msg.lang].userDidNotBlockBot .. '\n'
                            else
                                text = text .. v.id .. ' ' .. langs[msg.lang].userBlockedBot .. '\n'
                            end
                        end
                        return text ..(matches[2] or '') .. ' ' ..(matches[3] or '')
                    elseif msg.reply_to_message.service_type == 'chat_del_user' then
                        if sendChatAction(msg.reply_to_message.removed.id, 'typing') then
                            return langs[msg.lang].userDidNotBlockBot
                        else
                            return langs[msg.lang].userBlockedBot
                        end
                    else
                        if sendChatAction(msg.reply_to_message.from.id, 'typing') then
                            return langs[msg.lang].userDidNotBlockBot
                        else
                            return langs[msg.lang].userBlockedBot
                        end
                    end
                else
                    if sendChatAction(msg.reply_to_message.from.id, 'typing') then
                        return langs[msg.lang].userDidNotBlockBot
                    else
                        return langs[msg.lang].userBlockedBot
                    end
                end
            end
        elseif matches[2] and matches[2] ~= '' then
            if string.match(matches[2], '^%d+$') then
                if sendChatAction(matches[2], 'typing') then
                    return langs[msg.lang].userDidNotBlockBot
                else
                    return langs[msg.lang].userBlockedBot
                end
            else
                local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                if obj_user then
                    if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                        if sendChatAction(obj_user.id, 'typing') then
                            return langs[msg.lang].userDidNotBlockBot
                        else
                            return langs[msg.lang].userBlockedBot
                        end
                    end
                else
                    return langs[msg.lang].noObject
                end
            end
        end
        return
    end
    if matches[1]:lower() == 'typing' or matches[1]:lower() == 'upload_photo' or matches[1]:lower() == 'record_video' or matches[1]:lower() == 'upload_video' or matches[1]:lower() == 'record_audio' or matches[1]:lower() == 'upload_audio' or matches[1]:lower() == 'upload_document' or matches[1]:lower() == 'find_location' or matches[1]:lower() == 'record_videonote' or matches[1]:lower() == 'upload_videonote' then
        if msg.from.is_mod then
            mystat('/reactions')
            return sendChatAction(msg.chat.id, matches[1]:lower())
        else
            return langs[msg.lang].require_mod
        end
    end
    -- interact
    mystat('/interact')
    if matches[1]:lower() == 'sasha come va?' then
        return langs.phrases.interact.howareyou[math.random(#langs.phrases.interact.howareyou)]
    end
    if (matches[1]:lower() == 'sasha' and string.match(matches[2], '.*%?')) or matches[1]:lower() == '@aisashabot' then
        local rnd = math.random(0, 2)
        if rnd == 0 then
            return langs.phrases.interact.no[math.random(#langs.phrases.interact.no)]
        elseif rnd == 1 then
            return langs.phrases.interact.idontknow[math.random(#langs.phrases.interact.idontknow)]
        elseif rnd == 2 then
            return langs.phrases.interact.yes[math.random(#langs.phrases.interact.yes)]
        end
    end
    if matches[1]:lower() == 'sasha ti amo' or matches[1]:lower() == 'ti amo sasha' then
        return langs.phrases.interact.iloveyou[math.random(#langs.phrases.interact.iloveyou)]
    end
end

return {
    description = "INTERACT",
    patterns =
    {
        "^[#!/]([Ee][Cc][Hh][Oo]) +(.+)$",
        "^[#!/]([Dd][Ee][Ll][Ee][Cc][Hh][Oo]) +(.+)$",
        "^[#!/]([Mm][Aa][Rr][Kk][Dd][Oo][Ww][Nn][Ee][Cc][Hh][Oo]) +(.+)$",
        "^[#!/]([Dd][Ee][Ll][Mm][Aa][Rr][Kk][Dd][Oo][Ww][Nn][Ee][Cc][Hh][Oo]) +(.+)$",
        "^[#!/]([Hh][Tt][Mm][Ll][Ee][Cc][Hh][Oo]) +(.+)$",
        "^[#!/]([Dd][Ee][Ll][Hh][Tt][Mm][Ll][Ee][Cc][Hh][Oo]) +(.+)$",
        "^[#!/]([Tt][Ee][Ss][Tt][Uu][Ss][Ee][Rr]) (.*)$",
        "^[#!/]([Tt][Ee][Ss][Tt][Uu][Ss][Ee][Rr])$",
        -- react
        "^(@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Cc][Oo][Mm][Ee] [Vv][Aa]%?)$",
        "^([Ss][Aa][Ss][Hh][Aa])(.*%?)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Tt][Ii] [Aa][Mm][Oo])$",
        "^([Tt][Ii] [Aa][Mm][Oo] [Ss][Aa][Ss][Hh][Aa])$",
        -- reactions
        "^[#!/]([Tt][Yy][Pp][Ii][Nn][Gg])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Pp][Hh][Oo][Tt][Oo])$",
        "^[#!/]([Rr][Ee][Cc][Oo][Rr][Dd]_[Vv][Ii][Dd][Ee][Oo])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Vv][Ii][Dd][Ee][Oo])$",
        "^[#!/]([Rr][Ee][Cc][Oo][Rr][Dd]_[Aa][Uu][Dd][Ii][Oo])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Aa][Uu][Dd][Ii][Oo])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Dd][Oo][Cc][Uu][Mm][Ee][Nn][Tt])$",
        "^[#!/]([Ff][Ii][Nn][Dd]_[Ll][Oo][Cc][Aa][Tt][Ii][Oo][Nn])$",
        "^[#!/]([Rr][Ee][Cc][Oo][Rr][Dd]_[Vv][Ii][Dd][Ee][Oo][Nn][Oo][Tt][Ee])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Vv][Ii][Dd][Ee][Oo][Nn][Oo][Tt][Ee])$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#typing",
        "#upload_photo",
        "#record_video",
        "#upload_video",
        "#record_audio",
        "#upload_audio",
        "#upload_document",
        "#find_location",
        "#record_videonote",
        "#upload_videonote",
        "#testuser <id>|<username>|<reply>|from",
        "MOD",
        "#echo <text>",
        "#delecho <text>",
        "#markdownecho <text>",
        "#delmarkdownecho <text>",
        "#htmlecho <text>",
        "#delhtmlecho <text>",
    },
}