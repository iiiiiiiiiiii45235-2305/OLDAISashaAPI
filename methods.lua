-- *** START API FUNCTIONS ***

local BASE_URL = 'https://api.telegram.org/bot' .. config.bot_api_key
local PWR_URL = 'https://api.pwrtelegram.xyz/bot' .. config.bot_api_key

if not config.bot_api_key then
    error('You did not set your bot token in config.lua!')
end

function sendRequest(url)
    -- print(url)
    local dat, code = HTTPS.request(url)

    if not dat then
        return false, code
    end

    local tab = JSON.decode(dat)

    if code ~= 200 then
        if tab and tab.description then print(clr.onwhite .. clr.red .. code, tab.description .. clr.reset) end
        -- 403: bot blocked, 429: spam limit ...send a message to the admin, return the code
        if code == 400 then code = getCode(tab.description) end
        -- error code 400 is general: try to specify
        redis:hincrby('bot:errors', code, 1)
        if code ~= 403 and code ~= 429 and code ~= 110 and code ~= 111 then
            sendLog('#BadRequest\n' .. vardumptext(dat) .. '\n' .. code)
        end
        return false, code
    end

    -- actually, this rarely happens
    if not tab.ok then
        return false, tab.description
    end

    return tab
end

function getMe()
    local url = BASE_URL .. '/getMe'
    return sendRequest(url)
end

function getUpdates(offset)
    local url = BASE_URL .. '/getUpdates?timeout=20'
    if offset then
        url = url .. '&offset=' .. offset
    end
    return sendRequest(url)
end

function getChat(chat_id)
    local url = BASE_URL .. '/getChat?chat_id=' .. chat_id
    return sendRequest(url)
end

function getChatAdministrators(chat_id)
    local url = BASE_URL .. '/getChatAdministrators?chat_id=' .. chat_id
    return sendRequest(url)
end

function getChatMembersCount(chat_id)
    local url = BASE_URL .. '/getChatMembersCount?chat_id=' .. chat_id
    return sendRequest(url)
end

function getChatMember(chat_id, user_id)
    local url = BASE_URL .. '/getChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
    return sendRequest(url)
end

function getFile(file_id)
    local url = BASE_URL ..
    '/getFile?file_id=' .. file_id
    return sendRequest(url)
end

function getCode(error)
    for k, v in pairs(config.api_errors) do
        if error:match(v) then
            return k
        end
    end
    -- error unknown
    return 7
end

function code2text(code, ln)
    -- the default error description can't be sent as output, so a translation is needed
    if code == 101 or code == 105 or code == 107 then
        return langs[ln].kick_errors[1]
    elseif code == 102 or code == 104 then
        return langs[ln].kick_errors[2]
    elseif code == 103 then
        return langs[ln].kick_errors[3]
    elseif code == 106 then
        return langs[ln].kick_errors[4]
    elseif code == 7 then
        return false
    end
    return false
end

-- never call this outside this file
function kickChatMember(user_id, chat_id)
    local url = BASE_URL .. '/kickChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
    local dat, res = HTTPS.request(url)
    local tab = JSON.decode(dat)

    if res ~= 200 then
        -- if error, return false and the custom error code
        print(tab.description)
        return false, getCode(tab.description)
    end

    if not tab.ok then
        return false, tab.description
    end

    return tab
end

-- never call this outside this file
function unbanChatMember(user_id, chat_id)
    local url = BASE_URL .. '/unbanChatMember?chat_id=' .. chat_id .. '&user_id=' .. user_id
    -- return sendRequest(url)
    local dat, res = HTTPS.request(url)
    local tab = JSON.decode(dat)

    if res ~= 200 then
        return false, res
    end

    if not tab.ok then
        return false, tab.description
    end

    return tab
end

function leaveChat(chat_id)
    local url = BASE_URL .. '/leaveChat?chat_id=' .. chat_id
    return sendRequest(url)
end

