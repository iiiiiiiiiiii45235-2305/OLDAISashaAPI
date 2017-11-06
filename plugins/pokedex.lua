local function run(msg, matches)
    local query = URL.escape(matches[1])
    local url = "http://pokeapi.co/api/v2/pokemon/" .. query .. "/"
    local b, c = HTTPS.request(url)
    local pokemon = json:decode(b)

    pokemon.moves = nil
    pokemon.game_indices = nil
    sendLog(vardumptext(pokemon))
    if not pokemon then
        return langs[msg.lang].noPoke
    end
    -- api returns height and weight x10
    local height = tonumber(pokemon.height or 0) / 10
    local weight = tonumber(pokemon.weight or 0) / 10

    local text = 'ID Pokédex: ' ..(pokemon.id or 'ERROR') .. '\n' ..
    langs[msg.lang].pokeName ..(pokemon.name or 'ERROR') .. '\n' ..
    langs[msg.lang].pokeWeight .. weight .. " kg" .. '\n' ..
    langs[msg.lang].pokeHeight .. height .. " m"

    if pokemon.sprites then
        sendPhotoFromUrl(msg.chat.id, pokemon.sprites.front_default, text)
    end
end

return {
    description = "POKEDEX",
    patterns =
    {
        "^[#!/][Pp][Oo][Kk][Ee][Dd][Ee][Xx] (.*)$",
        "^[#!/][Pp][Oo][Kk][Ee][Mm][Oo][Nn] (.+)$"
    },
    run = run,
    min_rank = 0,
    syntax =
    {
        "USER",
        "(/pokedex|/pokemon) {name}|{id}",
    },
}