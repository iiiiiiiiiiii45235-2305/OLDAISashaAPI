local function run(msg, matches)
    if msg.service then
        if msg.service_type == 'chat_del_user' or msg.service_type == 'chat_del_user_leave' then
            local leave_ban = false
            local data = load_data(config.moderation.data)
            if data[tostring(msg.chat.id)] then
                if data[tostring(msg.chat.id)].settings then
                    if data[tostring(msg.chat.id)].settings.lock_leave then
                        leave_ban = data[tostring(msg.chat.id)].settings.lock_leave
                    end
                end
            end
            if msg.remover and msg.removed and leave_ban then
                if not is_mod2(msg.removed.id) then
                    return banUser(bot.id, msg.removed.id, msg.chat.id)
                end
            end
        end
    end
end

return {
    description = "LEAVE_BAN",
    patterns =
    {
        "!!tgservice chat_del_user_leave",
        "!!tgservice chat_del_user",
    },
    run = run,
    min_rank = 5
}