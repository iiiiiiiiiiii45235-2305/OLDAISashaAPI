local function run(msg, matches)
    if matches[1]:lower() == 'getalternatives' and matches[2] then
        mystat('/getalternatives')
        if data[tostring(msg.chat.id)] then
            if alternatives[tostring(msg.chat.id)] then
                matches[2] = matches[2]:gsub('[#!]', '/')
                if alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()] then
                    local text = langs[msg.lang].listAlternatives:gsub('X', matches[2]:lower()) .. '\n'
                    for k, v in pairs(alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()]) do
                        text = text .. k .. '. ' .. v .. '\n'
                    end
                    return text
                else
                    return langs[msg.lang].noAlternativeCommands:gsub('X', matches[2])
                end
            else
                return langs[msg.lang].useYourGroups
            end
        else
            return langs[msg.lang].useYourGroups
        end
        return list_variables(msg, false)
    end
    if matches[1]:lower() == 'getglobalalternatives' and matches[2] then
        mystat('/getglobalalternatives')
        matches[2] = matches[2]:gsub('[#!]', '/')
        if alternatives.global.cmdAlt[matches[2]:lower()] then
            local text = langs[msg.lang].listGAlternatives:gsub('X', matches[2]:lower()) .. '\n'
            for k, v in pairs(alternatives.global.cmdAlt[matches[2]:lower()]) do
                text = text .. k .. '. ' .. v .. '\n'
            end
            return text
        else
            return langs[msg.lang].noAlternativeCommands:gsub('X', matches[2])
        end
    end
    if matches[1]:lower() == 'setalternative' and matches[2] and matches[3] then
        if msg.from.is_mod then
            mystat('/setalternative')
            if #matches[3] > 3 then
                if string.match(matches[3], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                    return langs[msg.lang].crossexecDenial
                end
                matches[2] = matches[2]:gsub('[#!]', '/')
                if not alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)] then
                    alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)] = { }
                end
                table.insert(alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)], matches[3]:lower())
                alternatives[tostring(msg.chat.id)].altCmd[matches[3]:lower()] = string.sub(matches[2]:lower(), 1, 50)
                save_alternatives()
                return matches[3]:lower() .. langs[msg.lang].alternativeSaved
            else
                return langs[msg.lang].errorCommandTooShort
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'setglobalalternative' and matches[2] and matches[3] then
        if is_admin(msg) then
            mystat('/setglobalalternative')
            if #matches[3] > 3 then
                if string.match(matches[3], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                    return langs[msg.lang].crossexecDenial
                end
                matches[2] = matches[2]:gsub('[#!]', '/')
                if not alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)] then
                    alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)] = { }
                end
                table.insert(alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)], matches[3]:lower())
                alternatives[tostring(msg.chat.id)].altCmd[matches[3]:lower()] = string.sub(matches[2]:lower(), 1, 50)
                save_alternatives()
                return matches[3]:lower() .. langs[msg.lang].gAlternativeSaved
            else
                return langs[msg.lang].errorCommandTooShort
            end
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1]:lower() == 'unsetalternative' and matches[2] then
        if msg.from.is_mod then
            mystat('/unsetalternative')
            if alternatives[tostring(msg.chat.id)].altCmd[matches[2]:lower()] then
                local tempcmd = alternatives[tostring(msg.chat.id)].altCmd[matches[2]:lower()]
                alternatives[tostring(msg.chat.id)].altCmd[matches[2]:lower()] = nil
                if alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd] then
                    local tmptable = { }
                    for k, v in pairs(alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd]) do
                        if v ~= matches[2]:lower() then
                            table.insert(tmptable, v)
                        end
                    end
                    alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd] = tmptable
                end
                save_alternatives()
                return matches[2]:lower() .. langs[msg.lang].alternativeDeleted
            else
                return langs[msg.lang].noCommandsAlternative:gsub('X', matches[2])
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'unsetglobalalternative' and matches[2] then
        if is_admin(msg) then
            mystat('/unsetglobalalternative')
            if alternatives.global.altCmd[matches[2]:lower()] then
                local tempcmd = alternatives.global.altCmd[matches[2]:lower()]
                alternatives.global.altCmd[matches[2]:lower()] = nil
                if alternatives.global.cmdAlt[tempcmd] then
                    local tmptable = { }
                    for k, v in pairs(alternatives.global.cmdAlt[tempcmd]) do
                        if v ~= matches[2]:lower() then
                            table.insert(tmptable, v)
                        end
                    end
                    alternatives.global.cmdAlt[tempcmd] = tmptable
                end
                save_alternatives()
                return matches[2]:lower() .. langs[msg.lang].alternativegDeleted
            else
                return langs[msg.lang].noCommandsAlternative:gsub('X', matches[2])
            end
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1]:lower() == 'unsetalternatives' and matches[2] then
        if msg.from.is_owner then
            mystat('/unsetalternatives')
            matches[2] = matches[2]:gsub('[#!]', '/')
            if alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()] then
                local temptable = alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()]
                alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()] = nil
                for k, v in pairs(temptable) do
                    alternatives[tostring(msg.chat.id)].altCmd[v] = nil
                end
                save_alternatives()
                return langs[msg.lang].alternativesDeleted:gsub('X', matches[2])
            else
                return langs[msg.lang].noAlternativeCommands:gsub('X', matches[2])
            end
        else
            return langs[msg.lang].require_owner
        end
    end
end

local function pre_process(msg)
    if msg then
        if data[tostring(msg.chat.id)] then
            if alternatives[tostring(msg.chat.id)] then
                for k, v in pairs(alternatives[tostring(msg.chat.id)].altCmd) do
                    if string.match(msg.text:lower(), '^' .. k) then
                        -- one match is enough
                        msg.text = string.gsub(msg.text, '^' .. k, v)
                        return msg
                    end
                end
            end
        end
        return msg
    end
end

return {
    description = "ALTERNATIVES",
    patterns =
    {
        "^[#!/]([Gg][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss]) ([^%s]+)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) (.*)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss]) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) ([^%s]+) (.*)$",
        "^[#!/]([Gg][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss]) ([^%s]+)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) ([^%s]+) (.*)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) (.*)$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#getalternatives <command>",
        "#getglobalalternatives <command>",
        "MOD",
        "#setalternative <command> <alternative>",
        "#unsetalternative <alternative>",
        "OWNER",
        "#unsetalternatives <command>",
        "ADMIN",
        "#setglobalalternative <command> <alternative>",
        "#unsetglobalalternative <alternative>",
    },
}