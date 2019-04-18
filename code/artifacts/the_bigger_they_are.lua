local artifact = Artifact.new("The Bigger They Are...")
artifact.unlocked = true
artifact.loadoutSprite = Sprite.load("sprites/artifacts/the_bigger_they_are.png", 2, 18, 18)
artifact.loadoutText = "Every time you hit an enemy, The Director gets 1 point for each item you have."

local director_points
local players_items

registercallback("onItemPickup", function(player)
	players_items = player:get("item_count_total")
	if director_points == nil then director_points = 0 end
	player:set("attack_speed", director_points)
end)
registercallback("onHit", function(damager)
	if artifact.active then
		if damager:get("team") == "player" then
			local director = misc.director
			if players_items == nil then players_items = 0 end
			director:set("points", director:get("points") + players_items or 0)
			director_points = director:get("points")
		end
	end
end)