function sendMessage(chat_id, text, use_markdown, reply_to_message_id, send_sound)
    -- print(text)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            if text then
                if text ~= '' then
                    local text_max = 4096
                    local text_len = string.len(text)
                    local num_msg = math.ceil(text_len / text_max)
                    local url = BASE_URL ..
                    '/sendMessage?chat_id=' .. chat_id ..
                    '&disable_web_page_preview=true'
                    local reply = false
                    if reply_to_message_id then
                        url = url .. '&reply_to_message_id=' .. reply_to_message_id
                        reply = true
                    end
                    if use_markdown then
                        url = url .. '&parse_mode=Markdown'
                    end
                    if not send_sound then
                        url = url .. '&disable_notification=true'
                        -- messages are silent by default
                    end

                    if num_msg <= 1 then
                        url = url .. '&text=' .. URL.escape(text)

                        local res, code = sendRequest(url)

                        if not res and code then
                            -- if the request failed and a code is returned (not 403 and 429)
                            if code ~= 403 and code ~= 429 and code ~= 110 and code ~= 111 then
                                savelog('send_msg', code .. '\n' .. text)
                            end
                        end
                        obj = obj.result
                        local sent_msg = { from = bot, chat = obj, text = text, reply = reply }
                        print_msg(sent_msg)
                    else
                        local my_text = string.sub(text, 1, 4096)
                        local rest = string.sub(text, 4096, text_len)
                        url = url .. '&text=' .. URL.escape(my_text)

                        local res, code = sendRequest(url)

                        if not res and code then
                            -- if the request failed and a code is returned (not 403 and 429)
                            if code ~= 403 and code ~= 429 and code ~= 110 and code ~= 111 then
                                savelog('send_msg', code .. '\n' .. text)
                            end
                        end
                        obj = obj.result
                        local sent_msg = { from = bot, chat = obj, text = my_text, reply = reply }
                        print_msg(sent_msg)
                        res, code = sendMessage(chat_id, rest, use_markdown, reply_to_message_id, send_sound)
                    end

                    return res, code
                    -- return false, and the code
                end
            end
        end
    end
end

function sendMessage_SUDOERS(text, use_markdown)
    for v, user in pairs(config.sudo_users) do
        sendMessage(user, text, use_markdown, false, true)
    end
end

function sendReply(msg, text, markd, send_sound)
    return sendMessage(msg.chat.id, text, markd, msg.message_id, send_sound)
end

function sendLog(text, markdown)
    if config.log_chat then
        return sendMessage(config.log_chat, text, markdown)
    else
        for v, user in pairs(config.sudo_users) do
            -- print(text)
            sendMessage(user, text, markdown)
        end
    end
end

function resolveChannelSupergroupsUsernames(username)
    local url = PWR_URL .. '/getChat?chat_id=' .. username
    local dat, code = HTTPS.request(url)

    if not dat then
        return false, code
    end

    local tab = JSON.decode(dat)

    if not tab then
        return false
    else
        if tab.ok then
            return tab.result
        end
    end
end

function forwardMessage(chat_id, from_chat_id, message_id)
    local obj_from = getChat(from_chat_id)
    local obj_to = getChat(chat_id)
    if type(obj_from) == 'table' and type(obj_to) == 'table' then
        if obj_from.result and obj_to.result then
            local url = BASE_URL ..
            '/forwardMessage?chat_id=' .. chat_id ..
            '&from_chat_id=' .. from_chat_id ..
            '&message_id=' .. message_id
            obj_to = obj_to.result
            local sent_msg = { from = bot, chat = obj_to, text = text, forward = true }
            print_msg(sent_msg)
            return sendRequest(url)
        end
    end
end

function sendKeyboard(chat_id, text, keyboard, markdown)
    local url = BASE_URL .. '/sendMessage?chat_id=' .. chat_id
    if markdown then
        url = url .. '&parse_mode=Markdown'
    end
    url = url .. '&text=' .. URL.escape(text)
    url = url .. '&disable_web_page_preview=true'
    url = url .. '&reply_markup=' .. JSON.encode(keyboard)
    local res, code = sendRequest(url)

    if not res and code then
        -- if the request failed and a code is returned (not 403 and 429)
        if code ~= 403 and code ~= 429 and code ~= 110 and code ~= 111 then
            savelog('send_msg', code .. '\n' .. text)
        end
    end

    return res, code
    -- return false, and the code
end

