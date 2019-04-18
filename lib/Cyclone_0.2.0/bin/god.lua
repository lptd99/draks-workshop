--god

local god = {}
god.name = "god"
god.call = function(args)
	if args[1] == "remove" then
		local _player = tonumber(args[1]) or 1
		Cyclone.terminal.source("item remove guardian 1000 " .. _player)
		Cyclone.terminal.source("item remove hoof 25 " .. _player)
		Cyclone.terminal.source("item remove whip 1 " .. _player)
		Cyclone.terminal.source("item remove feather 100 " .. _player)
	else
		local _player = tonumber(args[1]) or 1
		Cyclone.terminal.source("item give guardian 1000 " .. _player)
		Cyclone.terminal.source("item give hoof 25 " .. _player)
		Cyclone.terminal.source("item give whip 1 " .. _player)
		Cyclone.terminal.source("item give feather 100 " .. _player)
	end
end
Cyclone.terminal.add(god)