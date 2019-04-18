--Rectangle

--Dependencies :
--  CycloneLib-Res
--  CycloneLib-Util


--######--
-- Meta --
--######--

local Rectangle = {}
local mt = {}
local get = {}
local set = {}
local var = {}
local def = {}
def.__index = def

mt.__index = function(self, key)
	if get[key] ~= nil then return get[key](self) else return var[self][key] end
end

mt.__newindex = function(self, key, value)
	if set[key] ~= nil then set[key](self, value) end
end

mt.__tostring = function() return "Rectangle" end


--#####--
-- Def --
--#####--

def.x = 0
def.y = 0
def.w = 0
def.h = 0
def.color = Color.fromRGB(255,255,255)
def.alpha = 1


--#####--
-- Get --
--#####--

get.top = function(self) return var[self].y end
get.bottom = function(self) return var[self].y + var[self].h end
get.left = function(self) return var[self].x end
get.right = function(self) return var[self].x + var[self].w end
get.centerx = function(self) return (var[self].x + var[self].w/2) end
get.centery = function(self) return (var[self].y + var[self].h/2) end


--#####--
-- Set --
--#####--

set.x = function(self, value) var[self].x = value end
set.y = function(self, value) var[self].y = value end
set.w = function(self, value) var[self].w = value end
set.h = function(self, value) var[self].h = value end
set.color = function(self, value) var[self].color = value end
set.alpha = function(self, value) var[self].alpha = value end


--#############--
-- Constructor --
--#############--

function Rectangle:new()
	local object = {}
	setmetatable(object, mt)
	var[object] = {}
	setmetatable(var[object], def)
	return object
end


--###################--
-- Functions/Methods --
--###################--

--Moves the rectangle to the given position.
--Translates it relative to its current position if relative is true.
function def:move(x,y,relative)
	local relative = relative or false
	if relative then
		var[self].x = var[self].x + x
		var[self].y = var[self].y + y
	else
		var[self].x = x
		var[self].y = y
	end
end

--Checks if it intersects another rectangle.
function def:intersectsRectangle(rectangle)
	if
	(
	self.x < rectangle.x + rectangle.w and
	self.x + self.w > rectangle.x and
	self.y < rectangle.y + rectangle.h and
	self.y + self.h > rectangle.y
	)
	then return true else return false end
end

--Checks if it intersects the given point.
function def:intersectsPoint(x,y)
	if
	(
	x > self.x and
	x < self.x + self.w and
	y > self.y and
	y < self.y + self.h
	)
	then return true else return false end
end

--Enlarges the rectangle without moving its center.
function def:extrude(w,h)
	var[self].x = var[self].x - w/2
	var[self].y = var[self].y - h/2
	var[self].w = w
	var[self].h = h
end


--###########--
-- Modloader --
--###########--

--Matches the rectangle to the position and size of the given instance.
--Uses the sprite if set with fromsprite or mask is not found.
function def:fromInstance(i, fromsprite)
	if not i:isValid() then return nil end
	local fromsprite = fromsprite or false
	local _s = nil
	if not fromsprite then _s = i.mask
		if _s == nil then _s = i.sprite end
		if _s == nil then return nil end
	else _s = i.sprite end
	var[self].w = math.abs(_s.width * i.xscale)
	var[self].h = math.abs(_s.height * i.yscale)
	var[self].x = i.x - var[self].w/2
	var[self].y = i.y - var[self].h/2
end

--Checks if the rectangle intersects the given instance.
function def:intersectsInstance(i)
	if i:isValid() then
		return CycloneLib.util.intersectsWith(i,
			var[self].x,
			var[self].y,
			var[self].w,
			var[self].h
		)
	end
end

--Draws the rectangle
function def:draw(color, alpha)
	graphics.drawImage{
		image = CycloneLib.sprites["emptyStandard"],
		x = var[self].x,
		y = var[self].y,
		width = var[self].w,
		height = var[self].h,
		color = color or var[self].color,
		alpha = alpha or var[self].alpha
	}
end


--#########--
-- Exports --
--#########--

export("CycloneLib.Rectangle", Rectangle)