function editMessageText(chat_id, message_id, text, keyboard, markdown)
    local url = BASE_URL ..
    '/editMessageText?chat_id=' .. chat_id ..
    '&message_id=' .. message_id ..
    '&text=' .. URL.escape(text)
    if markdown then
        url = url .. '&parse_mode=Markdown'
    end
    url = url .. '&disable_web_page_preview=true'
    if keyboard then
        url = url .. '&reply_markup=' .. JSON.encode(keyboard)
    end
    local res, code = sendRequest(url)

    if not res and code then
        -- if the request failed and a code is returned (not 403 and 429)
        if code ~= 403 and code ~= 429 and code ~= 110 and code ~= 111 then
            savelog('send_msg', code .. '\n' .. text)
        end
    end

    return res, code
    -- return false, and the code
end

function answerCallbackQuery(callback_query_id, text, show_alert)
    local url = BASE_URL ..
    '/answerCallbackQuery?callback_query_id=' .. callback_query_id ..
    '&text=' .. URL.escape(text)
    if show_alert then
        url = url .. '&show_alert=true'
    end
    return sendRequest(url)
end

function sendChatAction(chat_id, action)
    -- Support actions are typing, upload_photo, record_video, upload_video, record_audio, upload_audio, upload_document, find_location
    local url = BASE_URL ..
    '/sendChatAction?chat_id=' .. chat_id ..
    '&action=' .. action
    return sendRequest(url)
end

function sendLocation(chat_id, latitude, longitude, reply_to_message_id)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL ..
            '/sendLocation?chat_id=' .. chat_id ..
            '&latitude=' .. latitude ..
            '&longitude=' .. longitude
            local reply = false
            if reply_to_message_id then
                url = url .. '&reply_to_message_id=' .. reply_to_message_id
                reply = true
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'geo' }
            print_msg(sent_msg)
            return sendRequest(url)
        end
    end
end

----------------------------By Id-----------------------------------------

function sendPhotoId(chat_id, file_id, reply_to_message_id)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL ..
            '/sendPhoto?chat_id=' .. chat_id ..
            '&photo=' .. file_id
            local reply = false
            if reply_to_message_id then
                url = url .. '&reply_to_message_id=' .. reply_to_message_id
                reply = true
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'photo' }
            print_msg(sent_msg)
            return sendRequest(url)
        end
    end
end

function sendStickerId(chat_id, file_id, reply_to_message_id)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL ..
            '/sendSticker?chat_id=' .. chat_id ..
            '&sticker=' .. file_id
            local reply = false
            if reply_to_message_id then
                url = url .. '&reply_to_message_id=' .. reply_to_message_id
                reply = true
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'sticker' }
            print_msg(sent_msg)
            return sendRequest(url)
        end
    end
end

function sendVoiceId(chat_id, file_id, reply_to_message_id)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL ..
            '/sendVoice?chat_id=' .. chat_id ..
            '&voice=' .. file_id
            local reply = false
            if reply_to_message_id then
                url = url .. '&reply_to_message_id=' .. reply_to_message_id
                reply = true
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'voice' }
            print_msg(sent_msg)
            return sendRequest(url)
        end
    end
end

function sendAudioId(chat_id, file_id, reply_to_message_id)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL ..
            '/sendAudio?chat_id=' .. chat_id ..
            '&audio=' .. file_id
            local reply = false
            if reply_to_message_id then
                url = url .. '&reply_to_message_id=' .. reply_to_message_id
                reply = true
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'audio' }
            print_msg(sent_msg)
            return sendRequest(url)
        end
    end
end

function sendVideoId(chat_id, file_id, reply_to_message_id)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL ..
            '/sendVideo?chat_id=' .. chat_id ..
            '&video=' .. file_id
            local reply = false
            if reply_to_message_id then
                url = url .. '&reply_to_message_id=' .. reply_to_message_id
                reply = true
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'video' }
            print_msg(sent_msg)
            return sendRequest(url)
        end
    end
end

function sendDocumentId(chat_id, file_id, reply_to_message_id)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL ..
            '/sendDocument?chat_id=' .. chat_id ..
            '&document=' .. file_id
            local reply = false
            if reply_to_message_id then
                url = url .. '&reply_to_message_id=' .. reply_to_message_id
                reply = true
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'document' }
            print_msg(sent_msg)
            return sendRequest(url)
        end
    end
end

----------------------------To curl--------------------------------------------

function curlRequest(curl_command)
    -- Use at your own risk. Will not check for success.
    io.popen(curl_command)
end

