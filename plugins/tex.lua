--  Saves file to /tmp/. If file_name isn't provided, will get the text after the last "/" for filename and content-type for extension
local function tempDownloadFile(url, file_name)
    print("url to download: " .. url)
    local respbody = { }
    local options = {
        url = url,
        sink = ltn12.sink.table(respbody),
        redirect = true
    }
    -- nil, code, headers, status
    local response = nil
    if url:starts('https') then
        options.redirect = false
        response = { HTTPS.request(options) }
    else
        response = { http.request(options) }
    end
    local code = response[2]
    local headers = response[3]
    local status = response[4]
    if code ~= 200 then
        return
    end
    file_name = file_name or string.random(50)
    local file_path = "data/tmp/" .. file_name
    print("Saved to: " .. file_path)
    file_var = io.open(file_path, "w+")
    file_var:write(table.concat(respbody))
    file_var:close()
    return file_path
end

local function run(msg, matches)
    local file_path = tempDownloadFile("http://latex.codecogs.com/png.download?\\dpi{300}%20\\LARGE%20" .. URL.escape(matches[1]), false)
    if not file_path then
        -- Error
        return langs[msg.lang].errorFileDownload
    else
        return pyrogramUpload(msg.chat.id, "document", file_path, msg.message_id)
    end
end

return {
    description = "TEX",
    patterns =
    {
        "^[#!/][Tt][Ee][Xx] (.+)$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/tex {equation}",
    },
}