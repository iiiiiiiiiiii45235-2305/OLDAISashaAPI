local function pre_process(msg)
    if msg.service then
        if msg.service_type == 'chat_del_user' or msg.service_type == 'chat_del_user_leave' then
            local leave_ban = 'no'
            local data = load_data(config.moderation.data)
            if data[tostring(msg.chat.id)] then
                if data[tostring(msg.chat.id)]['settings'] then
                    if data[tostring(msg.chat.id)]['settings']['leave_ban'] then
                        leave_ban = data[tostring(msg.chat.id)]['settings']['leave_ban']
                    end
                end
            end
            if msg.remover and msg.removed and leave_ban == 'yes' then
                if not is_mod2(msg.removed.id) then
                    banUser(bot.id, msg.removed.id, msg.chat.id)
                end
            end
        end
    end
    return msg
end

return {
    description = "LEAVE_BAN",
    patterns = { },
    pre_process = pre_process,
    min_rank = 5
}