function sendPhoto(chat_id, photo, caption, reply_to_message_id)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL .. '/sendPhoto'
            local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "photo=@' .. photo .. '"'
            local reply = false
            if reply_to_message_id then
                curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
                reply = true
            end
            if caption then
                curl_command = curl_command .. ' -F "caption=' .. caption .. '"'
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'photo' }
            print_msg(sent_msg)
            return curlRequest(curl_command)
        end
    end
end

function sendSticker(chat_id, sticker, reply_to_message_id)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL .. '/sendSticker'
            local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "sticker=@' .. sticker .. '"'
            local reply = false
            if reply_to_message_id then
                curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
                reply = true
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'sticker' }
            print_msg(sent_msg)
            return curlRequest(curl_command)
        end
    end
end

function sendVoice(chat_id, voice, reply_to_message_id)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL .. '/sendVoice'
            local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "voice=@' .. voice .. '"'
            local reply = false
            if reply_to_message_id then
                curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
                reply = true
            end
            if duration then
                curl_command = curl_command .. ' -F "duration=' .. duration .. '"'
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'voice' }
            print_msg(sent_msg)
            return curlRequest(curl_command)
        end
    end
end

function sendAudio(chat_id, audio, reply_to_message_id, duration, performer, title)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL .. '/sendAudio'
            local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "audio=@' .. audio .. '"'
            local reply = false
            if reply_to_message_id then
                curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
                reply = true
            end
            if duration then
                curl_command = curl_command .. ' -F "duration=' .. duration .. '"'
            end
            if performer then
                curl_command = curl_command .. ' -F "performer=' .. performer .. '"'
            end
            if title then
                curl_command = curl_command .. ' -F "title=' .. title .. '"'
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'audio' }
            print_msg(sent_msg)
            return curlRequest(curl_command)
        end
    end
end

function sendVideo(chat_id, video, reply_to_message_id, duration, performer, title)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL .. '/sendVideo'
            local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "video=@' .. video .. '"'
            local reply = false
            if reply_to_message_id then
                curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
                reply = true
            end
            if caption then
                curl_command = curl_command .. ' -F "caption=' .. caption .. '"'
            end
            if duration then
                curl_command = curl_command .. ' -F "duration=' .. duration .. '"'
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'video' }
            print_msg(sent_msg)
            return curlRequest(curl_command)
        end
    end
end

function sendDocument(chat_id, document, reply_to_message_id)
    local obj = getChat(chat_id)
    if type(obj) == 'table' then
        if obj.result then
            local url = BASE_URL .. '/sendDocument'
            local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "document=@' .. document .. '"'
            local reply = false
            if reply_to_message_id then
                curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
                reply = true
            end
            obj = obj.result
            local sent_msg = { from = bot, chat = obj, text = text, reply = reply, media = true, media_type = 'document' }
            print_msg(sent_msg)
            return curlRequest(curl_command)
        end
    end
end

function sendDocument_SUDOERS(document)
    for v, user in pairs(config.sudo_users) do
        sendDocument(user, document)
    end
end

----------------------------From url functions---------------------------------
function getHttpFileName(url, headers)
    -- Eg: foo.var
    local file_name = url:match("[^%w]+([%.%w]+)$")
    -- Any delimited alphanumeric on the url
    file_name = file_name or url:match("[^%w]+(%w+)[^%w]+$")
    -- Random name, hope content-type works
    file_name = file_name or str:random(5)

    local content_type = headers["content-type"]

    local extension = nil
    if content_type then
        extension = mimetype.get_mime_extension(content_type)
    end
    if extension then
        file_name = file_name .. "." .. extension
    end

    local disposition = headers["content-disposition"]
    if disposition then
        -- attachment; filename=CodeCogsEqn.png
        file_name = disposition:match('filename=([^;]+)') or file_name
    end

    return file_name
end

-- Callback to remove a file
function removeTempFile(file_path)
    if file_path ~= nil then
        os.remove(file_path)
        print("Deleted: " .. file_path)
    end
end

