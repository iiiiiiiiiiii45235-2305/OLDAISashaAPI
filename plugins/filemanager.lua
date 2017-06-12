-- Base folder
local BASE_FOLDER = "/"

function run(msg, matches)
    if is_sudo(msg) then
        local folder = redis:get('api:folder')
        if folder then
            if matches[1]:lower() == 'folder' then
                mystat('/folder')
                return langs[msg.lang].youAreHere .. BASE_FOLDER .. folder
            end
            if matches[1]:lower() == 'cd' then
                mystat('/cd')
                if not matches[2] then
                    redis:set('api:folder', '')
                    return langs[msg.lang].backHomeFolder .. BASE_FOLDER
                else
                    redis:set('api:folder', matches[2])
                    return langs[msg.lang].youAreHere .. BASE_FOLDER .. matches[2]
                end
            end
            local action = ''
            if matches[1]:lower() == 'ls' then
                mystat('/ls')
                action = io.popen('ls "' .. BASE_FOLDER .. folder .. '"'):read("*all")
            end
            if matches[1]:lower() == 'mkdir' and matches[2] then
                mystat('/mkdir')
                io.popen('cd "' .. BASE_FOLDER .. folder .. '" && mkdir \'' .. matches[2] .. '\''):read("*all")
                return langs[msg.lang].folderCreated:gsub("X", matches[2])
            end
            if matches[1]:lower() == 'rm' and matches[2] then
                mystat('/rm')
                io.popen('cd "' .. BASE_FOLDER .. folder .. '" && rm -f \'' .. matches[2] .. '\''):read("*all")
                return matches[2] .. langs[msg.lang].deleted
            end
            if matches[1]:lower() == 'cat' and matches[2] then
                mystat('/cat')
                action = io.popen('cd "' .. BASE_FOLDER .. folder .. '" && cat \'' .. matches[2] .. '\''):read("*all")
            end
            if matches[1]:lower() == 'rmdir' and matches[2] then
                mystat('/rmdir')
                io.popen('cd "' .. BASE_FOLDER .. folder .. '" && rmdir \'' .. matches[2] .. '\''):read("*all")
                return langs[msg.lang].folderDeleted:gsub("X", matches[2])
            end
            if matches[1]:lower() == 'touch' and matches[2] then
                mystat('/touch')
                io.popen('cd "' .. BASE_FOLDER .. folder .. '" && touch \'' .. matches[2] .. '\''):read("*all")
                return matches[2] .. langs[msg.lang].created
            end
            if matches[1]:lower() == 'tofile' and matches[2] and matches[3] then
                mystat('/tofile')
                file = io.open(BASE_FOLDER .. folder .. matches[2], "w")
                file:write(matches[3])
                file:flush()
                file:close()
                langs[msg.lang].fileCreatedWithContent:gsub("X", matches[3])
            end
            if matches[1]:lower() == 'shell' and matches[2] then
                mystat('/shell')
                action = io.popen('cd "' .. BASE_FOLDER .. folder .. '" && ' .. matches[2]:gsub('—', '--')):read('*all')
            end
            if matches[1]:lower() == 'cp' and matches[2] and matches[3] then
                mystat('/cp')
                io.popen('cd "' .. BASE_FOLDER .. folder .. '" && cp -r \'' .. matches[2] .. '\' \'' .. matches[3] .. '\''):read("*all")
                return matches[2] .. langs[msg.lang].copiedTo .. matches[3]
            end
            if matches[1]:lower() == 'mv' and matches[2] and matches[3] then
                mystat('/mv')
                io.popen('cd "' .. BASE_FOLDER .. folder .. '" && mv \'' .. matches[2] .. '\' \'' .. matches[3] .. '\''):read("*all")
                return matches[2] .. langs[msg.lang].movedTo .. matches[3]
            end
            if matches[1]:lower() == 'upload' and matches[2] then
                mystat('/upload')
                if io.popen('find ' .. BASE_FOLDER .. folder .. matches[2]):read("*all") == '' then
                    return matches[2] .. langs[msg.lang].noSuchFile
                else
                    sendDocument(msg.chat.id, BASE_FOLDER .. folder .. matches[2])
                    return langs[msg.lang].sendingYou .. matches[2]
                end
            end
            if matches[1]:lower() == 'download' then
                mystat('/download')
                if msg.reply then
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
                        local file_path, res_code = download_to_file(download_link, folder .. file_name)
                        return langs[msg.lang].fileDownloadedTo ..(file_path or res_code)
                    end
                else
                    return langs[msg.lang].useQuoteOnFile
                end
            end
            return action
        else
            redis:set('api:folder', '')
            return langs[msg.lang].youAreHere .. BASE_FOLDER
        end
    else
        return langs[msg.lang].require_sudo
    end
end

return {
    description = "FILEMANAGER",
    patterns =
    {
        "^[#!/]([Ff][Oo][Ll][Dd][Ee][Rr])$",
        "^[#!/]([Cc][Dd])$",
        "^[#!/]([Cc][Dd]) (.*)$",
        "^[#!/]([Ll][Ss])$",
        "^[#!/]([Mm][Kk][Dd][Ii][Rr]) (.*)$",
        "^[#!/]([Rr][Mm][Dd][Ii][Rr]) (.*)$",
        "^[#!/]([Rr][Mm]) (.*)$",
        "^[#!/]([Tt][Oo][Uu][Cc][Hh]) (.*)$",
        "^[#!/]([Cc][Aa][Tt]) (.*)$",
        "^[#!/]([Tt][Oo][Ff][Ii][Ll][Ee]) ([^%s]+) (.*)$",
        "^[#!/]([Ss][Hh][Ee][Ll][Ll]) (.*)$",
        "^[#!/]([Cc][Pp]) (.*) (.*)$",
        "^[#!/]([Mm][Vv]) (.*) (.*)$",
        "^[#!/]([Uu][Pp][Ll][Oo][Aa][Dd]) (.*)$",
        "^[#!/]([Dd][Oo][Ww][Nn][Ll][Oo][Aa][Dd])"
    },
    run = run,
    min_rank = 4,
    syntax =
    {
        "SUDO",
        "#folder",
        "#cd [<directory>]",
        "#ls",
        "#mkdir <directory>",
        "#rmdir <directory>",
        "#rm <file>",
        "#touch <file>",
        "#cat <file>",
        "#tofile <file> <text>",
        "#shell <command>",
        "#cp <file> <directory>",
        "#mv <file> <directory>",
        "#upload <file>",
        "#download <reply>",
    },
}
-- Thanks to @imandaneshi