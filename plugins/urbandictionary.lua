function run(msg, matches)
    local term = matches[1]
    local url = 'http://api.urbandictionary.com/v0/define?term=' .. URL.escape(term)

    local jstr, res = http.request(url)
    if res ~= 200 then
        return langs[msg.lang].opsError
    end

    local jdat = json:decode(jstr)
    if jdat.result_type == "no_results" then
        return langs[msg.lang].opsError
    end

    local text = '*' .. jdat.list[1].word .. '*\n\n' .. jdat.list[1].definition:trim()
    if string.len(jdat.list[1].example) > 0 then
        text = text .. '_\n\n' .. jdat.list[1].example:trim() .. '_'
    end

    text = text:gsub('%[', ''):gsub('%]', '')

    if not sendReply(msg, text, 'markdown') then
        return text
    end
end

return {
    description = 'URBANDICTIONARY',
    patterns =
    {
        "^[#!/][Uu][Rr][Bb][Aa][Nn][Dd][Ii][Cc][Tt][Ii][Oo][Nn][Aa][Rr][Yy] (.+)$",
        "^[#!/][Uu][Rr][Bb][Aa][Nn] (.+)$",
        "^[#!/][Uu][Dd] (.+)$",
    },
    run = run,
    min_rank = 1,
    syntax =
    {
        "USER",
        "(/urbandictionary|/urban|/ud) {text}",
    },
}