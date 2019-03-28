local Jetpack = require("jetpack")

-- Locals
local sprite_size = 8

return {
	new = function(world, x, y)
		local player = {}

		function player:load()
			self.body	 = love.physics.newBody(world, x, y, "dynamic")
			self.shape   = love.physics.newRectangleShape(sprite_size, sprite_size)
			--self.shape   = love.physics.newCircleShape(sprite_size/2)
			self.fixture = love.physics.newFixture(player.body, player.shape)

			self.body:setMass(5)
			self.body:setLinearDamping(0.75)

			self.fixture:setUserData("player")
			self.fixture:setFriction(1)
			--player.fixture:setRestitution(0.5)

			self.jumpcounter = 0
			self.can_jump	 = false

			self.jetpack	 = Jetpack.new(self.body:getX(), self.body:getY())
			self.jetcap      = -250
			self.has_jetpack = false
			self.is_flying   = false

			self.jetpack:load()
		end

		function player:update(dt, input)
			self.dx, self.dy = self.body:getLinearVelocity()
			if input:down("right") then
				self.body:setLinearVelocity( 65, self.dy)
			elseif input:down("left") then
				self.body:setLinearVelocity(-65, self.dy)
			end

			if input:pressed("up") then
				if self.can_jump then
					self.body:applyLinearImpulse(0, -1000)
					--self.body:applyLinearImpulse(0, -10)

					self.jumpcounter = self.jumpcounter + 1
					if self.jumpcounter >= 2 then
						self.can_jump = false
						self.jumpcounter = 0
					end
				end
			end

			if input:pressed("toggle jetpack") then
				self.has_jetpack = not self.has_jetpack
			end

			if input:down("fly") and self.has_jetpack then
				self.can_jump  = false
				self.is_flying = true

				if self.dy > self.jetcap then
					self.body:applyForce(0, -5000)
				end
			else
				self.is_flying = false
			end

			self.jetpack:update(dt, player.body:getX() - 2, player.body:getY() + 3, self.is_flying)

			--self.body:setFixedRotation(true)
		end

		function player:draw_debug(tx, ty, scale)
			love.graphics.push()
			love.graphics.scale(scale)
			love.graphics.translate(tx, ty)
			love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
			--love.graphics.circle("line", self.body:getX(), self.body:getY(), self.shape:getRadius())
			love.graphics.pop()
		end

		return player
	end
}

