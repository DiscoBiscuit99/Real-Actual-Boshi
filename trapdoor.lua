-- Locals
local sprite_size = 8

return {
	new = function(world, x, y)
		trapdoor = {
			body    = love.physics.newBody(world, x, y, "static"),
			shape   = love.physics.newRectangleShape(sprite_size, sprite_size)
		}

		trapdoor.fixture = love.physics.newFixture(trapdoor.body, trapdoor.shape)
		trapdoor.fixture:setUserData("trapdoor")

		function trapdoor:draw_debug(tx, ty, scale)
			love.graphics.push()
			love.graphics.scale(scale)
			love.graphics.translate(tx, ty)
			love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
			love.graphics.pop()
		end

		return trapdoor
	end
}

