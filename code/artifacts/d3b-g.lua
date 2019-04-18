local artifact = Artifact.new("D3B-G")
artifact.unlocked = true
artifact.loadoutSprite = Sprite.load("sprites/artifacts/d3b-g.png", 2, 18, 18)
artifact.loadoutText = "DEBUG YOUR MODS! (Infinite Health and Shield)"

registercallback("onPlayerInit", function(player)
    if artifact.active then
        player:set("maxhpcap", 5000)
        player:set("maxhp", 5000)
        player:set("maxshieldcap", 5000)
        player:set("maxshield", 5000)
        player:set("hp", 5000)
        player:set("shield", 5000)
    end
end, -10)