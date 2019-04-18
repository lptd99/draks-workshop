--CycloneLib-Util

--Dependencies :
--  CycloneLib-Res
--  CycloneLib-Keys


--Export variables
local util = {}
util.input = {}
util.table = {}
util.math = {}

--Collision variables
local collisionSprite = CycloneLib.sprites["emptyStandard"]
local collisionObject = Object.new("CycloneLib_collider")
local collisionInstance = nil
local function refreshCollisionInstance()
	collisionInstance = collisionObject:create(0,0)
	collisionInstance.mask = collisionSprite
	collisionInstance.visible = false
end
registercallback("onStageEntry", refreshCollisionInstance)

--The relative coordinates of the world and screen.
local mOnSx, mOnSy, mOnWx, mOnWy, sOnWx, sOnWy = 0,0,0,0,0,0
registercallback("preStep", function()
	mOnSx, mOnSy = input.getMousePos(true) ; mOnWx, mOnWy = input.getMousePos(false)
	sOnWx = mOnWx - mOnSx ; sOnWy = mOnWy - mOnSy
end)


--#########--
-- General --
--#########--

--Returns a list of namespaces (mods) and indexes vanilla as the first.
function util.getNamespaces()
	local _namespaces = modloader.getMods()
	_namespaces[#_namespaces+1] = _namespaces[1]
	_namespaces[1] = "vanilla"
	return _namespaces
end

--Returns a list of namespaces (mods) and indexes vanilla as the first.
--Keeps the rest of the mods in modloader order. (Probably slower)
function util.getOrderedNamespaces()
	local _namespaces = { [1] = "vanilla" }
	for i,v in ipairs(modloader.getMods()) do
		_namespaces[i+1] = v
	end
	return _namespaces
end

-- Converts the world or screen coordinates to the other.
function util.screenToWorld(x,y) return (x + sOnWx), (y + sOnWy) end
function util.worldToScreen(x,y) return (x - sOnWx), (y - sOnWy) end


--######--
-- Math --
--######--

function util.math.vectorToAngle(i,j)
	local _angle = 0
	if i == 0 then
		if j > 0 then _angle = 90
		else _angle = -90 end
	else
		_angle = math.atan(j/i)*(180/math.pi)
		if i < 0 then _angle = _angle + 180 end
	end
	return (_angle%360)
end

--###########--
-- Collision --
--###########--

--!!!!
--TODO Store the width and height of the sprite and refresh them.
--!!!!

--Checks collision with an instance and a rectangle.
function util.intersectsWith(i,x,y,w,h)
	if not collisionInstance:isValid() then refreshCollisionInstance() end
	if not i:isValid() then return false end
	collisionInstance.x, collisionInstance.y = x, y
	collisionInstance.xscale = w/collisionSprite.width ; collisionInstance.yscale = h/collisionSprite.height
	return collisionInstance:collidesWith(i,x,y)
end

--Checks collision with the map and a rectangle.
function util.intersectsMap(x,y,w,h)
	if not collisionInstance:isValid() then refreshCollisionInstance() end
	collisionInstance.x, collisionInstance.y = x, y
	collisionInstance.xscale = w/collisionSprite.width ; collisionInstance.yscale = h/collisionSprite.height
	return collisionInstance:collidesMap(x,y)
end

--Checks collision with the map and a line.
function util.intersectsLineMap(x,y,dx,dy,precision)
	collisionInstance.x, collisionInstance.y = x, y
	collisionInstance.xscale = (precision or 0)/collisionSprite.width
	collisionInstance.yscale = math.sqrt(dx^2 + dy^2)/collisionSprite.height
	collisionInstance.angle = (90 + util.math.vectorToAngle(dx,dy))%360
	local _collides = collisionInstance:collidesMap(x,y)
	collisionInstance.angle = 0
	return _collides
end

--Checks collision with the map and a line. Uses two points instead of dx and dy.
function util.intersectsPLineMap(x1,y1,x2,y2,precision)
	return util.intersectsLineMap(x1,y1,x2-x1,-(y2-y1),precision)
end

--Returns the first ground y coordinate under the given position. Faster than the raycast version.
function util.getGround(x,y,precision)
	if util.intersectsMap(x,y,0,0) then return y end
	local _maxW, _maxH = Stage.getDimensions()
	local _bottom, _top = _maxH, y
	local precision = precision or 0.5
	while (math.abs(_bottom - _top) > precision) do
		local __top, __bottom = math.floor(_top), math.ceil(_bottom)
		if util.intersectsMap(x,__top,0,(__bottom-__top)/2)
		then _bottom = _bottom - (_bottom - _top)/2
		else _top = _top + (_bottom - _top)/2
		end
	end
	return _top
end

--Casts a ray from the given position towards the <dx,dy> vector.
--Works poorly when pointed at edges at an angle due to GM collisions.
function util.raycast(x,y,dx,dy,precision)
	if util.intersectsMap(x,y,0,0) then return x, y end
	local _x,_y = x,y
	local _maxW, _maxH = Stage.getDimensions()
	
	--NOTE The smaller the estimation the better for collisions but the worse for long range raycasts.
	local _maxD = math.sqrt(_maxW^2 + _maxH^2) * 0.5
	
	local _angle = util.math.vectorToAngle(dx,dy)
	local _fx, _fy = _x + _maxD * math.cos(_angle * (math.pi/180)), _y - _maxD * math.sin(_angle * (math.pi/180))
	local precision = precision or 0.5
	local _sx, _sy = dx > 0, dy > 0
	while math.sqrt((_fx - _x)^2 + (_fy - _y)^2) > precision do
		local __x, __y, __fx, __fy = 0,0,0,0
		if _sx then __x = math.floor(_x) ; __fx = math.ceil(_fx)
		else __x = math.ceil(_x) ; __fx = math.floor(_fx) end
		if _sy then __y = math.floor(_y) ; __fy = math.ceil(_fy)
		else __y = math.ceil(_y) ; __fy = math.floor(_fy) end
		if util.intersectsLineMap(__x,__y,(__fx-__x)/2,-(__fy-__y)/2,0)
		then _fx = _fx - (_fx-_x)/2 ; _fy = _fy - (_fy-_y)/2
		else _x = _x + (_fx-_x)/2 ; _y = _y + (_fy-_y)/2
		end
	end
	return _x,_y
end

--Gets the damage of an actor from the damager.
--Differs from the "damage" variable of the actor.
function util.getDamage(player)
	local _damager = player:fireBullet(1,1,1,1,1)
	return _damager:get("damage")
end


--#######--
-- Input --
--#######--

--Returns a table with all the pressed (or inputType) buttons.
function util.input.getPressed(inputType)
	local _type = inputType or input.HELD
	local _pressed = {}
	for k,v in pairs(CycloneLib.keys) do if input.checkKeyboard(v) == _type then table.insert(_pressed, v) end end
	return _pressed
end


--#######--
-- Table --
--#######--

--Tries to make a string out of a table.
--Should work for basic tables.
function table.tostring(t,l,r)
	local _s = ""
	local _l = l or ""
	local _r = r or {}
	for k,v in pairs(t) do
		_s = _s .. _l .. "Key=<<" .. tostring(k) .. ">>/Value=<<" .. tostring(v) .. ">>" .. "\n"
		if (type(v) == "table") and not _r[v] then
			_r[v] = true
			local __s, __r = table.tostring(v,_l .. "    ",_r)
			_s = _s .. __s
			for __k,__v in pairs(__r) do _r[__k] = true end
		end
	end
	if _l == "" then return _s
	else return _s, _r end
end

--Removes an item from an i-indexed table.
--Should be faster than table.remove on long tables.
function table.iremove(t,i)
	t[i] = t[#t]
	t[#t] = nil
end


--#######--
-- Debug --
--#######--

local gfb = false
registercallback("onHUDDraw", function() if gfb then graphics.circle(0,0,10); gfb = false end end)
function util.gfb() gfb = true end


--#########--
-- Exports --
--#########--

export("CycloneLib.util", util)
export("Cyclone.gfb", util.gfb)