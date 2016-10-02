local function run(msg, matches)
    if (matches[1]:lower() == 'markdownecho' or matches[1]:lower() == 'sasha markdown ripeti') and matches[2] then
        if is_mod(msg) then
            mystat('/markdownecho')
            if msg.reply then
                return sendReply(msg.reply_to_message, matches[2], true)
            else
                return matches[2]
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if (matches[1]:lower() == 'echo' or matches[1]:lower() == 'sasha ripeti') and matches[2] then
        if is_mod(msg) then
            mystat('/echo')
            if msg.reply then
                return sendReply(msg.reply_to_message, matches[2])
            else
                return matches[2]
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    -- interact
    mystat('/interact')
    if matches[1]:lower() == 'sasha come va?' then
        return sendReply(msg, langs.phrases.interact.howareyou[math.random(#langs.phrases.interact.howareyou)])
    end
    if matches[1]:lower() == 'sasha' and string.match(matches[2], '.*%?') then
        local rnd = math.random(0, 2)
        if rnd == 0 then
            return sendReply(msg, langs.phrases.interact.no[math.random(#langs.phrases.interact.no)])
        elseif rnd == 1 then
            return sendReply(msg, langs.phrases.interact.idontknow[math.random(#langs.phrases.interact.idontknow)])
        elseif rnd == 2 then
            return sendReply(msg, langs.phrases.interact.yes[math.random(#langs.phrases.interact.yes)])
        end
    end
    if matches[1]:lower() == 'sasha ti amo' or matches[1]:lower() == 'ti amo sasha' then
        return sendReply(msg, langs.phrases.interact.iloveyou[math.random(#langs.phrases.interact.iloveyou)])
    end
end

return {
    description = "INTERACT",
    patterns =
    {
        "^[#!/]([Ee][Cc][Hh][Oo]) +(.+)$",
        "^[#!/]([Mm][Aa][Rr][Kk][Dd][Oo][Ww][Nn][Ee][Cc][Hh][Oo]) +(.+)$",
        -- echo
        "^([Ss][Aa][Ss][Hh][Aa] [Rr][Ii][Pp][Ee][Tt][Ii]) +(.+)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Mm][Aa][Rr][Kk][Dd][Oo][Ww][Nn] [Rr][Ii][Pp][Ee][Tt][Ii]) +(.+)$",
        -- react
        "^([Ss][Aa][Ss][Hh][Aa] [Cc][Oo][Mm][Ee] [Vv][Aa]%?)$",
        "^([Ss][Aa][Ss][Hh][Aa])(.*%?)$",
        "^([Ss][Aa][Ss][Hh][Aa] [Tt][Ii] [Aa][Mm][Oo])$",
        "^([Tt][Ii] [Aa][Mm][Oo] [Ss][Aa][Ss][Hh][Aa])$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "MOD",
        "(#echo|sasha ripeti) <text>",
    },
}