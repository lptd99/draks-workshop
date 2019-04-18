-- HOOF

local c_hoof = Item("Centaur's Hoof")
c_hoof.pickupText = "Increases your move speed based on your maximum health, maximum shield and armor."
c_hoof.sprite = Sprite.load("sprites/items/centaur_hoof.png", 1, 15, 15)
c_hoof:setTier("uncommon")
c_hoof:setLog{
	group = "uncommon",
	description = "The toughest, the fastest",
	story = "Dropped this item in a MMORPG, thought it'd be cool to have it on Risk of Rain too.",
	destination = "Unknown",
	date = "2025-03-19"
}

local pHmax = {}
local pMaxHP
local pMaxShield
local pArmor
local mspd_per_stack

registercallback("onItemPickup", function(itemInst, player)
	local item = itemInst:getItem()
	if item == c_hoof then 
		pHmax[player] = player:get("pHmax")
		pMaxHP = player:get("maxhp")
		pMaxShield = player:get("maxshield")
		pArmor = player:get("armor")
		mspd_per_stack = pMaxHP + pMaxShield + pArmor
	end
end)

registercallback("preStep", function()
	for _, player in ipairs(misc.players) do
		if player then
			pHmax[player] = player:get("pHmax")
			pMaxHP = player:get("maxhp")
			pMaxShield = player:get("maxshield")
			pArmor = player:get("armor")
		end
	end
end)

c_hoof:addCallback("pickup", function(player)
	pHmax[player] = pHmax[player] + mspd_per_stack 
	player:set("pHmax", pHmax[player])
end)

if itemremover then
	itemremover.setRemoval(c_hoof, function(player, count)
		pHmax[player] = player:get("pHmax") - mspd_per_stack
		player:set("pHmax", pHmax[player])
	end)
end
