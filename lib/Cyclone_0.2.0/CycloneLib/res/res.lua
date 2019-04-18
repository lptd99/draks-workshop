--CycloneLib-Res

--Dependencies :
--  Nothing


--The locations of the resources and the prefix that they will be created under.
local prefix = "CycloneLib_"
local dir = "CycloneLib/res/"

--Export/return variables.
local resources = {}
resources.sprites = {}

-- A 2x2 sprite that is empty and transparent.
resources.sprites["alpha"] = Sprite.load(prefix .. "alpha", dir .. "alpha.png", 1, 1,1)

-- A 2x2 sprite that is empty and transparent. Not centered
resources.sprites["alphaStandard"] = Sprite.load(prefix .. "alphaStandard", dir .. "alpha.png", 1, 1,1)

-- A 2x2 sprite with nothing but white.
resources.sprites["empty"] = Sprite.load(prefix .. "empty", dir .. "empty.png", 1, 1,1)

-- A 2x2 sprite with nothing but white. Not centered.
resources.sprites["emptyStandard"] = Sprite.load(prefix .. "emptyStandard", dir .. "empty.png", 1, 0,0)

return resources