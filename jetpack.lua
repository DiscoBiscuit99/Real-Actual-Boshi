math.randomseed(os.time())

return {
	new = function(carrier_x, carrier_y)
		local jetpack = {}
		
		function jetpack:load()
			self.particles = {}
			self.types     = { "normal", "magic", "merged" }
			
			local rand = math.random(#self.types) -- Starts from 1 when no lower bound is specified.
			self.type  = self.types[rand] 
		end

		function jetpack:update(dt, carrier_x, carrier_y, is_flying)
			for _, particle in pairs(self.particles) do
				particle.x = particle.x + math.random(-80, 80)*dt
				particle.y = particle.y + 10*dt
			end
			
			if is_flying then
				self.particle  = {
					x = carrier_x,
					y = carrier_y,
					w = 3,
					h = 3,

					spawn_time = love.timer.getTime(),
					lifetime   = math.random(0.25, 0.4)
				}

				table.insert(self.particles, self.particle)
			end
			
			local particle_index = 1
			for _, particle in pairs(self.particles) do
				if love.timer.getTime() - particle.spawn_time > particle.lifetime then
					table.remove(self.particles, particle_index)	
				end
				particle_index = particle_index + 1
			end
		end

		function jetpack:draw()
			love.graphics.print(self.type, 10, 90)
			for _, particle in pairs(self.particles) do
				if self.type == "normal" then
					love.graphics.setColor(1, 0.522, 0)
				elseif self.type == "magic" then
					love.graphics.setColor(1, math.random(0.522, 0.775), math.random(0.95, 1))
				elseif self.type == "merged" then
					love.graphics.setColor(1, math.random(0.522, 0.775), math.random(0, 0.49))
				end

				love.graphics.rectangle("fill", particle.x, particle.y, particle.w, particle.h)
			end
		end

		return jetpack
	end
}


