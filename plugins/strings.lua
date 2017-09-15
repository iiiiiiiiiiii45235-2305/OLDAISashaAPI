local function run(msg, matches)
    if msg.cb then
        if matches[1] == '###cblangs' then
            local change_lang = true
            if msg.chat.type ~= 'private' then
                if not is_owner(msg) then
                    answerCallbackQuery(msg.cb_id, langs[msg.lang].require_owner, true)
                    change_lang = false
                end
            end
            if change_lang then
                if matches[2] == 'IT' then
                    redis:set('lang:' .. msg.chat.id, 'it')
                elseif matches[2] == 'EN' then
                    redis:set('lang:' .. msg.chat.id, 'en')
                end
                local lang = get_lang(msg.chat.id)
                if matches[3] == 'B' then
                    if not redis:hget('tagalert:usernames', msg.from.id) then
                        return editMessage(msg.chat.id, msg.message_id, langs[lang].startMessage, keyboard_tagalert_tutorial(lang))
                    else
                        return editMessage(msg.chat.id, msg.message_id, langs[lang].startMessage)
                        -- return editMessage(msg.chat.id, msg.message_id, langs[lang].startMessage, { inline_keyboard = { { { text = langs[msg.lang].tutorialWord, url = 'http://telegra.ph/TUTORIAL-AISASHABOT-09-15' } } } })
                    end
                elseif matches[3] == 'S' then
                    return editMessage(msg.chat.id, msg.message_id, langs[lang].langSet)
                end
            end
            return
        end
    end
    if matches[1]:lower() == 'setlang' then
        mystat('/setlang')
        if matches[2] then
            if msg.chat.type == 'private' then
                redis:set('lang:' .. msg.chat.id, matches[2]:lower())
                return langs[matches[2]:lower()].langSet
            elseif msg.from.is_owner then
                redis:set('lang:' .. msg.chat.id, matches[2]:lower())
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
        "^(###cblangs)(..)$",
        "^(###cblangs)(..)(.)$",

        '^[#!/]([Ss][Ee][Tt][Ll][Aa][Nn][Gg])$',
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
        "/setlang [it|en]",
        "OWNER",
        "/setlang [it|en]",
        "SUDO",
        "/reloadstrings|#reloadlangs",
    },
}