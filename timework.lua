require("bot")
local a, b, c, d = ...
os.execute("sleep " .. 3)
printvardump(a)
printvardump(b)
printvardump(c)
os.execute("sleep " .. 10)
printvardump(d(a))
printvardump(vardumptext(a))