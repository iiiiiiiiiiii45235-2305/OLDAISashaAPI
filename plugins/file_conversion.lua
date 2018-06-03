local function run(msg, matches)
    if matches[1]:lower() == 'convert' and msg.reply then
        if msg.reply_to_message.media then
            local file_name = ''
            local file_id = ''
            if msg.reply_to_message.media_type == 'photo' then
                file_name = msg.reply_to_message.photo.file_name or msg.reply_to_message.photo.file_id
                file_id = msg.reply_to_message.photo.file_id
            elseif msg.reply_to_message.media_type == 'video' then
                file_name = msg.reply_to_message.video.file_name or msg.reply_to_message.video.file_id
                file_id = msg.reply_to_message.video.file_id
            elseif msg.reply_to_message.media_type == 'video_note' then
                file_name = msg.reply_to_message.video_note.file_name or msg.reply_to_message.video_note.file_id
                file_id = msg.reply_to_message.video_note.file_id
            elseif msg.reply_to_message.media_type == 'audio' then
                file_name = msg.reply_to_message.audio.file_name or msg.reply_to_message.audio.file_id
                file_id = msg.reply_to_message.audio.file_id
            elseif msg.reply_to_message.media_type == 'voice_note' then
                file_name = msg.reply_to_message.voice.file_name or msg.reply_to_message.voice.file_id
                file_id = msg.reply_to_message.voice.file_id
            elseif msg.reply_to_message.media_type == 'gif' then
                file_name = msg.reply_to_message.document.file_name or msg.reply_to_message.document.file_id
                file_id = msg.reply_to_message.document.file_id
            elseif msg.reply_to_message.media_type == 'document' then
                file_name = msg.reply_to_message.document.file_name or msg.reply_to_message.document.file_id
                file_id = msg.reply_to_message.document.file_id
            elseif msg.reply_to_message.media_type == 'sticker' then
                file_name = msg.reply_to_message.sticker.file_name or msg.reply_to_message.sticker.file_id
                file_id = msg.reply_to_message.sticker.file_id
            else
                return langs[msg.lang].useQuoteOnFile
            end
            local res = getFile(file_id)
            local download_link = telegram_file_link(res)
            local file_path, res_code = download_to_file(download_link, "/home/pi/AISashaAPI/data/tmp/" .. file_name)
            --[[if msg.reply_to_message.media_type == 'photo' then
                file_name = msg.reply_to_message.photo.file_name or msg.reply_to_message.photo.file_id
                file_id = msg.reply_to_message.photo.file_id
            elseif msg.reply_to_message.media_type == 'video_note' then
                file_name = msg.reply_to_message.video_note.file_name or msg.reply_to_message.video_note.file_id
                file_id = msg.reply_to_message.video_note.file_id
            else]]if msg.reply_to_message.media_type == 'video' then
                return sendVideoNote(msg.chat.id, file_path)
            elseif msg.reply_to_message.media_type == 'audio' then
                return sendVoice(msg.chat.id, file_path)
            elseif msg.reply_to_message.media_type == 'voice_note' then
                return sendAudio(msg.chat.id, file_path)
            elseif msg.reply_to_message.media_type == 'gif' then
                return sendVideoNote(msg.chat.id, file_path)
            else
                return langs[msg.lang].useQuoteOnFile
            end
        end
    end
end

return {
    description = "FILE_CONVERSION",
    patterns =
    {
        "^[#!/]([Cc][Oo][Nn][Vv][Ee][Rr][Tt])$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/convert {reply}",
    }
}