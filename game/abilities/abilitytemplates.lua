-- Effect Function Factory
function CreateDamageEffectFunction(typefunc,damagefunc)
	return function (unit,caster,skill)
		unit:damage(typefunc(),damagefunc(),caster)
	end
end

-- Constant Function

-- Demo
