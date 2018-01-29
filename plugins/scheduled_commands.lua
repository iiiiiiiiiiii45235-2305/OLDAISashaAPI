local schedule_table = {
    -- chat_id = command
}
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
            if time then
                if tonumber(time) == 0 then
                    redis:hset(hash, var_name, true)
                else
                    redis:hset(hash, var_name, time)
                end
            else
                redis:hset(hash, var_name, true)
            end
            return langs[msg.lang].delwordAdded .. var_name
        end
    end
end

local function run(msg, matches)
    if msg.cb then
        if matches[1] then
            if matches[1] == '###cbdelword' then
                if matches[2] == 'DELETE' then
                    if not deleteMessage(msg.chat.id, msg.message_id, true) then
                        editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                    end
                elseif string.match(matches[2], '^%d+$') then
                    if delword_table[tostring(msg.from.id)] then
                        local time = tonumber(matches[2])
                        if matches[3] == 'BACK' then
                            answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].delwordIntro:gsub('X', delword_table[tostring(msg.from.id)]), keyboard_scheduledelword(matches[4], time))
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
                            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].delwordIntro:gsub('X', delword_table[tostring(msg.from.id)]), keyboard_scheduledelword(matches[5], time))
                            mystat(matches[1] .. matches[2] .. matches[3] .. matches[4] .. matches[5])
                        elseif matches[3] == 'DONE' then
                            if is_mod2(msg.from.id, matches[4], false) then
                                local tmp = { chat = { id = matches[4], type = '' }, lang = msg.lang }
                                if matches[4]:starts('-100') then
                                    tmp.chat.type = 'supergroup'
                                elseif matches[4]:starts('-') then
                                    tmp.chat.type = 'group'
                                end
                                local text = ''
                                if pcall( function()
                                        string.match(delword_table[tostring(msg.from.id)], delword_table[tostring(msg.from.id)])
                                    end ) then
                                    text = setunset_delword(tmp, delword_table[tostring(msg.from.id)], time)
                                else
                                    text = langs[msg.lang].errorTryAgain
                                end
                                answerCallbackQuery(msg.cb_id, text, false)
                                delword_table[tostring(msg.from.id)] = nil
                                sendMessage(matches[4], text)
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
            elseif matches[1]:lower() == '###cbschedule' then
                if is_sudo(msg) then
                    if matches[2] == 'DELETE' then
                        if not deleteMessage(msg.chat.id, msg.message_id, true) then
                            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                        end
                    elseif string.match(matches[2], '^%d+$') then
                        if schedule_table[tostring(msg.from.id)] then
                            local time = tonumber(matches[2])
                            if matches[3] == 'BACK' then
                                answerCallbackQuery(msg.cb_id, langs[msg.lang].keyboardUpdated, false)
                                editMessage(msg.chat.id, msg.message_id, 'SCHEDULE', keyboard_schedule(matches[4], time))
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
                                editMessage(msg.chat.id, msg.message_id, 'SCHEDULE', keyboard_schedule(matches[5], time))
                            elseif matches[3] == 'DONE' then
                                answerCallbackQuery(msg.cb_id, 'SCHEDULED', false)
                                io.popen('lua timework.lua "' .. schedule_table[tostring(msg.from.id)].method .. '" "' .. time .. '" "' .. schedule_table[tostring(msg.from.id)].chat_id .. '" "' .. schedule_table[tostring(msg.from.id)].text .. '"')
                                schedule_table[tostring(msg.from.id)] = nil
                                sendMessage(matches[4], 'SCHEDULED')
                                if not deleteMessage(msg.chat.id, msg.message_id, true) then
                                    editMessage(msg.chat.id, msg.message_id, langs[msg.lang].stop)
                                end
                            end
                        else
                            editMessage(msg.chat.id, msg.message_id, langs[msg.lang].errorTryAgain)
                        end
                    end
                end
            end
            return
        end
    end
    if matches[1]:lower() == 'scheduledelword' then
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
                local hash = get_censorships_hash(msg)
                if hash then
                    if redis:hget(hash, matches[2]:lower()) then
                        redis:hdel(hash, matches[2]:lower())
                        return langs[msg.lang].delwordRemoved .. matches[2]:lower()
                    else
                        if sendKeyboard(msg.from.id, langs[msg.lang].delwordIntro:gsub('X', matches[2]:lower()), keyboard_scheduledelword(msg.chat.id)) then
                            if msg.chat.type ~= 'private' then
                                local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt, 'html').result.message_id
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                                io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                                return
                            end
                        else
                            return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                        end
                    end
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'schedule' then
        if is_sudo(msg) then
            if matches[2] and matches[3] and matches[4] and matches[5] and matches[6] and matches[7] and matches[8] then
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
                io.popen('lua timework.lua "' .. matches[6]:lower() .. '" "' .. time .. '" "' .. matches[7]:lower() .. '" "' .. matches[8]:lower() .. '"')
                return 'SCHEDULED'
            else
                schedule_table[tostring(msg.from.id)] = { method = matches[2]:lower(), chat_id = matches[3], text = matches[4] }
                if sendKeyboard(msg.from.id, 'SCHEDULE', keyboard_schedule(msg.chat.id)) then
                    if msg.chat.type ~= 'private' then
                        local message_id = sendReply(msg, langs[msg.lang].sendTimeKeyboardPvt, 'html').result.message_id
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. message_id .. '"')
                        io.popen('lua timework.lua "deletemessage" "60" "' .. msg.chat.id .. '" "' .. msg.message_id .. '"')
                        return
                    end
                else
                    return sendKeyboard(msg.chat.id, langs[msg.lang].cantSendPvt, { inline_keyboard = { { { text = "/start", url = bot.link } } } }, false, msg.message_id)
                end
            end
        else
            return langs[msg.lang].require_sudo
        end
    end
