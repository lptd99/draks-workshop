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

local find_relic = Item.find("Vault Relic")

registercallback("onPlayerInit", function(player)
	p_boss_count = 0;
end)

local function give(player, item)
	if player:countItem(item) > 0 and item ~= find_relic and player:countItem(item) < 100 then
		item:getObject():create(player.x, player.y)
	end
end

local function give_from_list(player, list)
	for _, item in ipairs(list:toList()) do
		give(player, item)
	end
end

local player

registercallback("onPlayerStep", function(player)
	local p_vault_relics = player:countItem(find_relic)
	if p_vault_relics > 0 then
		for i=1, player:get("boss_count") - p_boss_count, 1 do
			p_boss_count = p_boss_count + 1
			local dice = math.random(1, 10000)
			-- chance_common = 4.00% + 1.00 * relic - 0
			if dice <= (400 + 100 * p_vault_relics - 0) then
				give_from_list(player, common_pool)
				
			end
			-- uncommon = 2.00% + 0.50 * relic - 5
			if p_vault_relics > 5 and dice <= (200 + 50 * (p_vault_relics - 5) ) then
				give_from_list(player, uncommon_pool)
			end
			-- chance_common = 1.00% + 0.25 * relic - 10
			if p_vault_relics > 10 and dice <= (100 + 25 * (p_vault_relics - 10) ) then
				give_from_list(player, rare_pool)
			end
		end
		p_boss_count = player:get("boss_count")
	end
end)

