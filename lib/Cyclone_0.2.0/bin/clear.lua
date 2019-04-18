--clear

local clear = {}
clear.name = "clear"
clear.call = function()
	Cyclone.terminal.stack = {}
end
Cyclone.terminal.add(clear)