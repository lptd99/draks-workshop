--tclip

local tclip = {}
tclip.name = "tclip"
tclip.call = function(args)
	if tonumber(args[1]) ~= nil then
		Cyclone.terminal.clipboard = Cyclone.terminal.stack[Cyclone.terminal.stack_index - tonumber(args[1]) - 1] or ""
		local _str, _end = Cyclone.terminal.clipboard:find(Cyclone.terminal.prompt, nil, true)
		if _end ~= nil then Cyclone.terminal.clipboard = Cyclone.terminal.clipboard:sub(_end + 1) end
	elseif args[1] == "raw" and tonumber(args[2]) ~= nil then
		Cyclone.terminal.clipboard = Cyclone.terminal.stack[Cyclone.terminal.stack_index - tonumber(args[2]) - 1] or ""
	elseif args[1] == "write" then
		Cyclone.terminal.write(Cyclone.terminal.clipboard)
	end
end
Cyclone.terminal.add(tclip)