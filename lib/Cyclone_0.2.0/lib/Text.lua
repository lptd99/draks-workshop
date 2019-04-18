--Text

--	Meta (var[object])

local Text = {}
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

mt.__tostring = function() return "Text" end

--	Def (def.<keyname> = <value>)

def.contents = ""
def.split = {}
def.lock_width = nil
def.lock_chars = 0
def.lock_cut = false
def.x = 0
def.y = 0
def.size = 14
def.scale = 1
def.alpha = 1
def.boundaries = Cyclone.Rectangle:new()
def.color = Color.fromRGB(0,0,0)

--	Get (get.<keyname> = function(self) return <value> end)(var[self].<keyname>)



--	Set (set.<keyname> = function(self, value)  end)(var[self].<keyname>)

set.contents = function(self, value)
	var[self].contents = value
	self:refresh()
end
set.x = function(self, value) var[self].x = value ; self:refreshBoundaries() end
set.y = function(self, value) var[self].y = value ; self:refreshBoundaries() end
set.size = function(self, value)
	var[self].size = value ; var[self].scale = value / 14
	self:refresh()
end
set.scale = function(self, value)
	var[self].scale = value ; var[self].size = value * 14
	self:refresh()
end
set.lock_width = function(self, value)
	var[self].lock_width = value
	self:refresh()
end
set.alpha = function(self, value) var[self].alpha = value end
set.color = function(self, value) var[self].color = value end
set.lock_cut = function(self, value) var[self].lock_cut = value end

--	Constructor

function Text:new()
	local object = {}
	setmetatable(object, mt)
	var[object] = {}
	setmetatable(var[object], def)
	return object
end

--	Functions/Methods (def:<keyname> = function()  end)(var[self].<keyname>)

function def.splitChars(split)
	local _chars = {}
	split:gsub(".", function(_char) table.insert(_chars, _char) end)
	return _chars
end

function def:refresh()
	if var[self].lock_width ~= nil then
		if var[self].lock_width <= 0 then
			var[self].split = {}
			var[self].split[1] = ""
			self:refreshBoundaries()
			return nil
		end
		var[self].lock_chars = math.floor((var[self].lock_width)/(8*var[self].scale))
		local _chars = def.splitChars(var[self].contents)
		local _split = 1
		var[self].split = {}
		var[self].split[_split] = ""
		for k,v in pairs(_chars) do
			if #var[self].split[_split] >= var[self].lock_chars then
				if not var[self].lock_cut then
					_split = _split + 1
					var[self].split[_split] = ""
					var[self].split[_split] = var[self].split[_split] .. v
				end
			else
				var[self].split[_split] = var[self].split[_split] .. v
			end
		end
	else
		var[self].split = {}
		var[self].split[1] = var[self].contents
	end
	self:refreshBoundaries()
end

function def:refreshBoundaries()
	var[self].boundaries = Cyclone.Rectangle:new()
	var[self].boundaries.w = #(var[self].split[1] or "") * Cyclone.sprites["font"].width * var[self].scale
	local _rows = 0
	for k,v in pairs(var[self].split) do
		_rows = _rows + 1
	end
	var[self].boundaries.h = _rows * 14 * var[self].scale
	var[self].boundaries.x = var[self].x
	var[self].boundaries.y = var[self].y
end

--	Modloader

function def:draw()
	local _chars = {}
	for k,v in pairs(var[self].split) do
		_chars[k] = def.splitChars(var[self].split[k])
	end
	local _fontsprite = Cyclone.sprites["font"]
	local _right = 0
	local _down = 0
	local _subimage = 1
	for k,v in pairs(_chars) do
		_right = 0
		for _k,_v in pairs(v) do
			if Cyclone.fontmap[_v] ~= nil then _subimage = Cyclone.fontmap[_v] else _subimage = 82 end
			if var[self].lock_cut and _down > 0 then _subimage = 83 end
			graphics.drawImage{
				image = _fontsprite,
				x = var[self].x + ((_right * 8) * var[self].scale),
				y = var[self].y + ((_down * 14) * var[self].scale),
				subimage = _subimage,
				scale = var[self].scale,
				color = var[self].color,
				alpha = var[self].alpha
			}
			_right = _right + 1
		end
		_down = _down + 1
	end
end

export("Cyclone.Text",Text)