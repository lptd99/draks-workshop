--teleporter

local teleporter = {}
teleporter.name = "teleporter"

local teleporterObject = Object.find("Teleporter", "vanilla")

-- Saturn's explanation
-- 1 : Start timer
-- 2 : Kill remaining enemies
-- 3 : Finished teleporter event and enemies killed
-- 4 : Teleport to the next level
-- 5 : Teleport to the last level

local cycle = 0

function teleporter.call(args)
	local _teleporter = teleporterObject:find(1)
	if _teleporter then
		if args[1] == "auto" then
			_teleporter:set("active", 3)
			Cyclone.terminal.write("Auto")
		elseif args[1] == "finish" then
			_teleporter:set("active", 3)
			Cyclone.w("Finished the teleporter.")
		elseif args[1] == "next" then
			_teleporter:set("active",4)
			Cyclone.w("Next stage.")
		--[=[
		elseif args[1] == "last" then
			_teleporter:set("active",5)
			Cyclone.w("Last stage.")
		--]=]
		elseif args[1] == "cycle" then
			cycle = tonumber(args[2]) or 5
			Cyclone.w("Cycling levels.")
			if _teleporter:get("active") <= 0 then
				cycle = cycle - 1
				Cyclone.terminal.source("teleporter next")
			end
		end
	else Cyclone.terminal.write("No teleporter found.") end
end

registercallback("onStageEntry", function()
	if cycle > 0 then Cyclone.terminal.source("teleporter next") ; cycle = cycle - 1 end
end)

Cyclone.terminal.add(teleporter)