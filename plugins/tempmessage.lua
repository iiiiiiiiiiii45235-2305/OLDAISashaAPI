local text_table = {
    -- chat_id = text
}

local function check_time(not_hour)
    if tonumber(not_hour) < 0 or tonumber(not_hour) >= 60 then
        return false
    end
    return true
end

local function keyboard_tempmessage(chat_id, time)
    if not time then
        time = 88260
    end
    local hours, minutes, seconds = 0
    hours = string.format("%02.f", math.floor(time / 3600))
    minutes = string.format("%02.f", math.floor((time / 60) -(hours * 60)))
    seconds = string.format("%02.f", math.floor(time -(hours * 3600) -(minutes * 60)))
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    for i = 1, 8 do
        keyboard.inline_keyboard[i] = { }
    end

    keyboard.inline_keyboard[1][1] = { text = langs[lang].seconds:gsub('X', seconds), callback_data = 'tempmessage' .. time .. 'BACK' .. chat_id }
    keyboard.inline_keyboard[2][1] = { text = "-10", callback_data = 'tempmessage' .. time .. 'SECONDS-10' .. chat_id }
    keyboard.inline_keyboard[2][2] = { text = "-5", callback_data = 'tempmessage' .. time .. 'SECONDS-5' .. chat_id }
    keyboard.inline_keyboard[2][3] = { text = "-1", callback_data = 'tempmessage' .. time .. 'SECONDS-1' .. chat_id }
    keyboard.inline_keyboard[2][4] = { text = "+1", callback_data = 'tempmessage' .. time .. 'SECONDS+1' .. chat_id }
    keyboard.inline_keyboard[2][5] = { text = "+5", callback_data = 'tempmessage' .. time .. 'SECONDS+5' .. chat_id }
    keyboard.inline_keyboard[2][6] = { text = "+10", callback_data = 'tempmessage' .. time .. 'SECONDS+10' .. chat_id }

    keyboard.inline_keyboard[3][1] = { text = langs[lang].minutes:gsub('X', minutes), callback_data = 'tempmessage' .. time .. 'BACK' .. chat_id }

    keyboard.inline_keyboard[4][1] = { text = "-10", callback_data = 'tempmessage' .. time .. 'MINUTES-10' .. chat_id }
    keyboard.inline_keyboard[4][2] = { text = "-5", callback_data = 'tempmessage' .. time .. 'MINUTES-5' .. chat_id }
    keyboard.inline_keyboard[4][3] = { text = "-1", callback_data = 'tempmessage' .. time .. 'MINUTES-1' .. chat_id }
    keyboard.inline_keyboard[4][4] = { text = "+1", callback_data = 'tempmessage' .. time .. 'MINUTES+1' .. chat_id }
    keyboard.inline_keyboard[4][5] = { text = "+5", callback_data = 'tempmessage' .. time .. 'MINUTES+5' .. chat_id }
    keyboard.inline_keyboard[4][6] = { text = "+10", callback_data = 'tempmessage' .. time .. 'MINUTES+10' .. chat_id }

    keyboard.inline_keyboard[5][1] = { text = langs[lang].hours:gsub('X', hours), callback_data = 'tempmessage' .. time .. 'BACK' .. chat_id }

    keyboard.inline_keyboard[6][1] = { text = "-5", callback_data = 'tempmessage' .. time .. 'HOURS-5' .. chat_id }
    keyboard.inline_keyboard[6][2] = { text = "-3", callback_data = 'tempmessage' .. time .. 'HOURS-3' .. chat_id }
    keyboard.inline_keyboard[6][3] = { text = "-1", callback_data = 'tempmessage' .. time .. 'HOURS-1' .. chat_id }
    keyboard.inline_keyboard[6][4] = { text = "+1", callback_data = 'tempmessage' .. time .. 'HOURS+1' .. chat_id }
    keyboard.inline_keyboard[6][5] = { text = "+3", callback_data = 'tempmessage' .. time .. 'HOURS+3' .. chat_id }
    keyboard.inline_keyboard[6][6] = { text = "+5", callback_data = 'tempmessage' .. time .. 'HOURS+5' .. chat_id }

    keyboard.inline_keyboard[7][1] = { text = "OK " .. hours .. langs[lang].hoursWord .. minutes .. langs[lang].minutesWord .. seconds .. langs[lang].secondsWord, callback_data = 'tempmessage' .. time .. 'DONE' .. chat_id }

    keyboard.inline_keyboard[8][1] = { text = langs[lang].updateKeyboard, callback_data = 'tempmessage' .. time .. 'BACK' .. chat_id }
    keyboard.inline_keyboard[8][2] = { text = langs[lang].deleteKeyboard, callback_data = 'tempmessageDELETE' }
    return keyboard
