--scan

local scan = {}
scan.name = "scan"

local r = Cyclone.Rectangle:new()

local function doScan(x,y)
	local _instances = {}
	r = Cyclone.Rectangle:new()
	r.w = 10 ; r.h = 10
	r.x = x - r.w/2 ; r.y = y - r.h/2
	for k,v in pairs(Object.findAll("vanilla")) do
		if v:getName() ~= "DirectorControl" then
			for _k,_v in pairs(v:findAll()) do
				if r:intersectsInstance(_v) then
					_instances[_v] = v
				end
			end
		end
	end
	return _instances
end

local function writeScan(x,y)
	for k,v in pairs(doScan(x,y)) do
		Cyclone.terminal.write(
			k.id, " ",
			k.x, " ",
			k.y, " ",
			v:getName(), " ",
			k.visible, " "
		)
	end
end

scan.call = function(args)
	if args[1] == "cursor" then
		writeScan(Cyclone.pos.x,Cyclone.pos.y)
	elseif args[1] == "player" then
		local _player = misc.players[1]
		if tonumber(args[2]) ~= nil then _player = misc.players[tonumber(args[2])] end
		writeScan(_player.x,_player.y)
	else
		local x,y = Cyclone.pos.x,Cyclone.pos.y
		if tonumber(args[2]) ~= nil then x = tonumber(args[2]) end
		if tonumber(args[3]) ~= nil then y = tonumber(args[3]) end
		writeScan(x,y)
	end
end
Cyclone.terminal.add(scan)