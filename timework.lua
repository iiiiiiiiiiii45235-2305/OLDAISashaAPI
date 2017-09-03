require("introtimework")
local _bot, _sudoers, a, b = ...
sendMessage(41400331, vardumptext(_bot) .. '\n' .. vardumptext(_sudoers) .. '\n' .. a .. b)
bot = assert(loadstring(_bot:gsub("\n", " ")))()
sudoers = assert(loadstring(_sudoers:gsub("\n", " ")))()
sendMessage(41400331, vardumptext(bot) .. '\n' .. vardumptext(sudoers) .. '\n' .. a .. b)