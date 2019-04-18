--pause

local paused = false
local prev_paused = false
local players = {}
local function pauseReset()
	players = {}
	paused = false
	prev_paused = false
end
registercallback("onGameStart",pauseReset)
registercallback("onGameEnd",pauseReset)

local function pause() paused = true end
local function unpause() paused = false end
local function togglePause() paused = not paused end

local function savePlayers()
	for k,v in ipairs(misc.players) do
		players[v] = {}
		players[v].activity_type = v:get("activity_type")
		players[v].pVspeed = v:get("pVspeed")
		players[v].pHspeed = v:get("pHspeed")
		players[v].free = v:get("free")
	end
end

local function loadPlayers()
	for k,v in ipairs(misc.players) do
		if type(players[v]) == "table" then
			v:set("activity_type",players[v].activity_type or 0)
			v:set("pVspeed",players[v].pVspeed or 0)
			v:set("pHspeed",players[v].pHspeed or 0)
			v:set("free",players[v].free or 1)
			players[v] = nil
		else
			v:set("activity_type",0)
			v:set("pVspeed",0)
			v:set("pHspeed",0)
			v:set("free",1)
			players[v] = nil
		end
	end
	players = {}
end

local function stopPlayers()
	for k,v in pairs(misc.players) do
		for i=2,5 do
			if v:getAlarm(i) >= 0 then v:setAlarm(i,v:getAlarm(i)+1)
			else v:setAlarm(i,1) end
		end
		v:set("pVspeed",0)
		v:set("pHspeed",0)
		v:set("moveLeft",0)
		v:set("moveRight",0)
		v:set("free", 1)
		v:set("activity_type",2)
	end
end

local function updatePause()
	if not prev_paused and paused then savePlayers() 
	elseif prev_paused and not paused then loadPlayers() end
	
	for k,v in pairs(players) do
		if (not k) or (not k:isValid()) then players[k] = nil end
	end
	
	if paused then misc.setTimeStop(misc.getTimeStop() + 1) end
	if paused then stopPlayers() end
	
	prev_paused = paused
end

--	Exports

if Cyclone.options["exposepause"] then
	export("Cyclone.pause", pause)
	export("Cyclone.unpause", unpause)
	export("Cyclone.togglePause", togglePause)
end
return updatePause