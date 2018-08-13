local function run(msg, matches)
    if msg.cb then
        local change_lang = true
        if msg.chat.type ~= 'private' then
            if not is_owner(msg) then
                answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                change_lang = false
            end
        end
        if change_lang then
            if data[tostring(msg.chat.id)] then
                data[tostring(msg.chat.id)].lang = matches[2]:lower()
            else
                redis_set_something('lang:' .. msg.chat.id, matches[2]:lower())
            end

            msg.lang = get_lang(msg.chat.id)
            if matches[3] == 'B' then
                if not redis_hget_something('tagalert:usernames', msg.from.id) then
                    return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].startMessage, keyboard_tagalert_tutorial(msg.lang))
                else
                    return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].startMessage)
                    -- return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].startMessage, { inline_keyboard = { { { text = langs[msg.lang].tutorialWord, url = 'http://telegra.ph/TUTORIAL-AISASHABOT-09-15' } } } })
                end
            elseif matches[3] == 'S' then
                return editMessageText(msg.chat.id, msg.message_id, langs[msg.lang].langSet)
            end
        end
        return
    end
    if matches[1]:lower() == 'setlang' then
        mystat('/setlang')
        if matches[2] then
            if msg.chat.type == 'private' then
                redis_set_something('lang:' .. msg.chat.id, matches[2]:lower())
                return langs[matches[2]:lower()].langSet
            elseif msg.from.is_owner and data[tostring(msg.chat.id)] then
                data[tostring(msg.chat.id)].lang = matches[2]:lower()
                return langs[matches[2]:lower()].langSet
            else
                return langs[msg.lang].require_owner
            end
        else
            return sendKeyboard(msg.chat.id, langs.selectLanguage, keyboard_langs('S'))
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
        "^(###cblangs)(..)(%u)$",
        "^(###cblangs)(..)$",

        '^[#!/]([Ss][Ee][Tt][Ll][Aa][Nn][Gg])$',
        '^[#!/]([Ss][Ee][Tt][Ll][Aa][Nn][Gg]) ([Ii][Tt])$',
        '^[#!/]([Ss][Ee][Tt][Ll][Aa][Nn][Gg]) ([Ee][Nn])$',
        '^[#!/]([Rr][Ee][Ll][Oo][Aa][Dd][Ss][Tt][Rr][Ii][Nn][Gg][Ss])$',
        '^[#!/]([Rr][Ee][Ll][Oo][Aa][Dd][Ll][Aa][Nn][Gg][Ss])$',
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/setlang [it|en]",
        "OWNER",
        "/setlang [it|en]",
        "SUDO",
        "/reloadstrings|#reloadlangs",
    },
}