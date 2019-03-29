local Jetpack = require("jetpack")

-- Locals
local sprite_size = 8

return {
	new = function(world, x, y)
		local player = {}

		function player:load()
			self.body	 = love.physics.newBody(world, x, y, "dynamic")
			self.shape   = love.physics.newRectangleShape(sprite_size, sprite_size)
			self.fixture = love.physics.newFixture(player.body, player.shape)

			self.body:setMass(5)
			self.body:setLinearDamping(0.75)

			self.fixture:setUserData("player")
			self.fixture:setFriction(1)

			self.jumpcounter = 0
			self.can_jump	 = false

			self.jetpack	 = Jetpack.new(world, self.body:getX(), self.body:getY())
			self.jetcap      = -200
			self.has_jetpack = false
			self.is_flying   = false

			self.jetpack:load()
		end

		function player:update(dt, input)
			self.dx, self.dy = self.body:getLinearVelocity()
			--if input:sequence("right", 0.5, "right") and not self.is_flying then
				--self.body:applyLinearImpulse( 50*dt, 0)
			--elseif input:sequence("left", 0.5, "left") and not self.is_flying then
				--self.body:applyLinearImpulse(-50*dt, 0)
			if input:down("right") then
				if self.is_flying then
					self.body:applyForce( 2000, 0)
					if self.dx > -self.jetcap then
						self.body:setLinearVelocity(-self.jetcap, self.dy)
					end
				else
					self.body:setLinearVelocity( 65, self.dy)
				end
			elseif input:down("left") then
				if self.is_flying then
					self.body:applyForce(-2000, 0)
					if self.dx < self.jetcap then
						self.body:setLinearVelocity( self.jetcap, self.dy)
					end
				else
					self.body:setLinearVelocity(-65, self.dy)
				end
			end

			if input:pressed("up") then
				if self.can_jump and not self.is_flying then
					self.body:applyLinearImpulse(0, -1000)
					--self.body:applyLinearImpulse(0, -10)

					self.jumpcounter = self.jumpcounter + 1
					if self.jumpcounter >= 2 then
						self.can_jump = false
						self.jumpcounter = 0
					end
				end
			end

			if input:down("fly") and self.has_jetpack then
				self.can_jump  = false
				self.is_flying = true

				self.fixture:setRestitution(0.3)

				if self.dy > self.jetcap then
					self.body:applyForce(0, -5000)
				end
			else
				self.is_flying = false
				self.fixture:setRestitution(0)
			end

			if input:pressed("toggle jetpack") then
				self.has_jetpack = not self.has_jetpack
			end

			self.jetpack:update(dt, player.body:getX() - 2, player.body:getY() + 3, self.is_flying, self.dx)
		end

		function player:draw_debug(tx, ty, scale)
			love.graphics.push()
			love.graphics.scale(scale)
			love.graphics.translate(tx, ty)
			love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
			love.graphics.pop()
		end

		return player
	end
}

