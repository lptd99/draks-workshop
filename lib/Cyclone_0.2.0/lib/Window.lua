--Window

--	Meta (var[object])

local Window = {}
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

mt.__tostring = function() return "Window" end

--	Def (def.<keyname> = <value>)

def.surface = nil
def.surface_boundaries = nil
def.body_color = Color.fromRGB(200,200,200)
def.body_elements = nil
def.title_boundaries = nil
def.title_color = Color.fromRGB(0,0,0)
def.controls_minimize_boundaries = nil
def.controls_close_boundaries = nil
def.name = ""
def.update = function() end
def.icon = nil

def.CONTROLSTITLE = 1
def.CONTROLSSIDE = 2
def.CONTROLSEXTEND = 3
def.controls_style = def.CONTROLSTITLE

def.title_hidden = false
def.hollow = false

def.controls_close_highlight = 0
def.controls_minimize_highlight = 0

def.surface_fixed = nil
def.panx = 0
def.pany = 0
def.lock_pan = false


--	Get (get.<keyname> = function(self) return <value> end)(var[self].<keyname>)

get.surface_boundaries = function(self) return self:getSurfaceBoundaries(true) end
get.body_elements = function(self) if var[self].body_elements ~= nil then return var[self].body_elements else return {} end end

--	Set (set.<keyname> = function(self, value)  end)(var[self].<keyname>)

set.name = function(self, value) var[self].name = value end
set.controls_close_highlight = function(self, value) var[self].controls_close_highlight = math.ceil(math.clamp(value, 0,1)) end
set.controls_minimize_highlight = function(self, value) var[self].controls_minimize_highlight = math.ceil(math.clamp(value, 0,1)) end
set.update = function(self, value) var[self].update = value end
set.title_hidden = function(self, value) var[self].title_hidden = value end
set.hollow = function(self, value) var[self].hollow = value end
set.body_color = function(self, value) var[self].body_color = value end
set.icon = function(self,value) var[self].icon = value end
set.lock_pan = function(self,value) var[self].lock_pan = value end

--	Constructor

function Window:new()
	local object = {}
	setmetatable(object, mt)
	var[object] = {}
	setmetatable(var[object], def)
	
	var[object].surface_boundaries = Cyclone.Rectangle:new()
	var[object].title_boundaries = Cyclone.Rectangle:new()
	var[object].controls_close_boundaries = Cyclone.Rectangle:new()
	var[object].controls_minimize_boundaries = Cyclone.Rectangle:new()
	
	return object
end

--	Functions/Methods (def:<keyname> = function()  end)(var[self].<keyname>)

function def:pan(x,y,relative)
	local _relative = relative or false
	if _relative then
		var[self].panx = var[self].panx + x
		var[self].pany = var[self].pany + y
	else
		var[self].panx = x
		var[self].pany = y
	end
end

function def:getSurfaceBoundaries(scaled)
	local _scaled = scaled or false
	local _boundaries = Cyclone.Rectangle:new()
	if _scaled then
		_boundaries.x = var[self].surface_boundaries.x / Cyclone.sc
		_boundaries.y = var[self].surface_boundaries.y / Cyclone.sc
		_boundaries.w = var[self].surface_boundaries.w / Cyclone.sc
		_boundaries.h = var[self].surface_boundaries.h / Cyclone.sc
	else
		_boundaries.x = var[self].surface_boundaries.x
		_boundaries.y = var[self].surface_boundaries.y
		_boundaries.w = var[self].surface_boundaries.w
		_boundaries.h = var[self].surface_boundaries.h
	end
	return _boundaries
end

function def:addElement(element)
	if var[self].body_elements == nil then var[self].body_elements = {} end
	if element ~= nil and type(element) == "function" then
		local _drawable = {}
		_drawable.draw = element
		table.insert(var[self].body_elements, _drawable)		
	elseif element.draw ~= nil and type(element.draw) == "function" then
		table.insert(var[self].body_elements, element)
	end
end

