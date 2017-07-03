local function run(msg, matches)
    if matches[1]:lower() == 'setlang' and matches[2] then
        mystat('/setlang')
        if msg.chat.type == 'private' then
            redis:set('lang:' .. msg.chat.id, matches[2]:lower())
            return langs[matches[2]:lower()].langSet
        elseif msg.from.is_owner then
            redis:set('lang:' .. msg.chat.id, matches[2]:lower())
            return langs[matches[2]:lower()].langSet
        else
            return langs[msg.lang].require_owner
        end
    end
    if matches[1]:lower() == 'reloadstrings' or matches[1]:lower() == 'reloadlangs' then
        mystat('/reloadstrings')
        if is_sudo(msg) then
            print('Loading languages.lua...')
            langs = dofile('languages.lua')
            return langs[msg.lang].langUpdate
        else
            return langs[msg.lang].require_sudo
        end
    end
end

return {
    description = "STRINGS",
    patterns =
    {
        '^[#!/]([Ss][Ee][Tt][Ll][Aa][Nn][Gg]) ([Ii][Tt])$',
        '^[#!/]([Ss][Ee][Tt][Ll][Aa][Nn][Gg]) ([Ee][Nn])$',
        '^[#!/]([Rr][Ee][Ll][Oo][Aa][Dd][Ss][Tt][Rr][Ii][Nn][Gg][Ss])$',
        '^[#!/]([Rr][Ee][Ll][Oo][Aa][Dd][Ll][Aa][Nn][Gg][Ss])$',
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "#setlang (it|en)",
        "OWNER",
        "#setlang (it|en)",
        "SUDO",
        "#reloadstrings|#reloadlangs",
    },
}