local function run(msg, matches)
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
            if file_size <= 20971520 or is_admin(msg) then
                io.popen('lua timework.lua "fileconversion" "0" "' .. msg.chat.id .. '" "' .. file_id .. '" "data/tmp/' .. file_name:gsub('"', '\\"') .. '" "' .. mediaDictionary[matches[2]:lower()] .. '" "' .. langs[msg.lang].fileDownloadedTo .. tostring('data/tmp/' .. file_name):gsub('"', '\\"') .. '"')
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
end

return {
    description = "FILECONVERSION",
    patterns =
    {
        "^[#!/]([Tt][Oo])(%w+)$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/to{type} {media}|{reply_media}",
    }
}