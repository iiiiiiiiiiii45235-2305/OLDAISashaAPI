require("introtimework")
local sleep_time, string_to_execute, chat_id = ...
os.execute('sleep ' .. sleep_time)
local output = loadstring(string_to_execute)()
if output then
    if type(output) == 'table' then
        output = nil
    end
end
if output then
    sendMessage(chat_id, tostring(output))
end