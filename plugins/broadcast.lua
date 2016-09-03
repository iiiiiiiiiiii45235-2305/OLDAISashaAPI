local function run(msg, matches)
    if matches[1] == 'br' then
        if is_admin(msg) then
            sendMessage(matches[2], matches[3])
        else
            return langs[msg.lang].require_admin
        end
    end
    if matches[1] == 'broadcast' then
        if is_sudo(msg) then
            -- Only sudo!
            local data = load_data(config.moderation.data)
            for k, v in pairs(data['groups']) do
                sendMessage(v, matches[2])
            end
        else
            return langs[msg.lang].require_sudo
        end
    end
end

return {
    description = "BROADCAST",
    patterns =
    {
        "^[#!/]([Bb][Rr][Oo][Aa][Dd][Cc][Aa][Ss][Tt]) +(.+)$",
        "^[#!/]([Bb][Rr]) (%d+) (.*)$"
    },
    run = run,
    min_rank = 3,
    syntax =
    {
        "ADMIN",
        "#br <group_id> <text>: Sasha invia <text> a <group_id>.",
        "SUDO",
        "#broadcast <text>: Sasha invia <text> a tutti i gruppi.",
    },
}