--  Saves file to /tmp/. If file_name isn't provided,
-- will get the text after the last "/" for filename
-- and content-type for extension
function tempDownloadFile(url, file_name)
    print("url to download: " .. url)

    local respbody = { }
    local options = {
        url = url,
        sink = ltn12.sink.table(respbody),
        redirect = true
    }

    -- nil, code, headers, status
    local response = nil

    if url:starts('https') then
        options.redirect = false
        response = { HTTPS.request(options) }
    else
        response = { http.request(options) }
    end

    local code = response[2]
    local headers = response[3]
    local status = response[4]

    if code ~= 200 then return nil end

    file_name = file_name or getHttpFileName(url, headers)

    local file_path = "data/tmp/" .. file_name
    print("Saved to: " .. file_path)

    file = io.open(file_path, "w+")
    file:write(table.concat(respbody))
    file:close()

    return file_path
end

-- Download the image and send to receiver, it will be deleted.
-- cb_function and extra are optionals callback
function sendPhotoFromUrl(chat_id, url_to_download, caption, reply_to_message_id)
    local file_path = tempDownloadFile(url_to_download, false)
    if not file_path then
        -- Error
        sendMessage(chat_id, langs[get_lang(chat_id)].errorFileDownload)
    else
        print("File path: " .. file_path)
        sendPhoto(chat_id, file_path, caption, reply_to_message_id)
    end
end

-- Download the document and send to receiver, it will be deleted.
-- cb_function and extra are optionals callback
function sendDocumentFromUrl(chat_id, url_to_download, reply_to_message_id)
    local file_path = tempDownloadFile(url_to_download, false)
    if not file_path then
        -- Error
        sendMessage(chat_id, langs[get_lang(chat_id)].errorFileDownload)
    else
        print("File path: " .. file_path)
        sendDocument(chat_id, file_path, reply_to_message_id)
    end
end

-- *** END API FUNCTIONS ***
function sudoInChat(chat_id, user_id)
    for v, user in pairs(config.sudo_users) do
        local member = getChatMember(chat_id, user_id)
        if member then
            if member.status == 'creator' or member.status == 'administrator' or member.status == 'member' then
                return true
            end
        end
    end
    return false
end

