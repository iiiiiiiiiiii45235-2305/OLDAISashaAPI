local function run(msg, matches)
    if config.log_chat then
        if is_admin(msg) then
            if msg.reply then
                forwardMessage(config.log_chat, msg.chat.id, msg.reply_to_message.message_id)
            end
            sendLog(msg.text)
            sendReply(msg, langs[msg.lang].ok)
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