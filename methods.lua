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
    local text_max = 4096
    local text_len = string.len(text)
    local num_msg = math.ceil(text_len / text_max)
    local url = BASE_URL ..
    '/sendMessage?chat_id=' .. chat_id ..
    '&disable_web_page_preview=true'
    if reply_to_message_id then
        url = url .. '&reply_to_message_id=' .. reply_to_message_id
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
                save_log('send_msg', code .. '\n' .. text)
            end
        end
    else
        local my_text = string.sub(text, 1, 4096)
        local rest = string.sub(text, 4096, text_len)
        url = url .. '&text=' .. URL.escape(my_text)

        local res, code = sendRequest(url)

        if not res and code then
            -- if the request failed and a code is returned (not 403 and 429)
            if code ~= 403 and code ~= 429 and code ~= 110 and code ~= 111 then
                save_log('send_msg', code .. '\n' .. text)
            end
        end
        res, code = sendMessage(chat_id, rest, use_markdown, reply_to_message_id, send_sound)
    end

    return res, code
    -- return false, and the code
end

function sendMessage_SUDOERS(text)
    for v, user in pairs(config.sudo_users) do
        if user ~= bot.id then
            -- print(text)
            sendMessage(user, text)
        end
    end
end

function sendReply(msg, text, markd, send_sound)
    return sendMessage(msg.chat.id, text, markd, msg.message_id, send_sound)
end

function sendAdmin(text, markdown)
    for v, user in pairs(config.sudo_users) do
        if user ~= bot.id then
            -- print(text)
            sendMessage(user, text, markdown)
        end
    end
end

function sendLog(text, markdown)
    if config.log_chat then
        return sendMessage(config.log_chat, text, markdown)
    else
        for v, user in pairs(config.sudo_users) do
            if user ~= bot.id then
                -- print(text)
                sendMessage(user, text, markdown)
            end
        end
    end
end

function forwardMessage(chat_id, from_chat_id, message_id)
    local url = BASE_URL ..
    '/forwardMessage?chat_id=' .. chat_id ..
    '&from_chat_id=' .. from_chat_id ..
    '&message_id=' .. message_id
    return sendRequest(url)
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
            save_log('send_msg', code .. '\n' .. text)
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
            save_log('send_msg', code .. '\n' .. text)
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
    local url = BASE_URL ..
    '/sendLocation?chat_id=' .. chat_id ..
    '&latitude=' .. latitude ..
    '&longitude=' .. longitude
    if reply_to_message_id then
        url = url .. '&reply_to_message_id=' .. reply_to_message_id
    end
    return sendRequest(url)
end

----------------------------By Id-----------------------------------------

function sendPhotoId(chat_id, file_id, reply_to_message_id)
    local url = BASE_URL ..
    '/sendPhoto?chat_id=' .. chat_id ..
    '&photo=' .. file_id
    if reply_to_message_id then
        url = url .. '&reply_to_message_id=' .. reply_to_message_id
    end
    return sendRequest(url)
end

function sendStickerId(chat_id, file_id, reply_to_message_id)
    local url = BASE_URL ..
    '/sendSticker?chat_id=' .. chat_id ..
    '&sticker=' .. file_id
    if reply_to_message_id then
        url = url .. '&reply_to_message_id=' .. reply_to_message_id
    end
    return sendRequest(url)
end

function sendVoiceId(chat_id, file_id, reply_to_message_id)
    local url = BASE_URL ..
    '/sendVoice?chat_id' .. chat_id ..
    '&voice=' .. file_id
    if reply_to_message_id then
        url = url .. '&reply_to_message_id=' .. reply_to_message_id
    end
    return sendRequest(url)
end

function sendAudioId(chat_id, file_id, reply_to_message_id)
    local url = BASE_URL ..
    '/sendAudio?chat_id' .. chat_id ..
    '&audio=' .. file_id
    if reply_to_message_id then
        url = url .. '&reply_to_message_id=' .. reply_to_message_id
    end
    return sendRequest(url)
end

function sendVideoId(chat_id, file_id, reply_to_message_id)
    local url = BASE_URL ..
    '/sendVideo?chat_id' .. chat_id ..
    '&video=' .. file_id
    if reply_to_message_id then
        url = url .. '&reply_to_message_id=' .. reply_to_message_id
    end
    return sendRequest(url)
end

function sendDocumentId(chat_id, file_id, reply_to_message_id)
    local url = BASE_URL ..
    '/sendDocument?chat_id=' .. chat_id ..
    '&document=' .. file_id
    if reply_to_message_id then
        url = url .. '&reply_to_message_id=' .. reply_to_message_id
    end
    return sendRequest(url)
end

----------------------------To curl--------------------------------------------

function curlRequest(curl_command)
    -- Use at your own risk. Will not check for success.
    io.popen(curl_command)
end

function sendPhoto(chat_id, photo, caption, reply_to_message_id)
    local url = BASE_URL .. '/sendPhoto'
    local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "photo=@' .. photo .. '"'
    if reply_to_message_id then
        curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
    end
    if caption then
        curl_command = curl_command .. ' -F "caption=' .. caption .. '"'
    end
    return curlRequest(curl_command)
end

function sendSticker(chat_id, sticker, reply_to_message_id)
    local url = BASE_URL .. '/sendSticker'
    local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "sticker=@' .. sticker .. '"'
    if reply_to_message_id then
        curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
    end
    return curlRequest(curl_command)
end

function sendVoice(chat_id, voice, reply_to_message_id)
    local url = BASE_URL .. '/sendVoice'
    local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "voice=@' .. voice .. '"'
    if reply_to_message_id then
        curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
    end
    if duration then
        curl_command = curl_command .. ' -F "duration=' .. duration .. '"'
    end
    return curlRequest(curl_command)
