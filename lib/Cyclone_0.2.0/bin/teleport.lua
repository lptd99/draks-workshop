--teleport

local teleport = {}
teleport.name = "teleport"

local teleporterObject = Object.find("Teleporter", "vanilla")
teleport.call = function(args)
	local _player = misc.players[tonumber(args[2]) or 1]
	if args[1] == "cursor" then
		_player.x = Cyclone.pos.x
		_player.y = Cyclone.pos.y
	elseif args[1] == "teleporter" then
		local _teleporter = teleporterObject:find(1)
		if _teleporter then _player.x = _teleporter.x ; _player.y = _teleporter.y -7
		else Cyclone.w("Teleporter not found.") end
	end
end
Cyclone.terminal.add(teleport)