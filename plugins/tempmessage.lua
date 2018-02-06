local text_table = {
    -- chat_id = text
}

local function run(msg, matches)
    if msg.cb then
        if matches[1] then
            if matches[1] == '###cbtempmessage' then
                if matches[2] == 'DELETE' then
                    if not deleteMessage(msg.chat.id, msg.message_id, true) then
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                    end
                elseif string.match(matches[2], '^%d+$') then
                    if text_table[tostring(msg.from.id)] then
                        local time = tonumber(matches[2])
                        if matches[3] == 'BACK' then
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].tempmessageIntro:gsub('X', text_table[tostring(msg.from.id)]), keyboard_tempmessage(matches[4], time))
                        elseif matches[3] == 'SECONDS' or matches[3] == 'MINUTES' or matches[3] == 'HOURS' then
                            local remainder, hours, minutes, seconds = 0
                            hours = math.floor(time / 3600)
                            remainder = time % 3600
                            minutes = math.floor(remainder / 60)
                            seconds = remainder % 60
                            if matches[3] == 'SECONDS' then
                                if tonumber(matches[4]) == 0 then
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].secondsReset, false)
                                    time = time - seconds
                                else
                                    if (time + tonumber(matches[4])) >= 0 and(time + tonumber(matches[4])) < 172800 then
                                        time = time + tonumber(matches[4])
                                    else
                                        answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTempTimeRange, true)
                                    end
                                end
                            elseif matches[3] == 'MINUTES' then
                                if tonumber(matches[4]) == 0 then
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].minutesReset, false)
                                    time = time -(minutes * 60)
                                else
                                    if (time +(tonumber(matches[4]) * 60)) >= 0 and(time +(tonumber(matches[4]) * 60)) < 172800 then
                                        time = time +(tonumber(matches[4]) * 60)
                                    else
                                        answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTempTimeRange, true)
                                    end
                                end
                            elseif matches[3] == 'HOURS' then
                                if tonumber(matches[4]) == 0 then
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].hoursReset, false)
                                    time = time -(hours * 60 * 60)
                                else
                                    if (time +(tonumber(matches[4]) * 60 * 60)) >= 0 and(time +(tonumber(matches[4]) * 60 * 60)) < 172800 then
                                        time = time +(tonumber(matches[4]) * 60 * 60)
                                    else
                                        answerCallbackQuery(msg.cb_id, langs[msg.lang].errorTempTimeRange, true)
                                    end
                                end
                            end
                            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].tempmessageIntro:gsub('X', text_table[tostring(msg.from.id)]), keyboard_tempmessage(matches[5], time))
                            mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] .. matches[5])
                        elseif matches[3] == 'DONE' then
                            if is_mod2(msg.from.id, matches[4], false) then
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].done, false)
                                local message_id = sendMessage(matches[4], text_table[tostring(msg.from.id)]).result.message_id
                                text_table[tostring(msg.from.id)] = nil
                                if message_id then
                                    io.popen('sudo lua timework.lua "deletemessage" "' .. time .. '" "' .. matches[4] .. '" "' .. message_id .. '"')
                                end
                                if not deleteMessage(msg.chat.id, msg.message_id, true) then
                                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                                end
                                mystat(matches[1] .. matches[2] .. matches[3] .. matches[4])
                            end
                        end
                    else
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].errorTryAgain)
                    end
                end
                return
            end
        end
    end
    if msg.chat.type ~= 'private' then
        if matches[1]:lower() == 'tempmsg' then
            if msg.from.is_mod then
                deleteMessage(msg.chat.id, msg.message_id)
                if matches[2] and matches[3] and matches[4] and matches[5] then
                    local hours = tonumber(matches[2])
                    local minutes = tonumber(matches[3])
                    local seconds = tonumber(matches[4])
                    if hours >= 48 then
                        hours = 47
                        minutes = 59
                        seconds = 59
                    end
                    if minutes >= 60 then
                        minutes = 59
                        seconds = 59
                    end
                    if seconds >= 60 then
                        seconds = 59
                    end
                    local time = seconds +(minutes * 60) +(hours * 60 * 60)
                    local message_id = sendMessage(msg.chat.id, matches[5]).result.message_id
                    if message_id then
                        io.popen('sudo lua timework.lua "deletemessage" "' .. time .. '" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                    end
                else
                    text_table[tostring(msg.from.id)] = matches[2]
                    if not sendKeyboard(msg.from.id, langs[msg.lang].tempmessageIntro:gsub('X', matches[2]), keyboard_tempmessage(msg.chat.id)) then
                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                    end
                end
            else
                return langs[msg.lang].require_mod
            end
        end
    else
        return langs[msg.lang].useYourGroups
    end
end

return {
    description = "TEMPMESSAGE",
    patterns =
    {
        "^(###cbtempmessage)(DELETE)$",
        "^(###cbtempmessage)(%d+)(BACK)(%-%d+)$",
        "^(###cbtempmessage)(%d+)(SECONDS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbtempmessage)(%d+)(MINUTES)([%+%-]?%d+)(%-%d+)$",
        "^(###cbtempmessage)(%d+)(HOURS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbtempmessage)(%d+)(DONE)(%-%d+)$",

        -- X hour Y minutes Z seconds
        "^[#!/]([Tt][Ee][Mm][Pp][Mm][Ss][Gg]) (%d+) (%d+) (%d+) (.*)$",
        -- private keyboard
        "^[#!/]([Tt][Ee][Mm][Pp][Mm][Ss][Gg]) (.*)$",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "MOD",
        "/tempmsg [{hours} {minutes} {seconds}] {text}",
    },
}