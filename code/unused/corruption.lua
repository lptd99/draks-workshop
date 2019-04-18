local allSprites = {}
local backups = {}

local dc = Object.find("DirectorControl")

local bl = {"PMask", "Rope", "BossPawn", "NoClimb", "BossSpawn2", "Spawn", "NoSpawn", "Thin", "RopeTop", "Bite1Mask", "SinglePixel", "DoublePixel"}
local blacklist = {}
for _, w in ipairs(bl) do blacklist[w] = true end

local alreadyStored = {}

local sprite_index = 1
local function storeSprite(spr)
	local newSpr = Sprite("backup_"..sprite_index, "sprites/placeholder.png", 1, 0, 0)
	newSpr:replace(spr)
	table.insert(backups, newSpr)
	table.insert(allSprites, spr)
	alreadyStored[newSpr] = true
	alreadyStored[spr] = true
	sprite_index = sprite_index + 1
end

registercallback("postLoad", function()
	-- Copy all sprites for safekeeping
	for _, mod in ipairs(modloader.getMods()) do
		for _, spr in ipairs(Sprite.findAll(mod)) do
			if not alreadyStored[spr] then
				storeSprite(spr)
			end
		end
	end
	for _, spr in ipairs(Sprite.findAll("vanilla")) do
		if not blacklist[spr:getName()] then
			storeSprite(spr)
		end
	end
end)

local aoc = Artifact("Corruption")

aoc.unlocked = true
aoc.loadoutSprite = Sprite.load("sprites/corruption.png", 2, 18, 18)
aoc.loadoutText = "All sprites are constantly randomized"

local function corruptRandomSprite()
	local sprite = allSprites[math.random(#allSprites)]
	sprite:replace(backups[math.random(#backups)])
end

local function uncorruptRandomSprite()
	local num = math.random(#allSprites)
	allSprites[num]:replace(backups[num])
end

registercallback("onStep", function()
	if aoc.active then
		-- Corrupt 1 sprite
		corruptRandomSprite()
		
		-- Pick 3 random sprites and uncorrupt them if they're corrupted
		for i = 1, 3 do
			uncorruptRandomSprite()
		end
	end
end)

registercallback("onGameEnd", function()
	for i, v in ipairs(allSprites) do
		v:replace(backups[i])
	end
end)

local function drawRectOnBlock(block)
    for _, v in ipairs(block:findAll()) do
        local x, y, w, h = v.x, v.y, v:get("width_box") * 16, v:get("height_box") * 16
        graphics.rectangle(x, y, x + w - 1, y + h - 1, false)
    end
end

local rope = Object.find("Rope")

local function drawRectOnRopes()
    for _, v in ipairs(rope:findAll()) do
        local x, y, w, h = v.x, v.y, 2, v:get("height_box") * 16
        graphics.rectangle(x, y, x + w, y + h, false)
    end
end

local blocks = {Object.find("BNoSpawn"), Object.find("BNoSpawn2"), Object.find("BNoSpawn3"), Object.find("B")}

registercallback("onDraw", function()
	if aoc.active then
		graphics.alpha(0.1)
		graphics.colour(Colour.WHITE)
		for _, obj in ipairs(blocks) do
			drawRectOnBlock(obj)
		end
		graphics.colour(Colour.YELLOW)
		drawRectOnRopes()
		graphics.alpha(1)
	end
end)