local function run(msg, matches)
    if msg.service then
        if msg.service_type then
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
        "^!!tgservice (.+)$"
    },
    run = run,
    min_rank = 5
}