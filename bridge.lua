-- Locals
local sprite_size = 8

return {
	new = function(world, x, y)
		bridge = {
			body    = love.physics.newBody(world, x, y, "static"),
			shape   = love.physics.newRectangleShape(sprite_size, sprite_size)
		}

		bridge.fixture = love.physics.newFixture(bridge.body, bridge.shape)
		bridge.fixture:setUserData("bridge")

		function bridge:draw_debug(tx, ty, scale)
			love.graphics.push()
			love.graphics.scale(scale)
			love.graphics.translate(tx, ty)
			love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
			love.graphics.pop()
		end

		return bridge
	end
}

