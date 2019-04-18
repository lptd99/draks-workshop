-- SYRINGE

local e_syringe = Item("Elite Syringe")
e_syringe.pickupText = "Increases your attack speed by 25% its value on pickup."
e_syringe.sprite = Sprite.load("sprites/items/elite_syringe.png", 1, 15, 15)
e_syringe:setTier("uncommon")
e_syringe:setLog{
	group = "uncommon",
	description = "Increases your attack speed even further, ",
	story = "Seems like the Soldier Syringe wasn't enough for you, huh?\nHere's something... stronger.\nPaint it red, soldier.",
	destination = "Actually, inside your body.",
	date = "2025-03-19"
}

local attack_speed_per_player = {}
local aspd_per_stack = 0.25

registercallback("onItemPickup", function(itemInst, player)
	local item = itemInst:getItem()
	if item == e_syringe then
		attack_speed_per_player[player] = player:get("attack_speed")
	end
end)

registercallback("preStep", function()
	for _, player in ipairs(misc.players) do
		attack_speed_per_player[player] = player:get("attack_speed")
	end
end)

e_syringe:addCallback("pickup", function(player)
	attack_speed_per_player[player] = attack_speed_per_player[player] + attack_speed_per_player[player] * aspd_per_stack
	player:set("attack_speed", attack_speed_per_player[player])
end)

if itemremover then
	itemremover.setRemoval(e_syringe, function(player, count)
		attack_speed_per_player[player] = player:get("attack_speed") - attack_speed_per_player[player] * aspd_per_stack
		player:set("attack_speed", attack_speed_per_player[player])
	end)
end
