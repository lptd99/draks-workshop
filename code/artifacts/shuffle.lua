local artifact = Artifact.new("Shuffle")
artifact.unlocked = true
artifact.loadoutSprite = Sprite.load("Artifacts/Shuffle.png", 2, 18, 18)
artifact.loadoutText = "Items are reshuffled upon stage entry."


common_pool = ItemPool.find("common", "vanilla")
uncommon_pool = ItemPool.find("uncommon", "vanilla")
rare_pool = ItemPool.find("rare", "vanilla")
boss_pool = ItemPool.new(boss)
boss_pool:add(Item.find("Burning Witness"))
boss_pool:add(Item.find("Colossal Knurl"))
boss_pool:add(Item.find("Ifrit's Horn"))
boss_pool:add(Item.find("Imp Overlord's Tentacle"))
boss_pool:add(Item.find("Legendary Spark"))

registered = {}


registercallback("onStageEntry", function()
	if artifact.active then
		for _, player in ipairs(misc.players) do
			for _, pool in ipairs({common_pool, uncommon_pool, rare_pool, boss_pool}) do
				local counter = 0
				for _, item in ipairs(pool:toList()) do
					if itemremover.getRemoval(item) then
						local num = player:countItem(item)
						for i = 1, num do
							itemremover.removeItem(player, item)
						end
						counter = counter + num
					end
				end
				for i = 1, counter do
					player:giveItem(pool:roll())
				end
			end
		end
	end
end)