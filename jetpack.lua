math.randomseed(os.time())

return {
	new = function(world, carrier_x, carrier_y)
		local jetpack = {}
		
		function jetpack:load()
			self.particles = {}
			self.types     = { "normal", "magic", "merged" }
			
			local rand = math.random(#self.types) -- Starts from 1 when no lower bound is specified.
			self.type  = self.types[rand] 
		end

		function jetpack:update(dt, carrier_x, carrier_y, is_flying, carrier_xvel)
			for _, particle in pairs(self.particles) do
				--particle.x = particle.x + math.random(-80, 80)*dt
				--particle.y = particle.y + 10*dt
				--particle.body:setY(particle.body:getY() - 75*dt)
				--particle.body:applyForce(0, 70*dt)
				--particle.body:setX(particle.body:getX() + math.random(-80*dt, 80*dt))
				particle.dx, particle.dy = particle.body:getLinearVelocity()
				particle.body:setLinearVelocity(math.random(-5000*dt, 5000*dt), math.random(-5000*dt, 5000*dt))
			end
			
			if is_flying then
				self.particle  = {
					x = carrier_x,
					y = carrier_y,
					d = math.random(2.85, 3),	-- d for dimensions.

					spawn_time = love.timer.getTime(),
					--lifetime   = math.random(0.25, 0.35)
					lifetime   = math.random(0.2, 0.3)
				}

				if carrier_xvel > 0 then
					self.particle.body    = love.physics.newBody(world, self.particle.x + 0, self.particle.y + 1, "dynamic")
				else
					self.particle.body    = love.physics.newBody(world, self.particle.x + 4, self.particle.y + 1, "dynamic")
				end
				self.particle.shape   = love.physics.newRectangleShape(self.particle.d, self.particle.d)
				self.particle.fixture = love.physics.newFixture(self.particle.body, self.particle.shape)

				self.particle.body:setMass(0)
				self.particle.body:setGravityScale(0)

				table.insert(self.particles, self.particle)
			end
			
			local particle_index = 1
			for _, particle in pairs(self.particles) do
				if love.timer.getTime() - particle.spawn_time > particle.lifetime then
					table.remove(self.particles, particle_index)	
					particle.body:destroy()
				end
				particle_index = particle_index + 1
			end
		end

		function jetpack:draw()
			love.graphics.print(self.type, 10, 90)
			for _, particle in pairs(self.particles) do
				if self.type == "normal" then
					love.graphics.setColor(1, math.random(0.522, 0.95), math.random(0, 0.1))
				elseif self.type == "magic" then
					love.graphics.setColor(1, math.random(0.522, 0.775), math.random(0.95, 1))
				elseif self.type == "merged" then
					love.graphics.setColor(1, math.random(0.522, 0.775), math.random(0, 0.49))
				end

				--love.graphics.rectangle("fill", particle.x, particle.y, particle.d, particle.d)
				love.graphics.polygon("fill", particle.body:getWorldPoints(particle.shape:getPoints()))
			end
		end

		return jetpack
	end
}


