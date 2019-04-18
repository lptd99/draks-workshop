--creator

local cr = {}

local function longest(buttons)
	local _longest = 0
	for k,v in pairs(buttons) do
		if _longest < v.boundaries.w then _longest = v.boundaries.w end
	end
	return _longest
end

function cr.menuFromTable(contents, window)
	local _contents = contents or {}
	local _count = 0
	for k,v in pairs(contents) do _count = _count + 1 end
	if _count == 0 then contents[1] = "Empty" end
	
	local _buttons = {}
	local _button = nil
	local _text = nil
	local _x = 0
	local _y = 0
	local _height = 10
	local _width = 10
	_buttons[_x] = {}
	
	for k,v in pairs(_contents) do
		if _height >= 500 then
			_width = _width + longest(_buttons[_x]) + 10
			_x = _x + 1
			_buttons[_x] = {}
			_height = 10
			_y = 0
		end
		_text = Cyclone.Text:new()
		_button = Cyclone.Button:new()
		_text.contents = tostring(v)
		_button.name = tostring(v)
		_button.text = _text
		_button.id = k
		_button.spacing_x = 5
		_button.spacing_y = 5
		_button.x = _width
		_button.y = 10 + _y * (_button.boundaries.h + 5)
		_height = _height + _button.boundaries.h + 5
		_buttons[_x][_y] = _button
		_y = _y + 1
	end
	local _window = window or (Cyclone.Window:new())
	_window:clear()
	for k,v in pairs(_buttons) do
		for _k, _v in pairs(v) do
			_window:addElement(_v)
		end
	end
	_height = 10
	for k,v in pairs(_buttons[0]) do
		_height = _height + v.boundaries.h + 5
	end
	_window:resize(_width + longest(_buttons[_x]) + 10, _height + 10)
	return _window
end

export("Cyclone.cr", cr)