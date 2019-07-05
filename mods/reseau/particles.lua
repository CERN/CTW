local BITPARTICLES_DELAY = 0.03
reseau.bitparticles_conductor = function(pos, depth)
	local minpos = vector.add(pos, vector.new(-0.5, -0.3, -0.5))
	local maxpos = vector.add(pos, vector.new( 0.5,  0.2,  0.5))

	local psspec = {
		amount = 3,
		time = 0.3,
		minpos = minpos,
		maxpos = maxpos,
		minvel = vector.new(-0.1, 0.2, -0.1),
		maxvel = vector.new( 0.1, 0.5,  0.1),
		minexptime = 0.1,
		maxexptime = 0.4,
		minsize = 0.5,
		maxsize = 1,
		collisiondetection = true,
		collision_removal = false,
		object_collision = false,
		vertical = false,
		texture = "reseau_zero.png",
		glow = 7
	}

	if math.random(1, 2) == 2 then
		psspec.texture = "reseau_one.png"
	end

	minetest.after((depth - 1) * BITPARTICLES_DELAY, function()
		minetest.add_particlespawner(psspec)
	end)
end

reseau.bitparticles_receiver = function(pos, depth)
	local minpos = vector.add(pos, vector.new(-0.2, -0.3, -0.2))
	local maxpos = vector.add(pos, vector.new( 0.2,  0.2,  0.2))

	local psspec = {
		amount = 20,
		time = 0.3,
		minpos = minpos,
		maxpos = maxpos,
		minvel = vector.new(-1.0, 5.5, -1.0),
		maxvel = vector.new( 1.0, 8.5, 1.0),
		minacc = vector.new(0, -10, 0),
		maxacc = vector.new(0, -10, 0),
		minexptime = 0.1,
		maxexptime = 2.5,
		minsize = 0.5,
		maxsize = 1,
		collisiondetection = false,
		collision_removal = false,
		object_collision = false,
		vertical = false,
		texture = "reseau_zero.png",
		glow = 7
	}

	minetest.after((depth - 1) * BITPARTICLES_DELAY, function()
		minetest.add_particlespawner(psspec)
		psspec.texture = "reseau_one.png"
		minetest.add_particlespawner(psspec)
	end)
end
