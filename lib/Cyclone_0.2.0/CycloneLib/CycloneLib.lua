--CycloneLib

--Dependencies :
--  Nothing


--Resources that are used in the library.
local resources = require("CycloneLib/res/res")

--Resource exports.
export("CycloneLib.resources", resources)
export("CycloneLib.sprites", resources.sprites)

--The keys that ML/GM uses.
local keys, keymap, shiftkeys = require("CycloneLib/util/keys")
export("CycloneLib.keys", keys)
export("CycloneLib.keymap", keymap)
export("CycloneLib.shiftkeys", shiftkeys)

--Utility functions and tools.
require("CycloneLib/util/util")
require("CycloneLib/util/input")

--Classes
require("CycloneLib/classes/Rectangle")
require("CycloneLib/classes/Vector2")

--Libraries
require("CycloneLib/libraries/Projectile")
require("CycloneLib/libraries/ForceBuff")


--###############--
-- Compatibility --
--###############--

local _Cyclone = Cyclone or {}
local _CycloneMT = {}
_CycloneMT.__index = CycloneLib
setmetatable(_Cyclone,_CycloneMT)
export("Cyclone",_Cyclone)

--!!!!
--TODO Add dir to files
--TODO Add dependencies to files
--!!!!