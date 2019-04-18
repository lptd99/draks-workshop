--vir

local vir = {}
vir.name = "vir"

local file = {}
local filename = "newfile"
local cursor = {}
local view = 1
cursor.x, cursor.y = 1,1
local mode = "n"
local message = ""
local command = ""
local clipboard = ""

vir.call = function(args)
	mode = "n"
	file = Cyclone.terminal.readFile(args[1])
	if file then filename = args[1]
	else filename = "newfile" ; file = {} end
	message = filename
	view = 1
	cursor.x, cursor.y = 1,1
	Cyclone.terminal.enableCustom("vir")
end

vir.terminate = function()
	Cyclone.terminal.disableCustom()
end

local function quit()
	vir.terminate()
end

local function toLua()
	_code = ""
	for i=1,#file do
		if file[i]:sub(1,2) ~= "--" then
			local _end = file[i]:match("%s(%S+)$")
			if _end and (_end == "do" or _end == "then" or _end:sub(-1,-1) == "(" or _end:sub(-1,-1) == ")") then
				_code = _code .. file[i] .. " "
			else
				_code = _code .. file[i] .. "; "
			end
		end
	end
	_code = _code:sub(1,-2)
	return _code
end

local function toLog()
	for i=1,#file do
		log(file[i])
	end
end

