loadfile("./introtimework.lua")()
local action, sleep_time = ...
if sleep_time then
    if tonumber(sleep_time) then
        if tonumber(sleep_time) > 0 then
            os.execute('sleep ' .. sleep_time)
        end
    end
end
if action == 'sendmessage' then
    action, sleep_time, chat_id, text = ...
    text = text:gsub('\\"', '"')
    sendMessage(chat_id, text)
elseif action == 'forwardmessage' then
    action, sleep_time, chat_id, message_id = ...
    forwardMessage(chat_id, chat_id, message_id)
elseif action == 'deletemessage' then
    action, sleep_time, chat_id, message_id = ...
    if not deleteMessage(chat_id, message_id, true) then
        -- sendMessage(chat_id, langs[get_lang(chat_id)].cantDeleteMessage, false, message_id)
    end
elseif action == 'kickuser' then
    action, sleep_time, chat_id, user_id, reason = ...
    sendMessage(chat_id, kickUser(bot.id, user_id, chat_id, reason))
end