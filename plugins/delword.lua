local delword_table = {
    -- chat_id = word|pattern
}

local function get_censorships_hash(msg)
    if msg.chat.type == 'group' then
        return 'group:' .. msg.chat.id .. ':censorships'
    end
    if msg.chat.type == 'supergroup' then
        return 'supergroup:' .. msg.chat.id .. ':censorships'
    end
    return false
end

local function setunset_delword(msg, var_name, time)
    local hash = get_censorships_hash(msg)
    if hash then
        if redis:hget(hash, var_name) then
            redis:hdel(hash, var_name)
            return langs[msg.lang].delwordRemoved .. var_name
        else
            redis:hset(hash, var_name, time or true)
            return langs[msg.lang].delwordAdded .. var_name
        end
    end
end

local function list_censorships(msg)
    local hash = get_censorships_hash(msg)

    if hash then
        local names = redis:hkeys(hash)
        local text = langs[msg.lang].delwordList
        for i = 1, #names do
            text = text .. names[i] .. '\n'
        end
        return text
    end
end

local function keyboard_tempdelword(chat_id, time)
    if not time then
        time = 88230
    end
    local remainder, hours, minutes, seconds = 0
    hours = math.floor(time / 3600)
    remainder = time % 3600
    minutes = math.floor(remainder / 60)
    seconds = remainder % 60
    local lang = get_lang(chat_id)
    local keyboard = { }
    keyboard.inline_keyboard = { }
    for i = 1, 8 do
        keyboard.inline_keyboard[i] = { }
    end

    keyboard.inline_keyboard[1][1] = { text = langs[lang].seconds:gsub('X', seconds), callback_data = 'delword' .. time .. 'SECONDS0' .. chat_id }
    keyboard.inline_keyboard[2][1] = { text = "-10", callback_data = 'delword' .. time .. 'SECONDS-10' .. chat_id }
    keyboard.inline_keyboard[2][2] = { text = "-5", callback_data = 'delword' .. time .. 'SECONDS-5' .. chat_id }
    keyboard.inline_keyboard[2][3] = { text = "-1", callback_data = 'delword' .. time .. 'SECONDS-1' .. chat_id }
    keyboard.inline_keyboard[2][4] = { text = "+1", callback_data = 'delword' .. time .. 'SECONDS+1' .. chat_id }
    keyboard.inline_keyboard[2][5] = { text = "+5", callback_data = 'delword' .. time .. 'SECONDS+5' .. chat_id }
    keyboard.inline_keyboard[2][6] = { text = "+10", callback_data = 'delword' .. time .. 'SECONDS+10' .. chat_id }

    keyboard.inline_keyboard[3][1] = { text = langs[lang].minutes:gsub('X', minutes), callback_data = 'delword' .. time .. 'MINUTES0' .. chat_id }

    keyboard.inline_keyboard[4][1] = { text = "-10", callback_data = 'delword' .. time .. 'MINUTES-10' .. chat_id }
    keyboard.inline_keyboard[4][2] = { text = "-5", callback_data = 'delword' .. time .. 'MINUTES-5' .. chat_id }
    keyboard.inline_keyboard[4][3] = { text = "-1", callback_data = 'delword' .. time .. 'MINUTES-1' .. chat_id }
    keyboard.inline_keyboard[4][4] = { text = "+1", callback_data = 'delword' .. time .. 'MINUTES+1' .. chat_id }
    keyboard.inline_keyboard[4][5] = { text = "+5", callback_data = 'delword' .. time .. 'MINUTES+5' .. chat_id }
    keyboard.inline_keyboard[4][6] = { text = "+10", callback_data = 'delword' .. time .. 'MINUTES+10' .. chat_id }

    keyboard.inline_keyboard[5][1] = { text = langs[lang].hours:gsub('X', hours), callback_data = 'delword' .. time .. 'HOURS0' .. chat_id }

    keyboard.inline_keyboard[6][1] = { text = "-5", callback_data = 'delword' .. time .. 'HOURS-5' .. chat_id }
    keyboard.inline_keyboard[6][2] = { text = "-3", callback_data = 'delword' .. time .. 'HOURS-3' .. chat_id }
    keyboard.inline_keyboard[6][3] = { text = "-1", callback_data = 'delword' .. time .. 'HOURS-1' .. chat_id }
    keyboard.inline_keyboard[6][4] = { text = "+1", callback_data = 'delword' .. time .. 'HOURS+1' .. chat_id }
    keyboard.inline_keyboard[6][5] = { text = "+3", callback_data = 'delword' .. time .. 'HOURS+3' .. chat_id }
    keyboard.inline_keyboard[6][6] = { text = "+5", callback_data = 'delword' .. time .. 'HOURS+5' .. chat_id }

    keyboard.inline_keyboard[7][1] = { text = "OK " .. hours .. langs[lang].hoursWord .. minutes .. langs[lang].minutesWord .. seconds .. langs[lang].secondsWord, callback_data = 'delword' .. time .. 'DONE' .. chat_id }

    keyboard.inline_keyboard[8][1] = { text = langs[lang].updateKeyboard, callback_data = 'delword' .. time .. 'BACK' .. chat_id }
    keyboard.inline_keyboard[8][2] = { text = langs[lang].deleteMessage, callback_data = 'delwordDELETE' }
    return keyboard
