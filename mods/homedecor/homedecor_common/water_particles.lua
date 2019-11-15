-- variables taken by the start... function
--
-- pos and node are as usual, from e.g. on_rightclick.
--
-- in the { particledef } table:
--
-- outletx/y/z are the exact coords of the starting point
--     for the spawner, relative to the center of the node
--
-- velocityx/y/z are the speed of the particles,
--    (x and z are relative to a node placed while looking north/facedir 0)
--    negative Y values flow downward.
--
-- spread is the radius from the starting point,
-- along X and Z only, to randomly spawn particles.
--
-- soundname is the filename (without .ogg) of the sound file
-- to be played along with the particle stream

function homedecor.start_particle_spawner(pos, node, particledef, soundname)

	local this_spawner_meta = minetest.get_meta(pos)
	local id = this_spawner_meta:get_int("active")
	local s_handle = this_spawner_meta:get_int("sound")

	if id ~= 0 then
		if s_handle then
			minetest.after(0, function(handle)
				minetest.sound_stop(handle)
			end, s_handle)
		end
		minetest.delete_particlespawner(id)
		this_spawner_meta:set_int("active", 0)
		this_spawner_meta:set_int("sound", 0)
		return
	end

	local fdir = node.param2

	if fdir and fdir < 4 and (not id or id == 0) then

		local outletx    = particledef.outlet.x
		local outlety    = particledef.outlet.y
		local outletz    = particledef.outlet.z
		local velocityx  = particledef.velocity_x
		local velocityy  = particledef.velocity_y
		local velocityz  = particledef.velocity_z
		local spread     = particledef.spread

		local minx_t = {  outletx - spread, -outletz - spread, outletx - spread, outletz - spread }
		local maxx_t = {  outletx + spread, -outletz + spread, outletx + spread, outletz + spread }
		local minz_t = { -outletz - spread,  outletx - spread, outletz - spread, outletx - spread }
		local maxz_t = { -outletz + spread,  outletx + spread, outletz + spread, outletx + spread }

		local minvelx_t = { velocityx.min, velocityz.min, -velocityx.max, -velocityz.max }
		local maxvelx_t = { velocityx.max, velocityz.max, -velocityx.min, -velocityz.min }
		local minvelz_t = { velocityz.min, velocityx.min, -velocityz.max,  velocityx.min }
		local maxvelz_t = { velocityz.max, velocityx.max, -velocityz.min,  velocityx.max }

		local minx = minx_t[fdir + 1]
		local maxx = maxx_t[fdir + 1]
		local minz = minz_t[fdir + 1]
		local maxz = maxz_t[fdir + 1]

		local minvelx = minvelx_t[fdir + 1]
		local minvelz = minvelz_t[fdir + 1]
		local maxvelx = maxvelx_t[fdir + 1]
		local maxvelz = maxvelz_t[fdir + 1]

		id = minetest.add_particlespawner({
			amount = 60,
			time = 0,
			collisiondetection = true,
			collision_removal = particledef.die_on_collision,
			minpos = {x=pos.x - minx, y=pos.y + outlety, z=pos.z - minz},
			maxpos = {x=pos.x - maxx, y=pos.y + outlety, z=pos.z - maxz},
			minvel = {x = minvelx, y = velocityy, z = minvelz},
			maxvel = {x = maxvelx, y = velocityy, z = maxvelz},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=-0.05, z=0},
			minexptime = 2,
			maxexptime = 4,
			minsize = 0.5,
			maxsize = 1,
			texture = "homedecor_water_particle.png",
		})
		s_handle = minetest.sound_play(soundname, {
			pos = pos,
			max_hear_distance = 5,
			loop = true
		})
		this_spawner_meta:set_int("active", id)
		this_spawner_meta:set_int("sound", s_handle)
		return
	end
end

function homedecor.stop_particle_spawner(pos)
	local this_spawner_meta = minetest.get_meta(pos)
	local id = this_spawner_meta:get_int("active")
	local s_handle = this_spawner_meta:get_int("sound")

	if id ~= 0 then
		minetest.delete_particlespawner(id)
	end

	if s_handle then
		minetest.after(0, function(handle)
			minetest.sound_stop(handle)
		end, s_handle)
	end

	this_spawner_meta:set_int("active", 0)
	this_spawner_meta:set_int("sound", 0)
end
