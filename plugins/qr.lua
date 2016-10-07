-- http://goqr.me/api/doc/create-qr-code/
-- psykomantis

local function get_hex(str)
    local colors = {
        red = "f00",
        blue = "00f",
        green = "0f0",
        yellow = "ff0",
        purple = "f0f",
        white = "fff",
        black = "000",
        gray = "ccc"
    }
    for color, value in pairs(colors) do
        if color == str then
            return value
        end
    end
    return str
end

local function run(msg, matches)
    local text = matches[1]
    local color
    local back
    if #matches > 1 then
        text = matches[3]
        color = matches[2]
        back = matches[1]
    end

    local url = "http://api.qrserver.com/v1/create-qr-code/?" ..
    "size=600x600&data=" .. URL.escape(text:trim())

    if color then
        url = url .. "&color=" .. get_hex(color)
    end
    if bgcolor then
        url = url .. "&bgcolor=" .. get_hex(back)
    end

    local response, code, headers = http.request(url)
    if code ~= 200 then
        return langs[msg.lang].opsError .. code
    end

    if #response > 0 then
        return sendPhotoId(msg.chat.id, URL.unescape(url))
    end
    return langs[msg.lang].opsError
end

return {
    description = "QR",
    patterns =
    {
        "^[#!/][Qq][Rr] \"(%w+)\" \"(%w+)\" (.+)$",
        "^[#!/][Qq][Rr] (.+)$",
        -- qr
        "^[Ss][Aa][Ss][Hh][Aa] [Qq][Rr] \"(%w+)\" \"(%w+)\" (.+)$",
        "^[Ss][Aa][Ss][Hh][Aa] [Qq][Rr] (.+)$",
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "(#qr|sasha qr) [\"<background_color>\" \"<data_color>\"] <text>",
    },
}