end

local function run(msg, matches)
    if msg.cb then
        if matches[1] then
            if matches[1] == '###cbdelword' then
                if matches[2] == 'DELETE' then
                    if not deleteMessage(msg.chat.id, msg.message_id, true) then
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                    end
                elseif string.match(matches[2], '^%d+$') then
                    if delword_table[tostring(msg.from.id)] then
                        local time = tonumber(matches[2])
                        if matches[3] == 'BACK' then
                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].delwordIntro:gsub('X', delword_table[tostring(msg.from.id)]), keyboard_tempdelword(matches[4], time))
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                        elseif matches[3] == 'SECONDS' or matches[3] == 'MINUTES' or matches[3] == 'HOURS' then
                            mystat('###cbdelword' .. matches[2] .. matches[3] .. matches[4] .. matches[5])
                            local remainder, hours, minutes, seconds = 0
                            hours = math.floor(time / 3600)
                            remainder = time % 3600
                            minutes = math.floor(remainder / 60)
                            seconds = remainder % 60
                            if matches[3] == 'SECONDS' then
                                if tonumber(matches[4]) == 0 then
                                    time = time - seconds
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].secondsReset, false)
                                else
                                    if (time + tonumber(matches[4])) >= 0 and(time + tonumber(matches[4])) < 172800 then
                                        time = time + tonumber(matches[4])
                                    else
                                        answerCallbackQuery(msg.cb_id, langs[msg.lang].errordelwordTimeRange, true)
                                    end
                                end
                            elseif matches[3] == 'MINUTES' then
                                if tonumber(matches[4]) == 0 then
                                    time = time -(minutes * 60)
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].minutesReset, false)
                                else
                                    if (time +(tonumber(matches[4]) * 60)) >= 0 and(time +(tonumber(matches[4]) * 60)) < 172800 then
                                        time = time +(tonumber(matches[4]) * 60)
                                    else
                                        answerCallbackQuery(msg.cb_id, langs[msg.lang].errordelwordTimeRange, true)
                                    end
                                end
                            elseif matches[3] == 'HOURS' then
                                if tonumber(matches[4]) == 0 then
                                    time = time -(hours * 60 * 60)
                                    answerCallbackQuery(msg.cb_id, langs[msg.lang].hoursReset, false)
                                else
                                    if (time +(tonumber(matches[4]) * 60 * 60)) >= 0 and(time +(tonumber(matches[4]) * 60 * 60)) < 172800 then
                                        time = time +(tonumber(matches[4]) * 60 * 60)
                                    else
                                        answerCallbackQuery(msg.cb_id, langs[msg.lang].errordelwordTimeRange, true)
                                    end
                                end
                            end
                            editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].delwordIntro:gsub('X', delword_table[tostring(msg.from.id)]), keyboard_tempdelword(matches[5], time))
                        elseif matches[3] == 'DONE' then
                            if is_mod2(msg.from.id, matches[4], false) then
                                mystat('###cbdelword' .. matches[2] .. matches[3] .. matches[4])
                                msg.chat.id = matches[4]
                                if matches[4]:starts('-100') then
                                    msg.chat.type = 'supergroup'
                                elseif matches[4]:starts('-') then
                                    msg.chat.type = 'group'
                                end
                                local text = setunset_delword(msg, delword_table[tostring(msg.from.id)], time)
                                delword_table[tostring(msg.from.id)] = nil
                                answerCallbackQuery(msg.cb_id, text, false)
                                deleteMessage(msg.chat.id, msg.message_id)
                            end
                        end
                    else
                        editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].errorTryAgain)
                    end
                end
                return
            end
        end
    end
    if matches[1]:lower() == 'dellist' then
        return list_censorships(msg)
    end
    if matches[1]:lower() == 'delword' then
        if msg.from.is_mod then
            return setunset_delword(msg, matches[2]:lower())
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'tempdelword' then
        if msg.from.is_mod then
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
                return setunset_delword(msg, matches[5]:lower(), time)
            else
                delword_table[tostring(msg.from.id)] = matches[2]:lower()
                if not sendKeyboard(msg.from.id, langs[msg.lang].delwordIntro:gsub('X', matches[2]:lower()), keyboard_tempdelword(msg.chat.id)) then
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = "t.me/AISashaBot" } } } }, false, msg.message_id)
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
end

