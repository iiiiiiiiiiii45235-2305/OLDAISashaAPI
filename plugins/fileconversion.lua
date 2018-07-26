local function run(msg, matches)
    if msg.from.is_mod then
        if matches[1]:lower() == 'to' and mediaDictionary[matches[2]:lower()] then
            local file_id, file_name, file_size, media_type
            if msg.reply then
                file_id, file_name, file_size = extractMediaDetails(msg.reply_to_message)
                media_type = msg.reply_to_message.media_type
            elseif msg.media then
                file_id, file_name, file_size = extractMediaDetails(msg)
                media_type = msg.media_type
            else
                return langs[msg.lang].useCommandOnFile
            end
            if file_id and file_name and file_size then
                if file_size <= 20971520 then
                    io.popen('lua timework.lua "fileconversion" "0" "' .. msg.chat.id .. '" "' .. file_id .. '" "' .. file_name:gsub('"', '\\"') .. '" "' .. file_size .. '" "' .. media_type .. '" "' .. mediaDictionary[matches[2]:lower()] .. '"')
                    return langs[msg.lang].workingOnYourRequest
                else
                    return langs[msg.lang].cantDownloadMoreThan20MB
                end
            else
                return langs[msg.lang].useCommandOnFile
            end
        else
            return langs[msg.lang].unknownType
        end
    else
        return langs[msg.lang].require_mod
    end
end

return {
    description = "FILECONVERSION",
    patterns =
    {
        "^[#!/]([Tt][Oo])(%w+)$",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "MOD",
        "/to{type} {media}|{reply_media}",
    }
}