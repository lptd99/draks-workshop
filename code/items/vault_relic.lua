local vault_relic = Item.new("Vault Relic")
vault_relic.pickupText = "Chance to duplicate your items on a Boss kill."
vault_relic.sprite = Sprite.load("sprites/items/vault_relic.png", 1, 15, 15)
vault_relic:setTier("rare")
vault_relic:setLog{
	group = "rare",
	description = "2% chance to add 1 to each item stack on a Boss kill, up to 100. Increases chance by 0.5% per stack.",
	story = "Handsome Jack had a hard time when near this relic, hope you don't have the same luck.",
	destination = "VAULT",
	date = "3702-03-19"
}

local p_boss_count

local common_pool = ItemPool.find("common", "vanilla")
local uncommon_pool = ItemPool.find("uncommon", "vanilla")
local rare_pool = ItemPool.find("rare", "vanilla")
local boss_pool = ItemPool.new(boss)
boss_pool:add(Item.find("Burning Witness"))
boss_pool:add(Item.find("Colossal Knurl"))
boss_pool:add(Item.find("Ifrit's Horn"))
boss_pool:add(Item.find("Imp Overlord's Tentacle"))
boss_pool:add(Item.find("Legendary Spark"))

registered = {}

registercallback("onPlayerInit", function(player)
	p_boss_count = 0;
end)

registercallback("onPlayerStep", function(player)
	if player:countItem(Item.find("Vault Relic")) > 0 then
		if math.random(1, 1000) <= (15 + player:countItem(Item.find("Vault Relic")) * 5) then
			if (player:get("boss_count") > p_boss_count) then
				for i=1, player:get("boss_count") - p_boss_count, 1 do
					for _, pool in ipairs({common_pool, uncommon_pool, rare_pool, boss_pool}) do
						for _, item in ipairs(pool:toList()) do
							if player:countItem(item) > 0 and item ~= Item.find("Vault Relic") and player:countItem(item) < 100 then
								player:giveItem(item)
							end
						end
					end
				end
				p_boss_count = player:get("boss_count")
			end
		else
			p_boss_count = player:get("boss_count")
		end
	else
		p_boss_count = player:get("boss_count")
	end
end)