local function pre_process(msg)
    if msg then
        if not msg.from.is_mod then
            local found = false
            local vars = list_censorships(msg)

            if vars ~= nil then
                local t = vars:split('\n')
                for i, word in pairs(t) do
                    local temp = word:lower()
                    if msg.text then
                        if not string.match(msg.text, "^[#!/]([Dd][Ee][Ll][Ww][Oo][Rr][Dd]) (.*)$") then
                            if string.match(msg.text:lower(), temp) then
                                found = true
                            end
                        end
                    end
                    if msg.media then
                        if msg.caption then
                            if not string.match(msg.caption, "^[#!/]([Dd][Ee][Ll][Ww][Oo][Rr][Dd]) (.*)$") then
                                if string.match(msg.caption:lower(), temp) then
                                    found = true
                                end
                            end
                        end
                    end
                    if found then
                        local hash = get_censorships_hash(msg)
                        local time = redis:hget(hash, temp)
                        if type(time) == 'boolean' then
                            deleteMessage(msg.chat.id, msg.message_id)
                        else
                            io.popen('lua timework.lua "delete" "' .. msg.chat.id .. '" "' .. time .. '" "' .. msg.message_id .. '"')
                        end
                        return nil
                    end
                end
            end
        end
        return msg
    end
end

return {
    description = "DELWORD",
    patterns =
    {
        "^(###cbdelword)(DELETE)$",
        "^(###cbdelword)(%d+)(BACK)(%-%d+)$",
        "^(###cbdelword)(%d+)(SECONDS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbdelword)(%d+)(MINUTES)([%+%-]?%d+)(%-%d+)$",
        "^(###cbdelword)(%d+)(HOURS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbdelword)(%d+)(DONE)(%-%d+)$",

        "^[#!/]([Tt][Ee][Mm][Pp][Dd][Ee][Ll][Ww][Oo][Rr][Dd]) (%d+) (%d+) (%d+) (.*)$",
        "^[#!/]([Tt][Ee][Mm][Pp][Dd][Ee][Ll][Ww][Oo][Rr][Dd]) (.*)$",
        "^[#!/]([Dd][Ee][Ll][Ww][Oo][Rr][Dd]) (.*)$",
        "^[#!/]([Dd][Ee][Ll][Ll][Ii][Ss][Tt])$",
    },
    pre_process = pre_process,
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#dellist",
        "MOD",
        "#delword <word>|<pattern>",
        "#tempdelword [<hours> <minutes> <seconds>] <word>|<pattern>",
    },
}