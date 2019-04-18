--Creates a new artifact which changes the players X and Y position to be near the teleporter whenever the player spawns on a new stage
local artifact = Artifact.new("Ambush")
artifact.unlocked = true

--Retrieves the sprite of the artifact in the sprites folder, then gives an ingame description of said artifact.
artifact.loadoutSprite = Sprite.load("sprites/artifacts/ambush.png", 2, 18, 18)
artifact.loadoutText = "Spawn at the teleporter, event lasts twice as long."

--called whenever the player enters a new stage
registercallback("onStageEntry", function(actor)
	if artifact.active then
	--finds the teleporter object in GMObjects/vanilla objects
		local teleporter = Object.find("Teleporter", "vanilla")
		--gets the instance from the object we just named ourselves
		local teleInst = teleporter:find(1)
			if teleInst ~= nil then
			--this part of the code multiplies maxtime by 2, the maxtime is the amount of time the teleporter event takes
			--if this value was 0, the teleporter would be activated and instantly ready for the player to go to the next level
			teleInst:set("maxtime", teleInst:get("maxtime") * 1.5)
			--gets each specific player (each player in a multiplayer game is different) and makes the y value match the teleporter 
			--(7 is taken from the y value so the player doesnt get stuck in the ground)
			--the x value is randomized to be slightly more or less than the teleporter, just for easthetics sake
			for _, player in ipairs(misc.players) do
				player.x = teleInst.x + math.random(-20, 20)
				player.y = teleInst.y-7
				--if the first teleport spawns the player in a wall, we will loop again until we find a value that doesn't put them in a wall.
				while player:collidesMap(player.x,player.y) do
					player.x = teleInst.x + math.random(-20, 20)
					player.y = teleInst.y - 7
				end
			end
		end
	end
end)