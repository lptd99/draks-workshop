--lua

local lua = {}
lua.name = "lua"

lua.errormessage = nil
lua.buffer = function() end

local function luaLoad(code)
	local _f, _m = load(code)
	if _m then
		lua.errormessage = _m
		return false, _m, _f
	else return true, nil, _f end
end

local function luaQuick(code,...)
	local _s, _m, _f = luaLoad(code)
	if _s then
		local _s, __m = pcall(_f,...)
		if _s then return true, nil, _f
		else
			lua.errormessage = __m
			return false, __m, _f
		end
	else return false, _m, _f end
end

lua.call = function(args, rawinput)
	lua.errormessage = nil
	local _code = rawinput:gsub("^lua%s%w+%s","",1)
	if args[1] == "buffer" then	
		local _s, _m, _f = luaLoad(_code)
		if _s then lua.buffer = _f ; Cyclone.w("Code loaded to buffer") end
	elseif args[1] == "run" then
		if _code == "buffer" then
			local _s, _m = pcall(lua.buffer)
			if not _s then Cyclone.w(_m) else Cyclone.w("Buffer has been run.") end
		else luaQuick(_code) end
		--[=[
	elseif args[1] == "file" then
		local _file = Cyclone.terminal.readFile(args[2])
		local _i = 0
		local _f, _m = load(function() _i = _i + 1 ; return _file[_i] end)
		print(pcall(_f))
	--]=]
	else Cyclone.terminal.write("No such command") end
	if lua.errormessage then Cyclone.w(lua.errormessage) end
end

Cyclone.terminal.add(lua)