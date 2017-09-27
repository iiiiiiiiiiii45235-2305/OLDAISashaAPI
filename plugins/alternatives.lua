local default_alternatives = {
    cmdAlt =
    {
        ['/kickme'] =
        {
            'sasha uccidimi',
            'sasha esplodimi',
            'sasha sparami',
            'sasha decompilami',
            'sasha bannami'
        },
        ['/getuserwarns'] =
        {
            'sasha ottieni avvertimenti',
            'ottieni avvertimenti'
        },
        ['/warn'] = { 'sasha avverti' },
        ['/unwarnall'] =
        {
            'sasha azzera avvertimenti',
            'azzera avvertimenti'
        },
        ['/kick'] =
        {
            'sasha uccidi',
            'uccidi',
            'sasha spara'
        },
        ['/ban'] =
        {
            'kaboom',
            'sasha banna',
            'banna',
            'sasha decompila',
            'decompila',
            'sasha esplodi'
        },
        ['/unban'] =
        {
            'sasha sbanna',
            'sbanna',
            'sasha ricompila',
            'ricompila'
        },
        ['/banlist'] =
        {
            'sasha lista ban',
            'lista ban'
        },
        ['/dellist'] =
        {
            'sasha lista censure',
            'lista censure'
        },
        ['/delword'] =
        {
            'sasha censura',
            'censura'
        },
        ['/dogify'] =
        {
            'sasha doge',
            'doge'
        },
        ['/startflame'] =
        {
            'sasha flamma',
            'flamma'
        },
        ['/stopflame'] =
        {
            'sasha stop flame',
            'stop flame'
        },
        ['/flameinfo'] =
        {
            'sasha info flame',
            'info flame'
        },
        ['/get'] = { 'sasha lista' },
        ['/getlist'] = { 'sasha lista' },
        ['/getgloballist'] = { 'sasha lista globali' },
        ['/getglobal'] = { 'sasha lista globali' },
        ['/set'] =
        {
            'sasha setta',
            'setta'
        },
        ['/setmedia'] =
        {
            'sasha setta media',
            'setta media'
        },
        ['/unset'] =
        {
            'sasha unsetta',
            'unsetta'
        },
        ['/rules'] = { 'sasha regole' },
        ['/modlist'] =
        {
            'sasha lista mod',
            'lista mod'
        },
        ['/link'] = { 'sasha link' },
        ['/setrules'] = { 'sasha imposta regole' },
        ['/newlink'] = { 'sasha crea link' },
        ['/muteuser'] = { 'voce' },
        ['/muteslist'] = { 'lista muti' },
        ['/mutelist'] = { 'lista utenti muti' },
        ['/lock'] =
        {
            'sasha blocca',
            'blocca'
        },
        ['/unlock'] =
        {
            'sasha sblocca',
            'sblocca'
        },
        ['/setlink'] = { 'sasha imposta link' },
        ['/unsetlink'] = { 'sasha elimina link' },
        ['/getadmins'] =
        {
            'sasha lista admin',
            'lista admin'
        },
        ['/promote'] =
        {
            'sasha promuovi',
            'promuovi'
        },
        ['/demote'] =
        {
            'sasha degrada',
            'degrada'
        },
        ['/mute'] = { 'silenzia' },
        ['/unmute'] = { 'ripristina' },
        ['/sudolist'] = { 'sasha lista sudo' },
        ['/help'] = { 'sasha aiuto' },
        ['/helpall'] = { 'sasha aiuto tutto' },
        ['/syntax'] = { 'sasha sintassi' },
        ['/syntaxall'] = { 'sasha sintassi tutto' },
        ['/getrank'] = { 'rango' },
        ['/info'] =
        {
            'sasha info',
            'info'
        },
        ['/echo'] = { 'sasha ripeti' },
        ['/markdownecho'] = { 'sasha markdown ripeti' },
        ['/leave'] = { 'sasha abbandona' },
        ['/plugins'] =
        {
            'sasha lista plugins',
            'lista plugins'
        },
        ['/disabledlist'] =
        {
            'sasha lista disabilitati',
            'lista disabilitati',
            'sasha lista disattivati',
            'lista disattivati'
        },
        ['/enable'] =
        {
            'sasha abilita',
            'abilita',
            'sasha attiva',
            'attiva'
        },
        ['/disable'] =
        {
            'sasha disabilita',
            'disabilita',
            'sasha disattiva',
            'disattiva'
        },
        ['/qr'] = { 'sasha qr' },
        ['/shout'] =
        {
            'sasha grida',
            'grida',
            'sasha urla',
            'urla'
        },
        ['/setlang'] = { 'lingua' },
        ['/tagall'] = { 'sasha tagga tutti' },
        ['/tex'] =
        {
            'sasha equazione',
            'equazione'
        },
        ['/webshot'] =
        {
            'sasha webshotta',
            'webshotta'
        },
    },
    altCmd =
    {
        ['sasha uccidimi'] = '/kickme',
        ['sasha esplodimi'] = '/kickme',
        ['sasha sparami'] = '/kickme',
        ['sasha decompilami'] = '/kickme',
        ['sasha bannami'] = '/kickme',
        ['sasha ottieni avvertimenti'] = '/getuserwarns',
        ['ottieni avvertimenti'] = '/getuserwarns',
        ['sasha avverti'] = '/warn',
        ['sasha azzera avvertimenti'] = '/unwarnall',
        ['azzera avvertimenti'] = '/unwarnall',
        ['sasha uccidi'] = '/kick',
        ['uccidi'] = '/kick',
        ['sasha spara'] = '/kick',
        ['kaboom'] = '/ban',
        ['sasha banna'] = '/ban',
        ['banna'] = '/ban',
        ['sasha decompila'] = '/ban',
        ['decompila'] = '/ban',
        ['sasha esplodi'] = '/ban',
        ['sasha sbanna'] = '/unban',
        ['sbanna'] = '/unban',
        ['sasha ricompila'] = '/unban',
        ['ricompila'] = '/unban',
        ['sasha lista ban'] = '/banlist',
        ['lista ban'] = '/banlist',
        ['sasha lista censure'] = '/dellist',
        ['lista censure'] = '/dellist',
        ['sasha censura'] = '/delword',
        ['censura'] = '/delword',
        ['sasha doge'] = '/dogify',
        ['doge'] = '/dogify',
        ['sasha flamma'] = '/startflame',
        ['flamma'] = '/startflame',
        ['sasha stop flame'] = '/stopflame',
        ['stop flame'] = '/stopflame',
        ['sasha info flame'] = '/flameinfo',
        ['info flame'] = '/flameinfo',
        ['sasha lista'] = '/getlist',
        ['sasha lista globali'] = '/getgloballist',
        ['sasha setta'] = '/set',
        ['setta'] = '/set',
        ['sasha setta media'] = '/setmedia',
        ['setta media'] = '/setmedia',
        ['sasha unsetta'] = '/unset',
        ['unsetta'] = '/unset',
        ['sasha regole'] = '/rules',
        ['sasha lista mod'] = '/modlist',
        ['lista mod'] = '/modlist',
        ['sasha link'] = '/link',
        ['sasha imposta regole'] = '/setrules',
        ['sasha crea link'] = '/newlink',
        ['voce'] = '/muteuser',
        ['lista muti'] = '/muteslist',
        ['lista utenti muti'] = '/mutelist',
        ['sasha blocca'] = '/lock',
        ['blocca'] = '/lock',
        ['sasha sblocca'] = '/unlock',
        ['sblocca'] = '/unlock',
        ['sasha imposta link'] = '/setlink',
        ['sasha elimina link'] = '/unsetlink',
        ['sasha lista admin'] = '/getadmins',
        ['lista admin'] = '/getadmins',
        ['sasha promuovi'] = '/promote',
        ['promuovi'] = '/promote',
        ['sasha degrada'] = '/demote',
        ['degrada'] = '/demote',
        ['silenzia'] = '/mute',
        ['ripristina'] = '/unmute',
        ['sasha lista sudo'] = '/sudolist',
        ['sasha aiuto'] = '/help',
        ['sasha aiuto tutto'] = '/helpall',
        ['sasha sintassi'] = '/syntax',
        ['sasha sintassi tutto'] = '/syntaxall',
        ['rango'] = '/getrank',
        ['sasha info'] = '/info',
        ['info'] = '/info',
        ['sasha ripeti'] = '/echo',
        ['sasha markdown ripeti'] = '/markdownecho',
        ['sasha abbandona'] = '/leave',
        ['sasha lista plugins'] = '/plugins',
        ['lista plugins'] = '/plugins',
        ['sasha lista disabilitati'] = '/disabledlist',
        ['lista disabilitati'] = '/disabledlist',
        ['sasha lista disattivati'] = '/disabledlist',
        ['lista disattivati'] = '/disabledlist',
        ['sasha abilita'] = '/enable',
        ['abilita'] = '/enable',
        ['sasha attiva'] = '/enable',
        ['attiva'] = '/enable',
        ['sasha disabilita'] = '/disable',
        ['disabilita'] = '/disable',
        ['sasha disattiva'] = '/disable',
        ['disattiva'] = '/disable',
        ['sasha qr'] = '/qr',
        ['sasha grida'] = '/shout',
        ['grida'] = '/shout',
        ['sasha urla'] = '/shout',
        ['urla'] = '/shout',
        ['lingua'] = '/setlang',
        ['sasha tagga tutti'] = '/tagall',
        ['sasha equazione'] = '/tex',
        ['equazione'] = '/tex',
        ['sasha webshotta'] = '/webshot',
        ['webshotta'] = '/webshot',
    },
}

