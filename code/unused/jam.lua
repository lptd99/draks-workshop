
------ jam.lua
---- Adds a new playable character.

local jam = Survivor.new("Jam Man")

-- Load all of our sprites into a table
local sprites = {
	idle = Sprite.load("jam_idle", "jam/idle", 1, 3, 10),
	walk = Sprite.load("jam_walk", "jam/walk", 8, 4, 10),
	jump = Sprite.load("jam_jump", "jam/jump", 1, 5, 11),
	climb = Sprite.load("jam_climb", "jam/climb", 2, 4, 7),
	death = Sprite.load("jam_death", "jam/death", 8, 48, 13),
	-- This sprite is used by the Crudely Drawn Buddy
	-- If the player doesn't have one, the Commando's sprite will be used instead
	decoy = Sprite.load("jam_decoy", "jam/decoy", 1, 9, 18),
}
-- Attack sprites are loaded separately as we'll be using them in our code
local sprShoot1 = Sprite.load("jam_shoot1", "jam/shoot1", 7, 4, 14)
local sprShoot2 = Sprite.load("jam_shoot2", "jam/shoot2", 5, 4, 11)
local sprShoot3 = Sprite.load("jam_shoot3", "jam/shoot3", 9, 6, 8)
local sprShoot4 = Sprite.load("jam_shoot4", "jam/shoot4", 15, 4, 19)
-- The hit sprite used by our X skill
local sprSparksJam = Sprite.load("jam_sparks1", "jam/bullet", 4, 10, 8)
-- The spikes creates by our V skill
local sprJamSpike = Sprite.load("jam_spike", "jam/spike", 5, 12, 32)
local sprSparksSpike = Sprite.load("jam_sparks2", "jam/hitspike", 4, 8, 9)
-- The sprite used by the skill icons
local sprSkills = Sprite.load("jam_skills", "jam/skills", 5, 0, 0)

-- Get the sounds we'll be using 
local sndClayShoot1 = Sound.find("ClayShoot1", "vanilla")
local sndBullet2 = Sound.find("Bullet2", "vanilla")
local sndBoss1Shoot1 = Sound.find("Boss1Shoot1", "vanilla")
local sndGuardDeath = Sound.find("GuardDeath", "vanilla")



-- Set the description of the character and the sprite used for skill icons
jam:setLoadoutInfo(
[[The &y&Jam Man&!& is an &y&example character&!& intended to serve as a base for other characters.
&y&Stab&!& can hit more enemies at a time compared to other melee attacks.
&y&Raspberry Bullet&!& can be used as an opener to deal extra damage as you use other skills.
&y&Spikes of Death&!& is very effective against large groups.]], sprSkills)

-- Set the character select skill descriptions
jam:setLoadoutSkill(1, "Stab",
[[Stab for &y&90% damage&!& hitting &y&up to 5&!& enemies.]])

jam:setLoadoutSkill(2, "Raspberry Bullet",
[[Fire a projectile from your rod for &y&60% damage.&!&
&y&Pierces enemies&!& and causes bleeding for &y&4x60% damage&!& over time.]])

jam:setLoadoutSkill(3, "Roll",
[[&y&Roll forward&!& a small distance.
You &b&cannot be hit&!& while rolling.]])

jam:setLoadoutSkill(4, "Spikes of Death",
[[Form spikes in front of yourself dealing up to &y&3x240% damage&!&.]])

-- The color of the character's skill names in the character select
jam.loadoutColor = Color(0xA23EE0)

-- The character's sprite in the selection pod
jam.loadoutSprite = Sprite.load("jam_select", "jam/select", 4, 2, 0)

-- The character's walk animation on the title screen when selected
jam.titleSprite = sprites.walk

-- Quote displayed when the game is beat as the character
jam.endingQuote = "..and so it left, still not knowing how it got here to begin with."

-- Called when the player is created
jam:addCallback("init", function(player)
	-- Set the player's sprites to those we previously loaded
	player:setAnimations(sprites)
	-- Set the player's starting stats
	player:survivorSetInitialStats(120, 14, 0.01)
	-- Set the player's skill icons
	player:setSkill(1,
		"Stab",
		"Stab for 90% damage hitting up to 5 enemies.",
		sprSkills, 1,
		40
	)
	player:setSkill(2,
		"Raspberry Bullet",
		"Fire a projectile from your rod for 60% damage.\nPierces enemies and causes bleeding for 4x60% damage over time.",
		sprSkills, 2,
		6 * 60
	)
	player:setSkill(3,
		"Roll",
		"Roll forward a small distance.\nYou cannot be hit while rolling.",
		sprSkills, 3,
		4.5 * 60
	)
	player:setSkill(4,
		"Spikes of Death",
		"Form spikes in front of yourself dealing up to 3x240% damage.",
		sprSkills, 4,
		7 * 60
	)
end)

