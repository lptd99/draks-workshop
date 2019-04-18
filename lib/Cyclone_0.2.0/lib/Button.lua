--Button
--	Cyclone.Text

--	Meta (var[object])

local Button = {}
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

mt.__tostring = function() return "Button" end

--	Def (def.<keyname> = <value>)

def.text = nil
def.x = 0
def.y = 0
def.spacing_x = 0
def.spacing_y = 0
def.id = 0
def.name = ""
def.color = Color.fromRGB(150,150,150)
def.highlightcolor = Color.fromRGB(100,100,100)
def.boundaries = Cyclone.Rectangle:new()

def.ALIGNPOSITIVE = 2
def.ALIGNCENTER = 1
def.ALIGNNEGATIVE = 0

def.align_h = def.ALIGNCENTER
def.align_v = def.ALIGNCENTER

def.highlighted = false

--	Get (get.<keyname> = function(self) return <value> end)(var[self].<keyname>)

get.boundaries = function(self)
	self:refresh()
	return var[self].boundaries
end

--	Set (set.<keyname> = function(self, value)  end)(var[self].<keyname>)

set.text = function(self, value) var[self].text = value ; self:refresh() end
set.spacing_x = function(self, value) var[self].spacing_x = value ; self:refresh() end
set.spacing_y = function(self, value) var[self].spacing_y = value ; self:refresh() end
set.x = function(self, value) var[self].boundaries.x = value ; var[self].x = value ; self:refresh() end
set.y = function(self, value) var[self].boundaries.y = value ; var[self].y = value ; self:refresh() end
set.color = function(self, value) var[self].color = value ; var[self].boundaries.color = value end
set.name = function(self, value) var[self].name = tostring(value) end
set.highlightcolor = function(self, value) var[self].highlightcolor = value end
set.highlighted = function(self, value) var[self].highlighted = value end
set.id = function(self, value) var[self].id = value end

--	Constructor

function Button:new()
	local object = {}
	setmetatable(object, mt)
	var[object] = {}
	setmetatable(var[object], def)
	return object
end

--	Functions/Methods (def:<keyname> = function()  end)(var[self].<keyname>)

function def:refresh()
	if var[self].text then
		var[self].boundaries = Cyclone.Rectangle:new()
		var[self].boundaries.x = var[self].x
		var[self].boundaries.y = var[self].y
		var[self].boundaries.w = var[self].text.boundaries.w + (2 * var[self].spacing_x)
		var[self].boundaries.h = var[self].text.boundaries.h + (2 * var[self].spacing_y)
		var[self].boundaries.color = var[self].color
		self:align{h = var[self].align_h, v = var[self].align_v}
	else
		var[self].boundaries = Cyclone.Rectangle:new()
		var[self].boundaries.x = var[self].x
		var[self].boundaries.y = var[self].y
		var[self].boundaries.w = (2 * var[self].spacing_x)
		var[self].boundaries.h = (2 * var[self].spacing_y)
		var[self].boundaries.color = var[self].color
	end
end

function def:align(alignment)
	local alignment = alignment or {}
	alignment.h = alignment.h or var[self].align_h
	alignment.v = alignment.v or var[self].align_v
	if var[self].text then
		var[self].text.x = var[self].x + (alignment.h * var[self].spacing_x)
		var[self].text.y = var[self].y + (alignment.v * var[self].spacing_y)
	end
	var[self].align_h = alignment.h
	var[self].align_v = alignment.v
end

--	Modloader

function def:draw()
	if var[self].highlighted then var[self].boundaries.color = var[self].highlightcolor end
	var[self].boundaries:draw()
	if var[self].highlighted then var[self].boundaries.color = var[self].color ; var[self].highlighted = false end
	if var[self].text then var[self].text:draw() end
end

export("Cyclone.Button",Button)