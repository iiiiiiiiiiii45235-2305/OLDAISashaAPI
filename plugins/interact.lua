local function run(msg, matches)
    if matches[1]:lower() == 'markdownedit' and matches[2] then
        if msg.from.is_mod then
            mystat('/markdownedit')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            if msg.reply then
                if msg.reply_to_message.from.id == bot.id then
                    if not editMessage(msg.chat.id, msg.reply_to_message.message_id, matches[2], nil, 'markdown') then
                        return langs[msg.lang].errorTryAgain
                    end
                else
                    return langs[msg.lang].cantEditOthersMessages
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'delmarkdownedit' and matches[2] then
        if msg.from.is_mod then
            mystat('/delmarkdownedit')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            if not deleteMessage(msg.chat.id, msg.message_id, true) then
                return langs[msg.lang].cantDeleteMessage
            end
            if msg.reply then
                if msg.reply_to_message.from.id == bot.id then
                    if not editMessage(msg.chat.id, msg.reply_to_message.message_id, matches[2], nil, 'markdown') then
                        return sendMessage(msg.chat.id, langs[msg.lang].errorTryAgain)
                    end
                else
                    return sendMessage(msg.chat.id, langs[msg.lang].cantEditOthersMessages)
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
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
            if not deleteMessage(msg.chat.id, msg.message_id, true) then
                return langs[msg.lang].cantDeleteMessage
            end
            if msg.reply then
                if not sendReply(msg.reply_to_message, matches[2], 'markdown') then
                    return sendMessage(msg.chat.id, langs[msg.lang].errorTryAgain)
                end
            else
                if not sendMessage(msg.chat.id, matches[2], 'markdown') then
                    return sendMessage(msg.chat.id, langs[msg.lang].errorTryAgain)
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'htmledit' and matches[2] then
        if msg.from.is_mod then
            mystat('/htmledit')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            if msg.reply then
                if msg.reply_to_message.from.id == bot.id then
                    if not editMessage(msg.chat.id, msg.reply_to_message.message_id, matches[2], nil, 'html') then
                        return langs[msg.lang].errorTryAgain
                    end
                else
                    return langs[msg.lang].cantEditOthersMessages
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'delhtmledit' and matches[2] then
        if msg.from.is_mod then
            mystat('/delhtmledit')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            if not deleteMessage(msg.chat.id, msg.message_id, true) then
                return langs[msg.lang].cantDeleteMessage
            end
            if msg.reply then
                if msg.reply_to_message.from.id == bot.id then
                    if not editMessage(msg.chat.id, msg.reply_to_message.message_id, matches[2], nil, 'html') then
                        return sendMessage(msg.chat.id, langs[msg.lang].errorTryAgain)
                    end
                else
                    return sendMessage(msg.chat.id, langs[msg.lang].cantEditOthersMessages)
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
            if not deleteMessage(msg.chat.id, msg.message_id, true) then
                return langs[msg.lang].cantDeleteMessage
            end
            if msg.reply then
                if not sendReply(msg.reply_to_message, matches[2], 'html') then
                    return sendMessage(msg.chat.id, langs[msg.lang].errorTryAgain)
                end
            else
                if not sendMessage(msg.chat.id, matches[2], 'html') then
                    return sendMessage(msg.chat.id, langs[msg.lang].errorTryAgain)
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'edit' and matches[2] then
        if msg.from.is_mod then
            mystat('/edit')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            if msg.reply then
                if msg.reply_to_message.from.id == bot.id then
                    return editMessage(msg.chat.id, msg.reply_to_message.message_id, matches[2])
                else
                    return langs[msg.lang].cantEditOthersMessages
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'deledit' and matches[2] then
        if msg.from.is_mod then
            mystat('/deledit')
            if string.match(matches[2], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                return langs[msg.lang].crossexecDenial
            end
            if not deleteMessage(msg.chat.id, msg.message_id, true) then
                return langs[msg.lang].cantDeleteMessage
            end
            if msg.reply then
                if msg.reply_to_message.from.id == bot.id then
                    return editMessage(msg.chat.id, msg.reply_to_message.message_id, matches[2])
                else
                    return sendMessage(msg.chat.id, langs[msg.lang].cantEditOthersMessages)
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
            if not deleteMessage(msg.chat.id, msg.message_id, true) then
                return langs[msg.lang].cantDeleteMessage
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
    if matches[1]:lower() == 'testobject' then
        mystat('/testobject')
        if msg.reply then
            if matches[2] then
                if matches[2]:lower() == 'from' then
                    if msg.reply_to_message.forward then
                        if msg.reply_to_message.forward_from then
                            if sendChatAction(msg.reply_to_message.forward_from.id, 'typing', true) then
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
                    if sendChatAction(msg.reply_to_message.from.id, 'typing', true) then
                        return langs[msg.lang].userDidNotBlockBot
                    else
                        return langs[msg.lang].userBlockedBot
                    end
                end
            else
                if msg.reply_to_message.service then
                    if msg.reply_to_message.service_type == 'chat_add_user' or msg.reply_to_message.service_type == 'chat_add_users' then
                        local text = ''
                        if sendChatAction(msg.reply_to_message.adder.id, 'typing', true) then
                            text = text .. msg.reply_to_message.adder.id .. ' ' .. langs[msg.lang].userDidNotBlockBot .. '\n'
                        else
                            text = text .. msg.reply_to_message.adder.id .. ' ' .. langs[msg.lang].userBlockedBot .. '\n'
                        end
                        for k, v in pairs(msg.reply_to_message.added) do
                            if sendChatAction(msg.reply_to_message.from.id, 'typing', true) then
                                text = text .. v.id .. ' ' .. langs[msg.lang].userDidNotBlockBot .. '\n'
                            else
                                text = text .. v.id .. ' ' .. langs[msg.lang].userBlockedBot .. '\n'
                            end
                        end
                        return text ..(matches[2] or '') .. ' ' ..(matches[3] or '')
                    elseif msg.reply_to_message.service_type == 'chat_del_user' then
                        if sendChatAction(msg.reply_to_message.removed.id, 'typing', true) then
                            return langs[msg.lang].userDidNotBlockBot
                        else
                            return langs[msg.lang].userBlockedBot
                        end
                    else
                        if sendChatAction(msg.reply_to_message.from.id, 'typing', true) then
                            return langs[msg.lang].userDidNotBlockBot
                        else
                            return langs[msg.lang].userBlockedBot
                        end
                    end
                else
                    if sendChatAction(msg.reply_to_message.from.id, 'typing', true) then
                        return langs[msg.lang].userDidNotBlockBot
                    else
                        return langs[msg.lang].userBlockedBot
                    end
                end
            end
        elseif matches[2] and matches[2] ~= '' then
            if string.match(matches[2], '^%-?%d+$') then
                if sendChatAction(matches[2], 'typing', true) then
                    return langs[msg.lang].userDidNotBlockBot
                else
                    return langs[msg.lang].userBlockedBot
                end
            else
                local obj_user = getChat('@' ..(string.match(matches[2], '^[^%s]+'):gsub('@', '') or ''))
                if obj_user then
                    if obj_user.type == 'bot' or obj_user.type == 'private' or obj_user.type == 'user' then
                        if sendChatAction(obj_user.id, 'typing', true) then
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
    if matches[1]:lower() == 'deltyping' or matches[1]:lower() == 'delupload_photo' or matches[1]:lower() == 'delrecord_video' or matches[1]:lower() == 'delupload_video' or matches[1]:lower() == 'delrecord_audio' or matches[1]:lower() == 'delupload_audio' or matches[1]:lower() == 'delupload_document' or matches[1]:lower() == 'delfind_location' or matches[1]:lower() == 'delrecord_video_note' or matches[1]:lower() == 'delupload_video_note' then
        mystat('/reactions')
        print(matches[1]:lower())
        if not deleteMessage(msg.chat.id, msg.message_id, true) then
            return langs[msg.lang].cantDeleteMessage
        end
        sendChatAction(msg.chat.id,(matches[1]:lower()):gsub('del', ''))
        return
    end
    if matches[1]:lower() == 'typing' or matches[1]:lower() == 'upload_photo' or matches[1]:lower() == 'record_video' or matches[1]:lower() == 'upload_video' or matches[1]:lower() == 'record_audio' or matches[1]:lower() == 'upload_audio' or matches[1]:lower() == 'upload_document' or matches[1]:lower() == 'find_location' or matches[1]:lower() == 'record_video_note' or matches[1]:lower() == 'upload_video_note' then
        mystat('/reactions')
        print(matches[1]:lower())
        sendChatAction(msg.chat.id, matches[1]:lower())
        return
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
        "^[#!/]([Tt][Ee][Ss][Tt][Oo][Bb][Jj][Ee][Cc][Tt]) (.*)$",
        "^[#!/]([Tt][Ee][Ss][Tt][Oo][Bb][Jj][Ee][Cc][Tt])$",
        "^[#!/]([Ee][Dd][Ii][Tt]) (.+)$",
        "^[#!/]([Dd][Ee][Ll][Ee][Dd][Ii][Tt]) (.+)$",
        "^[#!/]([Hh][Tt][Mm][Ll][Ee][Dd][Ii][Tt]) (.+)$",
        "^[#!/]([Dd][Ee][Ll][Hh][Tt][Mm][Ll][Ee][Dd][Ii][Tt]) (.+)$",
        "^[#!/]([Mm][Aa][Rr][Kk][Dd][Oo][Ww][Nn][Ee][Dd][Ii][Tt]) (.+)$",
        "^[#!/]([Dd][Ee][Ll][Mm][Aa][Rr][Kk][Dd][Oo][Ww][Nn][Ee][Dd][Ii][Tt]) (.+)$",
        -- react
        "^(@[Aa][Ii][Ss][Aa][Ss][Hh][Aa][Bb][Oo][Tt])$",
        "^([Ss][Aa][Ss][Hh][Aa] [Cc][Oo][Mm][Ee] [Vv][Aa]%?)$",
        "^([Ss][Aa][Ss][Hh][Aa])(.*%?)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Tt][Ii] [Aa][Mm][Oo])$",
        "^([Tt][Ii] [Aa][Mm][Oo] [Ss][Aa][Ss][Hh][Aa])$",
        -- reactions
        "^[#!/]([Dd][Ee][Ll][Tt][Yy][Pp][Ii][Nn][Gg])$",
        "^[#!/]([Dd][Ee][Ll][Uu][Pp][Ll][Oo][Aa][Dd]_[Pp][Hh][Oo][Tt][Oo])$",
        "^[#!/]([Dd][Ee][Ll][Rr][Ee][Cc][Oo][Rr][Dd]_[Vv][Ii][Dd][Ee][Oo])$",
        "^[#!/]([Dd][Ee][Ll][Uu][Pp][Ll][Oo][Aa][Dd]_[Vv][Ii][Dd][Ee][Oo])$",
        "^[#!/]([Dd][Ee][Ll][Rr][Ee][Cc][Oo][Rr][Dd]_[Aa][Uu][Dd][Ii][Oo])$",
        "^[#!/]([Dd][Ee][Ll][Uu][Pp][Ll][Oo][Aa][Dd]_[Aa][Uu][Dd][Ii][Oo])$",
        "^[#!/]([Dd][Ee][Ll][Uu][Pp][Ll][Oo][Aa][Dd]_[Dd][Oo][Cc][Uu][Mm][Ee][Nn][Tt])$",
        "^[#!/]([Dd][Ee][Ll][Ff][Ii][Nn][Dd]_[Ll][Oo][Cc][Aa][Tt][Ii][Oo][Nn])$",
        "^[#!/]([Dd][Ee][Ll][Rr][Ee][Cc][Oo][Rr][Dd]_[Vv][Ii][Dd][Ee][Oo]_[Nn][Oo][Tt][Ee])$",
        "^[#!/]([Dd][Ee][Ll][Uu][Pp][Ll][Oo][Aa][Dd]_[Vv][Ii][Dd][Ee][Oo]_[Nn][Oo][Tt][Ee])$",
        "^[#!/]([Tt][Yy][Pp][Ii][Nn][Gg])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Pp][Hh][Oo][Tt][Oo])$",
        "^[#!/]([Rr][Ee][Cc][Oo][Rr][Dd]_[Vv][Ii][Dd][Ee][Oo])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Vv][Ii][Dd][Ee][Oo])$",
        "^[#!/]([Rr][Ee][Cc][Oo][Rr][Dd]_[Aa][Uu][Dd][Ii][Oo])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Aa][Uu][Dd][Ii][Oo])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Dd][Oo][Cc][Uu][Mm][Ee][Nn][Tt])$",
        "^[#!/]([Ff][Ii][Nn][Dd]_[Ll][Oo][Cc][Aa][Tt][Ii][Oo][Nn])$",
        "^[#!/]([Rr][Ee][Cc][Oo][Rr][Dd]_[Vv][Ii][Dd][Ee][Oo]_[Nn][Oo][Tt][Ee])$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]_[Vv][Ii][Dd][Ee][Oo]_[Nn][Oo][Tt][Ee])$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "/[del]typing",
        "/[del]upload_photo",
        "/[del]record_video",
        "/[del]upload_video",
        "/[del]record_audio",
        "/[del]upload_audio",
        "/[del]upload_document",
        "/[del]find_location",
        "/[del]record_video_note",
        "/[del]upload_video_note",
        "/testobject {id}|{username}|{reply}|from",
        "MOD",
        "/echo [{reply}]{text}",
        "/edit {reply} {text}",
        "/delecho [{reply}]{text}",
        "/deledit {reply} {text}",
        "/markdownecho [{reply}]{text}",
        "/markdownedit {reply} {text}",
        "/delmarkdownecho [{reply}]{text}",
        "/delmarkdownedit {reply} {text}",
        "/htmlecho [{reply}]{text}",
        "/htmledit {reply} {text}",
        "/delhtmlecho [{reply}]{text}",
        "/delhtmledit {reply} {text}",
    },
}