function def:clear()
	var[self].body_elements = {}
end

--	Modloader

function def:refreshWindow()
	if var[self].surface_boundaries.w < 10 then var[self].surface_boundaries.w = 10 end
	if var[self].surface_boundaries.h < 10 then var[self].surface_boundaries.h = 10 end
	if type(var[self].surface) == "Surface" then var[self].surface:free() end
	if type(var[self].surface_fixed) == "Surface" then var[self].surface_fixed:free() end
	var[self].surface = Surface.new(1000,1000)
	var[self].surface_fixed = Surface.new(var[self].surface_boundaries.w, var[self].surface_boundaries.h)
	var[self].controls_close_boundaries.w = 30 * (1/Cyclone.sc)
	var[self].controls_close_boundaries.h = 22 * (1/Cyclone.sc)
	var[self].controls_minimize_boundaries.w = 30 * (1/Cyclone.sc)
	var[self].controls_minimize_boundaries.h = 22 * (1/Cyclone.sc)
end

function def:move(x,y,relative)
	local relative = relative or false
	var[self].surface_boundaries:move(x,y,relative)
	self:refreshWindow()
end

function def:resize(w,h,relative)
	local _relative = relative or false
	if _relative then
		if (var[self].surface_boundaries.w + w) > 0 and (var[self].surface_boundaries.h + h) > 0 then
			var[self].surface_boundaries.w = var[self].surface_boundaries.w + w
			var[self].surface_boundaries.h = var[self].surface_boundaries.h + h
			self:refreshWindow()
		end
	else
		if w > 0 and h > 0 then
			var[self].surface_boundaries.w = w
			var[self].surface_boundaries.h = h
			self:refreshWindow()
		end
	end
end

function def:refresh()
	if Surface.isValid(var[self].surface) and Surface.isValid(var[self].surface_fixed) then
		var[self].surface:clear()
		var[self].surface_fixed:clear()
		graphics.setTarget(var[self].surface)
		
		for k,v in pairs(self.body_elements) do
			if type(v) == "function" then v()
			else v:draw() end
		end
		
		graphics.resetTarget()
	else
		self:refreshWindow()
	end
	var[self].title_boundaries.x = (var[self].surface_boundaries.x) / Cyclone.sc
	var[self].title_boundaries.y = (var[self].surface_boundaries.y - Cyclone.sprites["controls"].height) / Cyclone.sc
	var[self].title_boundaries.w = (var[self].surface_boundaries.w) / Cyclone.sc
	var[self].title_boundaries.h = Cyclone.sprites["controls"].height / Cyclone.sc
	var[self].title_boundaries.color = var[self].bgtitle_color
end

function def:draw()
	self:refresh()
	self:display()
end

