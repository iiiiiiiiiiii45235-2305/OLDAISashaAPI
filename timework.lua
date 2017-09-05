require("introtimework")
local action, chat_id, sleep_time = ...
os.execute('sleep ' .. sleep_time)
if action == 'spamtext' then
    action, chat_id, sleep_time, text = ...
    return sendMessage(chat_id, text:gsub('\"', '"')
elseif action == 'spamforward' then
    action, chat_id, sleep_time, message_id = ...
    return forwardMessage(chat_id, chat_id, message_id)
elseif action == 'delete' then
    action, chat_id, sleep_time, message_id = ...
    if not deleteMessage(chat_id, message_id, true) then
        return sendMessage(chat_id, langs[msg.lang].cantDeleteMessage, false, message_id)
    end
end