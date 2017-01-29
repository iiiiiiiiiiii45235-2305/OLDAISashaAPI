local function get_variables_hash(msg, global)
    if global then
        return 'gvariables'
    else
        if msg.chat.type == 'channel' then
            return 'channel:' .. msg.chat.id .. ':variables'
        end
        if msg.chat.type == 'supergroup' then
            return 'supergroup:' .. msg.chat.id .. ':variables'
        end
        if msg.chat.type == 'group' then
            return 'group:' .. msg.chat.id .. ':variables'
        end
        if msg.chat.type == 'private' then
            return 'user:' .. msg.from.id .. ':variables'
        end
        return false
    end
end

local function unset_var(msg, name, global)
    if (not name) then
        return langs[msg.lang].errorTryAgain
    end

    local hash = get_variables_hash(msg, global)
    if hash then
        redis:hdel(hash, name:lower())
        if global then
            return name:lower() .. langs[msg.lang].gDeleted
        else
            return name:lower() .. langs[msg.lang].deleted
        end
    end
end

local function run(msg, matches)
    if matches[1]:lower() == 'unset' or matches[1]:lower() == 'sasha unsetta' or matches[1]:lower() == 'unsetta' then
        mystat('/unset')
        if msg.from.is_mod then
            return unset_var(msg, string.sub(matches[2], 1, 50), false)
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'unsetglobal' then
        mystat('/unsetglobal')
        if is_admin(msg) then
            return unset_var(msg, string.sub(matches[2], 1, 50), true)
        else
            return langs[msg.lang].require_admin
        end
    end
end

return {
    description = "UNSET",
    patterns =
    {
        "^[#!/]([Uu][Nn][Ss][Ee][Tt]) ([^%s]+)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll]) ([^%s]+)$",
        -- unset
        "^([Ss][Aa][Ss][Hh][Aa] [Uu][Nn][Ss][Ee][Tt][Tt][Aa]) ([^%s]+)$",
        "^([Uu][Nn][Ss][Ee][Tt][Tt][Aa]) ([^%s]+)$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "MOD",
        "(#unset|[sasha] unsetta) <var_name>|<pattern>",
        "ADMIN",
        "#unsetglobal <var_name>|<pattern>",
    },
}