local function render(window)
	local _text = nil
	local _height = 0
	local _size = #file
	local _l = 2
	while _size > 10 do _size = math.floor((_size)/10) ; _l = _l + 1 end
	local i = 0
	
	local _charwidth = math.floor((window.surface_boundaries.w * Cyclone.sc - _l * 8) / 8)
	local _cx = (cursor.x-1)%(_charwidth-1)
	--local _cy = math.floor((cursor.x-1)/(_charwidth-1)) + cursor.y - 1
	
	while ((window.surface_boundaries.h * Cyclone.sc - 28) > _height) and ((view + i) <= #file) do
		if (view + i) == cursor.y then
			local _cursor = Cyclone.Rectangle:new()
			_cursor.color = Color.fromRGB(0,160,160)
			--_cursor.x = _cx * 8 + _l * 8
			--_cursor.y = (view + i - 1) * 14
			if cursor.x > #file[view + i] then
				_cursor.y = _height + (math.floor((cursor.x-1)/_charwidth) * 14)
				_cursor.x = ((cursor.x-1)%_charwidth) * 8 + 16
			else
				_cursor.y = _height + (math.floor(cursor.x/_charwidth) * 14)
				--_cursor.x = _cx * 8 + _l * 8
				_cursor.x = ((cursor.x)%_charwidth) * 8 + 8
			end
			_cursor.w = 8
			_cursor.h = 14
			window:addElement(_cursor)
		end
	
		_text = Cyclone.Text:new()
		_text.contents = tostring(view + i)
		_text.color = Color.fromRGB(200,200,0)
		_text.x = 0
		_text.y = _height
		window:addElement(_text)
		
		_text = Cyclone.Text:new()
		_text.contents = file[view + i]
		_text.lock_width = window.surface_boundaries.w * Cyclone.sc - _l * 8
		_text.color = Color.fromRGB(222,222,222)
		_text.x = _l * 8
		_text.y = _height
		_height = _height + _text.boundaries.h
		window:addElement(_text)
		
		i = i + 1
	end
	
	_text = Cyclone.Text:new()
	local _line = ""
	for i=0,((window.surface_boundaries.w * Cyclone.sc)/8) do
		_line = _line .. "-"
	end
	_text.lock_cut = true
	_text.contents = _line
	_text.color = Color.fromRGB(100,100,200)
	_text.y = window.surface_boundaries.h * Cyclone.sc - 28
	window:addElement(_text)
	
	_text = Cyclone.Text:new()
	_text.lock_width = window.surface_boundaries.w * Cyclone.sc
	_text.color = Color.fromRGB(100,100,222)
	_text.y = window.surface_boundaries.h * Cyclone.sc - 14
	if mode == "c" then _text.contents = ":" .. tostring(command)
	elseif mode == "n" then _text.contents = message
	elseif mode == "i" then _text.contents = "Insert"
	else _text.contents = "Error" end
	window:addElement(_text)
end

local function move(x,y,relative)
	local _relative = relative or false
	if _relative then
		cursor.y = math.clamp(cursor.y + y, 1, #file)
		cursor.x = math.clamp(cursor.x + x, 1, #file[cursor.y]+1)
	else
		cursor.y = math.clamp(y, 1, #file)
		cursor.x = math.clamp(x, 1, #file[cursor.y]+1)
	end
end

local function fileAppend(str)
	local _str = str or ""
	file[#file+1] = _str
end

local function fileInsert(line, str)
	local _str = str or ""
	table.insert(file, line, str)
end

local function fileDelete(line)
	table.remove(file,line)
	if #file == 0 then file[1] = "" end
end

local function movement(_input)
	if _input.LEFT  then move(-1,0,true) end
	if _input.RIGHT then move(1,0,true) end
	if _input.UP    then move(0,-1,true) end
	if _input.DOWN  then move(0,1,true) end
	if _input.END   then move(#file[cursor.y],cursor.y,false) end
	if _input.HOME  then move(1,cursor.y,false) end
end

vir.update = function(window)
	local _in = Cyclone.input
	if #file == 0 then file[1] = "" end
	
	if input.checkKeyboard("tab") == 3 then mode = "n" ; message = "" end
	if mode == "n" then
		movement(_in)
		if _in.text:find("i") ~= nil then mode = "i" end
		if _in.text:find(":") ~= nil then mode = "c" ; command = "" end
		if _in.text:find("y") ~= nil then clipboard = file[cursor.y] ; message = "Copied line" end
		if _in.text:find("p") ~= nil then fileInsert(cursor.y+1,clipboard) ; message = "Pasted line" end
		if _in.text:find("n") ~= nil then filename = file[cursor.y] ; message = "Filename is now " .. filename end
	elseif mode == "i" then
		if _in.text == "" then
			movement(_in)
		end
		if _in.text ~= "" then
			local _b, _a = file[cursor.y]:sub(0,cursor.x-1), (file[cursor.y]:sub(cursor.x,-1) or "")
			_b = _b .. _in.text
			file[cursor.y] = _b .. _a
			move(#_in.text,0,true)
		end
		if _in.BCK then
			local _b, _a = file[cursor.y]:sub(0,cursor.x-1), (file[cursor.y]:sub(cursor.x,-1) or "")
			if #_b > 0 then
				_b = _b:sub(1,-2)
				file[cursor.y] = _b .. _a
				move(-1,0,true)
			else
				if cursor.y > 1 then
					local _e = 1
					if file[cursor.y - 1] then _e = #file[cursor.y - 1] + 1 end
					file[cursor.y - 1] = file[cursor.y - 1] .. _a
					fileDelete(cursor.y)
					move(0,-1,true)
					move(_e,cursor.y,false)
				end
			end
		end
		if _in.DEL then
			local _b, _a = (file[cursor.y]:sub(0,cursor.x-1) or ""), (file[cursor.y]:sub(cursor.x,-1) or "")
			if #_a > 0 then
				_a = _a:sub(2,-1)
				file[cursor.y] = _b .. _a
			else
				if file[cursor.y + 1] then
					file[cursor.y] = file[cursor.y] .. file[cursor.y + 1]
					fileDelete(cursor.y + 1)
				end
			end
		end
		if _in.RET then
			local _b, _a = file[cursor.y]:sub(0,cursor.x-1), (file[cursor.y]:sub(cursor.x,-1) or "")
			fileInsert(cursor.y + 1,_a)
			file[cursor.y] = _b
			move(0,1,true)
		end
	elseif mode == "c" then
		command = command .. _in.text
		if _in.BCK then command = command:sub(1,-2) end
		if _in.RET then
			if command == "lua" then
				Cyclone.terminal.source("lua run " .. toLua())
				message = Cyclone.terminal.bin["lua"].errormessage or "Ran with lua"
			elseif command:sub(1,1) == "w" then
				if command:sub(3,-1) then filename = command:sub(3,-1) end
				toLog()
				Cyclone.terminal.writeFile(filename, file)
				message = "Saved to log and " .. filename
			elseif command == "q" then
				quit()
			elseif command == "tclip" then
				fileInsert(cursor.y + 1, Cyclone.terminal.clipboard)
			end
			command = ""
			mode = "n"
		end
	end
	
	window:clear()
	render(window)
end

Cyclone.terminal.add(vir)