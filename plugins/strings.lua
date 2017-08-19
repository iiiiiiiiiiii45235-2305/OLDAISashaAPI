local function keyboard_langs()
    local keyboard = { }
    keyboard.inline_keyboard = { }
    local row = 1
    local column = 1
    local i = 0
    local flag = false
    keyboard.inline_keyboard[row] = { }
    keyboard.inline_keyboard[row][column] = { text = langs.italian, callback_data = 'botIT' }
    column = column + 1
    keyboard.inline_keyboard[row][column] = { text = langs.english, callback_data = 'botEN' }
    return keyboard
end

local function run(msg, matches)
    if msg.cb then
        if matches[1] == '###cbstrings' and matches[2] then
            local change_lang = true
            if msg.chat.type ~= 'private' then
                if not is_owner(msg) then
                    change_lang = false
                end
            end
            if change_lang then
                if matches[2] == 'IT' then
                    redis:set('lang:' .. msg.chat.id, 'it')
                    return editMessageText(msg.chat.id, msg.message_id, langs['it'].langSet)
                elseif matches[2] == 'EN' then
                    redis:set('lang:' .. msg.chat.id, 'en')
                    return editMessageText(msg.chat.id, msg.message_id, langs['en'].langSet)
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
            sendKeyboard(msg.chat.id, langs.selectLanguage, keyboard_langs())
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
        "^(###cbstrings)(..)$",
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
        "#setlang [it|en]",
        "OWNER",
        "#setlang [it|en]",
        "SUDO",
        "#reloadstrings|#reloadlangs",
    },
}