function run(msg, matches)
    if is_sudo(msg) then
        local path = redis:get('api:path')
        if path then
            if msg.cb then
                if matches[1] == '###cbfilemanager' then
                    local pathString = langs[msg.lang].youAreHere .. path
                    if matches[2] == 'DELETE' then
                        if not deleteMessage(msg.chat.id, msg.message_id, true) then
                            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                        end
                    elseif matches[2] == 'BACK' then
                        answerCallbackQuery(msg.cb_id, pathString)
                        editMessage(msg.chat.id, msg.message_id, pathString, keyboard_filemanager(path, matches[3]))
                    elseif matches[2] == 'PAGES' then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].uselessButton, false)
                    elseif matches[2]:gsub('%d', '') == 'PAGEMINUS' then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].turningPage)
                        editMessage(msg.chat.id, msg.message_id, pathString, keyboard_filemanager(path, tonumber(matches[3] or(tonumber(matches[2]:match('%d')) + 1)) - tonumber(matches[2]:match('%d'))))
                    elseif matches[2]:gsub('%d', '') == 'PAGEPLUS' then
                        answerCallbackQuery(msg.cb_id, langs[msg.lang].turningPage)
                        editMessage(msg.chat.id, msg.message_id, pathString, keyboard_filemanager(path, tonumber(matches[3] or(tonumber(matches[2]:match('%d')) -1)) + tonumber(matches[2]:match('%d'))))
                    elseif matches[2] == 'CD' then
                        if matches[3] == '.' then
                            answerCallbackQuery(msg.cb_id, pathString)
                            editMessage(msg.chat.id, msg.message_id, pathString, keyboard_filemanager(path))
                        elseif matches[3] == '..' then
                            if path ~= '/' then
                                local pathComponents = path:split('/')
                                local lastFolder = ''
                                for i, fldr in pairs(pathComponents) do
                                    if fldr then
                                        lastFolder = fldr .. '/'
                                    end
                                end
                                if lastFolder ~= '' then
                                    local folder = path:gsub(lastFolder, '')
                                    pathString = langs[msg.lang].youAreHere .. folder
                                    answerCallbackQuery(msg.cb_id, pathString)
                                    redis:set('api:path', folder)
                                    editMessage(msg.chat.id, msg.message_id, pathString, keyboard_filemanager(folder))
                                else
                                    answerCallbackQuery(msg.cb_id, pathString)
                                end
                            else
                                answerCallbackQuery(msg.cb_id, pathString)
                            end
                        else
                            local folder = path .. '' .. matches[3] .. '/'
                            pathString = langs[msg.lang].youAreHere .. folder
                            answerCallbackQuery(msg.cb_id, pathString)
                            redis:set('api:path', folder)
                            editMessage(msg.chat.id, msg.message_id, pathString, keyboard_filemanager(folder))
                        end
                    elseif matches[2] == 'UP' then
                        if io.popen('find ' .. path .. matches[3]):read("*all") ~= '' then
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].sendingYou .. matches[3])
                            sendDocument(msg.chat.id, path .. matches[3])
                            editMessage(msg.chat.id, msg.message_id, pathString, keyboard_filemanager(path))
                        else
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTryAgain)
                        end
                    end
                end
                return
            end
            if matches[1]:lower() == "filemanager" then
                if sendKeyboard(msg.from.id, "@AISASHABOT FILEMANAGER TESTING KEYBOARD", keyboard_filemanager(path)) then
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendKeyboardPvt, 'html').result.message_id
                        io.popen('sudo lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                        io.popen('sudo lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
            end
            if matches[1]:lower() == 'folder' or matches[1]:lower() == 'path' then
                mystat('/folder')
                return langs[msg.lang].youAreHere .. path
            end
            if matches[1]:lower() == 'cd' then
                mystat('/cd')
                if not matches[2] then
                    redis:set('api:path', '/')
                    return langs[msg.lang].backHomeFolder .. '/'
                else
                    redis:set('api:path', matches[2])
                    return langs[msg.lang].youAreHere .. matches[2]
                end
            end
            if matches[1]:lower() == 'ls' then
                mystat('/ls')
                return io.popen('ls -a "' .. path .. '"'):read("*all")
            end
            if matches[1]:lower() == 'mkdir' and matches[2] then
                mystat('/mkdir')
                io.popen('cd "' .. path .. '" && mkdir \'' .. matches[2] .. '\''):read("*all")
                return langs[msg.lang].folderCreated:gsub("X", matches[2])
            end
            if matches[1]:lower() == 'rm' and matches[2] then
                mystat('/rm')
                io.popen('cd "' .. path .. '" && rm -f \'' .. matches[2] .. '\''):read("*all")
                return matches[2] .. langs[msg.lang].deleted
            end
            if matches[1]:lower() == 'cat' and matches[2] then
                mystat('/cat')
                return io.popen('cd "' .. path .. '" && cat \'' .. matches[2] .. '\''):read("*all")
            end
            if matches[1]:lower() == 'rmdir' and matches[2] then
                mystat('/rmdir')
                io.popen('cd "' .. path .. '" && rmdir \'' .. matches[2] .. '\''):read("*all")
                return langs[msg.lang].folderDeleted:gsub("X", matches[2])
            end
            if matches[1]:lower() == 'touch' and matches[2] then
                mystat('/touch')
                io.popen('cd "' .. path .. '" && touch \'' .. matches[2] .. '\''):read("*all")
                return matches[2] .. langs[msg.lang].created
            end
            if matches[1]:lower() == 'tofile' and matches[2] and matches[3] then
                mystat('/tofile')
                file_to_write = io.open(path .. matches[2], "w")
                file_to_write:write(matches[3])
                file_to_write:flush()
                file_to_write:close()
                langs[msg.lang].fileCreatedWithContent:gsub("X", matches[3])
            end
            if matches[1]:lower() == 'shell' and matches[2] then
                mystat('/shell')
                return io.popen('cd "' .. path .. '" && ' .. matches[2]:gsub('—', '--')):read('*all')
            end
            if matches[1]:lower() == 'cp' and matches[2] and matches[3] then
                mystat('/cp')
                io.popen('cd "' .. path .. '" && cp -r \'' .. matches[2] .. '\' \'' .. matches[3] .. '\''):read("*all")
                return matches[2] .. langs[msg.lang].copiedTo .. matches[3]
            end
            if matches[1]:lower() == 'mv' and matches[2] and matches[3] then
                mystat('/mv')
                io.popen('cd "' .. path .. '" && mv \'' .. matches[2] .. '\' \'' .. matches[3] .. '\''):read("*all")
                return matches[2] .. langs[msg.lang].movedTo .. matches[3]
            end
            if matches[1]:lower() == 'upload' and matches[2] then
                mystat('/upload')
                if io.popen('find ' .. path .. matches[2]):read("*all") == '' then
                    return matches[2] .. langs[msg.lang].noSuchFile
                else
                    sendDocument(msg.chat.id, path .. matches[2])
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
                        local file_path, res_code = download_to_file(download_link, path .. file_name)
                        return langs[msg.lang].fileDownloadedTo ..(file_path or res_code)
                    end
                else
                    return langs[msg.lang].useQuoteOnFile
                end
            end
            return
        else
            redis:set('api:path', '/')
            return langs[msg.lang].youAreHere .. '/'
        end
    else
        return langs[msg.lang].require_sudo
    end
end

return {
    description = "FILEMANAGER",
    patterns =
    {
        "^(###cbfilemanager)(DELETE)$",
        "^(###cbfilemanager)(BACK)(%d+)$",
        "^(###cbfilemanager)(PAGES)$",
        "^(###cbfilemanager)(PAGE%dMINUS)(%d+)$",
        "^(###cbfilemanager)(PAGE%dPLUS)(%d+)$",
        "^(###cbfilemanager)(CD)(.*)$",
        "^(###cbfilemanager)(UP)(.*)$",

        "^[#!/]([Ff][Ii][Ll][Ee][Mm][Aa][Nn][Aa][Gg][Ee][Rr])$",
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
    min_rank = 5,
    syntax =
    {
        "SUDO",
        "/filemanager",
        "/folder|/path",
        "/cd [{directory}]",
        "/ls",
        "/mkdir {directory}",
        "/rmdir {directory}",
        "/rm {file}",
        "/touch {file}",
        "/cat {file}",
        "/tofile {file} {text}",
        "/shell {command}",
        "/cp {file} {directory}",
        "/mv {file} {directory}",
        "/upload {file}",
        "/download {reply}",
    },
}
-- Thanks to @imandaneshi