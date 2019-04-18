--fix

local breakable = Object.find("BlockDestroy")
if Cyclone.options["fix"] then
	registercallback("onImpact", function(damager)
		for k,v in pairs(breakable:findAll()) do
			if damager and damager:isValid() and v:isValid() and damager:getParent() and damager:getParent():isValid() and damager:getParent():getObject():getName() == "P" and damager:collidesWith(v,damager.x,damager.y) then
				v:set("active_total", (v:get("active_total") or 0) + 2)
			end
		end
	end)
end
if Cyclone.options["real_damage"] then
	registercallback("onFire", function(damagerInstance) damagerInstance:set("damage_fake", damagerInstance:get("damage")) end)
end