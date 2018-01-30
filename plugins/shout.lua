local function run(msg, matches)
    matches[1] = matches[1]:trim()

    if matches[1]:len() > 20 then
        matches[1] = matches[1]:sub(1, 20)
    end

    matches[1] = matches[1]:upper()
    local text = ''
    local inc = 0
    for mtch in matches[1]:gmatch('.') do
        text = text .. mtch .. ' '
    end
    text = text .. '\n'
    for mtch in matches[1]:sub(2):gmatch('.') do
        local spacing = ''
        for i = 1, inc do
            spacing = spacing .. '  '
        end
        inc = inc + 1
        text = text .. mtch .. ' ' .. spacing .. mtch .. '\n'
    end
    text = text:trim()
    if not sendReply(msg, text, false, false, true) then
        return langs[msg.lang].shoutError
    end
end

return {
    description = "SHOUT",
    patterns =
    {
        "^[#!/][Ss][Hh][Oo][Uu][Tt] (.*)$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "/shout {text}",
    },
}