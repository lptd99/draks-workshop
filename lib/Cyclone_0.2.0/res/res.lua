--Cyclone-Res

--Dependencies :
--  Nothing

--Locations and the load variables.
local dir = "res/"
local prefix = "Cyclone_"

--Export/return variables.
local resources = {}
resources.sprites = {}

--#########--
-- Sprites --
--#########--

resources.sprites["missing"]  = Sprite.load(prefix .. "missing"  , dir .. "missing.png", 1, 8,8)
resources.sprites["font"]     = Sprite.load(prefix .. "font"     , dir .. "cyclonefont.png", 93, 0,0)
resources.sprites["empty"]    = Sprite.load(prefix .. "empty"    , dir .. "empty.png", 1, 0,0)
resources.sprites["controls"] = Sprite.load(prefix .. "controls" , dir .. "controls.png", 4, 15,11)
resources.sprites["alpha"]    = Sprite.load(prefix .. "alpha"    , dir .. "alpha.png", 1 ,0,0)
resources.sprites["cursor"]   = Sprite.load(prefix .. "cursor"   , dir .. "cursor.png", 1, 8,8)
resources.sprites["terminal"] = Sprite.load(prefix .. "terminal" , dir .. "terminal.png", 1,8,8)

--#######################--
-- Compatibility Sprites --
--#######################--

Sprite.load("cyclonemissing", "res/missing.png", 1, 8,8)
Sprite.load("cyclonefont", "res/cyclonefont.png", 93, 0,0)
Sprite.load("cycloneempty", "res/empty.png", 1, 0,0)
Sprite.load("cyclonecontrols","res/controls.png", 4, 15,11)
Sprite.load("cyclonealpha", "res/alpha.png", 1 ,0,0)
Sprite.load("cyclonecursor", "res/cursor.png", 1, 8,8)
Sprite.load("cycloneterminal", "res/terminal.png", 1,8,8)

return resources