-- Called when the player levels up
jam:addCallback("levelUp", function(player)
	player:survivorLevelUpStats(24, 4, 0.002, 4)
end)

-- Called when the player picks up the Ancient Scepter
jam:addCallback("scepter", function(player)
	player:setSkill(4,
		"Spikes of Super Death",
		"Form spikes in both directions dealing up to 2x3x240% damage.",
		sprSkills, 5,
		7 * 60
	)
end)

-- Called when the player tries to use a skill
jam:addCallback("useSkill", function(player, skill)
	-- Make sure the player isn't doing anything when pressing the button
	if player:get("activity") == 0 then
		-- Set the player's state
		
		if skill == 1 then
			-- Z skill
			player:survivorActivityState(1, sprShoot1, 0.2, true, true)
		elseif skill == 2 then
			-- X skill
			player:survivorActivityState(2, sprShoot2, 0.25, true, true)
		elseif skill == 3 then
			-- C skill
			player:survivorActivityState(3, sprShoot3, 0.25, false, false)
		elseif skill == 4 then
			-- V skill
			player:survivorActivityState(4, sprShoot4, 0.25, true, true)
		end
		
		-- Put the skill on cooldown
		player:activateSkillCooldown(skill)
	end
end)

-- Called each frame the player is in a skill state
jam:addCallback("onSkill", function(player, skill, relevantFrame)
	-- The 'relevantFrame' argument is set to the current animation frame only when the animation frame is changed
	-- Otherwise, it will be 0

	
	if skill == 1 then 
		-- Z skill: stab
		
		if relevantFrame == 4 then
			-- Code is ran when the 4th frame of the animation starts
			
			-- The "survivorFireHeavenCracker" method handles the effects of the item Heaven Cracker
			-- If the effect is triggered, it returns the fired bullet, otherwise it returns nil
			if player:survivorFireHeavenCracker(0.9) == nil then
				-- The player's "sp" variable is the attack multiplier given by Shattered Mirror
				for i = 0, player:get("sp") do
					-- Fires an explosion 18 pixels in front of the player with a width multiplier of 13, height multiplier of 2,
					-- dealing 0.9 damage and using the sprite "sparks7" from the base game as its hit sprite
					local bullet = player:fireExplosion(player.x + player.xscale * 18, player.y, 1.3, 2, 0.9, nil, sprSparks7)
					bullet:set("max_hit_number", 5)
					if i ~= 0 then
						-- Makes the damage text pop up higher if firing multiple attacks at once
						bullet:set("climb", i * 8)
					end
				end
			end
			
			-- Plays the clay man stab sound effect
			sndClayShoot1:play(0.8 + math.random() * 0.2)
		end
		
		
	elseif skill == 2 then
		-- X skill: pierce
		
		if relevantFrame == 1 then
			for i = 0, player:get("sp") do
				local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 500, 0.6, sprSparksJam, DAMAGER_BULLET_PIERCE)
				bullet:set("bleed", 3)
				if i ~= 0 then
					bullet:set("climb", i * 8)
				end
			end
			
			sndBullet2:play(0.9 + math.random() * 0.2)
		end
		
		
		
	elseif skill == 3 then
		-- C skill: roll
		
		if relevantFrame == 8 then
			-- Ran on the last frame of the animation
			
			-- Reset the player's invincibility
			if player:get("invincible") <= 5 then
				player:set("invincible", 0)
			end
		else
			-- Ran all other frames of the animation
			
			-- Make the player invincible
			-- Only set the invincibility when below a certain value to make sure we don't override other invincibility effects
			if player:get("invincible") < 5 then
				player:set("invincible", 5)
			end
			
			-- Set the player's horizontal speed
			player:set("pHspeed", player:get("pHmax") * 2.2 * player.xscale)
		end
		
		
		
	elseif skill == 4 then
		-- V skill: jam spikes
		
		if relevantFrame == 6 or relevantFrame == 10 or relevantFrame == 14 then
			for i = 0, player:get("sp") do
				-- Calculate the offset from the player
				local pos = ((relevantFrame - 2) / 4) * 48 + i * 12
			
				-- Create the spike
				player:fireExplosion(player.x + player.xscale * pos, player.y, 2, 4, 2.4, sprJamSpike, sprSparksSpike)
			
				-- If we have ancient scepter, create a spike behind the player too
				if player:get("scepter") > 0 then
					player:fireExplosion(player.x + -player.xscale * pos, player.y, 2, 4, 2.4, sprJamSpike, sprSparksSpike)
					-- Layer sound effects when scepter is active
					sndGuardDeath:play(1.2 + math.random() * 0.3, 0.6)
				end
				
				-- Play a sound effect
				sndBoss1Shoot1:play(1.2 + math.random() * 0.3)
			end
		end
	end
end)
