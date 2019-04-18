 
------ drone.lua
---- Adds a new playable character.

local drone = Survivor.new("DR-1")

fireflag = modloader.checkFlag("dr1_oilfire_disable")

-- Load all of our sprites into a table
local sprites = {
	idle = Sprite.load("drone_idle", "drone/droneIdle", 1, 14, 19),
	walk = Sprite.load("drone_walk", "drone/droneWalk", 8, 14, 19),
	jump = Sprite.load("drone_jump", "drone/droneJump", 1, 14, 19),
	climb = Sprite.load("drone_climb", "drone/droneClimb", 2, 9, 19),
	death = Sprite.load("drone_death", "drone/droneDeath", 11, 22, 21),
	-- This sprite is used by the Crudely Drawn Buddy
	-- If the player doesn't have one, the Commando's sprite will be used instead
	decoy = Sprite.load("drone_decoy", "drone/droneDecoy", 1, 9, 18),
}
-- Attack sprites are loaded separately as we'll be using them in our code
local sprShoot1L = Sprite.load("drone_shoot1L", "drone/shoot1L", 8, 19, 19)
local sprShoot1R = Sprite.load("drone_shoot1R", "drone/shoot1R", 4, 17, 19)
local sprShoot1M = Sprite.load("drone_shoot1M", "drone/shoot1M", 3, 28, 19)
local sprShoot1FW = Sprite.load("drone_shoot1FW", "drone/shoot1FW", 8, 15, 19)
local sprShoot1FWR = Sprite.load("drone_shoot1FWR", "drone/shoot1FWR", 8, 15, 19)
local sprShoot1FS = Sprite.load("drone_shoot1FS", "drone/shoot1F", 4, 15, 19)
local sprShoot1F = Sprite.load("drone_shoot1F", "drone/shoot1F", 4, 15, 19)
local sprShoot3 = Sprite.load("drone_shoot3", "drone/shoot3", 8, 20, 19)
local sprShoot4 = Sprite.load("drone_shoot4", "drone/shoot4", 8, 30, 19)
-- The sprite used by the skill icons
local sprSkills = Sprite.load("drone_skills", "drone/droneSkills", 8, 0, 0)

-- Get the sounds we'll be using 
local sndBullet1 = Sound.find("Bullet1", "vanilla")
local sndBullet2 = Sound.find("Bullet2", "vanilla")
local sndBullet3 = Sound.find("Bullet3", "vanilla")
local sndSniper = Sound.find("Sniper2", "vanilla")
local sndFlame = Sound.load("flame", "drone/flame.ogg")
local sndHover = Sound.load("thruster", "drone/thruster.ogg")
local changeModeSnd = Sound.find("Click", "vanilla")

local rocket = Object.find("EfMissile", "vanilla")
local mode = {}
local direction = {}
local function resetVars()
	mode = {}
	direction = {}
