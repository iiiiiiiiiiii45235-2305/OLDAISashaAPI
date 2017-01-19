local ESEMPIO = {
    {
        date = 1475264730,
        role = "moderator",
        user =
        {
            access_hash = - 7.9989917793598e+18,
            first_name = "Eric",
            id = 41400331,
            last_name = "OTI Cancer Solinas",
            restricted = false,
            status =
            {
                _ = "userStatusRecently"
            },
            type = "user",
            username = "EricSolinas",
            verified = false
        }
    },
    {
        date = 1481751776,
        role = "moderator",
        user =
        {
            access_hash = 3.1994369395494e+18,
            first_name = "Sasha A.I.",
            id = 283058260,
            restricted = false,
            type = "bot",
            username = "AISashaBot",
            verified = false
        }
    },
    {
        date = 1481752069,
        role = "user",
        user =
        {
            access_hash = - 7.5057240319811e+18,
            first_name = "Ganjalf |senza trapano|",
            id = 286855451,
            last_name = "(Murtah lives)",
            restricted = false,
            status =
            {
                _ = "userStatusOnline",
                expires = 1484859383
            },
            type = "user",
            username = "Harakkak",
            verified = false
        }
    },
    {
        date = 1483623485,
        role = "user",
        user =
        {
            access_hash = 6.9650003237737e+18,
            first_name = "umbi",
            id = 189199922,
            restricted = false,
            status =
            {
                _ = "userStatusOnline",
                expires = 1484859394
            },
            type = "user",
            username = "umbit",
            verified = false
        }
    },
    {
        date = 1481828420,
        role = "user",
        user =
        {
            access_hash = - 8.7723268163288e+18,
            first_name = "Mr",
            id = 159788990,
            last_name = "\U0001f308Simona\U0001f308",
            restricted = false,
            status =
            {
                _ = "userStatusOffline",
                was_online = 1484859082
            },
            type = "user",
            username = "quello_stronzo",
            verified = false
        }
    },
    {
        role = "creator",
        user =
        {
            access_hash = 8.7659463919353e+18,
            first_name = "Sasha",
            id = 149998353,
            last_name = "A.I.",
            restricted = false,
            status =
            {
                _ = "userStatusOnline",
                expires = 1484859459
            },
            type = "user",
            username = "AISasha",
            verified = false
        }
    },
    {
        date = 1481752826,
        role = "user",
        user =
        {
            access_hash = - 8.2934067955326e+18,
            first_name = "Always\U0001f496 (83 11)",
            id = 165005704,
            restricted = false,
            status =
            {
                _ = "userStatusRecently"
            },
            type = "user",
            username = "Imthequeen99",
            verified = false
        }
    },
    {
        date = 1481752035,
        role = "user",
        user =
        {
            access_hash = 6.395878427014e+17,
            first_name = "MrF(Killu\U0001f577\ufe0f\U0001f577\ufe0f)",
            id = 33302924,
            last_name = "                                                                                                                                                                                                                                                               ",
            restricted = false,
            status =
            {
                _ = "userStatusOffline",
                was_online = 1484859133
            },
            type = "user",
            username = "FrancoFre",
            verified = false
        }
    },
    {
        date = 1478705622,
        role = "user",
        user =
        {
            access_hash = 5.7620155931715e+18,
            id = 289741153,
            restricted = false,
            type = "user",
            verified = false
        }
    },
    {
        date = 1471184887,
        role = "user",
        user =
        {
            access_hash = 8.8058539736368e+18,
            first_name = "Privè",
            id = 206056435,
            restricted = false,
            type = "bot",
            username = "LGP_bot",
            verified = false
        }
    },
    {
        date = 1458935909,
        role = "moderator",
        user =
        {
            access_hash = - 1.1729859909386e+18,
            first_name = "Lollo\u270c\U0001f60f",
            id = 155159899,
            restricted = false,
            status =
            {
                _ = "userStatusOffline",
                was_online = 1484859103
            },
            type = "user",
            username = "IlKingOttas",
            verified = false
        }
    }
}

local function callback_group_members(extra, success, result)
    local lang = get_lang(string.match(extra.receiver, '%d+'))
    local i = 1
    local chatname = result.print_name
    local text = langs[lang].usersIn .. string.gsub(chatname, "_", " ") .. ' ' .. result.peer_id .. '\n'
    for k, v in pairs(result.members) do
        if v.print_name then
            name = v.print_name:gsub("_", " ")
        else
            name = ""
        end
        if v.username then
            username = "@" .. v.username
        else
            username = "NOUSER"
        end
        text = text .. "\n" .. i .. ". " .. name .. "|" .. username .. "|" .. v.peer_id
        i = i + 1
    end
    local file = io.open("./groups/lists/" .. result.peer_id .. "memberlist.txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_large_msg(extra.receiver, text)
    send_document(extra.receiver, "./groups/lists/" .. msg.to.id .. "memberlist.txt", ok_cb, false)
end

local function callback_supergroup_members(extra, success, result)
    local lang = get_lang(string.match(extra.receiver, '%d+'))
    local text = langs[lang].membersOf .. extra.receiver .. '\n'
    local i = 1
    for k, v in pairsByKeys(result) do
        if v.print_name then
            name = v.print_name:gsub("_", " ")
        else
            name = ""
        end
        if v.username then
            username = "@" .. v.username
        else
            username = "NOUSER"
        end
        text = text .. "\n" .. i .. ". " .. name .. "|" .. username .. "|" .. v.peer_id
        i = i + 1
    end
    local file = io.open("./groups/lists/" .. string.match(extra.receiver, '%d+') .. "memberlist.txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_large_msg(extra.receiver, text)
    send_document(extra.receiver, "./groups/lists/" .. msg.to.id .. "memberlist.txt", ok_cb, false)
end

local function run(msg, matches)
    if is_sudo(msg) then
        if matches[1]:lower() == 'getchat' then
            return vardumptext(resolveChannelSupergroupsUsernames(matches[2]))
        end
        if matches[1]:lower() == 'pwr' then
            pwr_get_chat = true
        end
        if matches[1]:lower() == 'api' then
            pwr_get_chat = false
        end
    end
    if matches[1]:lower() == "who" or matches[1]:lower() == "members" or matches[1]:lower() == "sasha lista membri" or matches[1]:lower() == "lista membri" then
        if is_momod(msg) then
            local participants = getChatParticipants(msg.chat.id)
            local text = "PROVA\n"
            for k, v in pairsByKeys(result) do
                text = text ..(v.first_name or 'NONAME') ..(v.last_name or '') .. ' ' ..(v.username or 'NOUSER') .. ' ' .. v.id
                i = i + 1
            end
        else
            return langs[msg.lang].require_mod
        end
    end
end

return {
    description = "TEST",
    patterns =
    {
        "^[#!/]([Gg][Ee][Tt][Cc][Hh][Aa][Tt]) (.*)",
        "^[#!/]([Pp][Ww][Rr])",
        "^[#!/]([Aa][Pp][Ii])",
    },
    run = run,
    min_rank = 4,
    syntax =
    {
    }
}