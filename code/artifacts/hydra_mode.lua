local artifact = Artifact("Hydra Mode")
artifact.unlocked = true
artifact.loadoutSprite = Sprite("sprites/artifacts/hydra_mode.png", 2, 18, 18)
artifact.loadoutText = "When an enemy dies, it has a 50% chance to spawn two copies of itself"

local honor = Artifact.find("Honor")

local clone = false

local blacklist = {}
for _, obj in ipairs({"Boss1", "Boss2Clone", "Boss3", "Boss3Fake", "ImpM", "LizardFG", "WurmHead"}) do
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

local function adjustStat2(inst, stat, stat2)
	local s = inst:get(stat)
	if s then
		inst:set(stat, stat2)
	end
end

local function spawnStats(inst)
	inst:set("hp", inst:get("maxhp"))
	if honor.active then
		inst:set("elite", 2)
	end
	return inst
end

local function adjustBaseStats(inst, n)
	adjustStat(inst, "hp", n/5)
	adjustStat(inst, "maxhp", n/5)
	adjustStat(inst, "point_value", n/5)
	adjustStat(inst, "exp_worth", n/5)
	adjustStat(inst, "size", n/5)
	if honor.active then
	end
end

local function floodInst(inst)
	inst:set("za-flooded", 1)
	clone = true
	for i = 1, 2, 1 do
		adjustBaseStats(inst, i*i/2)
		cloneInst(inst, inst.x + i * 4, inst.y)
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
	if artifact.active and inst:get("hp") > 0 and #lizardSpawnQueue > 0 then
		table.remove(lizardSpawnQueue)
	end
end)

local queue = {}
local delayQueue = {}
local hasStepped = false

registercallback("onActorInit", function(inst)
	if artifact.active then
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

local lastEnemyKilled
local 

registercallback("onNPCDeath", function(npc)
	if artifact.active then
		local num = math.random(1, 10)
		if num > 5 then
			floodInst(spawnStats(npc))
		end
	end
end)

registercallback("onStep", function()
	if artifact.active then
		hasStepped = true
	end
end)