function def:display()
	if Surface.isValid(var[self].surface) and Surface.isValid(var[self].surface_fixed) then
		graphics.setTarget(var[self].surface_fixed)
		if not var[self].hollow then
			local _fill = Cyclone.Rectangle:new()
			_fill.w = var[self].surface_boundaries.w
			_fill.h = var[self].surface_boundaries.h
			_fill.color = var[self].body_color
			_fill:draw()
			_fill = nil
		end
		graphics.drawImage{
			image = var[self].surface,
			x = var[self].panx,
			y = var[self].pany,
		}
		--[=[
		graphics.drawImage{
			image = var[self].surface,
			x = var[self].surface_boundaries.x * (1/Cyclone.sc),
			y = var[self].surface_boundaries.y * (1/Cyclone.sc),
			scale = (1/Cyclone.sc)
		}
		--]=]
		graphics.resetTarget()
		graphics.drawImage{
			image = var[self].surface_fixed,
			x = var[self].surface_boundaries.x * (1/Cyclone.sc),
			y = var[self].surface_boundaries.y * (1/Cyclone.sc),
			scale = (1/Cyclone.sc)
		}
		if not var[self].title_hidden then
			var[self].title_boundaries:draw()
			local _title = Cyclone.Text:new()
			_title.contents = var[self].name
			_title.scale = (1/Cyclone.sc)
			_title.lock_cut = true
			_title.x = var[self].title_boundaries.x + 4/Cyclone.sc
			_title.y = var[self].title_boundaries.y + 4/Cyclone.sc
			if ((var[self].title_boundaries.w < var[self].controls_close_boundaries.w + var[self].controls_minimize_boundaries.w + 20) or (var[self].controls_style == self.CONTROLSEXTEND)) and (not (var[self].controls_style == self.CONTROLSSIDE)) then
				var[self].controls_close_boundaries.x = var[self].title_boundaries.right + (30 * (1/Cyclone.sc))
				var[self].controls_close_boundaries.y = var[self].title_boundaries.y
				var[self].controls_minimize_boundaries.x = var[self].title_boundaries.right
				var[self].controls_minimize_boundaries.y = var[self].title_boundaries.y
				graphics.drawImage{
					image = Cyclone.sprites["controls"],
					x = var[self].controls_minimize_boundaries.centerx,
					y = var[self].controls_minimize_boundaries.centery,
					subimage = 1 + var[self].controls_minimize_highlight,
					scale = (1/Cyclone.sc)
				}
				graphics.drawImage{
					image = Cyclone.sprites["controls"],
					x = var[self].controls_close_boundaries.centerx,
					y = var[self].controls_close_boundaries.centery,
					subimage = 3 + var[self].controls_close_highlight,
					scale = (1/Cyclone.sc)
				}
			elseif var[self].controls_style == self.CONTROLSSIDE then
				var[self].controls_close_boundaries.x = var[self].title_boundaries.right
				var[self].controls_close_boundaries.y = var[self].title_boundaries.y
				var[self].controls_minimize_boundaries.x = var[self].title_boundaries.right
				var[self].controls_minimize_boundaries.y = var[self].title_boundaries.y + (22 * (1/Cyclone.sc))
				graphics.drawImage{
					image = Cyclone.sprites["controls"],
					x = var[self].controls_close_boundaries.centerx,5,
					y = var[self].controls_close_boundaries.centery,
					subimage = 3 + var[self].controls_close_highlight,
					scale = (1/Cyclone.sc)
				}
				graphics.drawImage{
					image = Cyclone.sprites["controls"],
					x = var[self].controls_minimize_boundaries.centerx,
					y = var[self].controls_minimize_boundaries.centery,
					subimage = 1 + var[self].controls_minimize_highlight,
					scale = (1/Cyclone.sc)
				}
			else
				var[self].controls_close_boundaries.x = var[self].title_boundaries.right - (30 * (1/Cyclone.sc))
				var[self].controls_close_boundaries.y = var[self].title_boundaries.y
				var[self].controls_minimize_boundaries.x = var[self].title_boundaries.right - (60 * (1/Cyclone.sc))
				var[self].controls_minimize_boundaries.y = var[self].title_boundaries.y
				graphics.drawImage{
					image = Cyclone.sprites["controls"],
					x = var[self].controls_minimize_boundaries.centerx,
					y = var[self].controls_minimize_boundaries.centery,
					subimage = 1 + var[self].controls_minimize_highlight,
					scale = (1/Cyclone.sc)
				}
				graphics.drawImage{
					image = Cyclone.sprites["controls"],
					x = var[self].controls_close_boundaries.centerx,
					y = var[self].controls_close_boundaries.centery,
					subimage = 3 + var[self].controls_close_highlight,
					scale = (1/Cyclone.sc)
				}
			end
			var[self].controls_close_highlight = 0
			var[self].controls_minimize_highlight = 0
			_title.lock_width = math.clamp(var[self].title_boundaries.w - var[self].controls_close_boundaries.w - var[self].controls_minimize_boundaries.w - 15,4,50000)
			_title.color = var[self].title_color
			_title:draw()
		end
	else
		self:refreshWindow()
	end
end

export("Cyclone.Window",Window)