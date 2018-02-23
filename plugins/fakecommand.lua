-- no "SUDO" because there's no rank higher than "SUDO" (yes there's "BOT" but it's not a real rank)
-- "USER" can't use this because there's no rank lower than "USER"
local function run(msg, matches)
    if msg.from.is_mod then
        local rank = get_rank(msg.from.id, msg.chat.id, true)
        local fakerank = rank_table[matches[1]:upper()]
        print(rank, fakerank)
        if fakerank <= rank then
            -- yes
            mystat('/fakecommand')
            -- remove "[#!/]<rank> " from message so it's like a normal message
            local copied_msg = clone_table(msg)
            msg = nil
            copied_msg.text = copied_msg.text:gsub('#' .. matches[1] .. ' ', '')
            copied_msg.text = copied_msg.text:gsub('!' .. matches[1] .. ' ', '')
            copied_msg.text = copied_msg.text:gsub('/' .. matches[1] .. ' ', '')
            -- replace the id of the executer with a '*' followed by the rank value so when it's checked with (e.g.) is_mod(msg) bot knows it's a fakecommand
            copied_msg.from.id = - fakerank
            copied_msg.from.is_mod = false
            copied_msg.from.is_owner = false
            if is_owner(copied_msg, true) then
                copied_msg.from.is_mod = true
                copied_msg.from.is_owner = true
            end
            if is_mod(copied_msg, true) then
                copied_msg.from.is_mod = true
            end
            if msg_valid(copied_msg) then
                match_plugins(copied_msg)
            end
        else
            -- no
            return langs[msg.lang].fakecommandYouTried
        end
    else
        return langs[msg.lang].require_mod
    end
end

return {
    description = "FAKECOMMAND",
    patterns =
    {
        "^[#!/]([Uu][Ss][Ee][Rr]) (.*)",
        "^[#!/]([Mm][Oo][Dd]) (.*)",
        "^[#!/]([Oo][Ww][Nn][Ee][Rr]) (.*)",
        "^[#!/]([Aa][Dd][Mm][Ii][Nn]) (.*)",
    },
    run = run,
    min_rank = 2,
    syntax =
    {
        "MOD",
        "(/user|/mod|/owner|/admin) {command}",
    },
}