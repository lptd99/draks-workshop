--list

local list = {}
list.name = "list"
list.call = function()
	for k,v in pairs(Cyclone.terminal.bin) do
		Cyclone.terminal.write(v.name)
	end
end
Cyclone.terminal.add(list)