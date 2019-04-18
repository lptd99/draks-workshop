local flood = Artifact("Flood Revamped")
flood.unlocked = true
flood.loadoutSprite = Sprite("sprites/artifacts/flood_revamped.png", 2, 18, 18)
flood.loadoutText = "Each enemy copies itself 4 times, and each new copy have increased power"

local clone = false

local blacklist = {}
for _, obj in ipairs({"Boss1", "Boss2Clone", "Boss3", "Boss3Fake", 
		"WormHead", "WormBody", "ImpM", "LizardFG", "WurmHead"}) do
	blacklist[Object.find(obj, "vanilla")] = true
end

local function copyStat(stat, parent, child)
	local val = parent:get(stat)
	if val then	
		child:set(stat, val)
	end
end

local statsToCopy = {"hp", "maxhp", "point_value", "exp_worth", "elite", 
	"elite_tier", "cdr", "team", "lightning", "knockback_cap", "damage", 
	"fire_trail", "attack_speed", "pHmax", "explosive_shot", "lifesteal",
	"pal"}

local function copyStats(parent, child)
	for _, stat in ipairs(statsToCopy) do
		copyStat(stat, parent, child)
	end
end

local function cloneInst(inst, x, y)
	local child = inst:getObject():create(x, y)
	copyStats(inst, child)
	child:set("za-flooded", 1)
	child.xscale = inst.xscale
	child.blendColor = inst.blendColor
end

local function adjustStat(inst, stat, mult)
	local s = inst:get(stat)
	if s then
		inst:set(stat, s * mult)
	end
end

local function adjustBaseStats(inst, n)
	adjustStat(inst, "hp", n/5)
	adjustStat(inst, "maxhp", n/5)
	adjustStat(inst, "point_value", n/5)
	adjustStat(inst, "exp_worth", n/5)
	adjustStat(inst, "size", n/5)

end

local function floodInst(inst)
	inst:set("za-flooded", 1)
	clone = true
	for n = 2, 5, 1 do
		adjustBaseStats(inst, n)
		cloneInst(inst, inst.x + n * 4, inst.y)
	end
	clone = false
end

local graylist = {}

local slimeQueue = {}
graylist[Object.find("Slime", "vanilla")] = function(inst) 
	table.insert(slimeQueue, inst)
end

local lizardSpawnQueue = {}
graylist[Object.find("LizardF", "vanilla")] = function(inst)
	table.insert(lizardSpawnQueue, inst)
end

local lizardFG = Object.find("LizardFG")
lizardFG:addCallback("destroy", function(inst)
	if flood.active and inst:get("hp") > 0 and #lizardSpawnQueue > 0 then
		table.remove(lizardSpawnQueue)
	end
end)

local queue = {}
local delayQueue = {}
local hasStepped = false

registercallback("onActorInit", function(inst)
	if flood.active then
		local i = inst:getAccessor()
		local obj = inst:getObject()
		if not blacklist[obj] and not clone then
			if graylist[obj] then
				graylist[obj](inst)
			else
				if hasStepped then
					table.insert(queue, inst)
				else
					table.insert(delayQueue, inst)
				end
			end
		end
	end
end)

registercallback("preStep", function()
	hasStepped = false
end)

local function validateInstance(inst)
	return inst:isValid() and inst:get("ghost") == 0 and inst:get("team") == "enemy"
end

registercallback("onStep", function()
	if flood.active then
		hasStepped = true
		for _, inst in ipairs(slimeQueue) do
			if validateInstance(inst) then
				local s = inst:get("size_s")
				if s and s == 1 then
					floodInst(inst)
				end
			end
		end
		slimeQueue = {}
		for _, inst in ipairs(lizardSpawnQueue) do
			if validateInstance(inst) then
				floodInst(inst)
			end
		end
		lizardSpawnQueue = {}
		for _, inst in ipairs(queue) do
			if validateInstance(inst) then
				floodInst(inst)
			end
		end
		queue = {}
		for _, v in ipairs(delayQueue) do
			table.insert(queue, v)
		end
		delayQueue = {}
	end
end)