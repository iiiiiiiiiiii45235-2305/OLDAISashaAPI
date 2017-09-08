loadfile("./introtimework.lua")()
local action, chat_id, sleep_time = ...
print(action, chat_id, sleep_time)
if sleep_time then
    if tonumber(sleep_time) > 0 then
        os.execute('sleep ' .. sleep_time)
    end
end
if action == 'spamtext' then
    action, chat_id, sleep_time, text = ...
    text = text:gsub('\\"', '"')
    sendMessage(chat_id, text)
elseif action == 'spamforward' then
    action, chat_id, sleep_time, message_id = ...
    forwardMessage(chat_id, chat_id, message_id)
elseif action == 'delete' then
    action, chat_id, sleep_time, message_id = ...
    if not deleteMessage(chat_id, message_id, true) then
        sendMessage(chat_id, langs[msg.lang].cantDeleteMessage, false, message_id)
    end
end