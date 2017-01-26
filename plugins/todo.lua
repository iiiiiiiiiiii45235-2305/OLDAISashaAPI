local function run(msg, matches)
    if is_admin(msg) then
        if config.log_chat then
            if msg.reply then
                forwardMessage(config.log_chat, msg.chat.id, msg.reply_to_message.message_id)
            end
            sendLog(msg.text)
        end
    end
end

return {
    description = "TODO",
    patterns =
    {
        "^[#!/][Tt][Oo][Dd][Oo]",
    },
    run = run,
    min_rank = 3,
    syntax =
    {
        "ADMIN",
        "#todo <text>",
    }
}