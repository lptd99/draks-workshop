--Cyclone_Example_Item_Window

local icon = Sprite.load("cycloneitems","items.png", 1,8,8)

local window = Cyclone.Window:new()
window.name = "Items"
window.icon = icon

local pools = {}
pools.common = ItemPool.find("common", "vanilla")
pools.uncommon = ItemPool.find("uncommon", "vanilla")
pools.rare = ItemPool.find("rare", "vanilla")
pools.use = ItemPool.find("use", "vanilla")

local items = {}
items["other"] = {}

local function refreshItems()
	local seen = {}
	for k,v in pairs(pools) do
		for _k,_v in pairs(v:toList()) do
			seen[_v] = true
			if not items[v:getName()] then items[v:getName()] = {} end
			table.insert(items[v:getName()],_v)
		end
	end
	for k,v in pairs(Cyclone.util.getNamespaces()) do
		for _k,_v in pairs(Item.findAll(v)) do if not seen[_v] then
				table.insert(items["other"],_v)
		end end
	end
	seen = nil
end

registercallback("onGameStart", refreshItems)

local _poolLength = 0
local _poolHeight = 0
local function renderPools()
	local _i = 0
	local _w = 0
	local _h = 0
	for k,v in pairs(pools) do
		local _text = Cyclone.Text:new()
		_text.contents = v:getName()
		local _button = Cyclone.Button:new()
		_button.text = _text
		_button.name = v:getName()
		_button.x = 10
		_button.y = _i * 20 + 10
		_button.spacing_x = 2
		_button.spacing_y = 2
		window:addElement(_button)
		_i = _i + 1
		if _button.boundaries.right > _w then _w = _button.boundaries.right end
		if _button.boundaries.bottom > _h then _h = _button.boundaries.bottom end
	end
	local _text = Cyclone.Text:new()
	_text.contents = "other"
	local _button = Cyclone.Button:new()
	_button.text = _text
	_button.name = "other"
	_button.x = 10
	_button.y = _i * 20 + 10
	_button.spacing_x = 2
	_button.spacing_y = 2
	window:addElement(_button)
	if _button.boundaries.right > _w then _w = _button.boundaries.right end
	if _button.boundaries.bottom > _h then _h = _button.boundaries.bottom end
	window:resize(_w+10,_h+10)
	_poolLength = _w + 10
	_poolHeight = _h + 10
end

local function renderItems(items)
	local _i = 0
	local _y = 0
	for k,v in pairs(items) do
		local _x = _i % 5
		_y = math.floor(_i/5)
		local _button = Cyclone.Button:new()
		_button.id = v:getName()
		_button.spacing_x = 34 / 2
		_button.spacing_y = 34 / 2
		_button.x = _x * 36 + _poolLength + 10
		_button.y = _y * 36 + 10
		local _itemdrawfunction = function()
			graphics.drawImage{
				image = v.sprite,
				x = _button.x + 34/2,
				y = _button.y + 34/2,
			}
		end
		window:addElement(_button)
		window:addElement(_itemdrawfunction)
		_i = _i + 1
	end
	if _poolHeight > (_y * 36 + 20 + 34) then
		window:resize(_poolLength + 5 * 36 + 20, _poolHeight)
	else
		window:resize(_poolLength + 5 * 36 + 20, (_y * 36 + 20 + 34))
	end
end

registercallback("onGameStart", function()
	window:clear()
	renderPools()
	renderItems(items["common"])
end)

Cyclone.wmclient.registerEvent(window,"button",function(id,name)
	if name == "other" or pools[name] then
		window:clear()
		renderPools()
		renderItems(items[name])
	else
		print(id)
		Cyclone.terminal.source("item give \"" .. id .. "\"")
	end
end)

Cyclone.wmclient.registerWindow(window)