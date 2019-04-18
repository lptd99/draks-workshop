--terminal

local terminal = {}
local window = Cyclone.Window:new()
window.name = "Terminal"
window:resize(500,300)
window.body_color = Color.fromRGB(0,0,0)
window.icon = Cyclone.sprites["terminal"]
Cyclone.wmclient.registerWindow(window)

terminal.stack = {}
terminal.stack.mt = {}
terminal.stack.mt.__index = function() return "" end
setmetatable(terminal.stack, terminal.stack.mt)
terminal.stack_max = 200
terminal.stack_index = 1

terminal.command_stack = {}
terminal.command_stack.mt = {}
terminal.command_stack.mt.__index = function() return "" end
setmetatable(terminal.command_stack, terminal.command_stack.mt)
terminal.command_stack_max = 200
terminal.command_stack_index = 1
terminal.command_stack_current = 0

terminal.prompt = ""
terminal.input = ""
terminal.active = false
terminal.caps = false
terminal.shift = false

terminal.clipboard = ""

terminal.fs = {}
function terminal.writeFile(name, file) terminal.fs[name] = file end
function terminal.readFile(name) return terminal.fs[name] end

terminal.custom = nil
function terminal.enableCustom(name)
	terminal.custom = name
end
function terminal.disableCustom() terminal.custom = nil end

terminal.bin = {}

registercallback("onStageEntry", function()
	terminal.changePrompt("(".. tostring(misc.players[1]:getSurvivor():getName()) .."@" .. Stage.getCurrentStage():getName() .. "): ")
end)

function terminal.parseArgs(command, literal)
	--[=[
	local _args = {}
	local _i=0
	for _arg in command:gmatch("%S+") do
		_args[_i] = _arg
		_i = _i + 1
	end
	return _args
	--]=]
	
	local _args = {}
	local _i = 0
	local literal = literal or false
	local _string = ""
	for i=1,#command do
		local _char = command:sub(i,i)
		if literal then
			if (_char == "\"") and (command:sub(i-1,i-1) ~= "\\") then literal = false
			else _string = _string .. _char end
		elseif _char:find("%s") then
			if _string:find("%S") then _args[_i] = _string ; _string = "" ; _i = _i + 1 end
		elseif (_char == "\"") and (command:sub(i-1,i-1) ~= "\\") then
			if _string:find("%S") then _args[_i] = _string ; _string = "" ; _i = _i + 1 end
			literal = true
		else _string = _string .. _char
		end
	end
	if _string:find("%S") then _args[_i] = _string ; _string = "" ; _i = _i + 1 end
	return _args
end

function terminal.changePrompt(prompt)
	terminal.input = terminal.input:sub(#terminal.prompt)
	terminal.prompt = prompt
	terminal.input = prompt .. terminal.input
end

function terminal.getInput()
	return Cyclone.input.text, Cyclone.input.BCK, Cyclone.input.RET
end

local function renderStack()
	window:clear()
	local _text = nil
	local _height = 0
	for i=1,terminal.stack_max do
		if _height < (window.surface_boundaries.h * Cyclone.sc) and terminal.stack[terminal.stack_index - i] ~= nil then
			_text = Cyclone.Text:new()
			_text.lock_width = window.surface_boundaries.w * Cyclone.sc
			_text.contents = terminal.stack[terminal.stack_index - i]
			if string.find(terminal.stack[terminal.stack_index - i], terminal.prompt, 1, true) ~= nil then
				_text.color = Color.fromRGB(0,200,0)
			else
				_text.color = Color.fromRGB(220,220,220)
			end
			_text.x = 0
			_text.y = window.surface_boundaries.h * Cyclone.sc - _height - _text.boundaries.h - 14
			_height = _height + _text.boundaries.h
			window:addElement(_text)
		end
	end
	_text = Cyclone.Text:new()
	_text.contents = terminal.input
	_text.lock_width = window.surface_boundaries.w * Cyclone.sc
	_text.color = Color.fromRGB(0,255,0)
	_text.y = window.surface_boundaries.h * Cyclone.sc - 14
	window:addElement(_text)
	
	local _button = Cyclone.Button:new()
	_text = Cyclone.Text:new()
	_text.contents = "  "
	_button.text = _text
	_button.x = window:getSurfaceBoundaries().w - _button.boundaries.w
	_button.id = "Lock"
	_button.name = "Lock"
	_button.y = window:getSurfaceBoundaries().h - _button.boundaries.h
	_button.color = Color.fromRGB(50,0,0)
	_button.highlightcolor = Color.fromRGB(255,0,0)
	if terminal.active then _button.highlighted = true end
	window:addElement(_button)
end

window.update = function()
	if terminal.custom == nil then
		local _input, _back, _enter = Cyclone.input.text, Cyclone.input.BCK, Cyclone.input.RET
		terminal.input = terminal.input .. _input
		if Cyclone.input.UP then
			terminal.command_stack_current = terminal.command_stack_current + 1
			terminal.input = terminal.prompt .. terminal.command_stack[terminal.command_stack_index - terminal.command_stack_current]
		end
		if Cyclone.input.DOWN then
			terminal.command_stack_current = terminal.command_stack_current - 1
			terminal.input = terminal.prompt .. terminal.command_stack[terminal.command_stack_index - terminal.command_stack_current]
		end
		if _back and (#terminal.input > #terminal.prompt) then terminal.input = terminal.input:sub(1,-2) end
		if _enter then terminal.send() end
		
		renderStack()
		
	else
		terminal.bin[terminal.custom].update(window)
	end
end

function terminal.add(bin)
	terminal.bin[bin.name] = bin
end

function terminal.send()
	terminal.write(terminal.input)
	terminal.input = terminal.input:sub(#terminal.prompt + 1)
	local args = terminal.parseArgs(terminal.input)
	local _raw = terminal.input
	
	terminal.command_stack[terminal.command_stack_index] = _raw
	if terminal.command_stack_index > terminal.command_stack_max then	
		terminal.command_stack[terminal.command_stack_index - terminal.command_stack_max] = nil
	end
	terminal.command_stack_index = terminal.command_stack_index + 1
	terminal.command_stack_current = 0
	
	terminal.input = terminal.prompt
	for k,v in pairs(terminal.bin) do
		if args[0] == v.name then
			v.call(args, _raw)
		end
	end
	
	
end

function terminal.source(command)
	terminal.write(command)
	local args = terminal.parseArgs(command)
	for k,v in pairs(terminal.bin) do
		if args[0] == v.name then
			v.call(args, command)
		end
	end
end

function terminal.activate() if not terminal.active then terminal.active = true ; Cyclone.pause() end end
function terminal.deactivate() if terminal.active then terminal.active = false ; Cyclone.unpause() end end
function terminal.toggle() if terminal.active then terminal.deactivate() else terminal.activate() end end

function terminal.write(...)
	local args = {...}
	terminal.stack[terminal.stack_index] = ""
	for k,v in pairs(args) do
		terminal.stack[terminal.stack_index] = terminal.stack[terminal.stack_index] .. tostring(v)
	end
	if terminal.stack_index > terminal.stack_max then	
		terminal.stack[terminal.stack_index - terminal.stack_max] = nil
	end
	terminal.stack_index = terminal.stack_index + 1
end

Cyclone.wmclient.registerEvent(window, "button", function(id, name)
	if name == "Lock" then if terminal.active then terminal.deactivate() else terminal.activate() end end
end)

export("Cyclone.terminal", terminal)
export("Cyclone.terminal.window", window)
export("Cyclone.w",terminal.write)