end

local function run(msg, matches)
    if msg.cb then
        if matches[1] then
            if matches[1] == '###cbtempmessage' then
                if matches[2] then
                    if matches[2] == 'DELETE' then
                        if not deleteMessage(msg.chat.id, msg.message_id, true) then
                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                        end
                    elseif string.match(matches[2], '^%d+$') and matches[3] then
                        local time = tonumber(matches[2])
                        local hours, minutes, seconds = 0
                        hours = string.format("%02.f", math.floor(time / 3600))
                        minutes = string.format("%02.f", math.floor((time / 60) -(hours * 60)))
                        seconds = string.format("%02.f", math.floor(time -(hours * 3600) -(minutes * 60)))
                        if matches[3] == 'BACK' then
                            if matches[4] then
                                editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].tempmessageIntro, keyboard_tempmessage(matches[4], time))
                            end
                        elseif matches[3] == 'SECONDS' or matches[3] == 'MINUTES' or matches[3] == 'HOURS' then
                            if matches[4] and matches[5] then
                                if is_mod2(msg.from.id, matches[5], false) then
                                    if matches[3] == 'SECONDS' then
                                        if ((seconds + tonumber(matches[4])) >= 0) or((seconds + tonumber(matches[4])) < 60) then
                                            time = time + tonumber(matches[4])
                                        end
                                    elseif matches[3] == 'MINUTES' then
                                        if ((minutes + tonumber(matches[4])) >= 0) or((minutes + tonumber(matches[4])) < 60) then
                                            time = time +(tonumber(matches[4]) * 60)
                                        end
                                    elseif matches[3] == 'HOURS' then
                                        if ((hours + tonumber(matches[4])) >= 0) or((hours + tonumber(matches[4])) < 48) then
                                            time = time +(tonumber(matches[4]) * 60 * 60)
                                        end
                                    end
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].tempmessageIntro, keyboard_tempmessage(matches[5], time))
                                else
                                    editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].require_mod)
                                end
                            end
                        elseif matches[3] == 'DONE' then
                            local message_id = sendMessage(matches[5], text_table[tostring(msg.from.id)]).result.message_id
                            if message_id then
                                io.popen('lua timework.lua "delete" "' .. chat_id .. '" "' .. time .. '" "' .. message_id .. '"')
                            end
                        end
                    end
                end
                return
            end
        end
    end
    if msg.chat.type ~= 'private' then
        if matches[1]:lower() == 'tempmsg' then
            if msg.from.is_mod then
                if matches[2] and matches[3] and matches[4] and matches[5] then
                    local hours = tonumber(matches[1])
                    local minutes = tonumber(matches[2])
                    local seconds = tonumber(matches[3])
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
                    local message_id = sendMessage(msg.chat.id, matches[4]).result.message_id
                    if message_id then
                        io.popen('lua timework.lua "delete" "' .. chat_id .. '" "' .. time .. '" "' .. message_id .. '"')
                    end
                elseif matches[2] then
                    text_table[tostring(msg.from.id)] = matches[2]
                    if sendKeyboard(msg.from.id, langs[msg.lang].tempmessageIntro, keyboard_tempmessage(msg.chat.id)) then
                        if msg.chat.type ~= 'private' then
                            return sendMessage(msg.chat.id, langs[msg.lang].sendTimeKeyboardPvt)
                        end
                    else
                        return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
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
        "^(###cbtempmessage)(%d+)(SECONDS)([%+%-]%d?%d)(%-%d+)$",
        "^(###cbtempmessage)(%d+)(MINUTES)([%+%-]%d?%d)(%-%d+)$",
        "^(###cbtempmessage)(%d+)(HOURS)([%+%-]%d?%d)(%-%d+)$",
        "^(###cbtempmessage)(%d+)(DONE)(%-%d+)$",

        -- X hour Y minutes Z seconds
        "^[#!/]([Tt][Ee][Mm][Pp][Mm][Ss][Gg]) ([1234]?%d) ([12345]?%d) ([12345]%d) (.*)$",
        -- private keyboard
        "^[#!/]([Tt][Ee][Mm][Pp][Mm][Ss][Gg]) (.*)$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "MOD",
        "#tempmsg [<hours> <minutes> <seconds>] <text>",
    },
}