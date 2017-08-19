local function run(msg, matches)
    if is_admin(msg) then
        mystat('/todo <text>')
        if msg.reply then
            forwardLog(msg.chat.id, msg.reply_to_message.message_id)
            sendLog('#todo ' ..(matches[1] or ''), false, true)
        elseif matches[1] then
            sendLog('#todo ' .. matches[1], false, true)
        end
        return langs[msg.lang].ok
    end
end

return {
    description = "TODO",
    patterns =
    {
        "^[#!/][Tt][Oo][Dd][Oo]$",
        "^[#!/][Tt][Oo][Dd][Oo] (.*)$",
    },
    run = run,
    min_rank = 3,
    syntax =
    {
        "ADMIN",
        "#todo <reply> [<text>]",
        "#todo <text>",
    }
}