end

return {
    description = "SCHEDULED_COMMANDS",
    patterns =
    {
        "^(###cbdelword)(DELETE)$",
        "^(###cbdelword)(%d+)(BACK)(%-%d+)$",
        "^(###cbdelword)(%d+)(SECONDS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbdelword)(%d+)(MINUTES)([%+%-]?%d+)(%-%d+)$",
        "^(###cbdelword)(%d+)(HOURS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbdelword)(%d+)(DONE)(%-%d+)$",
        "^(###cbschedule)(DELETE)$",
        "^(###cbschedule)(%d+)(BACK)(%-%d+)$",
        "^(###cbschedule)(%d+)(SECONDS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbschedule)(%d+)(MINUTES)([%+%-]?%d+)(%-%d+)$",
        "^(###cbschedule)(%d+)(HOURS)([%+%-]?%d+)(%-%d+)$",
        "^(###cbschedule)(%d+)(DONE)(%-%d+)$",

        "^[#!/]([Ss][Cc][Hh][Ee][Dd][Uu][Ll][Ee][Dd][Ee][Ll][Ww][Oo][Rr][Dd]) (%d+) (%d+) (%d+) (.*)$",
        "^[#!/]([Ss][Cc][Hh][Ee][Dd][Uu][Ll][Ee][Dd][Ee][Ll][Ww][Oo][Rr][Dd]) (.*)$",
        "^[#!/]([Ss][Cc][Hh][Ee][Dd][Uu][Ll][Ee]) (%d+) (%d+) (%d+) ([^%s]+) (%-?%d+) (.*)$",
        "^[#!/]([Ss][Cc][Hh][Ee][Dd][Uu][Ll][Ee]) ([^%s]+) (%-?%d+) (.*)$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "MOD",
        "/scheduledelword [{hours} {minutes} {seconds}] {word}|{pattern}",
        "SUDO",
        "/schedule [{hours} {minutes} {seconds}] {method} {chat_id} {text}",
    },
}