-- call this to kick
function kickUser(executer, target, chat_id)
    local obj_chat = getChat(chat_id)
    local obj_remover = getChat(executer)
    local obj_removed = getChat(target)
    if type(obj_chat) == 'table' and type(obj_remover) == 'table' and type(obj_removed) == 'table' then
        if obj_chat.result and obj_remover.result and obj_removed.result then
            if compare_ranks(executer, target, chat_id) and not isWhitelisted(target) then
                -- try to kick
                local res, code = kickChatMember(target, chat_id)

                if res then
                    -- if the user has been kicked, then...
                    savelog(chat_id, "[" .. executer .. "] kicked user " .. target)
                    redis:hincrby('bot:general', 'kick', 1)
                    -- general: save how many kicks
                    -- unban
                    unbanChatMember(target, chat_id)
                    obj_chat = obj_chat.result
                    obj_remover = obj_remover.result
                    obj_removed = obj_removed.result
                    local sent_msg = { from = bot, chat = obj_chat, remover = obj_remover, removed = obj_removed, text = text, service = true, service_type = 'chat_del_user' }
                    print_msg(sent_msg)
                    return langs.phrases.banhammer[math.random(#langs.phrases.banhammer)]
                else
                    return code2text(code, get_lang(chat_id))
                end
            else
                if isWhitelisted(target) then
                    savelog(chat_id, "[" .. executer .. "] tried to kick user " .. target .. " that is whitelisted")
                    return langs[get_lang(chat_id)].cantKickWhitelisted
                else
                    savelog(chat_id, "[" .. executer .. "] tried to kick user " .. target .. " require higher rank")
                    return langs[get_lang(chat_id)].require_rank
                end
            end
        end
    end
end

-- call this to ban
function banUser(executer, target, chat_id)
    local obj_chat = getChat(chat_id)
    local obj_remover = getChat(executer)
    local obj_removed = getChat(target)
    if type(obj_chat) == 'table' and type(obj_remover) == 'table' and type(obj_removed) == 'table' then
        if obj_chat.result and obj_remover.result and obj_removed.result then
            if compare_ranks(executer, target, chat_id) and not isWhitelisted(target) then
                -- try to kick. "code" is already specific
                local res, code = kickChatMember(target, chat_id)

                if res then
                    -- if the user has been kicked, then...
                    savelog(chat_id, "[" .. executer .. "] banned user " .. target)
                    redis:hincrby('bot:general', 'ban', 1)
                    -- general: save how many kicks
                    local hash = 'banned:' .. chat_id
                    redis:sadd(hash, tostring(target))
                    obj_chat = obj_chat.result
                    obj_remover = obj_remover.result
                    obj_removed = obj_removed.result
                    local sent_msg = { from = bot, chat = obj_chat, remover = obj_remover, removed = obj_removed, text = text, service = true, service_type = 'chat_del_user' }
                    print_msg(sent_msg)
                    return langs[get_lang(chat_id)].user .. target .. langs[get_lang(chat_id)].banned .. '\n' .. langs.phrases.banhammer[math.random(#langs.phrases.banhammer)]
                else
                    if code == 106 then
                        local hash = 'banned:' .. chat_id
                        redis:sadd(hash, tostring(target))
                    end
                    return code2text(code, get_lang(chat_id))
                end
            else
                if isWhitelisted(target) then
                    savelog(chat_id, "[" .. executer .. "] tried to ban user " .. target .. " that is whitelisted")
                    return langs[get_lang(chat_id)].cantKickWhitelisted
                else
                    savelog(chat_id, "[" .. executer .. "] tried to ban user " .. target .. " require higher rank")
                    return langs[get_lang(chat_id)].require_rank
                end
            end
        end
    end
end

-- call this to unban
function unbanUser(target, chat_id)
    savelog(chat_id, "[" .. target .. "] unbanned")
    local hash = 'banned:' .. chat_id
    redis:srem(hash, tostring(target))
    -- redis:srem('chat:'..chat_id..':prevban', target) --remove from the prevban list
    local res, code = unbanChatMember(target, chat_id)
    return langs[get_lang(chat_id)].user .. target .. langs[get_lang(chat_id)].unbanned
end

-- Check if user_id is banned in chat_id or not
function isBanned(user_id, chat_id)
    -- Save on redis
    local hash = 'banned:' .. chat_id
    local banned = redis:sismember(hash, tostring(user_id))
    return banned or false
end

-- Returns chat_id ban list
function banList(chat_id)
    local hash = 'banned:' .. chat_id
    local list = redis:smembers(hash)
    local text = langs[get_lang(chat_id)].banListStart
    for k, v in pairs(list) do
        local user_info = redis:hgetall('user:' .. v)
        if user_info and user_info.print_name then
            local print_name = string.gsub(user_info.print_name, "_", " ")
            local print_name = string.gsub(print_name, "?", "")
            text = text .. k .. " - " .. print_name .. " [" .. v .. "]\n"
        else
            text = text .. k .. " - " .. v .. "\n"
        end
    end
    return text
end

-- Global ban
function gbanUser(user_id)
    if tonumber(user_id) == tonumber(bot.id) then
        -- Ignore bot
        return
    end
    if is_admin2(user_id) then
        -- Ignore admins
        return
    end
    -- Save to redis
    local hash = 'gbanned'
    redis:sadd(hash, user_id)
end

-- Global unban
function ungbanUser(user_id)
    -- Save on redis
    local hash = 'gbanned'
    redis:srem(hash, user_id)
end

-- Check if user_id is globally banned or not
function isGbanned(user_id)
    -- Save on redis
    local hash = 'gbanned'
    local gbanned = redis:sismember(hash, user_id)
    return gbanned or false
end

function blockUser(user_id, lang)
    if not is_admin2(user_id) then
        redis:sadd('bot:blocked', user_id)
        return langs[lang].userBlocked
    else
        return langs[lang].cantBlockAdmin
    end
end

function unblockUser(user_id, lang)
    redis:srem('bot:blocked', user_id)
    return langs[lang].userUnblocked
end

function isBlocked(user_id)
    if redis:sismember('bot:blocked', user_id) then
        return true
    else
        return false
    end
end

-- Check if user_id is whitelisted or not
function isWhitelisted(user_id)
    -- Save on redis
    local hash = 'whitelist'
    local whitelisted = redis:sismember(hash, user_id)
    return whitelisted or false
end

function resolveUsername(username)
    username = '@' .. username:lower()
    local obj = resolveChannelSupergroupsUsernames(username)
    if obj then
        return obj
    else
        local hash = 'bot:usernames'
        local stored = redis:hget(hash, username)
        if stored then
            local obj = getChat(stored)
            if obj.result then
                obj = obj.result
                return obj
            end
        else
            return false
        end
    end
end