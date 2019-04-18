--Cyclone_Example

--The command example
require("bin")

--The window example
require("window")

--Another window example that is more hands-on.
require("itemwindow")

--Projectile example
local projectile = Cyclone.Projectile.new({
name = "Projectile_example",
vx = 15/4,
vy = 0,
ax = -0.25/8,
ay = 0.04,
sprite = Cyclone.sprites["controls"],
mask = Cyclone.sprites["empty"],
damage = 2,
pierce = false,
deathsprite_life = Cyclone.sprites["missing"],
life = 60,
explosion = true,
ghost = false,
--multihit = false,
explosionw = 30,
explosionh = 30,
rotate = 90,
damager_variables = {
		climb = 90,
	},
bounce = 0.9,
})

projectile:addCallback("step",function(projectileInstance)
	if projectileInstance:isValid() then
		if projectileInstance:get("Projectile_dead") == 1 then -- Triggers once when it dies. Is set to -1 while the death animation is being played
			projectileInstance.alpha = 0.5
			projectileInstance.spriteSpeed = 0.05
		end
		if misc.getTimeStop() > 0 then
			Cyclone.Projectile.stop(projectileInstance)
		else
			Cyclone.Projectile.start(projectileInstance)
		end
	end
end)

Survivor.find("Commando", "vanilla"):addCallback("step", function(player)
	if input.checkKeyboard("B") == 3 then
		local _projectileInstance = Cyclone.Projectile.fire(projectile,player.x,player.y,player)
		Cyclone.Projectile.configure(_projectileInstance, {vx = (math.random(3200,1600)/1000)*player.xscale, life = math.random(1500,4500)/100})
	end
end)