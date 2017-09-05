require("introtimework")
local action, chat_id, sleep_time = ...
os.execute('sleep ' .. sleep_time)
if action == 'spamtext' then
    action, chat_id, sleep_time, text = ...
    return sendMessage(chat_id, text)
elseif action == 'spamforward' then
    action, chat_id, sleep_time, message_id = ...
    return forwardMessage(chat_id, chat_id, message_id)
end