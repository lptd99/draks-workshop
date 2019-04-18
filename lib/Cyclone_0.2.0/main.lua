--Cyclone

--Dependencies :
--  CycloneLib


--The Cyclone Library
require("CycloneLib/CycloneLib")


--###############--
-- Compatibility --
--###############--
--[[
local _Cyclone = Cyclone
local _CycloneMT = {}
_CycloneMT.__index = CycloneLib
setmetatable(_Cyclone,_CycloneMT)
export("Cyclone",_Cyclone)
--]]

--Resources and their exports
local resources = require("res/res")
export("Cyclone.resources", resources)
export("Cyclone.sprites", resources.sprites)

--Options and exports.
local options = require("options")
export("Cyclone.options", options)

--Fixes for several annoyances and bugs.
require("lin/fix")

--Pause functionality and graphics variables.
local updatePause = require("lin/pause")
export("Cyclone.sc", misc.getOption("video.scale"))
registercallback("preStep", function() export("Cyclone.sc", misc.getOption("video.scale")) ; updatePause() end)

--Fontmap
local fontmap   = require("etc/fontmap")   ; export("Cyclone.fontmap", fontmap)

--GUI Classes
require("lib/Text")
require("lib/Button")
require("lib/Window")

--GUI/Util Binaries
require("bin/creator")
require("bin/wmserver")
require("bin/terminal")

--Terminal Binaries
for k,v in pairs(require("etc/terminalrc")) do
	require("bin/"..v)
end


--#########--
-- Updates --
--#########--

local t = 0
registercallback("onStep", function() t = t + 1 end)
registercallback("onGameStart", function() t = 0 end)

registercallback("onStep", function() Cyclone.wmserver.update() end)
registercallback("onHUDDraw", function() Cyclone.wmserver.render() end)

local _pos = {} ; _pos.x = 0 ; _pos.y = 0 ; _pos.fade = 0
local _oldpos = {}
export("Cyclone.pos", _pos)
export("Cyclone.getPos", function() return _pos.x, _pos.y end)
registercallback("onStep", function()
	_pos = Cyclone.pos
	if input.checkMouse("right") == 3 then _pos.x, _pos.y = input.getMousePos() end
	if (_oldpos.x == _pos.x) and (_oldpos.y == _pos.y) then _pos.fade = _pos.fade - 1
	else _pos.fade = options["fade-cursor"] * 60 end
	export("Cyclone.pos",_pos)
	_oldpos.x = _pos.x
	_oldpos.y = _pos.y
end)
registercallback("onStageEntry", function()
	_pos.x, _pos.y = misc.players[1].x, misc.players[1].y - 2
	export("Cyclone.pos",_pos)
end)
registercallback("onDraw", function()
	if not (_pos.fade == 0) then
		local _alpha = 1
		if not (options["fade-cursor"] < 0) then _alpha = math.clamp(_pos.fade / 60,0,1) end
		graphics.drawImage{
			image = resources.sprites["cursor"],
			subimage = 1,
			x = _pos.x,
			y = _pos.y,
			alpha = _alpha
		}
	end
end)