--kill

local kill = {}
kill.name = "kill"
kill.call = function(args)
	local _i = 1
	local _player = tonumber(args[_i])
	if _player then
		while not (_player == nil) do
			if misc.players[_player] then misc.players[_player]:kill() end
			_i = _i + 1
			_player = tonumber(args[_i])
		end
	else
		for k,v in pairs(misc.players) do
			v:kill()
		end
	end
end
Cyclone.terminal.add(kill)