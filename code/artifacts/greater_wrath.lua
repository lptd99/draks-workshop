local artifact = Artifact.new("Greater Wrath")
artifact.unlocked = true
artifact.loadoutSprite = Sprite.load("sprites/artifacts/greater_wrath.png", 2, 18, 18)
artifact.loadoutText = "Every 15 seconds, you get a random Common item and a Boss spawns."

local t = 0

local common_pool = ItemPool.find("common", "vanilla")

registercallback("onGameStart", function()
    t = 0
end)

registercallback("onPlayerStep", function(player)
	if artifact.active then
		local director = misc.director
		if t==(15*60) then
			player:giveItem(common_pool:roll())
			director:set("spawn_boss", 1)
			director:set("points", director:get("points")+800)
			t = 0
		else
			t = t + 1
		end
	end
end)
