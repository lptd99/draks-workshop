-- Creating new item

local model_item = Item("Director's Ring")
model_item.pickupText = ""
model_item.sprite = Sprite.load("sprites/items/director-s_ring.png", 1, 15, 15)
model_item:setTier("rare")
model_item:setLog{
	group = "uncommon",
	description = "The toughest, the fastest",
	story = "Dropped this item in a MMORPG, thought it'd be cool to have it on Risk of Rain too.",
	destination = "Unknown",
	date = "2025-03-19"
}
