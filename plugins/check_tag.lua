local function check_tag(msg, user_id, user)
    -- check if username is in message
    if user.username then
        if msg.text then
            if string.find(msg.text:lower(), user.username:lower()) or string.find(msg.text, user.first_name) then
                return true
            end
        end
        if msg.media then
            if msg.caption then
                if string.find(msg.caption:lower(), user.username:lower()) or string.find(msg.caption, user.first_name) then
                    return true
                end
            end
        end
    else
        if msg.text then
            if string.find(msg.text, user.first_name) then
                return true
            end
        end
        if msg.media then
            if msg.caption then
                if string.find(msg.caption, user.first_name) then
                    return true
                end
            end
        end
    end

    local tagged = false
    -- if forward check forward
    if msg.forward then
        if msg.forward_from then
            tagged = check_tag(msg.forward_from, user_id, user)
        elseif msg.forward_from_chat then
            tagged = check_tag(msg.forward_from_chat, user_id, user)
        end
    end

    -- if reply check reply
    if msg.reply then
        tagged = check_tag(msg.reply_to_message, user_id, user)
    end
    return tagged
end

-- send message to sudoers when tagged
local function pre_process(msg)
    if msg then
        -- exclude private chats with bot
        if (msg.chat.type == 'group' or msg.chat.type == 'supergroup') then
            for v, user in pairs(config.sudo_users) do
                -- exclude bot tags, autotags and tags of API version
                if tonumber(msg.from.id) ~= tonumber(bot.id) and tonumber(msg.from.id) ~= tonumber(user) and tonumber(msg.from.id) ~= 202256859 then
                    local obj_user = getChat(user).result
                    local tagged = check_tag(msg, user, obj_user)

                    if tagged then
                        if msg.reply then
                            forwardMessage(obj_user.result.id, msg.chat.id, msg.reply_to_message.message_id)
                        end
                        local text = langs[msg.lang].receiver .. msg.chat.print_name:gsub("_", " ") .. ' [' .. msg.chat.id .. ']\n' .. langs[msg.lang].sender
                        if msg.from.username then
                            text = text .. '@' .. msg.from.username .. ' [' .. msg.from.id .. ']\n'
                        else
                            text = text .. msg.from.print_name:gsub("_", " ") .. ' [' .. msg.from.id .. ']\n'
                        end
                        text = text .. langs[msg.lang].msgText

                        if msg.text then
                            text = text .. msg.text .. ' '
                        end
                        if msg.media then
                            if msg.caption then
                                text = text .. msg.media.caption
                            end
                        end
                        sendMessage(user, text)
                    end
                end
            end
        end
    end
    return msg
end

return {
    description = "CHECK_TAG",
    patterns = { },
    pre_process = pre_process,
    min_rank = 5
}