end
registercallback("onGameStart", resetVars)
registercallback("onGameEnd", resetVars)
-- Set the description of the character and the sprite used for skill icons
drone:setLoadoutInfo(
[[THE &y&DR-1&!& UNIT IS HIGHLY ADAPTABLE, CAPABLE OF CHANGING BETWEEN 4 FIRING MODES:
&b&RIFLES&!& HANDLE SINGLE TARGETS WITH EASE.
&r&LASERS&!& ARE WEAK AGAINST SINGLE TARGETS BUT MELT GROUPS.
&g&ROCKETS&!& AUTOMATICALLY HOME IN ON TARGETS.
&or&FLAMES&!& CAN BE FIRED WHILE MOVING, BUT DON'T PIERCE WELL.]], sprSkills)

-- Set the character select skill descriptions
drone:setLoadoutSkill(1, "PRIMARY FIRE",
[[FIRE FROM CURRENTLY POWERED BARRELS.
TO CHANGE FIRING MODE, REROUTE POWER WITH &y&BARREL SWAP&!&]])

drone:setLoadoutSkill(2, "BARREL SWAP",
[[REROUTE POWER TO THE NEXT SET OF BARRELS
ORDER OF ROUTING IS &b&RIFLE&!&, &r&LASER&!&, &g&MISSILE&!&, &or&FLAME&!&.]])

drone:setLoadoutSkill(3, "HOVER",
[[&b&LAUNCH FORWARD&!&, &y&SCORCHING ENEMIES&!& BENEATH AND BEHIND. 
JUMP WHILE USING TO GAIN SOME HEIGHT!]])

drone:setLoadoutSkill(4, "MUL-T MODE",
[[SURGE POWER TO ALL CANNONS, 
&r&KNOCKING ENEMIES BACK&!& AND &r&FRYING THEM&!&.]])

-- The color of the character's skill names in the character select
drone.loadoutColor = Color.fromRGB(92, 217, 255)
-- The character's sprite in the selection pod
drone.loadoutSprite = Sprite.load("drone_select", "drone/select", 14, -2, 0)
drone.loadoutWide = true
-- The character's walk animation on the title screen when selected
drone.titleSprite = sprites.walk

-- Quote displayed when the game is beat as the character
drone.endingQuote = "..and so it left, ready to return to duty."

-- Called when the player is created
drone:addCallback("init", function(player)
	mode[player] = 1	
	
	
	-- Set the player's sprites to those we previously loaded
	player:setAnimations(sprites)
	-- Set the player's starting stats
	player:survivorSetInitialStats(100, 11, 0.01)
	-- Set the player's skill icons
	player:setSkill(1,
		"PRIMARY FIRE - RIFLE",
		"FIRE CANNONSIDE RIFLES, MAY CAUSE SERIOUS INJURY TO THOSE AT THE END OF BARRELS.",
		sprSkills, 1,
		0
	)
	player:setSkill(2,
		"BARREL SWAP",
		"REROUTE POWER TO THE NEXT SET OF BARRELS.\nORDER OF ROUTING IS RIFLE, LASER, MISSILE, FLAME.",
		sprSkills, 2,
		20
	)
	player:setSkill(3,
		"HOVER",
		"LAUNCH FORWARD, SCORCHING ENEMIES BENEATH AND BEHIND. JUMP WHILE USING TO GET SOME HEIGHT!",
		sprSkills, 3,
		4.5 * 60
	)
	player:setSkill(4,
		"MUL-T MODE",
		"SURGE POWER TO ALL CANNONS, KNOCKING ENEMIES BACK AND FRYING THEM.",
		sprSkills, 4,
		7 * 60
	)
	mode[player] = 1
end)

-- Called when the player levels up
drone:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(24, 4, 0.002, 4)
end)

-- Called when the player picks up the Ancient Scepter
drone:addCallback("scepter", function(player)
	player:setSkill(4,
		"4-TRESS MODE",
		"SURGE POWER TO ALL CANNONS FOR &r&IMMEDIATE EVISCERATION&!&.",
		sprSkills, 8,
		7 * 60
	)
end)

-- Called when the player tries to use a skill
drone:addCallback("useSkill", function(player, skill)
	-- Make sure the player isn't doing anything when pressing the button
	if player:get("activity") == 0 then
		-- Set the player's state
		
		if skill == 1 then
				if mode[player] == 1 then
					player:survivorActivityState(1, sprShoot1R, 0.3, true, true)
				elseif mode[player] == 2 then
					player:survivorActivityState(1, sprShoot1L, 0.2, true, true)
				elseif mode[player] == 3 then
					player:survivorActivityState(1, sprShoot1M, 0.1, false, true)
				elseif mode[player] == 4 then
					if player:get("pHspeed") ~= 0  then
						sprShoot1F:replace(sprShoot1FW)
						player:survivorActivityState(1, sprShoot1F, 0.30, true, false)
						if direction[player] == 0 then
							direction[player] = player.xscale
						end
					else
						sprShoot1F:replace(sprShoot1FS)
						player:survivorActivityState(1, sprShoot1F, 0.30, true, true)
						if direction[player] == 0 then
							direction[player] = player.xscale
						end
					end
				end
		elseif skill == 2 then
			-- X skill
				changeModeSnd:play(0.8 + math.random() * 2.2)
				if mode[player] == 1 then
					mode[player] = 2
						player:setSkill(1,
						"PRIMARY FIRE - LASER",
						"BLAST DR-1'S LASERS, RECOMMENDED TO NOT LOOK DIRECTLY INTO LENS WHILE IN USE.",
						sprSkills, 5,
						0
						)
				elseif mode[player] == 2 then
					mode[player] = 3
						player:setSkill(1,
						"PRIMARY FIRE - MISSILES",
						"LAUNCH SHOULDER MOUNTED MISSILES, THEY JUST DO THE WORK FOR YOU.",
						sprSkills, 6,
						40 / player:get("attack_speed")
						)
				elseif mode[player] == 3 then
					mode[player] = 4
						player:setSkill(1,
						"PRIMARY FIRE - FLAMES",
						"SPRAY UNDERSIDE FLAMETHROWERS WHILE MOBILE, EVEN WORKS UNDERWATER!",
						sprSkills, 7,
						0
						)
				elseif mode[player] == 4 then
					mode[player] = 1
						player:setSkill(1,
						"PRIMARY FIRE - RIFLE",
						"FIRE CANNONSIDE RIFLES, MAY CAUSE SERIOUS INJURY TO THOSE AT THE END OF BARRELS.",
						sprSkills, 1,
						0
						)
				end
		elseif skill == 3 then
			-- C skill
			player:survivorActivityState(3, sprShoot3, 0.2, false, false)
			
		elseif skill == 4 then
			-- V skill
			player:survivorActivityState(4, sprShoot4, 0.2, true, true)
		end
		
		-- Put the skill on cooldown
		player:activateSkillCooldown(skill)
	end
end)

registercallback("onPlayerDeath", function(player)
	sndFlame:stop()
end)
registercallback("onPlayerStep", function(player)
	if player:get("z_skill") == 0 and player:get("activity") ~= 1 then
		sndFlame:stop()
		direction[player] = 0
	end
end)

-- Called each frame the player is in a skill state
drone:addCallback("onSkill", function(player, skill, relevantFrame)
	if skill == 1 then 
		
		
		if mode[player] == 1 then
			if relevantFrame == 1 then
				if player:survivorFireHeavenCracker(0.9) == nil then
					for i = 0, player:get("sp") do
						local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 750, 0.45)
						if i ~= 0 then
							bullet:set("climb", i * 8)
						end
					end
					sndBullet1:play(0.6 + math.random() * 0.1)
				end
			elseif relevantFrame == 3 then
				if player:survivorFireHeavenCracker(0.9) == nil then
					for i = 0, player:get("sp") do
						local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 750, 0.4, nil, DAMAGER_NO_PROC)
						if i ~= 0 then
							bullet:set("climb", i * 8)
						end
					end
					sndBullet1:play(0.6 + math.random() * 0.1)
				end
			end
			
			
			
			
		elseif mode[player] == 2 then
			if relevantFrame == 4 then
				if player:survivorFireHeavenCracker(0.9) == nil then
					
					for i = 0, player:get("sp") do
						local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 750, 1, nil, DAMAGER_BULLET_PIERCE)
						bullet:set("damage_degrade", -0.2)
						if i ~= 0 then
							bullet:set("climb", i * 8)
						end
					end
					sndBullet3:play(.8 + math.random() * 0.2)
				end
			end
			
			
			
		elseif mode[player] == 3 then
			if relevantFrame == 1 then
				if player:getFacingDirection() == 0 then	
					local rocketInstance = rocket:create(player.x + 4, player.y -10)
					rocketInstance:set("parent", player.id)
					rocketInstance:set("damage", player:get("damage")/1.6)
					local rocketInstance2 = rocket:create(player.x -8, player.y -10)
					rocketInstance2:set("parent", player.id)
					rocketInstance2:set("damage", player:get("damage")/1.5)
				elseif player:getFacingDirection() == 180 then
					local rocketInstance = rocket:create(player.x + -4, player.y -10)
					rocketInstance:set("parent", player.id)
					rocketInstance:set("damage", player:get("damage")/1.6)
					local rocketInstance2 = rocket:create(player.x + 8, player.y -10)
					rocketInstance2:set("parent", player.id)
					rocketInstance2:set("damage", player:get("damage")/1.5)
				end
			end
			
			
			
			
		elseif mode[player] == 4 then -- Flamethrower
			if not sndFlame:isPlaying() then
				sndFlame:play(1.0)
			end
			if player:get("moveLeft") == 1 and direction[player] == -1 then
				sprShoot1F:replace(sprShoot1FW)
				player:set("pHspeed", player:get("pHmax")*-1)
				player.xscale = direction[player]
			elseif player:get("moveRight") == 1 and direction[player] == -1 then
				sprShoot1F:replace(sprShoot1FWR)
				player:set("pHspeed", player:get("pHmax")*1)
				player.xscale = direction[player]
			elseif player:get("moveLeft") == 1 and direction[player] == 1 then
				sprShoot1F:replace(sprShoot1FWR)
				player:set("pHspeed", player:get("pHmax")*-1)
				player.xscale = direction[player]
			elseif player:get("moveRight") == 1 and direction[player] == 1 then
				sprShoot1F:replace(sprShoot1FW)
				player:set("pHspeed", player:get("pHmax")*1)
				player.xscale = direction[player]
			else
				player:set("pHspeed", 0)
				sprShoot1F:replace(sprShoot1FS)
			end
			if relevantFrame == 1 or relevantFrame == 3 then
				local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 75, 0.2, nil, DAMAGER_BULLET_PIERCE)
				bullet:set("damage_degrade", 0.6)
			elseif relevantFrame == 5 or relevantFrame == 7 then
				local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 75, 0.3, nil, DAMAGER_BULLET_PIERCE + DAMAGER_NO_PROC)
				bullet:set("damage_degrade", 0.55)
			
			end
		end
		
		
		
		
		
	elseif skill == 3 then -- Hover
		
			local bullet = player:fireExplosion(player.x - player.xscale * 5, player.y, 0.1, 1, 0.1, nil, nil, DAMAGER_NO_PROC)
			bullet:set("fear", 0.3)
			player:set("pHspeed", player:get("pHmax") * 3 * player.xscale)
			if input.checkControl("jump", player) == input.HELD then
				player:set("pVspeed", -2.5)
			else
				player:set("pVspeed", -0.3)
			end
			
			if relevantFrame == 1 then
			sndHover:play(2.0, 1.0)
		end
			
	elseif skill == 4 then -- MUL-T Mode
		if relevantFrame == 4 then
			sndBullet2:play(1.0)
			local rocketInstance = rocket:create(player.x + 4, player.y -10)
			rocketInstance:set("parent", player.id)
			rocketInstance:set("damage", player:get("damage")/2 + player:get("damage")/4)
			rocketInstance = rocket:create(player.x -8, player.y -10)
			rocketInstance:set("parent", player.id)
			rocketInstance:set("damage", player:get("damage")/2 + player:get("damage")/4)
			if player:get("scepter") > 0 then
				local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 750, 4, nil, DAMAGER_BULLET_PIERCE)
				bullet:set("damage_degrade", -0.2)
			else
				local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 750, 2, nil, DAMAGER_BULLET_PIERCE)
				bullet:set("damage_degrade", -0.2)
			end
			bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 68, 2, nil, DAMAGER_BULLET_PIERCE)
			bullet:set("stun", 1)
			bullet:set("knockback", 5)	
		end
		if relevantFrame >= 4 then
			sndBullet1:play(.5 + math.random() * 0.1)
			local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 750, 0.3)
			bullet:set("climb", 8)
			local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 75, .5, nil, DAMAGER_BULLET_PIERCE)
			bullet:set("stun", 0.1)
			bullet:set("climb", 16)
			if player:get("scepter") > 0 then
				local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 75, .5, nil, DAMAGER_BULLET_PIERCE)
				bullet:set("climb", 24)
			end
		end
		if relevantFrame == 5 then
			local rocketInstance = rocket:create(player.x + 4, player.y -10)
			rocketInstance:set("parent", player.id)
			rocketInstance:set("damage", player:get("damage")/2)
			rocketInstance = rocket:create(player.x -8, player.y -10)
			rocketInstance:set("parent", player.id)
			rocketInstance:set("damage", player:get("damage")/2)
		end
		if player:get("scepter") > 0 then
			if relevantFrame == 6 then
				local rocketInstance = rocket:create(player.x + 4, player.y -10)
				rocketInstance:set("parent", player.id)
				rocketInstance:set("damage", player:get("damage")/2)
				rocketInstance = rocket:create(player.x -8, player.y -10)
				rocketInstance:set("parent", player.id)
				rocketInstance:set("damage", player:get("damage")/2)
			end
		end
	end
end)