local artifact = Artifact.new("Inferno")
artifact.unlocked = true
artifact.loadoutSprite = Sprite.load("sprites/artifacts/hell_mode.png", 2, 18, 18)
artifact.loadoutText = "Every time you hit an enemy, The Director gets 100 points."

registercallback("onHit", function(damager)
	if artifact.active then
		if damager:get("team") == "player" then
			local director = misc.director
			director:set("points", director:get("points") + 100)
			director_points = director:get("points")
		end
	end
end)


registercallback("onPlayerStep", function()
	if misc.director:get("points") > 40000 then
		misc.director:set("points", 10000)
	end
end)