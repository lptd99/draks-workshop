--CycloneLib-Input

--Export variables
local _input = {}
_input.raw = {}
_input.text = ""
_input.MPOS = {}
_input.oMPOS = {} -- Old position
_input.dMPOS = {} -- Delta position

--###############--
-- Configuration --
--###############--

local repeat_delay = 12
local repeat_startscale = 6
local function rpt(key, scale)
	return (_input.raw[key] == 0) or ((_input.raw[key]) and (_input.raw[key] > repeat_delay*scale*repeat_startscale) and (_input.raw[key]%(math.ceil(repeat_delay*scale)) == 0))
end


--################--
-- Input Handling --
--################--

local function update_input()
	--Raw input gathering.
	local _held = CycloneLib.util.input.getPressed(input.HELD)
	local _released = CycloneLib.util.input.getPressed(input.RELEASED)
	for k,v in pairs(_held) do _input.raw[v] = (_input.raw[v] or -1) + 1 end
	for k,v in pairs(_released) do _input.raw[v] = nil end
	
	--Some important inputs and custom delays.
	_input.SHF = ((_input.raw["shift"] or -1) >= 0)
	_input.RET = rpt("enter",1)
	_input.BCK = rpt("backspace",0.2)
	_input.LEFT = rpt("left",0.5)
	_input.RIGHT = rpt("right",0.5)
	_input.UP = rpt("up",0.5)
	_input.DOWN = rpt("down",0.5)
	_input.DEL = rpt("delete",1)
	_input.HOME = rpt("home",1)
	_input.END = rpt("end",1)
	_input.CTRL = (_input.raw["control"] or -1) >= 0
	
	--Getting the text input for typing.
	_input.text = ""
	for k,v in pairs(_input.raw) do
		if (k ~= "shift") and (k ~= "enter") and (k ~= "backspace") and (k~="text") then
			if rpt(k,0.5) then
				if _input.SHF then
					if (CycloneLib.shiftkeys[k]) then _input.text = _input.text .. (CycloneLib.shiftkeys[k] or "")
					else _input.text = _input.text .. string.upper(CycloneLib.keymap[k] or "") end
				else _input.text = _input.text .. string.lower(CycloneLib.keymap[k] or "") end
			end
		end
	end
	
	--Mouse positions.
	_input.oMPOS.x , _input.oMPOS.y = _input.MPOS.x or 0 , _input.MPOS.y or 0
	_input.MPOS.x , _input.MPOS.y = input.getMousePos(true)
	_input.dMPOS.x , _input.dMPOS.y = _input.MPOS.x - _input.oMPOS.x , _input.MPOS.y - _input.oMPOS.y
end


--#########--
-- Exports --
--#########--

export("CycloneLib.input", _input)
registercallback("onStep", function()
	update_input()
	export("CycloneLib.input", _input)
end)