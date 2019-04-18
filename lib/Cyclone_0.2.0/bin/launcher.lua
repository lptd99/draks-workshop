--launcher

local launcher = {}
launcher.window = Cyclone.Window:new()
launcher.window.name = "Launcher"
launcher.window.title_hidden = true
launcher.window.hollow = true
launcher.window.lock_pan = true

local missing_icon = Cyclone.sprites["missing"]

function launcher.update(windows)
	launcher.window:clear()
	local w,h = graphics.getHUDResolution()
	launcher.window:move(0,0)
	local _count = -1
	for k,v in pairs(windows) do _count = _count + 1 end
	if _count <= 0 then return nil end
	local _text = nil
	local _button = nil
	local _i = 0
	for k,v in pairs(windows) do if (k.name ~= "Launcher") and (v == 0) then
		_text = Cyclone.Text:new()
		_text.lock_cut = true
		_text.contents = k.name
		_text.color = Color.fromRGB(0,0,0)
		_text.lock_width = 80
		_button = Cyclone.Button:new()
		_button.text = _text
		_button.color = Color.fromRGB(200,200,200)
		_button.highlightcolor = Color.fromRGB(100,100,100)
		_button.spacing_x = 2
		_button.spacing_y = 2
		_button.id = k
		_button.name = k.name
		_button.x = 20
		_button.y = _i * 20 - (((_count - 1) * (5) + (_count) * (_button.boundaries.h))/2) + (h/2)*Cyclone.sc
		launcher.window:addElement(_button)
		local icon = {}
		icon.y = _button.y
		icon.sprite = k.icon or missing_icon
		icon.draw = function()
			icon.sprite:draw(10,icon.y+9,1)
		end
		launcher.window:addElement(icon)
		_i = _i + 1
	end end
	launcher.window:resize(150,h*Cyclone.sc)
end

Cyclone.wmclient.registerEvent(launcher.window,"button",function(id,name)
	Cyclone.wmclient.openWindow(id)
end)

Cyclone.wmclient.registerWindow(launcher.window)
Cyclone.wmclient.openWindow(launcher.window)

export("Cyclone.launcher", launcher)