local function run(msg, matches)
    if matches[1]:lower() == 'getalternatives' and matches[2] then
        mystat('/getalternatives')
        local text = langs[msg.lang].listAlternatives:gsub('X', matches[2]:lower()) .. '\n'
        if alternatives.global.cmdAlt[matches[2]:lower()] then
            for k, v in pairs(alternatives.global.cmdAlt[matches[2]:lower()]) do
                text = text .. k .. 'G. ' .. v .. '\n'
            end
        end
        if data[tostring(msg.chat.id)] then
            if alternatives[tostring(msg.chat.id)] then
                matches[2] = matches[2]:gsub('[#!]', '/')
                if alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()] then
                    for k, v in pairs(alternatives[tostring(msg.chat.id)].cmdAlt[matches[2]:lower()]) do
                        text = text .. k .. '. ' .. v .. '\n'
                    end
                end
            end
        end
        if text ==(langs[msg.lang].listAlternatives:gsub('X', matches[2]:lower()) .. '\n') then
            return langs[msg.lang].noAlternativeCommands:gsub('X', matches[2])
        else
            return text
        end
    end
    if matches[1]:lower() == 'previewalternative' and matches[2] then
        mystat('/previewalternative')
        if alternatives[tostring(msg.chat.id)] then
            for k, v in pairs(alternatives[tostring(msg.chat.id)].altCmd) do
                if k == matches[2] then
                    if string.match(k, '^media:photo') then
                        sendPhotoId(msg.chat.id, string.match(k, '^media:photo(.*)'), '', msg.message_id)
                    elseif string.match(k, '^media:video') then
                        sendVideoId(msg.chat.id, string.match(k, '^media:video(.*)'), '', msg.message_id)
                    elseif string.match(k, '^media:video_note') then
                        sendVideoNoteId(msg.chat.id, string.match(k, '^media:video_note(.*)'), msg.message_id)
                    elseif string.match(k, '^media:audio') then
                        sendAudioId(msg.chat.id, string.match(k, '^media:audio(.*)'), '', msg.message_id)
                    elseif string.match(k, '^media:voice_note') or string.match(k, '^media:voice') then
                        if string.match(k, '^media:voice_note(.*)') then
                            sendVoiceId(msg.chat.id, string.match(k, '^media:voice_note(.*)'), '', msg.message_id)
                        elseif string.match(k, '^media:voice(.*)') then
                            sendVoiceId(msg.chat.id, string.match(k, '^media:voice(.*)'), '', msg.message_id)
                        end
                    elseif string.match(k, '^media:gif') then
                        sendDocumentId(msg.chat.id, string.match(k, '^media:gif(.*)'), '', msg.message_id)
                    elseif string.match(k, '^media:document') then
                        sendDocumentId(msg.chat.id, string.match(k, '^media:gif(.*)'), '', msg.message_id)
                    elseif string.match(k, '^media:sticker') then
                        sendStickerId(msg.chat.id, string.match(k, '^media:sticker(.*)'), msg.message_id)
                    else
                        sendReply(msg, v)
                    end
                end
            end
        end
        if alternatives.global then
            for k, v in pairs(alternatives.global.altCmd) do
                if k == matches[2] then
                    if string.match(k, '^media:photo') then
                        sendPhotoId(msg.chat.id, string.match(k, '^media:photo(.*)'), '', msg.message_id)
                    elseif string.match(k, '^media:video') then
                        sendVideoId(msg.chat.id, string.match(k, '^media:video(.*)'), '', msg.message_id)
                    elseif string.match(k, '^media:video_note') then
                        sendVideoNoteId(msg.chat.id, string.match(k, '^media:video_note(.*)'), msg.message_id)
                    elseif string.match(k, '^media:audio') then
                        sendAudioId(msg.chat.id, string.match(k, '^media:audio(.*)'), '', msg.message_id)
                    elseif string.match(k, '^media:voice_note') or string.match(k, '^media:voice') then
                        if string.match(k, '^media:voice_note(.*)') then
                            sendVoiceId(msg.chat.id, string.match(k, '^media:voice_note(.*)'), '', msg.message_id)
                        elseif string.match(k, '^media:voice(.*)') then
                            sendVoiceId(msg.chat.id, string.match(k, '^media:voice(.*)'), '', msg.message_id)
                        end
                    elseif string.match(k, '^media:gif') then
                        sendDocumentId(msg.chat.id, string.match(k, '^media:gif(.*)'), '', msg.message_id)
                    elseif string.match(k, '^media:document') then
                        sendDocumentId(msg.chat.id, string.match(k, '^media:gif(.*)'), '', msg.message_id)
                    elseif string.match(k, '^media:sticker') then
                        sendStickerId(msg.chat.id, string.match(k, '^media:sticker(.*)'), msg.message_id)
                    else
                        sendReply(msg, v)
                    end
                end
            end
        end
    end
    if matches[1]:lower() == 'setalternative' and matches[2] then
        if msg.from.is_mod then
            mystat('/setalternative')
            if matches[3] then
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
            elseif msg.reply then
                if msg.reply_to_message.media then
                    local file_id = ''
                    if msg.reply_to_message.media_type == 'photo' then
                        local bigger_pic_id = ''
                        local size = 0
                        for k, v in pairsByKeys(msg.reply_to_message.photo) do
                            if v.file_size then
                                if v.file_size > size then
                                    size = v.file_size
                                    bigger_pic_id = v.file_id
                                end
                            end
                        end
                        file_id = bigger_pic_id
                    elseif msg.reply_to_message.media_type == 'video' then
                        file_id = msg.reply_to_message.video.file_id
                    elseif msg.reply_to_message.media_type == 'video_note' then
                        file_id = msg.reply_to_message.video_note.file_id
                    elseif msg.reply_to_message.media_type == 'audio' then
                        file_id = msg.reply_to_message.audio.file_id
                    elseif msg.reply_to_message.media_type == 'voice_note' then
                        file_id = msg.reply_to_message.voice.file_id
                    elseif msg.reply_to_message.media_type == 'gif' then
                        file_id = msg.reply_to_message.document.file_id
                    elseif msg.reply_to_message.media_type == 'document' then
                        file_id = msg.reply_to_message.document.file_id
                    elseif msg.reply_to_message.media_type == 'sticker' then
                        file_id = msg.reply_to_message.sticker.file_id
                    else
                        return langs[msg.lang].useQuoteOnFile
                    end
                    matches[2] = matches[2]:gsub('[#!]', '/')
                    if not alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)] then
                        alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)] = { }
                    end
                    table.insert(alternatives[tostring(msg.chat.id)].cmdAlt[string.sub(matches[2]:lower(), 1, 50)], 'media:' .. msg.reply_to_message.media_type .. file_id)
                    alternatives[tostring(msg.chat.id)].altCmd['media:' .. msg.reply_to_message.media_type .. file_id] = string.sub(matches[2]:lower(), 1, 50)
                    save_alternatives()
                    return 'media:' .. msg.reply_to_message.media_type .. file_id .. langs[msg.lang].alternativeSaved
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'setglobalalternative' and matches[2] then
        if is_admin(msg) then
            mystat('/setglobalalternative')
            if matches[3] then
                if #matches[3] > 3 then
                    if string.match(matches[3], '[Cc][Rr][Oo][Ss][Ss][Ee][Xx][Ee][Cc]') then
                        return langs[msg.lang].crossexecDenial
                    end
                    matches[2] = matches[2]:gsub('[#!]', '/')
                    if not alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)] then
                        alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)] = { }
                    end
                    table.insert(alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)], matches[3]:lower())
                    alternatives.global.altCmd[matches[3]:lower()] = string.sub(matches[2]:lower(), 1, 50)
                    save_alternatives()
                    return matches[3]:lower() .. langs[msg.lang].gAlternativeSaved
                else
                    return langs[msg.lang].errorCommandTooShort
                end
            elseif msg.reply then
                if msg.reply_to_message.media then
                    local file_id = ''
                    if msg.reply_to_message.media_type == 'photo' then
                        local bigger_pic_id = ''
                        local size = 0
                        for k, v in pairsByKeys(msg.reply_to_message.photo) do
                            if v.file_size then
                                if v.file_size > size then
                                    size = v.file_size
                                    bigger_pic_id = v.file_id
                                end
                            end
                        end
                        file_id = bigger_pic_id
                    elseif msg.reply_to_message.media_type == 'video' then
                        file_id = msg.reply_to_message.video.file_id
                    elseif msg.reply_to_message.media_type == 'video_note' then
                        file_id = msg.reply_to_message.video_note.file_id
                    elseif msg.reply_to_message.media_type == 'audio' then
                        file_id = msg.reply_to_message.audio.file_id
                    elseif msg.reply_to_message.media_type == 'voice_note' then
                        file_id = msg.reply_to_message.voice.file_id
                    elseif msg.reply_to_message.media_type == 'gif' then
                        file_id = msg.reply_to_message.document.file_id
                    elseif msg.reply_to_message.media_type == 'document' then
                        file_id = msg.reply_to_message.document.file_id
                    elseif msg.reply_to_message.media_type == 'sticker' then
                        file_id = msg.reply_to_message.sticker.file_id
                    else
                        return langs[msg.lang].useQuoteOnFile
                    end
                    matches[2] = matches[2]:gsub('[#!]', '/')
                    if not alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)] then
                        alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)] = { }
                    end
                    table.insert(alternatives.global.cmdAlt[string.sub(matches[2]:lower(), 1, 50)], 'media:' .. msg.reply_to_message.media_type .. file_id)
                    alternatives.global.altCmd['media:' .. msg.reply_to_message.media_type .. file_id] = string.sub(matches[2]:lower(), 1, 50)
                    save_alternatives()
                    return 'media:' .. msg.reply_to_message.media_type .. file_id .. langs[msg.lang].gAlternativeSaved
                end
            end
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1]:lower() == 'setdefaultalternatives' then
        if msg.from.is_owner then
            mystat('/setdefaultalternatives')
            alternatives[tostring(msg.chat.id)] = default_alternatives
            save_alternatives()
            return langs[msg.lang].alternativeCommandsRestored
        else
            return langs[msg.lang].require_owner
        end
    end
    if matches[1]:lower() == 'setdefaultglobalalternatives' then
        if is_admin(msg) then
            mystat('/setdefaultglobalalternatives')
            alternatives.global = default_alternatives
            save_alternatives()
            return langs[msg.lang].alternativeCommandsRestored
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1]:lower() == 'unsetalternative' then
        if msg.from.is_mod then
            mystat('/unsetalternative')
            if matches[2] then
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
            elseif msg.reply then
                if msg.reply_to_message.media then
                    local file_id = ''
                    if msg.reply_to_message.media_type == 'photo' then
                        local bigger_pic_id = ''
                        local size = 0
                        for k, v in pairsByKeys(msg.reply_to_message.photo) do
                            if v.file_size then
                                if v.file_size > size then
                                    size = v.file_size
                                    bigger_pic_id = v.file_id
                                end
                            end
                        end
                        file_id = bigger_pic_id
                    elseif msg.reply_to_message.media_type == 'video' then
                        file_id = msg.reply_to_message.video.file_id
                    elseif msg.reply_to_message.media_type == 'video_note' then
                        file_id = msg.reply_to_message.video_note.file_id
                    elseif msg.reply_to_message.media_type == 'audio' then
                        file_id = msg.reply_to_message.audio.file_id
                    elseif msg.reply_to_message.media_type == 'voice_note' then
                        file_id = msg.reply_to_message.voice.file_id
                    elseif msg.reply_to_message.media_type == 'gif' then
                        file_id = msg.reply_to_message.document.file_id
                    elseif msg.reply_to_message.media_type == 'document' then
                        file_id = msg.reply_to_message.document.file_id
                    elseif msg.reply_to_message.media_type == 'sticker' then
                        file_id = msg.reply_to_message.sticker.file_id
                    else
                        return langs[msg.lang].useQuoteOnFile
                    end
                    if alternatives[tostring(msg.chat.id)].altCmd['media:' .. msg.reply_to_message.media_type .. file_id] then
                        local tempcmd = alternatives[tostring(msg.chat.id)].altCmd['media:' .. msg.reply_to_message.media_type .. file_id]
                        alternatives[tostring(msg.chat.id)].altCmd['media:' .. msg.reply_to_message.media_type .. file_id] = nil
                        if alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd] then
                            local tmptable = { }
                            for k, v in pairs(alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd]) do
                                if v ~=('media:' .. msg.reply_to_message.media_type .. file_id) then
                                    table.insert(tmptable, v)
                                end
                            end
                            alternatives[tostring(msg.chat.id)].cmdAlt[tempcmd] = tmptable
                        end
                        save_alternatives()
                        return 'media:' .. msg.reply_to_message.media_type .. file_id .. langs[msg.lang].alternativeDeleted
                    else
                        return langs[msg.lang].noCommandsAlternative:gsub('X', 'media:' .. msg.reply_to_message.media_type .. file_id)
                    end
                end
            end
        else
            return langs[msg.lang].require_mod
        end
    end
    if matches[1]:lower() == 'unsetglobalalternative' then
        if is_admin(msg) then
            mystat('/unsetglobalalternative')
            if matches[2] then
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
            elseif msg.reply then
                if msg.reply_to_message.media then
                    local file_id = ''
                    if msg.reply_to_message.media_type == 'photo' then
                        local bigger_pic_id = ''
                        local size = 0
                        for k, v in pairsByKeys(msg.reply_to_message.photo) do
                            if v.file_size then
                                if v.file_size > size then
                                    size = v.file_size
                                    bigger_pic_id = v.file_id
                                end
                            end
                        end
                        file_id = bigger_pic_id
                    elseif msg.reply_to_message.media_type == 'video' then
                        file_id = msg.reply_to_message.video.file_id
                    elseif msg.reply_to_message.media_type == 'video_note' then
                        file_id = msg.reply_to_message.video_note.file_id
                    elseif msg.reply_to_message.media_type == 'audio' then
                        file_id = msg.reply_to_message.audio.file_id
                    elseif msg.reply_to_message.media_type == 'voice_note' then
                        file_id = msg.reply_to_message.voice.file_id
                    elseif msg.reply_to_message.media_type == 'gif' then
                        file_id = msg.reply_to_message.document.file_id
                    elseif msg.reply_to_message.media_type == 'document' then
                        file_id = msg.reply_to_message.document.file_id
                    elseif msg.reply_to_message.media_type == 'sticker' then
                        file_id = msg.reply_to_message.sticker.file_id
                    else
                        return langs[msg.lang].useQuoteOnFile
                    end
                    if alternatives.global.altCmd['media:' .. msg.reply_to_message.media_type .. file_id] then
                        local tempcmd = alternatives.global.altCmd['media:' .. msg.reply_to_message.media_type .. file_id]
                        alternatives.global.altCmd['media:' .. msg.reply_to_message.media_type .. file_id] = nil
                        if alternatives.global.cmdAlt[tempcmd] then
                            local tmptable = { }
                            for k, v in pairs(alternatives.global.cmdAlt[tempcmd]) do
                                if v ~=('media:' .. msg.reply_to_message.media_type .. file_id) then
                                    table.insert(tmptable, v)
                                end
                            end
                            alternatives.global.cmdAlt[tempcmd] = tmptable
                        end
                        save_alternatives()
                        return 'media:' .. msg.reply_to_message.media_type .. file_id .. langs[msg.lang].alternativegDeleted
                    else
                        return langs[msg.lang].noCommandsAlternative:gsub('X', 'media:' .. msg.reply_to_message.media_type .. file_id)
                    end
                end
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
        if not msg.service then
            if data[tostring(msg.chat.id)] then
                if alternatives[tostring(msg.chat.id)] then
                    for k, v in pairs(alternatives[tostring(msg.chat.id)].altCmd) do
                        if msg.media then
                            local file_id = ''
                            if msg.media_type == 'photo' then
                                local bigger_pic_id = ''
                                local size = 0
                                for k1, v1 in pairsByKeys(msg.photo) do
                                    if v1.file_size then
                                        if v1.file_size > size then
                                            size = v1.file_size
                                            bigger_pic_id = v1.file_id
                                        end
                                    end
                                end
                                file_id = bigger_pic_id
                            elseif msg.media_type == 'video' then
                                file_id = msg.video.file_id
                            elseif msg.media_type == 'video_note' then
                                file_id = msg.video_note.file_id
                            elseif msg.media_type == 'audio' then
                                file_id = msg.audio.file_id
                            elseif msg.media_type == 'voice_note' or msg.media_type == 'voice' then
                                file_id = msg.voice.file_id
                            elseif msg.media_type == 'gif' then
                                file_id = msg.document.file_id
                            elseif msg.media_type == 'document' then
                                file_id = msg.document.file_id
                            elseif msg.media_type == 'sticker' then
                                file_id = msg.sticker.file_id
                            else
                                return msg
                            end
                            if ('media:' .. msg.media_type .. file_id) == k then
                                -- one match is enough
                                if msg.caption then
                                    msg.text = v .. ' ' .. msg.caption
                                else
                                    msg.text = v
                                end
                                return msg
                            end
                        elseif msg.text then
                            if string.match(msg.text:lower(), '^' .. k) then
                                -- one match is enough
                                local thing_to_remove = string.sub(msg.text, 1, #k)
                                print(thing_to_remove, v)
                                msg.text = msg.text:gsub(thing_to_remove, v)
                                return msg
                            end
                        end
                    end
                end
                if alternatives.global then
                    for k, v in pairs(alternatives.global.altCmd) do
                        if msg.media then
                            local file_id = ''
                            if msg.media_type == 'photo' then
                                local bigger_pic_id = ''
                                local size = 0
                                for k1, v1 in pairsByKeys(msg.photo) do
                                    if v1.file_size then
                                        if v1.file_size > size then
                                            size = v1.file_size
                                            bigger_pic_id = v1.file_id
                                        end
                                    end
                                end
                                file_id = bigger_pic_id
                            elseif msg.media_type == 'video' then
                                file_id = msg.video.file_id
                            elseif msg.media_type == 'video_note' then
                                file_id = msg.video_note.file_id
                            elseif msg.media_type == 'audio' then
                                file_id = msg.audio.file_id
                            elseif msg.media_type == 'voice_note' or msg.media_type == 'voice' then
                                file_id = msg.voice.file_id
                            elseif msg.media_type == 'gif' then
                                file_id = msg.document.file_id
                            elseif msg.media_type == 'document' then
                                file_id = msg.document.file_id
                            elseif msg.media_type == 'sticker' then
                                file_id = msg.sticker.file_id
                            else
                                return msg
                            end
                            if ('media:' .. msg.media_type .. file_id) == k then
                                -- one match is enough
                                if msg.caption then
                                    msg.text = v .. ' ' .. msg.caption
                                else
                                    msg.text = v
                                end
                                return msg
                            end
                        elseif msg.text then
                            if string.match(msg.text:lower(), '^' .. k) then
                                -- one match is enough
                                local thing_to_remove = string.find(msg.text, 1, #k)
                                print(thing_to_remove, v)
                                msg.text = msg.text:gsub(thing_to_remove, v)
                                return msg
                            end
                        end
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
        "^[#!/]([Gg][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss]) ([#!/][^%s]+)$",
        "^[#!/]([Pp][Rr][Ee][Vv][Ii][Ee][Ww][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) (.*)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) (.*)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee])$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss]) ([#!/].*)$",
        "^[#!/]([Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) ([#!/][^%s]+) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) ([#!/][^%s]+)$",
        "^[#!/]([Ss][Ee][Tt][Dd][Ee][Ff][Aa][Uu][Ll][Tt][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss])$",
        "^[#!/]([Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) ([#!/][^%s]+) (.*)$",
        "^[#!/]([Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) ([#!/][^%s]+)$",
        "^[#!/]([Ss][Ee][Tt][Dd][Ee][Ff][Aa][Uu][Ll][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee][Ss])$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee]) (.*)$",
        "^[#!/]([Uu][Nn][Ss][Ee][Tt][Gg][Ll][Oo][Bb][Aa][Ll][Aa][Ll][Tt][Ee][Rr][Nn][Aa][Tt][Ii][Vv][Ee])$",
    },
    run = run,
    pre_process = pre_process,
    min_rank = 0,
    syntax =
    {
        "USER",
        "/getalternatives /{command}",
        "/previewalternative {alternative}",
        "MOD",
        "/setalternative /{command} {alternative}|{reply_media}",
        "/unsetalternative {alternative}|{reply_media}",
        "OWNER",
        "/setdefaultalternatives",
        "/unsetalternatives /{command}",
        "ADMIN",
        "/setglobalalternative /{command} {alternative}|{reply_media}",
        "/setdefaultglobalalternatives",
        "/unsetglobalalternative {alternative}|{reply_media}",
    },
}