local artifact = Artifact.new("Weak Glass")
artifact.unlocked = true
artifact.loadoutSprite = Sprite.load("sprites/artifacts/weak_glass.png", 2, 18, 18)
artifact.loadoutText = "True Glass, but bearable (max HP 25, max Shield 125)."

local commonItems = ItemPool.find("common", "vanilla")
local uncommonItems = ItemPool.find("uncommon", "vanilla")
local rareItems = ItemPool.find("rare", "vanilla")
local useItems = ItemPool.find("use", "vanilla")

if modloader.checkFlag("weak_glass_remove_items") then
    --removes all of these items if the flag "weak_glass_remove_items" exists.
    commonItems:remove(Item.find("Meat Nugget", "vanilla"))
    commonItems:remove(Item.find("First Aid Kit", "vanilla"))
    commonItems:remove(Item.find("Bitter Root", "vanilla"))
    commonItems:remove(Item.find("Bustling Fungus", "vanilla"))
    commonItems:remove(Item.find("Sprouting Egg", "vanilla"))
    commonItems:remove(Item.find("Monster Tooth", "vanilla"))
    commonItems:remove(Item.find("Mysterious Vial", "vanilla"))

    uncommonItems:remove(Item.find("Tough Times", "vanilla"))
    uncommonItems:remove(Item.find("Leeching Seed", "vanilla"))

    rareItems:remove(Item.find("Interstellar Desk Plant", "vanilla"))

    useItems:remove(Item.find("Massive Leech", "vanilla"))
    useItems:remove(Item.find("Foreign Fruit", "vanilla"))
end

registercallback("onPlayerInit", function(player)
    if artifact.active then
        player:set("maxhpcap", 25)
        player:set("maxshieldcap", 125)
    end
end, 1)