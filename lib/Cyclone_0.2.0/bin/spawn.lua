--spawn

local spawn = {}
spawn.name = "spawn"

local alias = {
["chest"] = "Chest1",
["magmaworm"] = "Worm",
}

spawn.call = function(args)
	local pos = Cyclone.pos
	
	local _count = tonumber(args[#args]) or 1
	for k,v in pairs(args) do
		if k ~= 0 then
			local _obj = Object.find(alias[v] or v)
			if _obj ~= nil then 
				for i=1,_count do
					_obj:create(pos.x,pos.y)
				end
			else Cyclone.terminal.write("Object could not be found") end
		end
	end
end

Cyclone.terminal.add(spawn)