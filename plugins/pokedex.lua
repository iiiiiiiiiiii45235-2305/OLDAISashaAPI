local function run(msg, matches)
    local query = URL.escape(matches[1])
    local url = "http://pokeapi.co/api/v2/pokemon/" .. query .. "/"
    local b, c = http.request(url)
    local pokemon = json:decode(b)

    if pokemon == nil then
        return langs[msg.lang].noPoke
    end
    -- api returns height and weight x10
    local height = tonumber(pokemon.height) / 10
    local weight = tonumber(pokemon.weight) / 10

    local text = 'ID Pokédex: ' .. pokemon.id .. '\n' ..
    langs[msg.lang].pokeName .. pokemon.name .. '\n' ..
    langs[msg.lang].pokeWeight .. weight .. " kg" .. '\n' ..
    langs[msg.lang].pokeHeight .. height .. " m"

    local image = nil
    if pokemon.sprites then
        if pokemon.sprites[1] then
            image = pokemon.sprites['front_default'].resource_uri
        end
    end

    if image then
        sendPhotoFromUrl(msg.chat.id, image, text)
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
        "#pokedex|#pokemon <name>|<id>",
    },
}