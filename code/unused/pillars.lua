local pillars = Artifact("Pillars")
pillars.unlocked = true
pillars.loadoutSprite = Sprite("sprites/pillars.png", 2, 18, 18)
pillars.loadoutText = "Your item selection is very limited"

local pools = {
	common = ItemPool.find("common", "vanilla"),
	uncommon = ItemPool.find("uncommon", "vanilla"),
	rare = ItemPool.find("rare", "vanilla"),
	use = ItemPool.find("use", "vanilla")
}

local poolStorage = {}

local function copyList(list)
	local newlist = {}
	for _, v in ipairs(list) do
		table.insert(newlist, v)
	end
	return newlist
end

local function shuffleList(list)
	for i = #list, 1, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end
	return list
end

local function clearPool(pool)
	for _, item in ipairs(pool:toList()) do
		pool:remove(item)
	end
end

local function limitPool(tier, number)
	local poolList = pools[tier]:toList()
	poolStorage[tier] = poolList
	clearPool(pools[tier])
	local shuffledList = shuffleList(copyList(poolList))
	for i = 1, math.min(number, #shuffledList) do
		pools[tier]:add(shuffledList[i])
	end
end

local function resetPool(tier)
	clearPool(pools[tier])
	for i = #poolStorage[tier], 1, -1 do
		pools[tier]:add(poolStorage[tier][i])
	end
end
	
registercallback("onGameStart", function()
	if pillars.active then
		limitPool("common", 9)
		limitPool("uncommon", 6)
		limitPool("rare", 3)
		limitPool("use", 5)
	end
end, 20)

registercallback("onGameEnd", function()
	if pillars.active then
		resetPool("common")
		resetPool("uncommon")
		resetPool("rare")
		resetPool("use")
	end
end, 0)