end

function sendAudio(chat_id, audio, reply_to_message_id, duration, performer, title)
    local url = BASE_URL .. '/sendAudio'
    local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "audio=@' .. audio .. '"'
    if reply_to_message_id then
        curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
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
    return curlRequest(curl_command)
end

function sendVideo(chat_id, video, reply_to_message_id, duration, performer, title)
    local url = BASE_URL .. '/sendVideo'
    local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "video=@' .. video .. '"'
    if reply_to_message_id then
        curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
    end
    if caption then
        curl_command = curl_command .. ' -F "caption=' .. caption .. '"'
    end
    if duration then
        curl_command = curl_command .. ' -F "duration=' .. duration .. '"'
    end
    return curlRequest(curl_command)
end

function sendDocument(chat_id, document, reply_to_message_id)
    local url = BASE_URL .. '/sendDocument'
    local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. chat_id .. '" -F "document=@' .. document .. '"'
    if reply_to_message_id then
        curl_command = curl_command .. ' -F "reply_to_message_id=' .. reply_to_message_id .. '"'
    end
    return curlRequest(curl_command)
end

function sendDocument_SUDOERS(document)
    for v, user in pairs(config.sudo_users) do
        if user ~= bot.id then
            local url = BASE_URL .. '/sendDocument'
            local curl_command = 'curl "' .. url .. '" -F "chat_id=' .. user .. '" -F "document=@' .. document .. '"'
            curlRequest(curl_command)
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

-- *** END API FUNCTIONS ***

-- call this to kick
function kickUser(executer, target, chat_id)
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
            return langs.phrases.banhammer[math.random(#langs.phrases.banhammer)]
        else
            local motivation = code2text(code, get_lang(chat_id))
            return res, motivation
        end
    else
        if isWhitelisted(target) then
            savelog(chat_id, "[" .. executer .. "] tried to kick user " .. target .. " that is whitelisted")
            --
            return langs[get_lang(chat_id)].cantKickWhitelisted
        else
            savelog(chat_id, "[" .. executer .. "] tried to kick user " .. target .. " require higher rank")
            return langs[get_lang(chat_id)].require_rank
        end
    end
end

-- call this to ban
function banUser(executer, target, chat_id)
    if compare_ranks(executer, target, chat_id) and not isWhitelisted(target) then
        -- try to kick. "code" is already specific
        local res, code = kickChatMember(target, chat_id)

        if res then
            -- if the user has been kicked, then...
            savelog(chat_id, "[" .. executer .. "] banned user " .. target)
            redis:hincrby('bot:general', 'ban', 1)
            -- genreal: save how many kicks
            local hash = 'banned:' .. chat_id
            redis:sadd(hash, target)
            return langs[get_lang(chat_id)].user .. target .. langs[get_lang(chat_id)].banned .. '\n' .. langs.phrases.banhammer[math.random(#langs.phrases.banhammer)]
            -- return res and not the text
        else
            --- else, the user haven't been kicked
            --[[if code == 106 then --if trying to ban an user that is not in the group, add it to the prevban list. The user will be banned as soon as he join. Return true if the user is a new entry
			local db_res = redis:sadd('chat:'..chat_id..':prevban', target)
			if db_res == 1 then --if not already added, then return an error and the motivation
				return false, make_text(langs[ln].banhammer.already_banned_normal, target)
			else
				return true
			end
		end]]
            -- else, if the user has not been banned because of different errors from the error [106], then...
            local text = code2text(code, get_lang(chat_id))
            return res, text
            -- return the motivation too
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

-- call this to unban
function unbanUser(target, chat_id)
    savelog(chat_id, "[" .. target .. "] unbanned")
    local hash = 'banned:' .. chat_id
    local removed = redis:srem(hash, target)
    if removed == 0 then
        return false
    end
    -- redis:srem('chat:'..chat_id..':prevban', target) --remove from the prevban list
    local res, code = unbanChatMember(target, chat_id)
    return langs[get_lang(chat_id)].user .. target .. langs[msg.lang].unbanned
end

-- Check if user_id is banned in chat_id or not
function isBanned(user_id, chat_id)
    -- Save on redis
    local hash = 'banned:' .. chat_id
    local banned = redis:sismember(hash, user_id)
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
    return langs[get_lang(chat_id)].user .. target .. langs[msg.lang].gbanned
end

-- Global unban
function ungbanUser(user_id)
    -- Save on redis
    local hash = 'gbanned'
    redis:srem(hash, user_id)
    return langs[get_lang(chat_id)].user .. target .. langs[msg.lang].ungbanned
end

-- Check if user_id is globally banned or not
function isGbanned(user_id)
    -- Save on redis
    local hash = 'gbanned'
    local gbanned = redis:sismember(hash, user_id)
    return gbanned or false
end

-- Returns globally ban list
function gbanList()
    local hash = 'gbanned'
    local list = redis:smembers(hash)
    local text = langs[get_lang(chat_id)].gbanListStart
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

function block_user(user_id, lang)
    if not is_admin2(user_id) then
        redis:sadd('bot:blocked', user_id)
        return langs[lang].userBlocked
    else
        return langs[lang].cantBlockAdmin
    end
end

function unblock_user(user_id, lang)
    redis:srem('bot:blocked', user_id)
    return langs[lang].userUnblocked
end

function is_blocked(user_id)
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
        local stored = db:hget(hash, username)
        if stored then
            return getChat(stored).result
        else
            return false
        end
    end
end