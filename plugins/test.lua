local function run(msg, matches)
    if is_sudo(msg) then
        for k, v in pairsByGroupName(data) do
            if data[tostring(k)] and data[tostring(k)].settings then
                local abc = redis:smembers('whitelist:' .. id_to_cli(k))
                local whitelisted_users = { }
                for k1, v1 in pairs(abc) do
                    table.insert(whitelisted_users, v1)
                end
                local xyz = redis:smembers('whitelist:gban:' .. id_to_cli(k))
                local whitelisted_gbanned = { }
                for k1, v1 in pairs(xyz) do
                    table.insert(whitelisted_gbanned, v1)
                end
                data[tostring(k)].lang = get_lang(k)
                data[tostring(k)].link = data[tostring(k)].set_link
                data[tostring(k)].lock_grouplink = data[tostring(k)].settings.lock_group_link
                data[tostring(k)].type = data[tostring(k)].group_type
                data[tostring(k)].owner = data[tostring(k)].set_owner
                data[tostring(k)].name = data[tostring(k)].set_name
                data[tostring(k)].whitelist = { gbanned = clone_table(whitelisted_gbanned), links = clone_table(data[tostring(k)].settings.links_whitelist), users = clone_table(whitelisted_users), }
                data[tostring(k)].settings.time_ban = 86400
                data[tostring(k)].settings.time_restrict = 86400
                data[tostring(k)].settings.max_flood = data[tostring(k)].settings.flood_max
                data[tostring(k)].settings.max_warns = data[tostring(k)].settings.warn_max
                if redis:get('notice:' .. k) then
                    data[tostring(k)].pmnotices = true
                else
                    data[tostring(k)].pmnotices = false
                end
                if redis:get('tagalert:' .. k) then
                    data[tostring(k)].tagalert = true
                else
                    data[tostring(k)].tagalert = false
                end
                data[tostring(k)].settings.warns_punishment = 7
                if data[tostring(k)].settings.lock_arabic then
                    data[tostring(k)].settings.locks.arabic = 2
                else
                    data[tostring(k)].settings.locks.arabic = false
                end
                if data[tostring(k)].settings.lock_bots then
                    data[tostring(k)].settings.locks.bots = 3
                else
                    data[tostring(k)].settings.locks.bots = false
                end
                if data[tostring(k)].settings.lock_delword then
                    data[tostring(k)].settings.locks.delword = 2
                else
                    data[tostring(k)].settings.locks.delword = false
                end
                if data[tostring(k)].settings.flood then
                    data[tostring(k)].settings.locks.flood = 3
                else
                    data[tostring(k)].settings.locks.flood = false
                end
                data[tostring(k)].settings.locks.gbanned = 4
                if data[tostring(k)].settings.lock_leave then
                    data[tostring(k)].settings.locks.leave = 3
                else
                    data[tostring(k)].settings.locks.leave = false
                end
                if data[tostring(k)].settings.lock_link then
                    data[tostring(k)].settings.locks.links = 2
                else
                    data[tostring(k)].settings.locks.links = false
                end
                if data[tostring(k)].settings.lock_member then
                    data[tostring(k)].settings.locks.members = 3
                else
                    data[tostring(k)].settings.locks.members = false
                end
                if data[tostring(k)].settings.lock_rtl then
                    data[tostring(k)].settings.locks.rtl = 2
                else
                    data[tostring(k)].settings.locks.rtl = false
                end
                if data[tostring(k)].settings.lock_spam then
                    data[tostring(k)].settings.locks.spam = 2
                else
                    data[tostring(k)].settings.locks.spam = false
                end
                if data[tostring(k)].settings.mutes.all then
                    data[tostring(k)].settings.mutes.all = 1
                else
                    data[tostring(k)].settings.mutes.all = false
                end
                if data[tostring(k)].settings.mutes.audio then
                    data[tostring(k)].settings.mutes.audios = 2
                else
                    data[tostring(k)].settings.mutes.audios = false
                end
                if data[tostring(k)].settings.mutes.contact then
                    data[tostring(k)].settings.mutes.contacts = 2
                else
                    data[tostring(k)].settings.mutes.contacts = false
                end
                if data[tostring(k)].settings.mutes.document then
                    data[tostring(k)].settings.mutes.documents = 2
                else
                    data[tostring(k)].settings.mutes.documents = false
                end
                if data[tostring(k)].settings.mutes.game then
                    data[tostring(k)].settings.mutes.games = 2
                else
                    data[tostring(k)].settings.mutes.games = false
                end
                if data[tostring(k)].settings.mutes.gif then
                    data[tostring(k)].settings.mutes.gifs = 2
                else
                    data[tostring(k)].settings.mutes.gifs = false
                end
                if data[tostring(k)].settings.mutes.location then
                    data[tostring(k)].settings.mutes.locations = 2
                else
                    data[tostring(k)].settings.mutes.locations = false
                end
                if data[tostring(k)].settings.mutes.photo then
                    data[tostring(k)].settings.mutes.photos = 2
                else
                    data[tostring(k)].settings.mutes.photos = false
                end
                if data[tostring(k)].settings.mutes.sticker then
                    data[tostring(k)].settings.mutes.stickers = 2
                else
                    data[tostring(k)].settings.mutes.stickers = false
                end
                if data[tostring(k)].settings.mutes.text then
                    data[tostring(k)].settings.mutes.text = 2
                else
                    data[tostring(k)].settings.mutes.text = false
                end
                if data[tostring(k)].settings.mutes.tgservice then
                    data[tostring(k)].settings.mutes.tgservices = 1
                else
                    data[tostring(k)].settings.mutes.tgservices = false
                end
                if data[tostring(k)].settings.mutes.video then
                    data[tostring(k)].settings.mutes.videos = 2
                else
                    data[tostring(k)].settings.mutes.videos = false
                end
                if data[tostring(k)].settings.mutes.video_note then
                    data[tostring(k)].settings.mutes.video_notes = 2
                else
                    data[tostring(k)].settings.mutes.video_notes = false
                end
                if data[tostring(k)].settings.mutes.voice_note then
                    data[tostring(k)].settings.mutes.voice_notes = 2
                else
                    data[tostring(k)].settings.mutes.voice_notes = false
                end
                if data[tostring(k)].settings.strict then
                    data[tostring(k)].settings.locks.forward = 4
                    data[tostring(k)].settings.locks.delword = 7
                else
                    data[tostring(k)].settings.locks.forward = false
                end
                data[tostring(k)].set_link = nil
                data[tostring(k)].settings.lock_group_link = nil
                data[tostring(k)].settings.lock_name = nil
                data[tostring(k)].settings.lock_photo = nil
                data[tostring(k)].group_type = nil
                data[tostring(k)].set_owner = nil
                data[tostring(k)].set_name = nil
                data[tostring(k)].settings.links_whitelist = nil
                data[tostring(k)].settings.flood_max = nil
                data[tostring(k)].settings.warn_max = nil
                data[tostring(k)].settings.lock_arabic = nil
                data[tostring(k)].settings.lock_bots = nil
                data[tostring(k)].settings.lock_delword = nil
                data[tostring(k)].settings.lock_leave = nil
                data[tostring(k)].settings.lock_link = nil
                data[tostring(k)].settings.lock_member = nil
                data[tostring(k)].settings.lock_rtl = nil
                data[tostring(k)].settings.lock_spam = nil
                data[tostring(k)].settings.mutes.audio = nil
                data[tostring(k)].settings.mutes.contact = nil
                data[tostring(k)].settings.mutes.document = nil
                data[tostring(k)].settings.mutes.game = nil
                data[tostring(k)].settings.mutes.gif = nil
                data[tostring(k)].settings.mutes.location = nil
                data[tostring(k)].settings.mutes.photo = nil
                data[tostring(k)].settings.mutes.sticker = nil
                data[tostring(k)].settings.mutes.tgservice = nil
                data[tostring(k)].settings.mutes.video = nil
                data[tostring(k)].settings.mutes.video_note = nil
                data[tostring(k)].settings.mutes.voice_note = nil
            end
        end
        save_data(config.moderation.data, data)
        sendMessage_SUDOERS(io.popen('git pull'):read('*all'))
        os.execute('sleep 10')
        io.popen('kill -9 $(pgrep lua)'):read('*all')
    end
end

return {
    description = "TEST",
    patterns = { "^[#!/][Tt][Ee][Ss][Tt]$", },
    run = run,
    min_rank = 5,
    syntax = { }
}