--cursor

local cursor = {}
cursor.name = "cursor"

local function pos(x,y)
	local _pos = {} ; _pos.x = x ; _pos.y = y
	export("Cyclone.pos", _pos)
end

cursor.call = function(args)
	local x, y = Cyclone.getPos()
	if args[1] == "move" then
		if tonumber(args[2]) ~= nil then x = x + tonumber(args[2]) end
		if tonumber(args[3]) ~= nil then y = y + tonumber(args[3]) end
	elseif args[1] == "player" then
		x = misc.players[1].x
		y = misc.players[1].y
	elseif args[1] == "mouse" then
		x,y = input.getMousePos()
	else
		if tonumber(args[2]) ~= nil then x = tonumber(args[1]) end
		if tonumber(args[3]) ~= nil then y = tonumber(args[2]) end
	end
	if x and y then pos(x,y) end
end

Cyclone.terminal.add(cursor)