local function run(msg, matches)
    if msg.from.is_mod then
        if matches[1]:lower() == 'to' and mediaDictionary[matches[2]:lower()] then
            if msg.reply then
                if msg.reply_to_message.media then
                    local file_name = ''
                    local file_id = ''
                    if msg.reply_to_message.media_type == 'photo' then
                        local bigger_pic_id = ''
                        local size = 0
                        for k, v in pairsByKeys(msg.reply_to_message.photo) do
                            if v.file_size then
                                if v.file_size > size then
                                    size = v.file_size
                                    bigger_pic_id = v.file_id
                                end
                            end
                        end
                        file_id = bigger_pic_id
                        file_name = bigger_pic_id
                        -- document, sticker
                    elseif msg.reply_to_message.media_type == 'audio' then
                        file_name = msg.reply_to_message.audio.file_name or msg.reply_to_message.audio.file_id
                        file_id = msg.reply_to_message.audio.file_id
                        -- document, video, video_note, voice
                    elseif msg.reply_to_message.media_type == 'document' then
                        file_name = msg.reply_to_message.document.file_name or msg.reply_to_message.document.file_id
                        file_id = msg.reply_to_message.document.file_id
                        -- audio, document, photo, sticker, video, video_note, voice
                    elseif msg.reply_to_message.media_type == 'gif' then
                        file_name = msg.reply_to_message.document.file_name or msg.reply_to_message.document.file_id
                        file_id = msg.reply_to_message.document.file_id
                        -- document, video, video_note
                    elseif msg.reply_to_message.media_type == 'sticker' then
                        file_name = msg.reply_to_message.sticker.file_name or msg.reply_to_message.sticker.file_id
                        file_id = msg.reply_to_message.sticker.file_id
                        -- document, photo
                    elseif msg.reply_to_message.media_type == 'video' then
                        file_name = msg.reply_to_message.video.file_name or msg.reply_to_message.video.file_id
                        file_id = msg.reply_to_message.video.file_id
                        -- audio, document, video_note, voice
                    elseif msg.reply_to_message.media_type == 'video_note' then
                        file_name = msg.reply_to_message.video_note.file_name or msg.reply_to_message.video_note.file_id
                        file_id = msg.reply_to_message.video_note.file_id
                        -- audio, document, video, voice
                    elseif msg.reply_to_message.media_type == 'voice_note' then
                        file_name = msg.reply_to_message.voice.file_name or msg.reply_to_message.voice.file_id
                        file_id = msg.reply_to_message.voice.file_id
                        -- audio, document, video, video_note
                    else
                        return langs[msg.lang].useQuoteOnFile
                    end
                    local res = getFile(file_id)
                    local download_link = telegram_file_link(res)
                    local file_path, res_code = download_to_file(download_link, "/home/pi/AISashaAPI/data/tmp/" .. file_name)
                    if mediaDictionary[matches[2]:lower()] == 'audio' then
                        if msg.reply_to_message.media_type == 'document' or msg.reply_to_message.media_type == 'video' or msg.reply_to_message.media_type == 'video_note' or msg.reply_to_message.media_type == 'voice_note' then
                            return sendAudio(msg.chat.id, file_path)
                        else
                            return langs[msg.lang].cantSendAs .. mediaDictionary[matches[2]:lower()]
                        end
                    elseif mediaDictionary[matches[2]:lower()] == 'document' then
                        return sendDocument(msg.chat.id, file_path, langs[msg.lang].downloadAndRename)
                    elseif mediaDictionary[matches[2]:lower()] == 'photo' then
                        if msg.reply_to_message.media_type == 'document' or msg.reply_to_message.media_type == 'sticker' then
                            return sendPhoto(msg.chat.id, file_path)
                        else
                            return langs[msg.lang].cantSendAs .. mediaDictionary[matches[2]:lower()]
                        end
                    elseif mediaDictionary[matches[2]:lower()] == 'sticker' then
                        if msg.reply_to_message.media_type == 'document' or msg.reply_to_message.media_type == 'photo' then
                            return sendSticker(msg.chat.id, file_path)
                        else
                            return langs[msg.lang].cantSendAs .. mediaDictionary[matches[2]:lower()]
                        end
                    elseif mediaDictionary[matches[2]:lower()] == 'video' then
                        if msg.reply_to_message.media_type == 'audio' or msg.reply_to_message.media_type == 'document' or msg.reply_to_message.media_type == 'gif' or msg.reply_to_message.media_type == 'video_note' or msg.reply_to_message.media_type == 'voice_note' then
                            return sendVideo(msg.chat.id, file_path)
                        else
                            return langs[msg.lang].cantSendAs .. mediaDictionary[matches[2]:lower()]
                        end
                    elseif mediaDictionary[matches[2]:lower()] == 'video_note' then
                        if msg.reply_to_message.media_type == 'audio' or msg.reply_to_message.media_type == 'document' or msg.reply_to_message.media_type == 'gif' or msg.reply_to_message.media_type == 'video' or msg.reply_to_message.media_type == 'voice_note' then
                            return sendVideoNote(msg.chat.id, file_path)
                        else
                            return langs[msg.lang].cantSendAs .. mediaDictionary[matches[2]:lower()]
                        end
                    elseif mediaDictionary[matches[2]:lower()] == 'voice' then
                        if msg.reply_to_message.media_type == 'audio' or msg.reply_to_message.media_type == 'document' or msg.reply_to_message.media_type == 'video' or msg.reply_to_message.media_type == 'video_note' then
                            return sendVoice(msg.chat.id, file_path)
                        else
                            return langs[msg.lang].cantSendAs .. mediaDictionary[matches[2]:lower()]
                        end
                    end
                else
                    return langs[msg.lang].useQuoteOnFile
                end
            else
                return langs[msg.lang].useQuoteOnFile
            end
        else
            return langs[msg.lang].unknownType
        end
    else
        return langs[msg.lang].require_mod
    end
end

return {
    description = "FILECONVERSION",
    patterns =
    {
        "^[#!/]([Tt][Oo])(%w+)$",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "MOD",
        "/to{type} {reply}",
    }
}