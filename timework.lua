require("introtimework")
local _bot, _sudoers, a, b = ...
sendMessage(41400331, vardumptext(bot) .. '\n' .. vardumptext(sudoers) .. '\n' .. a .. b)
bot = assert(loadstring(_bot))()
sudoers = assert(loadstring(_sudoers))()
sendMessage(41400331, vardumptext(bot) .. '\n' .. vardumptext(sudoers) .. '\n' .. a .. b)